import icalendar
import requests
import datetime
import dateutil.rrule as rrule
import re

from urllib.parse import urlparse
from pyramid.settings import aslist
from tzlocal import get_localzone

def str_to_freq(v):
    return {
        "YEARLY": rrule.YEARLY,
        "MONTHLY": rrule.MONTHLY,
        "WEEKLY": rrule.WEEKLY,
        "DAILY": rrule.DAILY,
        "HOURLY": rrule.HOURLY,
        "MINUTELY": rrule.MINUTELY,
        "SECONDLY": rrule.SECONDLY,
    }[v.upper()]

def str_to_weekday(v):
    return {
        'MO': rrule.MO,
        'TU': rrule.TU,
        'WE': rrule.WE,
        'TH': rrule.TH,
        'FR': rrule.FR,
        'SA': rrule.SA,
        'SU': rrule.SU,
    }[v.upper()]

def make_naive(date):
    if type(date) is datetime.date:
        return date
    if date.tzinfo is None:
        return date
    return date.astimezone(get_localzone()).replace(tzinfo=None)

def add_midnight_to_date(date):
    if type(date) is datetime.datetime:
        return date
    return datetime.datetime.combine(date, datetime.datetime.min.time())

def expand_recurring(obj):
    """
    Takes a VEVENT object from iCalendar and returns a list:

    >>> [(start_date, end_date, vevent_object), ...]
    """
    ## Exit early if event is not recurring
    if not obj.get('RRULE'):
        yield make_naive(obj.decoded('dtstart')), make_naive(obj.decoded('dtend')), obj
        return

    params = {}
    freq = None

    ## Translate iCalendar's output format to rrule's input format
    for k, v in dict(obj.get('RRULE')).items():
        if k.upper() in ['COUNT', 'INTERVAL']:
            v = v[0]
        elif k.upper() == 'UNTIL':
                v = make_naive(v[0])
        elif k.upper() in ['BYDAY', 'BYWEEKDAY']:
            k = 'BYWEEKDAY'
            v = str_to_weekday(str(v[0]))
        elif k.upper() == 'FREQ':
            freq = str_to_freq(str(v[0]))
            continue # don't add this to params
        elif k.upper() == 'WKST':
            v = str_to_weekday(str(v[0]))
        elif k.upper() in ['BYMONTH', 'BYMONTHDAY', 'BYYEARDAY', 'BYWEEKNO',
                'BYHOUR', 'BYMINUTE', 'BYSECOND', 'BYEASTER', 'BYSETPOS']:
            v = int(v[0])
        else:
            v = str(v[0])

        params[k.lower()] = v

    ## Strip timezone info if type is datetime, because rrule doesn't like them
    params['dtstart'] = make_naive(obj.decoded('dtstart'))

    ## Add UNTIL rule if there's none
    if not 'until' in params.keys():
        params['until'] = datetime.date.today() + datetime.timedelta(days=365)

    ## Needed for calculation of actual event end
    duration = obj.decoded('dtend') - obj.decoded('dtstart')

    for start_date in rrule.rrule(freq, **params):
        yield (start_date, start_date + duration, obj)

def is_in_near_future(start, end, event, now):
    today = now.date()
    tomorrow = (now + datetime.timedelta(days=1)).date()

    if type(start) is datetime.datetime:
        start = start.date()
    if type(end) is datetime.datetime:
        end = end.date()

    return start <= today <= end or start <= tomorrow <= end

class Calendar:

    def __init__(self, settings):
        self.urls = aslist(settings['calendar.ics.urls'])

    def schedule(self):
        events = []
        for url in self.urls:
            events.extend(list(self.schedule_url(url.strip())))
        return sorted(events, key=lambda e: add_midnight_to_date(e[0]))

    def schedule_url(self, url):
        r = requests.get(url)
        r.raise_for_status()

        ## Fix iCloud invalid TZOFFSETFROM
        ## see https://github.com/pimutils/khal/issues/140
        def check_tzoffset(matches):
            contents = matches.group(2)
            if abs(int(contents)) >= 2400:
                return ""
            return matches.group(1)

        url_parsed = urlparse(url)
        if 'calendars.icloud.com' in url_parsed.netloc.lower():
            ical = re.sub(r'(TZOFFSETFROM:(\+[\d]{4}))', check_tzoffset, r.text, re.MULTILINE)
        else:
            ical = r.text

        now = datetime.datetime.now(datetime.timezone.utc).astimezone()

        for obj in icalendar.Calendar.from_ical(ical).walk():
            if obj.name == 'VEVENT':
                for start, end, event in expand_recurring(obj):
                    if is_in_near_future(start, end, event, now):
                        yield start, end, event

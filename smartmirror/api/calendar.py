import icalendar
import requests
import datetime
import dateutil.rrule as rrule

from pyramid.settings import aslist

def str_to_freq(v):
    return {
        "YEARLY": rrule.YEARLY,
        "MONTHLY": rrule.MONTHLY,
        "WEEKLY": rrule.WEEKLY,
        "DAIlY": rrule.DAILY,
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

def expand_recurring(obj):
    params = {}
    freq = None

    ## Translate iCalendar's output format to rrule's input format
    for k, v in dict(obj.get('RRULE')).items():
        if k.upper() in ['COUNT', 'INTERVAL']:
            v = v[0]
        elif k.upper() == 'UNTIL':
            if type(v[0]) is datetime.datetime and v[0].tzinfo is not None:
                v = v[0].replace(tzinfo=None)
            else:
                v = v[0]
        elif k.upper() in ['BYDAY', 'BYWEEKDAY']:
            k = 'BYWEEKDAY'
            v = str_to_weekday(str(v[0]))
        elif k.upper() == 'FREQ':
            freq = str_to_freq(str(v[0]))
            continue
        elif k.upper() == 'WKST':
            v = str_to_weekday(str(v[0]))
        elif k.upper() in ['BYMONTH', 'BYMONTHDAY', 'BYYEARDAY', 'BYWEEKNO',
                'BYHOUR', 'BYMINUTE', 'BYSECOND', 'BYEASTER', 'BYSETPOS']:
            v = int(v[0])
        else:
            v = str(v[0])

        params[k.lower()] = v

    ## Strip timezone info if type is datetime, because rrule doesn't like them
    if type(obj.decoded('dtstart')) is datetime.datetime:
        params['dtstart'] = obj.decoded('dtstart').replace(tzinfo=None)
    else:
        params['dtstart'] = obj.decoded('dtstart')

    ## Add UNTIL rule if there's none
    if not 'until' in params.keys():
        params['until'] = datetime.date.today() + datetime.timedelta(days=365)

    return list(rrule.rrule(freq, **params))

def is_today(obj, now):
    ## If event is recurring, calc the actual dates
    if obj.get('RRULE'):
        dates = expand_recurring(obj)
        for date in dates:
            if type(date) is datetime.datetime:
                date = date.date()
            if date == now.date():
                return True
        return False
    else:
        start = obj.decoded('dtstart')
        end = obj.decoded('dtend')

        if type(start) is datetime.datetime:
            return start.date() <= now.date() <= end.date()
        else:
            return start <= now.date() <= end

class Calendar:

    def __init__(self, settings):
        self.urls = aslist(settings['calendar.ics.urls'])

    def schedule(self):
        events = []
        for url in self.urls:
            events.extend(list(self.schedule_url(url.strip())))
        return sorted(events, key=lambda e: e.decoded('dtstart'))

    def schedule_url(self, url):
        r = requests.get(url)
        r.raise_for_status()
        now = datetime.datetime.now(datetime.timezone.utc).astimezone()

        for obj in icalendar.Calendar.from_ical(r.text).walk():
            if obj.name == 'VEVENT':
                if is_today(obj, now):
                    yield obj

<%def name="render_timing(calendar, toggl)">
	<%! from datetime import datetime %>
	<%! from tzlocal import get_localzone %>

	<div class="time">${datetime.now().strftime('%H:%M')}</div>
	<div class="day">${datetime.now().strftime('%A')}, KW${datetime.now().strftime('%W')}</div>
	<div class="date">${datetime.now().strftime('%-d. %B %Y')}</div>

	<div class="events">
		% for event in calendar:
		<div class="event">
			% if type(event.decoded('dtstart')) is datetime:
				<span>${event.decoded('dtstart').astimezone(get_localzone()).strftime('%H:%M')} &ndash;</span>
			% endif

			${event.get('summary')}
		</div>
		% endfor
	</div>

	% if toggl:
	<div class="toggl">
		<img class="img-middle" src="${request.static_url('smartmirror:static/img/toggl.png')}" height="24">
		${toggl['description']}
	</div>
	% endif
</%def>

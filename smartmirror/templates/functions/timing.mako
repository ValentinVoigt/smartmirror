<%! from datetime import datetime, timedelta %>

<%def name="relative_time(date)">
	<% today = datetime.now().date() %>
	<% tomorrow = (datetime.now() + timedelta(days=1)).date() %>

	% if type(date) is datetime:
		% if date.date() == tomorrow:
			${date.strftime('morgen, %H:%M')}
		% elif date.date() == today:
			${date.strftime('%H:%M')}
		% else:
			${date.strftime('%d.%m., %H:%M')}
		% endif
	% else:
		% if date == tomorrow:
			morgen
		% elif date == today:
			heute
		% else:
			${date.strftime('%d.%m.')}
		% endif
	% endif
</%def>

<%def name="render_timing(calendar, toggl)">
	<div class="time">${datetime.now().strftime('%H:%M')}</div>
	<div class="day">${datetime.now().strftime('%A')}, KW${datetime.now().strftime('%W')}</div>
	<div class="date">${datetime.now().strftime('%-d. %B %Y')}</div>

	% if len(calendar) > 0:
	<div class="events">
		<% count = 0 %>
		% for start, end, event in calendar:
			% if count == 10:
				<div class="event ellipsis">...</div>
				<% break %>
			% endif

			<% count += 1 %>
			<div class="event">
				<span>${relative_time(start)} &ndash;</span>

				${event.get('summary')}
			</div>
		% endfor
	</div>
	% endif


	% if toggl:
	<div class="toggl">
		<img class="img-middle" src="${request.static_url('smartmirror:static/img/toggl.png')}" height="24">
		${toggl.get('description', '')}
	</div>
	% endif
</%def>

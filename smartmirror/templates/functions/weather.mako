<%!
from datetime import datetime

def deg_to_compass(deg):
	a = (round(deg - 22.5) % 360) // 45
	return ['NO', 'O', 'SO', 'S', 'SW', 'W', 'NW', 'N'][a]

%>

<%def name="render_weather(weather)">
	% if weather is not None:
		<div class="row" style="justify-content: flex-end;">
			<div class="spacing temperature">${round(weather['main']['temp'])}°C</div>
			<div class="spacing icon">
				<img src="${request.static_url('smartmirror:static/img/%s.svg' % weather['weather'][0]['icon'])}" width="64">
			</div>
		</div>
		<div class="spacing text">${weather['weather'][0]['description']}</div>
		<table class="forecast spacing">
		% for idx, entry in zip(range(8), forecast['list']):
			<% time = datetime.fromtimestamp(int(entry['dt'])) %>
			<% if time <= datetime.now(): continue %>
			<tr>
				<td>${time.strftime('%H')}<sup>${time.strftime('%M')}</sup></td>
				<td><img class="img-middle" src="${request.static_url('smartmirror:static/img/%s.svg' % entry['weather'][0]['icon'])}" height="24"></td>
				<td>${round(entry['main']['temp'])}°C</td>
				<td><img class="img-middle" src="${request.static_url('smartmirror:static/img/meteocons/6_ed.svg')}" height="24"></td>
				<td>${round(entry['wind']['speed'])}<sup>km</sup>&frasl;<sub>h</sub></td>
				<td>${deg_to_compass(float(entry['wind']['deg']))}</td>
			</tr>
		% endfor
		</table>
	% endif
</%def>

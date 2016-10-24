<%!
from pprint import pformat
from datetime import datetime
from tzlocal import get_localzone

def deg_to_compass(deg):
	a = round((deg - 22.5) % 360) // 45
	return ['NO', 'O', 'SO', 'S', 'SW', 'W', 'NW', 'N'][a]

%>
<!doctype html>
<html lang="de">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Smartmirror</title>
		<style type="text/css">
		html, body {
			margin: 0;
			padding: 0;
		}
		body {
			background:#000;
			color:#fff;
			font-family:Century Gothic,sans-serif;
			letter-spacing: 1px;
		}

		.row {
			display:flex;
			flex-direction:row;
		}
		.column {
			display:flex;
			flex-direction:column;
		}
		.img-middle {
			vertical-align: middle;
		}

		.weather {
			position: absolute;
			top: 15px;
			right:15px;
		}
		.weather .spacing {
			margin:8px;
		}
		.weather .temperature {
			font-size:64px;
		}
		.weather .icon {
			padding-top:10px;
		}
		.weather .city {
			font-size:32px;
		}
		.weather .text {
			font-size:24px;
			align-self: flex-end;
		}
		.weather table.forecast {
			align-self: flex-end;
		}
		.weather table.forecast td {
			padding: 0 8px;
			text-align:right;
		}

		.timing {
			position:absolute;
			top:15px;
			left:15px;
		}
		.timing .time {
			font-size:80px;
			font-weight:500;
		}
		.timing .day {
			font-size:32px;
			font-weight:lighter;
		}
		.timing .date {
			font-size:32px;
			font-weight:lighter;
		}
		.timing .events {
			font-size:24px;
			margin-top:20px;
			padding-top:20px;
			border-top:2px solid #888;
		}
		.timing .event {
			font-size:24px;
		}
		.timing .event span {
			color:#888;
		}
		.timing .toggl {
			margin-top:20px;
			padding-top:20px;
			border-top:2px solid #888;
			font-size:20px;
		}

		.news {
			position:absolute;
			bottom:15px;
			left:0;
			padding:15px;
			width:90%;
			justify-content:center;
			align-items:center;
		}
		.news .source {
			font-size:16px;
		}
		.news .entry {
			font-size:24px;
		}
		
		#curtain {
			position:absolute;
			top:0;
			bottom:0;
			left:0;
			right:0;
			display:none;
			background-color:black;
			z-index:999;
		}
		</style>
	</head>
	<body>
		<div class="timing column">
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
		</div>

		<div class="weather column">
			<div class="row" style="justify-content: flex-end;">
				<div class="spacing temperature">${round(weather['main']['temp'])}°C</div>
				<div class="spacing icon">
					<img src="${request.static_url('smartmirror:static/img/%s.svg' % weather['weather'][0]['icon'])}" width="64">
				</div>
			</div>
			<div class="spacing text">${weather['weather'][0]['description']}</div>
			<table class="forecast spacing">
			% for idx, entry in zip(range(8), forecast['list'][1:]):
				<% time = datetime.fromtimestamp(int(entry['dt'])) %>
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
		</div>

		<div class="news column">
			<div class="source">${news.feed.title}</div>
			% for idx, entry in zip(range(10), news.entries):
			<div class="entry" style="${'display:none' if idx!=0 else ''}" data-id="${idx}">${entry.title}</div>
			% endfor
		</div>

		<div id="curtain"></div>

		<script type="text/javascript" src="${request.static_url('smartmirror:static/js/jquery-3.1.1.min.js')}"></script>
		<script type="text/javascript" src="${request.static_url('smartmirror:static/js/jquery-ui.min.js')}"></script>
		<script type="text/javascript">
		var current_news = 0;
		var num_news = $('.news .entry').length;

		function switch_to_next_news() {
			var last_news = current_news;
			if (++current_news > num_news-1) {
				current_news = 0;
			}
			$('.news .entry[data-id='+last_news+']').toggle('slide', {'direction': 'up'}, function() {
				$('.news .entry[data-id='+current_news+']').toggle('slide', {'direction': 'down'}, function() {
					setTimeout(switch_to_next_news, 3000);
				});
			});
		}

		function show_time() {
			var now = new Date(); 
			$('.timing .time').html(now.getHours() + ":" + now.getMinutes());
			setTimeout(show_time, 1000);
		}

		if (num_news > 0) {
			setTimeout(switch_to_next_news, 3000);
		}
		show_time();

		$("html").keydown(function(event) {
			if (event.key == ' ') {
				$('#curtain').fadeToggle();
			}
		});
		</script>
	</body>
</html>

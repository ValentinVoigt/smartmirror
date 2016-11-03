<%inherit file="base.mako"/>
<%namespace file="functions/timing.mako" import="render_timing"/>


<div id="timing" class="column" data-ajax-url="${request.route_path('ajax-timing')}">
	## Render timing on page load to speed up display
	${render_timing([], None)}
</div>

<div id="weather" class="column" data-ajax-url="${request.route_path('ajax-weather')}"></div>
<div id="news" class="column" data-ajax-url="${request.route_path('ajax-news')}"></div>

<div class="main">Main 1</div>
<div class="main">Main 2</div>
<div class="main">Main 3</div>

<%inherit file="base.mako"/>

<div id="timing" class="column" data-ajax-url="${request.route_path('ajax-timing')}"></div>
<div id="weather" class="column" data-ajax-url="${request.route_path('ajax-weather')}"></div>
<div id="news" class="column" data-ajax-url="${request.route_path('ajax-news')}"></div>

<div class="main">Main 1</div>
<div class="main">Main 2</div>
<div class="main">Main 3</div>

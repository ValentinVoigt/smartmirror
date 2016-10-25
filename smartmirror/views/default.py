from pyramid.view import view_config

from smartmirror.api import Weather, RSS, Calendar, Toggl

@view_config(route_name='ajax-news', renderer='ajax/news.mako')
def news(request):
    rss = RSS(request.registry.settings)
    return {'news': rss.news()}

@view_config(route_name='ajax-weather', renderer='ajax/weather.mako')
def weather(request):
    weather = Weather(request.registry.settings)
    return {'weather': weather.weather(), 'forecast': weather.forecast()}

@view_config(route_name='ajax-timing', renderer='ajax/timing.mako')
def timing(request):
    calendar = Calendar(request.registry.settings)
    toggl = Toggl(request.registry.settings)
    return {'calendar': calendar.schedule(), 'toggl': toggl.current_time_entry()}

@view_config(route_name='home', renderer='home.mako')
def home(request):
    return {}

from pyramid.view import view_config

from smartmirror.api import Weather, RSS, Calendar, Toggl

@view_config(route_name='home', renderer='home.mako')
def home(request):
    weather = Weather(request.registry.settings)
    rss = RSS(request.registry.settings)
    calendar = Calendar(request.registry.settings)
    toggl = Toggl(request.registry.settings)

    return {
        'weather': weather.weather(),
        'forecast': weather.forecast(),
        'news': rss.news(),
        'calendar': calendar.schedule(),
        'toggl': toggl.current_time_entry(),
    }

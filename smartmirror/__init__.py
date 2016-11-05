import locale

from pyramid.config import Configurator

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_mako')
    config.include('.models')
    config.include('.routes')
    config.scan()

    newlocale = settings.get('smartmirror.setlocale')
    if newlocale:
        locale.setlocale(locale.LC_ALL, newlocale)

    return config.make_wsgi_app()

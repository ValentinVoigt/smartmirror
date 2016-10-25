import feedparser
from pyramid.settings import aslist

class RSS:

    def __init__(self, settings):
        self.urls = aslist(settings['rss.urls'])

    def news(self):
        for url in self.urls:
            yield feedparser.parse(url)

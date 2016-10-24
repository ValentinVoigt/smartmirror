import feedparser

class RSS:

    def __init__(self, settings):
        self.url = settings['rss.url']

    def news(self):
        return feedparser.parse(self.url)

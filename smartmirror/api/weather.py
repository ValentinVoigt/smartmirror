import requests

API_CALL_WEATHER = 'http://api.openweathermap.org/data/2.5/weather'
API_CALL_FORECAST = 'http://api.openweathermap.org/data/2.5/forecast'

class Weather:

    def __init__(self, settings):
        self.apikey = settings['openweathermap.apikey']
        self.cityid = settings['openweathermap.cityid']

    def _api_call(self, url):
        if any([len(i.strip()) == 0 for i in (self.apikey, self.cityid,)]):
            return None

        r = requests.get(url, params={
            'APPID': self.apikey,
            'units': 'metric',
            'lang': 'de',
            'id': self.cityid,
        })
        r.raise_for_status()
        return r.json()

    def weather(self):
        return self._api_call(API_CALL_WEATHER)

    def forecast(self):
        return self._api_call(API_CALL_FORECAST)

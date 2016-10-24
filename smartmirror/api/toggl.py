import requests

TOGGL_URL_CURRENT = 'https://www.toggl.com/api/v8/time_entries/current'

class Toggl:

    def __init__(self, settings):
        self.token = settings['toggl.token']

    def current_time_entry(self):
        r = requests.get(TOGGL_URL_CURRENT, auth=(self.token, 'api_token'))
        r.raise_for_status()
        return r.json()['data']

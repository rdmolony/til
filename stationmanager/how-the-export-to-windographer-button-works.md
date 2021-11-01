# How the export to windographer button works

The user double clicks on a station on the sidebar or map which generates a `station_detail.html` containing the station information:

- Django receives a request for **station/#id** where id is the station identifier which has been found by JS in `map.html` (see [rdmolony/tml](https://github.com/rdmolony/til))
- searches `urls.py` for a corresponding URL
- finds `url(r'^station/(?P<id>[\d]+)?/?$', station_detail, name="station_detail")`
- searches `views.py` for `station_detail`
- passes `#id` to `station_detail` and queries the database for the station data via `station = get_object_or_404(Station, id=id)`
- passes some local view variables such as the `station` object (from which all station data can be accessed) to `station_detail.html` and renders it via `Django` templating.

> `r'^station/(?P<id>[\d]+)?/?$'` is a regular expression and `(?P<id>[\d]+)` is a [named capture group](https://regexone.com/lesson/capturing_groups)

`station_detail.html` is created with a Windographer (windog) button `{% url 'windog' station_id=station.id %}` which passes the station id to `windog` view when clicked, and redirects the user to a URL `windog/station/#id` which automatically downloads a file of station data that is compatible with windog. 

The outputter windog file stores metadata in the first N rows followed by a standard csv of comma separated columns of column names following the windog conventions.  `StationManager` calls `export_station` from the `MRP` package to rename the columns to follow this convention and to find its timezone, it then uses the inbuilt `csv` Python package to write the metadata rows and `pandas` to append the columnar table to this.
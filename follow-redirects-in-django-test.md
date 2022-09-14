I'm generating text files for use in `Windographer` in an external task.  I want to serve these files via `Django`, ideally via `Azure` using `django-storages`.

I can save files to a model via `FileField`.  I can redirect the user to the `FileField` object attribute `url` to serve files!

```python
from django.http import HttpResponseBadRequest

from stationmanager import models


def get_flagged_windog_file(request, station_id) -> str:
    station = get_object_or_404(models.Station, pk=station_id)
    _data = models.WindogData.objects.get(station=station, is_flagged=True)
    if not _data:
        response = HttpResponseBadRequest(
            f"A Windog file for {station} does not exist, please contact the maintainers!"
        )
    else:
        url = _data.file.url
        response = redirect(url)
    return response
```

I can test this by using the `Django` test client to follow redirects!

```python
from django.shortcuts import redirect
import pytest

from stationmanager import tasks


@pytest.mark.usefixtures("ch008_01_factory") # saves a sample Station to the database
@pytest.mark.django_db
def test_get_windog_file_exports_data(admin_client: Client) -> None:
    station = models.Station.objects.get(name="ch008_01")
    tasks.export_station_timeseries_to_windog(station=station, is_flagged=True)
    
    url = reverse("get_flagged_windog_file", kwargs={"station_id": station.id})
    response = admin_client.get(url, follow=True)
    
    content = response.content.decode("utf-8")
    assert ...
```

> https://testdriven.io/blog/storing-django-static-and-media-files-on-amazon-s3/

#django

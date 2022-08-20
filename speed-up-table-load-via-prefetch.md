I have a table defined in `Django`.  It's takes ~1m to load due to ~2000 queries being required.  Each row represents a measurement station, and each station links to numerous sensors via a `ManyToManyColumn`.  By default, `django-tables2` a separate query for every station to evaluate the sensors.  Each sensor links to a node representing a discrete height on the measurement station.  `django-tables2` again makes a separate query for every node for every sensor!

We can speed this up using `prefetch_related` & `select_related`

Initially the view looks like ...

```python
def _colour_sensor_on_quality(quality: int) -> str:

    if quality < 50:

        colour = "red"

    elif quality < 75:

        colour = "orange"

    else:

        colour = "green"

    return colour

  
  

class StationTable(tables.Table):

    class Meta:

        model = Station

        template_name = "django_tables2/bootstrap.html"

        fields = ("name", "sensorquality_set")

  

    sensorquality_set = tables.ManyToManyColumn(

        verbose_name="Sensors",

        transform=(

            lambda s: format_html(

                '<span'

                + (

                    f' style="color: {_colour_sensor_on_quality(s.last_week)}"'

                    if s.last_week is not None

                    else ''

                )

                + ' data-toggle="tooltip"'

                + ' data-placement="top"'

                + ' data-html="true"'

                + ' title="'

                + f'Overall: {s.overall}\n'

                + f'Last month: {s.last_month}\n'

                + f'Last week: {s.last_week}\n'

                + f'Most recent timestamp: {s.most_recent_timestamp}\n'

                + f'Quality check last run: {s.last_modified}'

                + '"'

                +'>'

                + str(s.node)

                + '</span>'

            )

        ),

    )



class StationListView(LoginRequiredMixin, SingleTableMixin):

    model = models.Station

    table_class = tables.StationTable

    template_name = 'stationmanager/station_list.html'
```

Overriding the table queryset to use `fetch_related` on `node_set` & `sensor_quality_set` reduces page loadiing to ~2000 queries in 2.9s ...

```python
class StationListView(LoginRequiredMixin, SingleTableMixin, FilterView):

    model = models.Station

    table_class = tables.StationTable

    template_name = 'stationmanager/station_list.html'

    def get_queryset(self):

        qs = super().get_queryset()

        qs = qs.prefetch_related("sensorquality_set", "node_set")

        return qs
```

... which generates SQL queries like ...

```sql
**  
SELECT** `stationmanager_sensorquality`.`id`,  
	   `stationmanager_sensorquality`.`station_id`,  
	   `stationmanager_sensorquality`.`sensor`,  
	   `stationmanager_sensorquality`.`node_id`,  
	   `stationmanager_sensorquality`.`overall`,  
	   `stationmanager_sensorquality`.`last_month`,  
	   `stationmanager_sensorquality`.`last_week`,  
	   `stationmanager_sensorquality`.`most_recent_timestamp`,  
	   `stationmanager_sensorquality`.`last_modified`  **FROM** `stationmanager_sensorquality` **WHERE** `stationmanager_sensorquality`.`station_id` IN (1470, 230, 592, 610, 611, 612, 553, 1425, 2098, 2102, 2103, 2190, 474, 475, 109, 110, 1480, 17, 129, 130, 131, 237, 507, 542, 1436)
```

Overriding the queryset to use `fetch_related` for `sensorquality_set`  and a `select_related` on `node_set`  relative to `sensor_quality_set` is even faster; 5 queries in 1s! 

`select_related` joins the `sensorquality` table with the related foreign key `nodes` before prefetching via ... 

```python
class StationListView(LoginRequiredMixin, SingleTableMixin, FilterView):

    model = models.Station

    table_class = tables.StationTable

    template_name = 'stationmanager/station_list.html'

    def get_queryset(self):

        qs = super().get_queryset()

        # NOTE: Join nodes & sensorquality into a single table via select_related

        # ... then prefetch the sensorquality related to the stations in the current

        # ... table view

        # ... Otherwise tables2 makes separate queries for sensorqualities & then nodes

        # ... so would run ~100x slower

        # https://stackoverflow.com/questions/54569384/django-chaining-prefetch-related-and-select-related

        sensorquality_set = Prefetch(

            "sensorquality_set",

            queryset=models.SensorQuality.objects.select_related("node")

        )

        qs = qs.prefetch_related(sensorquality_set)

        return qs
```

... which generates ...

```sql
**SELECT** `stationmanager_sensorquality`.`id`,  
	   `stationmanager_sensorquality`.`station_id`,  
	   `stationmanager_sensorquality`.`sensor`,  
	   `stationmanager_sensorquality`.`node_id`,  
	   `stationmanager_sensorquality`.`overall`,  
	   `stationmanager_sensorquality`.`last_month`,  
	   `stationmanager_sensorquality`.`last_week`,  
	   `stationmanager_sensorquality`.`most_recent_timestamp`,  
	   `stationmanager_sensorquality`.`last_modified`,  
	   `node`.`id`,  
	   `node`.`idStation`,  
	   `node`.`idDataType`,  
	   `node`.`Height`,  
	   `node`.`Magnetic_Orientation`,  
	   `node`.`Boom_Length`,  
	   `node`.`Inclination_Angle`,  
	   `node`.`is_IEC_Compliant`,  
	   `node`.`Raw_DB_Field`,  
	   `node`.`Raw_DB_Field_Std`,  
	   `node`.`Raw_DB_Field_Max`,  
	   `node`.`Raw_DB_Field_Min`,  
	   `node`.`raw_db_field_gust_max`  **FROM** `stationmanager_sensorquality` **INNER JOIN** `node`    **ON** (`stationmanager_sensorquality`.`node_id` = `node`.`id`) **WHERE** `stationmanager_sensorquality`.`station_id` IN (1470, 230, 592, 610, 611, 612, 553, 1425, 2098, 2102, 2103, 2190, 474, 475, 109, 110, 1480, 17, 129, 130, 131, 237, 507, 542, 1436)
```


> Inspired by ...
> **Django for Professionals** by Will Vincent
> & https://stackoverflow.com/questions/54569384/django-chaining-prefetch-related-and-select-related

#django 
#python 
#django-tables2 
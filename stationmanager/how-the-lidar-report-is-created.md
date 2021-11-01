# How the lidar report table is created

The `Django` view `lidar_report` renders `lidar_report.html` once a user navigates to the LIDAR report page.

This view queries the database for stations ...

```python
stations = Station.objects.filter(
    idowner__name='MRP',
    idstationtype__name='LIDAR',
    idstationstatus__name__in=['Operational','Undergoing Maintenance','Storage']
)
```

... and passes this 'stations' object to `lidar_report.html` which can use it to access station data and display it in a table.

`StationManager` uses `Django` templating to regroup the stations by their `idstationstatus` (Operational, Storage, Undergoing Maintenance), to flag stations that have exceeded their decommissioning date and finally to color the text of maintenance services that are upcoming or overdue:

```html
{% regroup stations by idstationstatus as stationtype_list %}
   <tbody>
      {% for stationstatus in stationtype_list %}
      ...
      {% for s in stationstatus.list %}
      <tr class= "grouper">
         <td>
            <strong>{{ stationstatus.grouper }}</strong>
         </td>
      </tr>
      {% for s in stationstatus.list %}
      ...
      {% if s.decom_exceeded == True %}
      <tr class="problem">
      {% else %}
      <tr>
      {% endif %}
        <td><a href="{% url 'admin:stationmanager_station_change' s.id %}"><span class="glyphicon glyphicon-edit"></span></a>
          <a href="{% url 'station_detail' id=s.id %}">{{s.name}}</a>
        </td>
        ...
        <td>{{s.idmaWnufacturer.name}}</td>
        ...
        {% if s.next_maintenance_delta_days >= 365 %}
        <td class="overdue">
        {% elif s.next_maintenance_delta_days > 0 and s.next_maintenance_delta_days < 365 %}
        <td class="due">
        {% elif s.next_maintenance_delta_days <= 0 %}
        <td>
        {% else %}
        <td>
        {% endif %}
           {% if s.next_maintenance_date %}
           {{ s.next_maintenance_date }}
           {%else%}
           <a href="{% url 'admin:stationmanager_station_change' s.id %}">[add date]</a>
           {% endif %}
        </td>
        ...
      </tr>
      {% endfor %}
    </tbody>
...
{% endblock %}
```

`{% regroup stations by idstationstatus as stationtype_list %}` reorders the stations into `idstationstatus` (Operational, Storage, Undergoing Maintenance) so each group can be displayed in separate tables.  

`<a href="{% url 'admin:stationmanager_station_change' s.id %}"><span class="glyphicon glyphicon-edit"></span></a>` displays an 'Edit Me' icon that links to `Django` `admin` and enables editing of station metadata.

`<a href="{% url 'station_detail' id=s.id %}">{{s.name}}</a>` generates a URL to link to the corresponding station page using the `station_detail` view

Lastly `{% if s.next_maintenance_delta_days >= 365 %}` etc color the text depending on the remaining days till maintenance via `<td class="overdue">` which links the table cell to `CSS` styling via its class "overdue". 

---

From the [`Django` docs](https://docs.djangoproject.com/en/3.2/ref/templates/builtins/):

> `Django` `regroup` regroups a list of alike objects by a common attribute

A list of dicts of cities within countries can be ordered by and displayed using `regroup` from ...

```python
cities = [
    {'name': 'Mumbai', 'population': '19,000,000', 'country': 'India'},
    {'name': 'Calcutta', 'population': '15,000,000', 'country': 'India'},
    {'name': 'New York', 'population': '20,000,000', 'country': 'USA'},
    {'name': 'Chicago', 'population': '7,000,000', 'country': 'USA'},
    {'name': 'Tokyo', 'population': '33,000,000', 'country': 'Japan'},
]
```

... to ...

```
India
- Mumbai: 19,000,000
- Calcutta: 15,000,000

USA
- New York: 20,000,000
- Chicago: 7,000,000

Japan
- Tokyo: 33,000,000
```

... by ...

```html
{% regroup cities by country as country_list %}

<ul>
{% for country in country_list %}
    <li>{{ country.grouper }}
    <ul>
        {% for city in country.list %}
          <li>{{ city.name }}: {{ city.population }}</li>
        {% endfor %}
    </ul>
    </li>
{% endfor %}
</ul>
```

> The `Django` `if` tag evaluates a variable, and if that variable is “true” the contents of the block are output

```html
{% if athlete_list %}
    Number of athletes: {{ athlete_list|length }}
{% elif athlete_in_locker_room_list %}
    Athletes should be out of the locker room soon!
{% else %}
    No athletes.
{% endif %}
```

> `Django` `cycle` produces one of its arguments each time this tag is encountered. The first argument is produced on the first encounter, the second argument on the second encounter, and so forth. Once all arguments are exhausted, the tag cycles to the first argument and produces it again, so ...

```html
{% for o in some_list %}
    <tr class="{% cycle 'row1' 'row2' %}">
        ...
    </tr>
{% endfor %}
```

... produces HTML that refers to class row1, the second to row2, the third to row1 again.
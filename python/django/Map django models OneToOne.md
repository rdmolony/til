I can create a new database table called `CoreWindData` (containing the timestamp of the most recently updated data) and map it to another table `Station` using a `OneToOneField` in `django` ...

```python
class CoreWindData(models.Model):
    station = models.OneToOneField("stationmanager.Station", on_delete=CASCADE)
	...
```

I can then access `CoreWindData` objects from `Station` via `<station>.corewinddata`

#python 
#django
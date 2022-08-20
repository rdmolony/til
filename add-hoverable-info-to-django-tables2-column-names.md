I want to reduce the size of my columns by adding a hoverable info box beside the column name to provide more information.

I can pass a string rendered by `Django` builtin `render_html` to `verbose_name`!

```python
class StationTable(tables.Table):
    class Meta:
        model = Station
        template_name = "django_tables2/bootstrap.html"
        fields = ("name",)

	...
	
    lag_days = tables.Column(
        format_html(
            'Lag [Days]<span title="Most Recent Timestamp in Database">❔</span>',
        ),
    )
```

#python 
#django 
#django-tables2
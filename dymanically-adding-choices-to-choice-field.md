I want to dynamically generate choices for fields in my `Django` form on the form's creation.  

This particular form enables users to edit the configuration of our stations; wind speed sensor settings etc.  Each station links to a separate timeseries database of sensor readings.  I want to query the timeseries database for sensor names, and display these names as options in a `ChoiceField`.  In other words, the choices are station-specific, so the form to edit sensor settings needs to know which station it is.  

I can override initialise the form instantiation to prefill the form choice fields to use the model instance ...

```python
from django.forms import ModelForm


def get_sensor_fields(form, fields):
    # get the fields from the database
    pass

def get_db_field_choices(form, fields):
    # create sensor specific choice fields
    pass

class StationForm(ModelForm):
    class Meta:
        model = Article
        fields = '__all__'
    
    raw_db_field = forms.ChoiceField(choices=(), required=False)

    def __init__(self, *args, **kwargs):
        # NOTE: I have to override raw_db_field etc with sensor names found from
        # ... the timeseries database for a specific station
        # ... on instantiating a form
        # ... 
        super().__init__(*args, **kwargs)
        form = self
        station = self.instance
        sensor_fields = get_sensor_fields(station)
        field_choices = create_db_field_choices(form, sensor_fields)
        for field, choices in field_choices.items():
            form.fields[field].choices = choices
```

> https://stackoverflow.com/questions/2237064/passing-arguments-to-a-dynamic-form-in-django

#django
#django-forms

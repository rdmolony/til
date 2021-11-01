# How the station metadata is uploaded

Upon opening the page:

- `Django` searches `urls.py` for `station_upload`
- finds `url(r'^upload/station_upload/$', IeaDataModelExcel.as_view(), name='station_upload')`
- looks for form in `IeaDataModelExcel` and finds `IeaModelFormExcel`
- looks for template in `IeaDataModelExcel` and finds `stationmanager/iea_data_model_form_excel.html`

```python
class IeaDataModelExcel(FormView):
    template_name = 'stationmanager/iea_data_model_form_excel.html'
    form_class = IeaModelFormExcel
    success_url = 'upload_success'
    form = IeaModelFormExcel()
    def form_valid(self, form):
        form.process_data()
        return super().form_valid(form)
```

- set acceptable form inputs or fields & define `process_data` which is called upon receiving a valid form input

```python
class IeaModelFormExcel(forms.Form):

    uploaded_by = forms.CharField(
        max_length=50, widget=forms.TextInput(attrs={'class': 'input-field'})
    )
    excel_file = forms.FileField(
        validators=[FileExtensionValidator(allowed_extensions=['xlsx'])]
    )

    def process_data(self):
        # load & process data from file
        ...
```

- render template, filling the `form` fields by looping through each form object via `{% for field in form %}` and calling the attributes `{{ field.label_tag }}` and `{{field.help_text|safe}}` to generate the form HTML label and input boxes.  It also raises errors on invalid form input via `{% if field.errors %}`!

```html
<form method="POST" class="post-form" enctype="multipart/form-data"> {% csrf_token %}
  <table width = 100% >
    {% for field in form %}
    <tr>
      <td>{{ field.label_tag }}</td>
      <td align="left">{{ field }}</td>
      <td>{{field.help_text|safe}}</td>
      {% if field.errors %}
      <div class="alert alert-danger">
        {{ field.errors | striptags}}
      </div>
      {% endif %}
    </tr>
    {% endfor %}
  </table>
  <button type="submit" class="save btn btn-default">Upload</button>
</form>
```

> [`Django` translates](https://docs.djangoproject.com/en/3.2/ref/forms/api/) `IeaModelFormExcel` attributes to HTML, so *uploaded_by* becomes `<label class="required" for="uploaded_by">Uploaded by:</label>` when called via `form.label_tag`.

> `{% csrf_token %}` is [required by `Django`](https://docs.djangoproject.com/en/3.2/ref/csrf/) when submitting a POST request for security reasons

- link the user to a template Excel file containing two sheets:

  - station metadata such as the contractor
  - sensor metadata such as calibrations.

- on upload `Django` calls `process_data` which

  - reads both sheets via pandas
  - concatenates the sheets into a single DataFrame
  - finds the database tables associated with each metadata attribute creating a new table if it does not yet exist.  The sensor metadata is looped through so the database is queried for each individual sensor
  - cleans the data to a standardised format
  - saves it

  ```python
  try:
    project_django = Project.objects.get(name=info['Plant name'][0], idcountry=country_type, idtype=project_type)
  except Project.DoesNotExist:
    project_django = Project(idtype=project_type, name=info['Plant name'][0], idcountry=country_type)
  
  project_django.save()
  ```

  > The following tables are queried by `process_data`: `FkProjecttype`, `FkCountry`, `Project`, `FkStationtype`, `FkInstaller`, `FkLoggermodel`, `Timezone`, `FkOwner`, `Station`, `Logger`, `FkDatatype`, `FkSensortype`,  `FkSensormodel`, `Sensor`, `FkCalibrationBody`, `Node`, `Sensor`

  > [`Nominatim`](https://nominatim.org/), the `Openstreetmap` geocoding engine, is called to determine the address of each inputted latitude and longitude
I want to create a test for a `Django` form that is failing when the user uploads specific files. 

I can test `Django` forms directly by passing test data to them & checking the form responses.  Specifically, I can pass a dictionary called `data` for all non-file fields & a dictionary called `files` for all file fields!

```python
# depends on: django, pytest, pytest-django


# --- forms.py ---

from django import forms
from django.core.validators import FileExtensionValidator


class TurbineModelForm(forms.Form):
    cut_in_speed = forms.FloatField(
        widget=forms.NumberInput(attrs={'class':'input-field'})
    )
    cut_out_speed = forms.FloatField(
        widget=forms.NumberInput(attrs={'class':'input-field'})
    )
    power_curve_file = forms.FileField(
        validators=[FileExtensionValidator(allowed_extensions=['csv'])]
    )
    thrust_curve_file = forms.FileField(
        validators=[FileExtensionValidator(allowed_extensions=['csv'])]
    )


# --- test_forms.py ---

from pathlib import Path

from django.core.files.uploadedfile import SimpleUploadedFile
import pytest


@pytest.fixture
def matrix_power_curve_csv() -> Path:
    return "PATH_TO_DATA"
    

@pytest.fixture
def matrix_thrust_curve_csv() -> Path:
    return "PATH_TO_DATA"
    

@pytest.mark.django_db
class TestTurbineModelForm:
    def test_error_message_is_raised_on_invalid_power_curve_file(
        self, matrix_power_curve_csv: Path, matrix_thrust_curve_csv: Path
    ) -> None:
         
        with open(matrix_power_curve_csv, "rb") as power, open(matrix_thrust_curve_csv, "rb") as thrust:   
            data = {
                # ...
                "cut_in_speed": 3,
                "cut_out_speed": 25,
                # ...
            }
            files = {
                "power_curve_file": SimpleUploadedFile(
                    name="power.csv", content=power.read(), content_type="text/csv"
                ),
                "thrust_curve_file": SimpleUploadedFile(
                    name="thrust.csv", content=thrust.read(), content_type="text/csv"
                ),
            }
        
        form = forms.TurbineModelForm(data=data, files=files)
```

---

I had to drop a debugger in the `Django` source code to find this one out, which showed that extracting values from fields requires `self.files`!

```python
# django v2.2.28
# django/forms/forms.py
class BaseForm:
    def _clean_fields(self):
        
        for name, field in self.fields.items():
            # value_from_datadict() gets the data from the data dictionaries.
            # Each widget type knows how to retrieve its own data, because some
            # widgets split data over several HTML fields.
            if field.disabled:
                value = self.get_initial_for_field(field, name)
            else:
                value = field.widget.value_from_datadict(self.data, self.files, self.add_prefix(name))
            try:
                if isinstance(field, FileField):
                    initial = self.get_initial_for_field(field, name)
                    value = field.clean(value, initial)
                else:
                    value = field.clean(value)
                self.cleaned_data[name] = value
                if hasattr(self, 'clean_%s' % name):
                    value = getattr(self, 'clean_%s' % name)()
                    self.cleaned_data[name] = value
            except ValidationError as e:
                self.add_error(name, e)
```

---

> https://adamj.eu/tech/2020/06/15/how-to-unit-test-a-django-form/ 

#django
#django-forms
#testing
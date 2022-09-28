I can prefill a form in `Django` from another view by overriding `get_initial` & parsing `request.META["HTTP_REFERER"]` to find out about the previous request ...

```python
## forms.py

from django import forms

from . import models


class RenderNotebookTemplatesForm(forms.Form):
    class Meta:
        model = models.Station
        fields = []
        
    ...

    stations = forms.ModelMultipleChoiceField(
        queryset=models.Station.objects.select_related(),
    )
    

## views.py

from . import forms


class RenderNotebookTemplatesView(FormView):
    template_name = "render_notebook_templates.html"
    form_class = forms.RenderNotebookTemplatesForm
    
    def get_initial(self):
        referrer = self.request.META["HTTP_REFERER"]
        if "/station/" in referrer:
            try:
                station_id = int(referrer.split("/")[-1])
            except:
                messages.error(self.request, f"Could parse station id from {referrer}")
                initial = self.get_initial()
            else:
                initial = {"stations": [station_id]}
        else:
            initial = self.get_initial()
        
        return initial
```

> http://ccbv.co.uk/projects/Django/4.0/django.views.generic.edit/FormView/

#python
#django
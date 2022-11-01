We have an existing nested `Django` formset that displays meteorological station nodes & the sensors associated with each node.  Nodes represent unique data types, heights and orientations on a mast; like wind speed at 80 meters at 90 degree orientation.

A previous migration from `Python` 2 to 3 meant that the delete button of this existing nested formset no longer works.

Nested formsets in `Django` require a bit of hacking.  We can include fields within fields by overriding a forms `add_fields` method to include a `nested` attribute associated with a nested form.  `Django` is smart enough to associated the fields in this nested form with the  

Here's an incomplete (adapted) example -

```python
# models.py


# forms.py
from django.forms.models import BaseInlineFormSet, inlineformset_factory
from django.utils.translation import gettext_lazy as _

from .models import Station, Node, Sensor


# The formset for editing the Sesnors that belong to a Node.
SensorFormset = inlineformset_factory(
    Node, Sensor, extra=1
)


class NodeFormset(BaseInlineFormSet):
    """
    The base formset for editing Nodes belonging to a Station, and the
    Sensors belonging to those Nodes.
    """

    def add_fields(self, form, index):
        super().add_fields(form, index)

        # Save the formset for a Node's Sensors in the nested property.
        form.nested = SensorFormset(
            instance=form.instance,
            data=form.data if form.is_bound else None,
            files=form.files if form.is_bound else None,
            prefix="node_set-%s-%s"
            % (form.prefix, SensorFormset.get_default_prefix()),
        )

    def is_valid(self):
        """
        Also validate the nested formsets.
        """
        result = super().is_valid()

        if self.is_bound:
            for form in self.forms:
                if hasattr(form, "nested"):
                    result = result and form.nested.is_valid()

        return result


    def save(self, commit=True):
        """
        Also save the nested formsets.
        """
        result = super().save(commit=commit)

        for form in self.forms:
            if hasattr(form, "nested"):
                form.nested.save(commit=commit)

        return result

InlineNodeFormset = inlineformset_factory(
    Station,
    Node,
    formset=NodeFormset,
    extra=1,
)
```

> Adapted from https://github.com/philgyford/django-nested-inline-formsets-example

#django
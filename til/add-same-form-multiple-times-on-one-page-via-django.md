I want to create an editable table in a `Django` view via `django-htmx` & `django-autocomplete-light`.

Specifically, each table cell is an `HTML` form that can be submitted via `HTMX`.  With auto-complete enabled it should feel like `Excel`.

I was pulling my hair out because ...

1. The `HTMX` fragments containing autocomplete elements wouldn't render https://github.com/rdmolony/til/blob/4629fb581c74e486422059769bc239758cde853b/til/django-htmx-autocomplete.md
2. `django-autocomplete-light` only overrides a single input widget.

It turns out that `django-autocomplete-light` requires that each form & its input widgets have a unique ID.  Otherwise it only override a single widget with autocomplete!

We can use `Django` form prefixes to prefix each form with a unique id to create this.  I had to be careful that each time the form is instantiated in my view I included the prefix

https://github.com/yourlabs/django-autocomplete-light/issues/1235

#django
#django-htmx
#django-autocomplete-light

I can serve csv files via `django-whitenoise` by placing them in a folder called `csv/csv`!  This means that I can share `csv` files without `nginx` by linking to files via ...

- `/static/csv/<FILENAME>.csv`
- Or by rendering a template with variable `filename` & accessing the URL via `{% static filename %}` using  the `Django` templating language

#django
#django-whitenoise
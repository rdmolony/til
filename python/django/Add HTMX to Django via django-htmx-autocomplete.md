I wanted to glue together `django-htmx` & `django-autocomplete-light` but really struggled.

It turns out that because `HTMX` only sends `HTML` over the wire their recommended manner of linking to `CSS` & `JS` media files doesn't work for `HTML` fragments!
We need to include the required media in the base template.  In this case the base template `JS` for `Select2` can then override the `HTML` sent over 
the wire to include autocompletion!

#django
#htmx
#django-htmx
#django-autocomplete-light

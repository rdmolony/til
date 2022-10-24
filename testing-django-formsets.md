I want to patch a form that we use internally for adding maintenance logs when something goes wrong at one of our stations.

We are using `Django` formsets to display all of the existing logs, to add new logs or delete existing ones.  Strangely users could not delete logs, so I have to patch the formset to add this.

Before merging my patch I want to test that I can add & delete logs.  I can test the form directly to see if it can save valid data. 

I can also test POSTing data to the view via the `Django` test client.  To test formsets I need to add some extra parameters to the test client ...

```python
{
    'form-TOTAL_FORMS': 1, 
    'form-INITIAL_FORMS': 0 
}
```

Note that in the case of adding a single form is essential that `INITIAL_FORMS` is zero!  In my case I had both as 1 & my test complained that I was missing an `id`!

> https://adamj.eu/tech/2020/06/15/how-to-unit-test-a-django-form/
> https://stackoverflow.com/questions/1630754/django-formset-unit-test
> https://docs.djangoproject.com/en/3.1/topics/forms/formsets/#formset-validation

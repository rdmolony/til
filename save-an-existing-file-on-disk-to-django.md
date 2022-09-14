I can use `django.core.files.File` to upload an existing file on disk to whatever storage is implemented for media files by my `Django` web app.

I can use `django-storages` to switch my storage to `s3`, `Azure` etc!

`Django` merely stores the files somewhere & records where they are stored in the database.


```python
# models.py
from django.db import models

class Car(models.Model):
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=5, decimal_places=2)
    photo = models.ImageField(upload_to='cars')
    specs = models.FileField(upload_to='specs')

# roughwork.py
from pathlib import Path
from django.core.files import File

path = Path('/some/external/specs.pdf')
car = Car.objects.get(name='57 Chevy')
with path.open(mode='rb') as f:
    car.specs = File(f, name=path.name)
    car.save()
```

> https://docs.djangoproject.com/en/4.1/topics/files/#using-files-in-models

#django
#django-storages
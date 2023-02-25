I wanted to save a user uploaded file to disk on our production server.  The simplest way seems to be to create a model & to link a form to this model via `ModelForm` which fills a form with predefined model fields. 

I can render my model `WindogFlag` ...

```python
class WindogFlag(models.Model):

    flags = models.FileField(upload_to="flags/")

    upload_date = models.DateField(auto_now=True)
```

... as a form `WindogFlagForm` ...

```python
class WindogFlagForm(forms.ModelForm):

    class Meta:

        model = models.WindogFlag

        fields = ['flags']
```

... and render it in `myview` ...

```python
def myview(request):
	...
	if request.method == 'POST':
		
		form = WindogFlagForm(request.POST, request.FILES)

        file = request.FILES["flags"]

        if form.is_valid():

            try:
                upload_windog_flags_to_datalog(file, station, request)

            except Exception as e:

                msg = f"Upload Windographer Flags Failed: {e.__class__} {e}"

                messages.error(request, msg)

            else:

                form.save()

                return redirect(request.path)

        else:

            raise ValueError(form.errors)

    else:

        form = WindogFlagForm()
    ...
```

> The file won't be saved to disk until `form.save()` is called!

I can test then this with `pytest` ...

```python
@pytest.mark.django_db
@pytest.mark.usefixtures("ch020_01_factory")
@pytest.mark.usefixtures("fill_flags")
def test_windog_flags_are_saved_to_disk(
    admin_client, ch020_01_windog_flags_txt: Path, tmp_path: Path, monkeypatch
) -> None:

    client = admin_client

    flags_file = ch020_01_windog_flags_txt

    filename = flags_file.name

    station = models.Station.objects.get(name="ch020_01")

	monkeypatch.setattr(
        "stationmanager.models.WindogFlag.flags.field.storage.location", tmp_path
    )

    with open(flags_file, "r") as fp:

        client.post(f"/stationmanager/station/{station.id}", {"flags": fp})

    uploaded_flags = [f.name for f in tmp_path.iterdir()]

    assert filename in uploaded_flags
```

Annoyingly it seems that the `pytest-django` fixture `settings` doesn't work when changing `MEDIA_ROOT` as `Django` saves `MEDIA_ROOT` in `WindogFlag.flags.field.storage.location` on intialisation of the `WindogFlag` model
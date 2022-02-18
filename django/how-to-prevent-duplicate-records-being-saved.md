# How to prevent duplicate records being saved

I want to save unique flags indicating faulty time-series data to a database.  I want `Django` to raise an error if an attempt is made to save a record that already exists.  I could write some logic to catch this prior to writing the data each time but I'd rather have a validator at the model level.

I thought that setting the `unique=True` constraint on each `DateTimeField` would prevent this.  It didn't.  It seems this constraint is intended to prevent duplicates across an entire field rather than across fields - so say "Ireland" can't be written twice to a field called "countries".

I can instead validate by checking new values against existing values in the database prior to saving: 

```python
class Flag(models.Model):
    id = models.AutoField(primary_key=True, db_column='id', blank=False, null=False)
    flag = models.CharField(db_column='Notes', null=False, blank=False, max_length=255)
    start_timestamp = models.DateTimeField(db_column='Start_Timestamp', blank=False, null=False)
    stop_timestamp = models.DateTimeField(db_column='Stop_Timestamp', blank=False, null=False)

    def is_a_new_record(self) -> bool:
        record_exists = Flag.objects.filter(
            flag=self.flag,
            start_timestamp=self.start_timestamp,
            stop_timestamp=self.stop_timestamp
        ).exists()
        return not record_exists

    def save(self, *args, **kwargs):
        if self.is_a_new_record():
            return super().save(*args, **kwargs)
        else:
            print(f"{self} is not a new record!")
```
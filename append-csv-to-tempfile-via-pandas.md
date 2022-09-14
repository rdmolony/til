I must explicitely `seek` the start of the tempfile before I can append a csv to existing text

I can't do ...

```python
header = "I am metadata\n"
with tempfile.NamedTemporaryFile() as f:
    f.write(header.encode("utf-8"))
    data.to_csv(f.name, mode="a", encoding="utf-8")
```

I can do ...

```python
header = "I am metadata\n"
with tempfile.NamedTemporaryFile() as f:
    f.write(header.encode("utf-8"))
    f.seek(0) # Go to the start of the tempfile
    data.to_csv(f.name, mode="a", encoding="utf-8")
```

#python
#pandas
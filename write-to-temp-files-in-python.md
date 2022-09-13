I can't do ...

```python
temp_file = tempfile.TemporaryFile()
with open(temp_file, mode="w", encoding='utf-8') as f:
    f.write("text")
```

I can do ...

```python
with tempfile.TemporaryFile(encoding='utf-8') as f:
    f.write("text")
```

> https://www.askpython.com/python/tempfile-module-in-python

#python
I can't do ...

```python
text = "text"
temp_file = tempfile.TemporaryFile()
with open(temp_file, mode="w", encoding='utf-8') as f:
    f.write(text)
```

I can do ...

```python
text = "text"
with tempfile.TemporaryFile() as f:
    f.write(text.encode("utf-8"))
```

> https://www.askpython.com/python/tempfile-module-in-python

#python
I want to check a directory for a potential list of subfolders & if it exists select it.

I can check if it exists like ...

```python
subfolders = [
	"Generic_calibration",
	"Generic Calibration",
	"Table10m",
	"TenMin",
]
subfolder_exists = any(filesystem.exists(sfp) for sfp in subfolders)
```

... and get the first subfolder that exists via ...

```python
if subfolder_exists:
	subfolder = next(sfp for sfp in subfolder_paths if filesystem.exists(sfp))
else:
	subfolder = station_dir
```

I could do this more efficiently via ...

```
subfolder = next(
	(sfp for sfp in subfolder_paths if filesystem.exists(sfp)).
	station_dir
)
```

... where `station_dir` is the default value if the generator is exausted, but it doesn't read as nicely!

> [python how can return first value = true in a list? - Stack Overflow](https://stackoverflow.com/questions/34349430/python-how-can-return-first-value-true-in-a-list)

#python 
#functional-programming
I want to generate a compressed file & then save it as `Django` media.

I can do so by making a temporary directory, saving my file contentn there & compressing it from there ...  

> **Caveat**: File contents must fit in memory! 

```python
import shutil
import tempfile


filename = "myfile" 
zipped_filename = filename + ".zip"
with tempfile.TemporaryDirectory() as tmp_dir:
    tmp_path = Path(tmp_dir) / filename 

    with open(tmp_path, "w") as f:
        f.write(contents)
        contents = open(
            shutil.make_archive(filename, "zip", root_dir=tmp_dir), "rb"
        ).read()
            
```

> https://stackoverflow.com/questions/11967720/create-a-temporary-compressed-file

#python
#django
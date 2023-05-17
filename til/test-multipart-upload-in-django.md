I can test the uploading of multiple files like ...

```python
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse


def test_upload_documentation(self, admin_client):
    url = reverse("upload-documentation", kwargs={"pk": 1})
    files = [
        SimpleUploadedFile(
            name, b"file_content", content_type="text/plain"
        )
        for name in ("file1.txt", "file2.txt")
    ]

    response = admin_client.post(url, data={"file": files})
    # ...
```

... instead of `admin_client.post(url, files={"file": files})`,  strange ....

https://stackoverflow.com/questions/11170425/how-to-unit-test-file-upload-in-django

#django

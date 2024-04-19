I tried ...

```python
import filecmp

left = "<FILEPATH>"
right = "<FILEPATH"
assert filecmp.cmp(left, right)
```

... but this proved to be flakey across test runs...  Does `cmp` also compare file metadata?

I tried ...

```python
left = "<FILEPATH>"
right = "<FILEPATH"
with open(left) as l, open(right) as r
	assert left.read() == right.read()
```

... but this takes an age to run & doesn't scale as it loads each file into memory!

Finally, this `Stackoverflow` functional-style approach seemed to work fine ...

```python
def assert_files_are_equivalent(left: os.PathLike, right: os.PathLike):
    # https://stackoverflow.com/questions/254350/in-python-is-there-a-concise-way-of-comparing-whether-the-contents-of-two-text
    
    with open(left, "rb") as l, open(right, "rb") as r:
        assert (
            os.fstat(l.fileno()).st_size == os.fstat(r.fileno()).st_size,
            "Files are different sizes!"
        )

        # set up one 4k-reader for each file
        l_reader= functools.partial(l.read, 4096)
        r_reader= functools.partial(r.read, 4096)

        # pair each 4k-chunk from the two readers while they do not return '' (EOF)
        cmp_pairs= zip(iter(l_reader, b''), iter(r_reader, b''))

        # return True for all pairs that are not equal
        # voilà; any() stops at first True value
        assert (
            not any(itertools.starmap(operator.ne, cmp_pairs)), "File content differs!"
        )
```

> [In Python, is there a concise way of comparing whether the contents of two text files are the same? - Stack Overflow](https://stackoverflow.com/questions/254350/in-python-is-there-a-concise-way-of-comparing-whether-the-contents-of-two-text)

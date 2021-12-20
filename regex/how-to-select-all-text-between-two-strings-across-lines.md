# How to select all text between two strings across lines

I want to remove a block of text from the docstrings of 20+ functions at once where each block of text coincides with `.. plot::` and `"""` ...

```python
    ...
    .. plot::

        :include-source:
        
        import mrp
        from mrp import crosstab
        test_station = mrp.load_test_station(mrp.__file__)
        
        ct = crosstab.heightbydata( test_station, test_station.t1avg, 2 )
        crosstab.plot(ct, show_values=False)
    """
```

I can't use the **Meta Escape** character `.` as this does not include **line terminators** `\n`.  I can, however, use `[\w\W]`, which means select all words and non-words, alongside the one or more **lazy** quantifier `+?` where `?` forces it to match as few words as possible ...

```
(.. plot::[\w\W]+?)"""
```
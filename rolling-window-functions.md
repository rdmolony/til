I have anemometer sensor data & some of it is faulty.  Sometimes sensors get stuck.  This shows up in the data as "flatlined" sensor readings.

How do we create a rule to catch flatlined data?  

I found https://github.com/DHI/tsod which implement a `ConstantValueDetector` which uses window functions to find constant values.  Something like ...

```python
window_size = 3
threshold = 1e-7
rollmax = data.rolling(window_size, center=True).apply(np.nanmax)
rollmin = data.rolling(window_size, center=True).apply(np.nanmin)
anomalies = np.abs(rollmax - rollmin) < threshold
```

What are rolling window functions?

This is most easily understood by example.  For a window size of 3 & readings [10,0,5,2,6,7] the rolling minimum is [NAN,NAN,0,0,2,2].
In this case, what's the smallest value in the last 3 rows?

> The first two values don't have enough values preceeding them to answer this question so the answer is NAN

> https://pandas.pydata.org/docs/user_guide/window.html for more info

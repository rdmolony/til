# How to flag wind turbine faults

I have ...

| ... | fault_start_time | fault_end_time | ... |
| --- | --- | --- | --- |
| ... | 2017-12-31 17:00:00 | 2017-12-31 17:00:00 | ... |
| ... | 2017-12-31 17:10:00 | 2017-12-31 17:11:00 | ... |

... and I want to know if there has been any wind turbine faults during any 10 minute time interval.  I can find this out by comparing `fault_start_time` to `fault_end_time` and flagging if they differ.

First I need to read the data and convert it the time columns to `datetime` data types to access the `pandas` datetime operations.

```python
import pandas as pd

timeseries = pd.read_csv(
    "timeseries.csv",
    dtype={"fault_start_time": "datetime", "fault_end_time": "datetime"}
)
```

Or equivalently

```python
timeseries = pd.read_csv(
    "timeseries.csv"
).astype({"fault_start_time": "datetime", "fault_end_time": "datetime"}) 
```

Now I can compare them using a simple equality operator :)

```python
is_turbine_fault = timeseries["fault_start_time"] == timeseries["fault_end_time"]
timeseries["turbine_fault_occurs"] = is_turbine_fault
```

---

For more information see the [`pandas` timeseries user guide](https://pandas.pydata.org/pandas-docs/stable/user_guide/timeseries.html)
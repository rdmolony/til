I have turbine timeseries readings & turbine fault flags ...

| time | ... |
| --- | --- |
| 2017-12-31 17:00:00 | ... |
| 2017-12-31 17:10:00 | ... |
| 2017-12-31 17:20:00 | ... |
| 2017-12-31 17:30:00 | ... |

| ... | fault_start_time | fault_end_time | ... |
| --- | --- | --- | --- |
| ... | 2017-12-31 17:02:00 | 2017-12-31 17:12:00 | ... |

... and I want to know if there has been any wind turbine faults during any 10 minute time interval

| time | ... | turbine_fault_occurs |
| --- | --- | --- |
| 2017-12-31 17:00:00 | ... | False |
| 2017-12-31 17:10:00 | ... | True |
| 2017-12-31 17:20:00 | ... | True |
| 2017-12-31 17:30:00 | ... | False |

How do I adapt my fault time interval into the same 10 minute interval as my timeseries data?

Lets first code these expectations as a unit test on which we can test our implementation ...

```python
import pandas as pd
from pandas.testing import assert_frame_equal


def test_flag_turbine_fault_occurences() -> None:
    timeseries = pd.DataFrame(
        {
            "time": [
                "2017-12-31 17:00:00",
                "2017-12-31 17:10:00",
                "2017-12-31 17:20:00",
                "2017-12-31 17:30:00",
            ],
        },
        dtype="datetime64[s]",
    )
    faults = pd.DataFrame(
        {
            "fault_start_time": ["2017-12-31 17:02:00"],
            "fault_end_time": ["2017-12-31 17:12:00"],
        },
        dtype="datetime64[s]",
    )
    expected_output = pd.DataFrame(
        {
            "time": pd.Series(
                [
                    "2017-12-31 17:00:00",
                    "2017-12-31 17:10:00",
                    "2017-12-31 17:20:00",
                    "2017-12-31 17:30:00",
                ],
                dtype="datetime64[s]",
            ),
            "turbine_fault_occurs": [False, True, True, False],
        },
    )

    output = flag_turbine_fault_occurences(
        timeseries,
        faults,
        column_name_map={
            "time": "time",
            "fault_start_time": "fault_start_time",
            "fault_end_time": "fault_end_time",
        },
    )

    assert_frame_equal(output, expected_output)
```

Now for implementation ...

We need to round each timestamp to the nearest 10 minute interval so `fault_start_time` `2017-12-31 17:02:00` becomes `2017-12-31 17:10:00` and `fault_end_time` `2017-12-31 17:12:00` becomes `2017-12-31 17:20:00` to capture the time interval in which either fault occurs. 

```python
import pandas as pd
from pandas.testing import assert_series_equal


def test_ceil_to_nearest_10Min_interval() -> None:
    s = pd.Series(["2017-12-31 17:02:00", "2017-12-31 17:58:00"], dtype="datetime64[s]")
    expected_output = pd.Series(
        ["2017-12-31 17:10:00", "2017-12-31 18:00:00"], dtype="datetime64[s]"
    )
    
    output = ceil_to_nearest_10Min_interval(s)

    assert_series_equal(output, expected_output)


def ceil_to_nearest_10Min_interval(s: pd.Series) -> pd.Series:
    return s + pd.to_timedelta(-s.dt.minute % 10, unit='Min')
```

Now we can call this `ceil` function to band the timestamps and link each start and end fault time with its corresponding time interval with a simple `LEFT` merge, which ensures we don't lose any time intervals for which no fault occurs.  Lastly, we can check whether or not a fault begins or ends within each time interval and flag this with `True` or `False`

```python
from typing import Dict

import pandas as pd


def flag_turbine_fault_occurences(
    timeseries: pd.DataFrame, faults: pd.DataFrame, column_name_map: Dict[str, str]
) -> pd.DataFrame:
    faults = faults.copy()

    c_time = column_name_map["time"]
    c_fault_start_time = column_name_map["fault_start_time"]
    c_fault_end_time = column_name_map["fault_end_time"]

    fault_start_time_interval = ceil_to_nearest_10Min_interval(
        faults[c_fault_start_time]
    )
    fault_end_time_interval = ceil_to_nearest_10Min_interval(
        faults[c_fault_end_time]
    )

    timeseries_with_faults = (
        timeseries.merge(
            fault_start_time_interval,
            left_on=c_time,
            right_on=c_fault_start_time,
            how="left"
        )
        .merge(
            fault_end_time_interval,
            left_on=c_time,
            right_on=c_fault_end_time,
            how="left"
        )
    )
    timeseries_with_faults["turbine_fault_occurs"] = (
        (timeseries_with_faults[c_fault_start_time].notnull())
        | (timeseries_with_faults[c_fault_end_time].notnull())
    )
    return timeseries_with_faults.drop(columns=[c_fault_start_time, c_fault_end_time])
    ```

> Inspired by [how-to-join-two-dataframes-for-which-column-values-are-within-a-certain-range](https://stackoverflow.com/questions/46525786/how-to-join-two-dataframes-for-which-column-values-are-within-a-certain-range) & [merge-pandas-dataframes-where-one-value-is-between-two-others](https://stackoverflow.com/questions/30627968/merge-pandas-dataframes-where-one-value-is-between-two-others)

#pandas
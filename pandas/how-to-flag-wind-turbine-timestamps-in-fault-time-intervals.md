# How to flag wind turbine timestamps in fault time intervals

I have turbine timeseries readings & turbine fault flags ...

| time | ... |
| --- | --- |
| 2017-12-31 16:50:00 | ... |
| 2017-12-31 17:00:00 | ... |
| 2017-12-31 17:10:00 | ... |
| 2017-12-31 17:20:00 | ... |

| ... | fault_start_time | fault_end_time | ... |
| --- | --- | --- | --- |
| ... | 2017-12-31 17:02:00 | 2017-12-31 17:12:00 | ... |

... and I want to know if there has been any wind turbine faults during any 10 minute time interval

| time | ... | turbine_fault_occurs |
| --- | --- | --- |
| 2017-12-31 16:50:00 | ... | False |
| 2017-12-31 17:00:00 | ... | False |
| 2017-12-31 17:10:00 | ... | True |
| 2017-12-31 17:20:00 | ... | False |

How do I adapt my fault time interval into the same 10 minute interval as my timeseries data?

Lets first code these expectations as a unit test on which we can test our implementation ...

```python
import pandas as pd
from pandas.testing import assert_frame_equal


def test_flag_turbine_fault_occurences() -> None:
    timeseries = pd.DataFrame(
        {
            "time": [
                "2017-12-31 16:50:00",
                "2017-12-31 17:00:00",
                "2017-12-31 17:10:00",
                "2017-12-31 17:20:00",
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
                    "2017-12-31 16:50:00",
                    "2017-12-31 17:00:00",
                    "2017-12-31 17:10:00",
                    "2017-12-31 17:20:00",
                ],
                dtype="datetime64[s]",
            ),
            "turbine_fault_occurs": [False, False, True, False],
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

This is surprisingly difficult to do in `pandas` and simple in `SQL`, so we're using `SQL`

> Inspired by [how-to-join-two-dataframes-for-which-column-values-are-within-a-certain-range](https://stackoverflow.com/questions/46525786/how-to-join-two-dataframes-for-which-column-values-are-within-a-certain-range) & [merge-pandas-dataframes-where-one-value-is-between-two-others](https://stackoverflow.com/questions/30627968/merge-pandas-dataframes-where-one-value-is-between-two-others)

```python
from typing import Dict

import pandas as pd
import sqlite3


def flag_turbine_fault_occurences(
    timeseries: pd.DataFrame, faults: pd.DataFrame, column_name_map: Dict[str, str]
) -> pd.DataFrame:
    faults = faults.copy()
    
    c_time = column_name_map["time"]
    c_fault_start_time = column_name_map["fault_start_time"]
    c_fault_end_time = column_name_map["fault_end_time"]
    
    faults["turbine_fault_occurs"] = True
    
    con = sqlite3.connect(':memory:')
    timeseries.to_sql("timeseries", con=con, index=False)
    faults.to_sql("faults", con=con, index=False)
    query = f"""
    SELECT
        *
    FROM
        timeseries LEFT JOIN faults ON
        time BETWEEN "{c_fault_start_time}" AND "{c_fault_end_time}"
    """
    use_columns = list(timeseries.columns) + ["turbine_fault_occurs"]
    timeseries_with_faults = pd.read_sql_query(sql=query, con=con).loc[:, use_columns]
    timeseries_with_faults["turbine_fault_occurs"] = (
        timeseries_with_faults["turbine_fault_occurs"]
        .fillna(False)
        .replace({1: True})
        .astype("bool")
    )
    return timeseries_with_faults.astype({c_time: "datetime64[s]"})
```

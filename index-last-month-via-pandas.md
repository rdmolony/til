I have a timeseries  ...

```csv
"TmStamp","RecNum","WS_80m_90deg_Avg",...
2021-06-29 00:00:00.000,459742,3.245,...
...
```

... and I want to grab the last month via `pandas`.

I can do this easily using `pandas.DateOffset`!

```python
offset = myseries.index[-1] - pd.DateOffset(hours=5)
myseries.loc[offset::]
```

> [python - Previous month datetime pandas - Stack Overflow](https://stackoverflow.com/questions/43090840/previous-month-datetime-pandas)
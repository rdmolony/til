I have two dataframes; one of uncalibrated wind data & one of calibrated wind data.

I wanted to compare unncalibrated wind directions to calibrated wind directions so that
I could visualise if these calibrations were being correctly applied.

> https://matplotlib.org/stable/gallery/pie_and_polar_charts/polar_demo.html

I can use the `matplotlib` polar plot for this purpose.  In my case, I want a polar histogram,
or wind rose. To summarise the data for the wind rose I can use `pd.cut` to bin wind directions
it into a number of intervals & value counts to find the number of occurences of each interval.
Now I just need radians & I can use a polar plot.

```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def plot_polar(ax, theta, title):
    bins = pd.cut(theta, bins=np.linspace(0, 360, num=50)).value_counts(sort=False)
    r = bins.values
    radii = np.deg2rad(bins.index.map(lambda x: x.mid))
    ax.grid(True)
    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1)
    ax.set_title(title)
    ax.plot(radii, r)
```

To compare the two dataframes I can use `plt.subplots` to plot each graph
alongside one another

```python
def plot_uncalibrated_vs_calibrated(
    uncalibrated: pd.DataFrame, calibrated: pd.DataFrame
) -> None:
    assert set(calibrated.columns) == set(uncalibrated.columns)
    columns = calibrated.columns
    num_plots = len(columns)

    fig, ax = plt.subplots(
        num_plots,
        2,
        subplot_kw={'projection': 'polar'},
        figsize=(7.5,7.5)
    )
    fig.tight_layout(h_pad=5)
    
    for i, column in enumerate(columns):
        plot_polar(ax[i, 0], uncalibrated[column], title=column)
        plot_polar(ax[i, 1], calibrated[column], title=column)
        
    fig.suptitle('Uncalibrated vs Calibrated Wind Directions')
    plt.subplots_adjust(top=0.85)
    plt.show()
    ```
    
    

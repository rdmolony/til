# Estimating wind speed forecast uncertainty

## Measurement accuracy

### **On-site wind monitoring**

| Type | Description | Causes | Estimate? | Reduce? |
| --- | --- | --- | --- | --- |
| Instrument accuracy | - | Calibration and mounting arrangement of the instruments | ~2-3% | ~0.2-0.3% by calibration  |
| Measurement interference | - | Anemometer mounting,  type of tower, echoes from nearby objects | - | - |
| Measurement inconsistency | - | Icing or equipment malfunction | - | - |
| Second-order effects | - | Over-speeding, degradation or air density variations | - | - |

### **Long-term wind resource extrapolation**

> Also known as long-term measurement higher wind regime

| Type | Description | Causes | Estimate? | Reduce? |
| --- | --- | --- | --- | --- |
| On-site data synthesis | - | Strength of the correlations between mast locations, amount of data synthesised | - | - |
| Consistency of reference data | - | Level, nature & metadata of regional validation available | - | - |
| Correlation to reference station | - | - | - | - |
| Representativeness of period of data | - | How well the record period represents the long-term wind conditions | inter-annual variability / SQRT(years of measurement data) | - |
| Historical wind frequency distribution | - | Uncertainty of the wind speed distribution measured over the period of data collected | 2% / SQRT(years of measurement data) | - |

### Other

| Type | Description | Causes | Estimate? | Reduce? |
| --- | --- | --- | --- | --- |
| **Vertical wind resource extrapolation** | Hub height shear values estimated up from mast values | Representativeness of masts and heights, consistency of shear between towers, atmospheric stability and measurement configurations | - | - |
| Input data accuracy | - | Validity of the topographic map, land cover map, position and height of obstacles to the flow as windbreaks for both the historical and future period of operation | - | - |
| **Spatial wind resource extrapolation** | Turbine values estimated across from mast values |  Representativeness of measurement locations vs turbine locations, complexity of the wind flow at the site (variations in ground cover) | model vs measured wind speeds | - | 

## **Loss factor uncertainty**

> Also known as energy production analysis

| Type | Description | Causes | Estimate? | Reduce? |
| --- | --- | --- | --- | --- |
| Wakes | - | Representativeness of model | normal distribution with a standard deviation of ~25-35% of the wake effect | - |
| Availability | Availability of the wind turbine, substation & electrical grid | "" | weibull distribution with a standard deviation of 3% | - |
| Electrical | - | "" | normal distribution with a standard deviation of 10% of the loss | - |
| Turbine performance | - | "" | normal distribution with a standard deviation of 2-3% of the loss | - |
| Environmental | - | "" | normal distribution with a standard deviation of 10% of the loss | - |
| Curtailment | - | "" | normal distribution with a standard deviation of 10% of the loss | - |

## **Inter-annual variability**

| Type | Description | Causes | Estimate? | Reduce? |
| --- | --- | --- | --- | --- |
| Future wind frequency distribution  | Year-to-year variability of wind speed distribution and air density | - | ~2% | - |
| Inter-annual variability | Year-to-year variation of average wind speed | - | inter-annual variation / SQRT(10), ~6% | Take a longer time-period |

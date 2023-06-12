# Hospital Occupancy Model 
## About
The model uses discrete time (days) and iterates over a given time-sequence of new-confirmed cases. In principle, for every new confirmed case, with a certain probability, a delay (x) and a staying time (y) is sampled given a specific distribution, so that the case reported on day t contributes to the observable of choice, typically the hospitalised persons, between t+x and t+x+y. The model itself is macroscopic though! Cases are multiplied with a discret(ized) probability function resulting in a vector for the admissions.
E.g. input cases [100 - - - - - - -] lead to admissions [0 2 4 2 1 1 0 0] using admission rate 0.1 and a delay distribution with peak at day 2 after reporting. This strategy allows a fast evaluation of the model and consquently also a rigorous calibration.

### Calibration Strategy 
The calibration/forecast strategy uses four points in time:
#### tzero
The model is started at tzero without persons in the system (hospitalised persons). This is not the "official" start time of the simulation (*tstart*), but a ***transient time*** earlier, typically between 50 and 100 days. The idea behind is, that by *tstart* all persons in the system are a a result of the admissions after *tzero* (and not earlier).
#### tstart
The official start time of the simulation. Automatically determined by the last day, for which reference data (usually hospital data) is found.
#### tstartcalib
Determined by *tstart* minus a ***calibration time***. The time between *tstartcalib* and *tstart* is used for calibration. Note that *tzero* of the calibration runs is calculated based on *tstartcalib* and not on *tstart*.
#### tend
End time of the official forecast simulation. Note that *tendcalib*=*tstart*. 
#### Parameterspace
The model has three free parameters: the admission rate p, the mean of the (Gammma distributed) delay mu(x), and the mean of the (Gammma distributed) staying time mu(y). These parameters are calibrated using the Nelder-Mead simplex algorithm used in SciPy. 

## Usage
### Requirements
The code was developed with Python 3.9.2. Moreover, the following toolboxes must be installed (with the version used for code development)

- scipy (1.8.9)
- numpy (1.20.1)
- matplotlib (3.3.4)

Backwards compatibility with earlier Python 3 versions or earlier versions of the toolboxes might be given up to a certain extent, but is not tested yet.

## Run the Program
### Run Script
The model is run using the corresponding `run.py` script with path to the config file as runtime argument. E.g.
```
python3 run.py config_figure5_ba4_base.json
```
The simulation runs automatically and generates reproducible results in the corresponding folder.
**Before use** make sure that the result folder specified in the config exists.
### Config File(s)
The files `config_....json` contain all relevant input to the simulation model including model parameters and paths to input files. Many fields within the config file are rather self explanatory, some of them require specific explanation:

| field | structure | interpretation |
| :--- | :--- | :------------ |
| filename... | string | Any input (and the calibration reference) is stated using a *filename* / *columns* tuple. When opening the file the model automatically uses and parses the first column as time column. Hence, if time is not coded in the first column, the file needs to be restructured. Also the files need to use UTF-8 encoding. |
| columns... | list(string) | Every config file can use multiple inputs and calibration references as subscenarios as long as they are saved within the same file. To make this possible, a list of column headers needs to be specified. The longest input list among "CaseNumbers","Hospitalized","Forecast",(if available),"RateFactors" decides how many subscenarios will be run, say, henceforth ***m***. All the *columns...* fields of the config therefore need to be lists with either length *m* or *1*. In the latter case, the single entry is used for all scenarios. |
| ...RateFactors | - | Optionally, the user can specifiy a "filenameRateFactors" and "columnsRateFactors". The time series will then be used as a time dependent scaling factor to the admission rate. This can, exemplary, be used to integrade a new variant with increased/reduced virulence or an increasing/decreasing level of immunity against severe disease. If the field is missing, all factors are 1.0. |
| forecastDay | yyyy-mm-dd | Matches *tstart* (see description of the calibration strategy above) |
| calibrationDays/transientDays | int | See *tzero*, *tstartcalib* and *tstart* in the first section. |
| forecastDays | int | Defines *tend* via *tstart+forecastDays* |
| ...DelayDistributions | list(string) | Identifier for the shape used to create the discrete probability distributions. |
| parameters/subfield | list(double) | Contains subfields according to the (free) parameters of model. In the given model version, *rate*,*delay* and *stay* standing for the admission rate and average admission delay and stay times are used. Either *parameters* or *bounds* must be present in the file. In the prior case, the values are directly used for simulation, in the latter case, the calibration process is triggered (see below). |
| bounds/subfield | list(\[double\])] | Contains subfields according to the (free) parameters of model. In the given model version, *rate*,*delay* and *stay* standing for the admission rate and average admission delay and stay times are used. Either *parameters* or *bounds* must be present in the file. In the latter case, the specified values are taken as lower and upper bound for the Nelder-Mead method in the calibration, in the prior case the values are taken directly without calibration (see above).|
It is highly recommended to copy and modify a given config file rather than developing one from the scratch. The git repository contains some samples.

### Data
Together with the source code, the user also receives files containing sample data from Austria to test the code (`data/cases_and_hospitals.csv`). The data contains timelines of cases, hospital occupancy and icu occupancy in Austria per federal state and a forecast developed with an epidemiological model and is subject to the CC BY 4.0 license. The data was collected from the free online source https://info.gesundheitsministerium.gv.at/data/timeline-faelle-bundeslaender.csv. 

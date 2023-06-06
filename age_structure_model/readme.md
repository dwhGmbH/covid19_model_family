# Age SIR Model
## About
The included MATLAB simulation model includes a numeric simulation (Method of Lines) of a partial differential equation SIR type model. It is based on the McKendrick equation and considers age as a second continuous variable. In addition to standard models, which consider the compartments S,I,R, the given approach also depicts Sv and Iv, which stand for susceptible and infectious vaccinated persons.

The simulation comes with a calibration method which uses an iteratively applied bisection method to fit transmission rates to given data.

## Usage
### Requirements
The code was written with MATLAB R2021a, but the main components of the program should easily work with older versions of MATLAB as well. Some specifics in the plot routines might not though. Required toolboxes:
- Image processing (for heatmap plots)
### Run the Program
There are two main functions to run the simulation:
***
**File** `age_sir_macro.m` contains the function age\_sir\_macro which is called with one required and one optional argument. The main argument is a string which points to the configuration file in JSON format. The config file contains all necessary information for the model parameters and the initial conditions of the simulation. Several config files calibrated to different disease waves in Austria and Czechia are included in the repository. Example, how the function can be executed:
```
age_sir_macro('config_AT_waveDelta_fc20211123.json')
```
The second optional program argument is a boolean which indicates whether the simulation should produce visible output or not. It is primarily used by the calibration (see below) to suppress the output when calibrating.

**Before use** one has to generate a folder named *results*, since simulation output is automatically saved there.
***
**File** `calibrate.m` is used to fit the transmission parameters of the model to the given *IValidation* data in the config-file. Note, that the error function ignores the age cohorts in data and simulation output and fits the curves only with respect to the total number of infectious individuals per day. 
The script iteratively calls `age_sir_macro` with adapted config-files which are termporarily saved in a folder *calibration*.
The free parameters of the calibration are a vector of positive double values which correspond to the value of a transmissibility step function. Each vector-entry corresponds to the value of the step function in a certain time period \[ti,ti+1). The length of the time periods are specified by the *calibinterval* parameter in the config file. A smaller interval leads to a greater number of parameter values and, typically, to a higher fluctuating transmissibility curve.

**Before use** one has to generate a folder named *calibration*, since temporarily generated config-files are automatically saved there.
***
**File** `config_....json` specifies the parameters of the scenario to be evaluated by the simulation. It needs to contain the following fields:

| field | structure | interpretation |
| :--- | :--- | :------------ |
| scenario | string with \[a-zA-Z0-9_\] | short ID for the depicted scenario |
| scenarioName | string | long ID for the scenario to be used in labels |
| t0 | yyyy-mm-dd | start-date of the simulation |
| tend | yyyy-mm-dd | end-date of the simulation |
| xi | decimal | vaccine effectiveness |
| gamma | decimal | recovery rate |
| calibinterval | int | time-interval in which the transmissibility function may change its value|
| beta | list(double) | function values of the transmissibility-function beta. Either manually chosen or set by the calibration routine. Its length must match the number of days between startdate and enddate, divided by the calibinterval, and rounded up.|
| contactMatrixFile | string | path to the file containing the contact data. The rows and columns of the matrix must match the specified ageclasses. |
| ageClasses | list(int) | lower bounds of the age classes used in the data |
| I0/Iv0/S0/Sv0/R0 | list(int) | number of unvaccinated infectious/vaccinated infectious/unvaccinated susceptible/vaccinated susceptible/recovered individuals at startdate. Need to be equal length as ageClasses|
| IValidation | list(list(int)) | number of infectious individuals per day and age-class used as calibration reference and/or validation reference. Its first dimension mus match the number of days between startdate and enddate, its second dimension must match the length of the age-vector. If used for calibration only, the age-distribution of the cases does not matter. Therefore, one may also put all cases into the first age-compartment, leaving all other compartments at zero. |

In general, it is recommended to copy and modify one of the existing config files rather than developing one completely from the scratch.
# Immunity Loss Model
## About
The model uses daily time steps to simulate the impact of detected and undetected infections and vaccinations on the immunization level of a countries population or a sub-region (it was originally developed for federal-states in Austria).

The simulation initializes one agent for X inhabitants, with arbitrary scale X, of the country/region and loads vaccination and case data to distribute daily cases and vaccinations on them. It hereby iterates daily and selects suitable agents for the infections and vaccinations. 

Core of the model is the immunization and immunity loss process triggered by selecting an agent. The model uses an immunization-source/immunization-target matrix to decide whether and for how long an immunization event (e.g. recovery from a specific variant or a specific vaccination dose) renders the agent immune against a certain observable (e.g. infection with a certain variant or hospitalization).

The immunization level, vice versa, is resposible for whether an agent is rendered "suitable" for being selected in the distribution process for infections.

The model output is given by the time-series of all immune agents against the specified immunization-target.

### Kaplan Meier Estimation

Besides offering the model logic to determine the immunization level, the repository also includes a simple mechanism to fit measured effectiveness data from cohort studies to Kaplan Meier survival curves with user-specified survival distributions. This way, model parameters can not only be specified directly but estimated from e.g. published studies.

## Usage
### Requirements
The code was developed with Python 3.9.2. Moreover, the following toolboxes must be installed (with the version used for code development)

- scipy (1.8.9)
- numpy (1.20.1)
- matplotlib (3.3.4)
- lifelines (0.27.0)

Backwards compatibility with earlier Python 3 versions or earlier versions of the toolboxes might be given up to a certain extent, but is not tested yet. The package lifelines is used for Kaplan-Meier fitting and can be omitted, if all distribution parameters are known in advance.

## Run the Program
### Run Script
The model is run using the corresponding `run.py` script with path to the config file as runtime argument. E.g.
```
python3 run.py config_base.json
```
The simulation runs automatically and generates reproducible results in the corresponding folder.
### Config File(s)
The files `config_....json` contain all relevant input to the simulation model including model parameters and paths to input files. Many fields within the config file are rather self explanatory, some of them require specific explanation

| field | structure | interpretation |
| :--- | :--- | :------------ |
| scenario | string \[a-zA-Z0-9_\] | Identifyer for the scenario |
| seed | int | Seed for the pseudo-random-number-generator (Mersenne Twister) |
| scale | decimal | Fraction by which factor the real population is scaled in the model. We recommend to run the model with at least 50000 agents to get stable results |
| t0/tend | YYYY-mm-dd | Start and enddate of the simulation. Note, that it is crucial, that all relevant prior infections are included in the simulation timespan to get a complete picture. So we advise to always start the simulation with the very fist confirmed infection |
| detectionProbability | {YYYY-mm-dd:decimal} | Fraction, how many actual infections are detected by the national surveillance system. Necessary to compute undetected infections. Since the detection rate parameter strongly varies with the availability of tests and general awareness, we implemented it as a linear spline interpolant between the specified points here. |
| plotPdfs | bool | If true, all result images are also printed as vector graphics (PDF). Takes longer. |
| plotFits | bool | If true, a matrix image of the used/fitted distributions is generated. Takes quite some time to plot|
| observables | {target:{cause:{immunizationParameters}}} | Core parameters of the immunization model since they specify whether and for how long an immunization *cause* leads to immunity against a certain *target*. See below for different *immunizatioParameters* options.|
| immunizationParameters:distribution | string | Identifyer to specify the distribution chosen to sample immunity waning. Various ones are already preimplemented (e.g. "weibull","exponential","lognormal","uniform",...). Their parametrization is always given by one scale parameter, typically the mean. All other parameters are hard-coded in `loss_sampler.py`. See there for all options.
| immunizationParameters:base/mean | decimal/decimal | To parametrize the model directly, one needs to specify base and mean values of the immunization process. The base value between 0 and 1 defines, how likely an immunization event leads to immunity at all. The mean value corresponds to the scale parameter of the defined distribution. The higher, the longer immunization is given on average. |
| immunizationParameters:values | list(\[int,int,decimal\]) | To parametrize the model using published effectiveness data and the described Kaplan Meier fitter, one needs to omit the mean and base fields and specify the value field instead. Each specified triple \[a,b,c\] defines the measured effectiveness c against the required target within a to b days after the immunization event.|
| immunizationParameters:source | String | Free comment field without any particular role in the simulation to note the source of the data. It is printed as footnotes into the fit-plot if performed. |
| vaccDelay | int | Number of days after the vaccination after which we assume the maximum likeliness of immunization. |
| vaccIntervals | list(int) | Recommended interval between the doses. Used within the distribution process of doses. |
| recoveryDelay | list(int) | Time after which we assume that an infected person whose infection is getting detected recovers. The individual recovery time is drawn at random from this list.|
| recoveryDelayUndet | list(int) | Same as before for undetected cases. We usually assume much shorter recovery times due to mild symptomatic.|
| detDelay | list(int) | Time between a person's infection and detection. The individual delay is drawn at random from this list.|
| filename...data | String | Path to the specific file.|
It is highly recommended to copy and modify a given config file rather than developing one from the scratch. The git repository contains a sample.

### Data
Together with the source code, the user also receives four files containing sample data from Austria to test the code. All data is gathered from open sources with CC BY-NC 4.0 or CC BY 4.0 license.
#### population_data.csv
contains the 2022-01-01 population of each federal-state of Austria. It was taken from Statistics Austria (direct link [https://www.statistik.at/statistiken/bevoelkerung-und-soziales/bevoelkerung/bevoelkerungsstand/bevoelkerung-zu-jahres-/-quartalsanfang], accessed 2023-06-02)

#### case_data.csv
contains a time-line of new confirmed SARS-CoV-2 cases for each federal-state in Austria. It was aggregated from `CovidFaelle_Timeline_GKZ.csv` which is part of the data-set, free for download at the AGES dashboard [https://covid19-dashboard.ages.at/] (accessed 2023-06-02).

#### vaccination_data.csv
contains a time-line of vaccinations against COVID-19 for each federal-state in Austria. It was aggregated from dataset *COVID-19: Zeitreihe der verabreichten Impfungen der Corona-Schutzimpfung* available on [https://www.data.gv.at/]. Direct link to dataset [https://www.data.gv.at/katalog/dataset/6475a5ce-d9a4-4a14-ac3e-58eadc25bb25] (accessed 2023-06-02).

#### variant_data.csv
contains a time-line of the SARS-CoV-2 variant split. It was created ourselves by smoothing the information on  [https://gisaid.org/] with logistic growth curves.


## License
The developers attribute the Creative Commons NonCommercial 4.0 International (CC BY-NC 4.0) license for the source code.
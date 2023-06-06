import plot_scripts
from case_numbers import CaseNumbers
from config import Config
from hospital_numbers import HospitalNumbers
from hospital_parameters import HospitalParameters
from hospital_sim import HospitalSim
from rate_factors import RateFactors


class Forecast:
    """
    Class to perform forecasts. Requires fitted parameters in the config instance
    I.e. config.parameters must be a 3 element float list
    """

    def __init__(self, config: Config) -> None:
        """
        Class to perform forecasts. Requires fitted parameters in the config instance
        I.e. config.parameters must be a 3 element float list
        :param config: config instance
        """
        self.config = config

    def forecast(self) -> dict[str, float]:
        """
        Performs the forecast for all columns/scenarios specified in the config
        :return: dict object with 'time' and one occupancy timeline per scenario
        """
        Result = dict()
        caseNumbers = CaseNumbers(self.config)
        hospNumbers = HospitalNumbers(self.config)
        rateFactors = RateFactors(self.config)
        for i in range(self.config.get_column_number()):
            params = HospitalParameters()
            params.set(self.config.get_parameters(i))
            sim = HospitalSim(caseNumbers.get_cases(i), params, self.config.get_admission_delay_distribution(i),
                              self.config.get_stay_delay_distribution(i), rateFactors.get_factors(i))
            beds, admissions, releases = sim.run(self.config.get_start_transient_day(),
                                                 self.config.get_end_forecast_day(), self.config.get_forecast_day(),
                                                 hospNumbers.get_value(i, self.config.get_forecast_day()))
            Result[i] = beds.get_values()
            Result['time'] = beds.get_times()
            plot_scripts.plot_result(self.config, hospNumbers.get_beds(i), beds, i,
                                     self.config.get_columns_hospitalized()[i])
        return Result

from enum import Enum

class EventType(Enum):
    """
    Enum for discrete event simulation
    """
    StartUndetActive = 1
    EndUndetActive = 2
    StartDetActive = 3
    EndDetActive = 4
    StartImmune = 5
    EndImmune = 6
    StartVaccinated = 7
    SwitchUndetDet = 8

class Person:
    def __init__(self,index):
        """
        Class for individual in simulation
        :param index: unique id of the person
        """
        self.id = index #unique id
        self.immune = dict() #person is immune against specific observables
        self.immDate = dict()  # day of immunization
        self.lossDate = dict()  # day of immunity loss
        self.vacc = 0 #number of vaccine shots
        self.conf = False #person is confirmed case or not
        self.active = False #person is currently active case
        self.rec = False #person is recovered
        self.recDate = None #day of recovery
        self.vaccDate = None #day of vaccination
        self.infDate = None #day of infection
        self.confDate = None #day of positive test
        self.variant = None
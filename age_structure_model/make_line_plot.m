function [] = make_line_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal)
%Displays, how well the simulation output was fit to the reference data
%   SCENARIO   -> (string) simulation scenario
%   T0         -> (datetime) start date
%   DAYS       -> (int) number of days
%   POPAUSTRIA -> ([int]) population
%   ageFunSimINon -> (@(t,x)) simulated I compartment for non vaccinated
%   ageFunSimIVacc -> (@(t,x)) simulated I compartment for vaccinated
%   IReal      -> ([double]) reference I comparment

Tsolnew = (0:DAYS)';
agevec = (0:99);
figure(position=[100,100,1000,700]);
hold on;
set(gca(),'TickLabelInterpreter','latex') 
values = zeros(length(Tsolnew),length(agevec));
for i = 1:length(Tsolnew)
    fun = @(a) ageFunSimIAll(Tsolnew(i),a);
    for j=1:length(agevec)
        values(i,j) = fun(agevec(j));
    end
end
count = sum(values,2);
plot(Tsolnew,count);
count2 = sum(IReal,2);
plot(Tsolnew,count2,'r');
legend({'I compartment simulation','active cases data'},'Interpreter','latex');
set(gca(),'TickLabelInterpreter','latex');
savefig(['results/fitcases_',SCENARIO,'.fig']);
end
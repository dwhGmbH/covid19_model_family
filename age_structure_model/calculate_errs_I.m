function [errs] = calculate_errs_I(SCENARIO,T0,DAYS,POP,ageFunSimIAll,IReal)
%Computes error between simulation result ageFunSimIAll and the reference IReal
%   SCENARIO   -> (string) simulation scenario
%   T0         -> (datetime) start date
%   DAYS       -> (int) number of days
%   POPAUSTRIA -> ([int]) population
%   ageFunSimIAll -> (@(t,x)) sum of both simulated I compartments
%   IReal      -> ([double]) reference I comparment

Tsolnew = (0:DAYS)';
agevec = (0:99);
values = zeros(length(Tsolnew),length(agevec));
for i = 1:length(Tsolnew)
    fun = @(a) ageFunSimIAll(Tsolnew(i),a);
    for j=1:length(agevec)
        values(i,j) = fun(agevec(j));
    end
end
count = sum(values,2);
count2 = sum(IReal,2);
errs = (count-count2);
end

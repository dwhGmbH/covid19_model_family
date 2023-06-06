function [] = make_surf_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal)
%Plots age structure and time of the simulation output as 3D surface
%   SCENARIO   -> (string) simulation scenario
%   T0         -> (datetime) start date
%   DAYS       -> (int) number of days
%   POPAUSTRIA -> ([int]) population
%   ageFunSimINon -> (@(t,x)) simulated I compartment for non vaccinated
%   ageFunSimIVacc -> (@(t,x)) simulated I compartment for vaccinated
%   IReal      -> ([double]) reference I comparment

figure(position=[100,100,1400,700]);
Tsolnew = (0:DAYS)';
agevec = (0:99);
[XX,YY] = meshgrid(agevec,Tsolnew);
values = zeros(length(Tsolnew),length(agevec));
for i = 1:length(Tsolnew)
    fun = @(a) ageFunSimIAll(Tsolnew(i),a);
    for j=1:length(agevec)
        values(i,j) = fun(agevec(j));
    end
end
valuesNormed = zeros(length(Tsolnew),length(agevec));
for i = 1:length(Tsolnew)
    if sum(values(i,:))>0
        valuesNormed(i,:)=values(i,:)/sum(values(i,:));
    else
        valuesNormed(i,:)=values(i,:);
    end
end
surf(XX,YY,valuesNormed);
xlabel('ageclass');
ylabel('time');
set(gca(),'TickLabelInterpreter','latex');
savefig(['results/surface_',SCENARIO,'.fig']);
end


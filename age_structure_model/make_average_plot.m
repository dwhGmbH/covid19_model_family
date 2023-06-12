% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Copyrighht (C) 2023 dwh GmbH - All Rights Reserved
% You may use, distribute and modify this code under the 
% terms of the MIT license.
% 
% You should have received a copy of the MIT license with
% this file. If not, please write to: 
% martin.bicher@dwh.at or visit 
% https://github.com/dwhGmbH/covid19_model_family/blob/main/LICENSE.txt
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [] = make_average_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal)
%Plots how the age-percentiles of the infectious persons changed in the
%course of the disease wave
%   SCENARIO   -> (string) simulation scenario
%   T0         -> (datetime) start date
%   DAYS       -> (int) number of days
%   POP        -> ([int]) population
%   ageFunSimIAll -> (@(t,x)) sum of both simulated I compartments
%   IReal      -> ([double]) reference I compartment
cmap2 = @(quantity) summer(quantity);

percs = [5,10,15,25,35,50,65,75,85,90,95];

Tsolnew = (0:DAYS)';
figure(position=[100,100,1000,700]);

for ind = 1:2
    percCurves = zeros(length(percs),length(Tsolnew));
    if ind == 1
        subplot(1,2,1);
        title('simulation result');
        for i = 1:length(Tsolnew)
            fun = @(a) ageFunSimIAll(Tsolnew(i),a);
            sm = 0;
            for j=0:0.1:100
                sm = sm+fun(j);
            end
            sum2 = 0;
            pi = 1;
            for j=0:0.1:100
                sum2 = sum2+fun(j)/sm;
                if sum2>(percs(pi)/100)
                   percCurves(pi,i)=j;
                   pi = pi+1;
                   if pi>length(percs)
                       break;
                   end
                end
            end
        end
    else
        subplot(1,2,2);
        title('measured data');
        for i = 1:length(Tsolnew)
            dist = IReal(i,:);
            width = 100/length(dist);
            sm = sum(dist);
            pi = 1;
            sum2 = 0;
            for j = 1:length(dist)
                sum21 = sum2+dist(j)/sm;
                while sum21>(percs(pi)/100)
                    age =  width*(j-1)+width*(percs(pi)/100-sum2)/(sum21-sum2);
                    percCurves(pi,i)=age;
                    pi=pi+1;
                    if pi>length(percs)
                       break;
                    end
                end
                sum2 = sum21;
                if pi>length(percs)
                    break;
                end
            end
        end
    end
    hold on;
    lg = {};
    
    half = floor(length(percs)/2);
    mp = cmap2(half);
    for i = 1:half
        j=length(percs)-i+1;
        fill([Tsolnew;Tsolnew(end:-1:1)],[percCurves(i,1:end),percCurves(j,end:-1:1)],mp(i,:),'edgecolor','none');
        lg{end+1}=['$',num2str(percs(j)-percs(i)),'\%$ CI'];
    end
    plot(Tsolnew,percCurves(half+1,1:end),'k');
    lg{end+1}='median';
    legend(lg,'Interpreter','latex');
    xlim([Tsolnew(1),Tsolnew(end)]);
    xlabel('days');
    ylim([0,100]);
    ylabel('age');
    set(gca(),'TickLabelInterpreter','latex');
end
savefig(['results/averageAge_',SCENARIO,'.fig']);
end


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

function [] = make_arrow_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal)
%Plots initial and final state of the age distribution as well as arrows
%between them to indicate how the structure of the infectious cases
%changed over time
%   SCENARIO   -> (string) simulation scenario
%   T0         -> (datetime) start date
%   DAYS       -> (int) number of days
%   POP        -> ([int]) population
%   ageFunSimIAll -> (@(t,x)) sum of both simulated I compartments
%   IReal      -> ([double]) reference I compartment

%% setup plots
cmap = @(quantity) autumn(quantity);
TOTPOP = sum(POP);

figure(position=[100,100,1000,400]);
Tsolnew = (0:DAYS)';
for ind = 1:2
    if ind == 1
        agevec = (0:99);
        subplot(1,2,1);
        title([SCENARIONAME,' - Simulation'])
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
        offset = 0.5;
    else
        subplot(1,2,2);
        title([SCENARIONAME,' - Measured Data'])
        agevec = (0:5:99);
        INormedReal = IReal;
        for i = 1:size(IReal,1)
            INormedReal(i,:)=IReal(i,:)/sum(IReal(i,:));
        end
        valuesNormed = INormedReal/5; %/5 since we have 5-year age classes
        offset = 2.5;
    end
    hold on;
    bar(0.5+(0:100),POP/TOTPOP,1.0,'EdgeColor','none');
    
    mp = cmap(2);
    xv = [agevec,agevec(end)+2*offset];
    xv = [xv;xv];
    xv = xv(:);
    xv = xv(2:end-1);
    
    col = mp(1,:);
    yv = valuesNormed(1,:);
    yv = [yv;yv];
    yv=yv(:);
    plot(xv,yv,'color',col,'LineWidth',2);
    %col = mp(2,:);
    %s = floor(size(valuesNormed,1)/2);
    %yvx = valuesNormed(s,:);
    %yvx = [yvx;yvx];
    %yvx=yvx(:);
    %plot(xv,yvx,'color',col,'LineWidth',2);
    col = mp(2,:);
    yv2 = valuesNormed(end,:);
    yv2 = [yv2;yv2];
    yv2=yv2(:);
    plot(xv,yv2,'color',col,'LineWidth',2);
    
    legend({'population distribution',['case distribution ',char(T0)],['case distribution ',char(T0+DAYS)]},'Interpreter','latex');
    xlabel('ageclasses')
    %xtks = {}; for i = agevec xtks{end+1}=['[',num2str(i),'-',num2str(i+4),']']; end
    %xticks(2.5+(agevec));
    %xticklabels(xtks);
    ylabel('fraction');
    yl = ylim();
    ylim([0,yl(2)]);
    
    if ind == 1
        for i = 1:5:length(agevec)
            draw_arrow([offset+agevec(i),valuesNormed(1,i)],[offset+agevec(i),valuesNormed(end,i)]);
        end
    else
        for i = 1:length(agevec)
            draw_arrow([offset+agevec(i),valuesNormed(1,i)],[offset+agevec(i),valuesNormed(end,i)]);
        end
    end
    set(gca(),'TickLabelInterpreter','latex') 
end
savefig(['results/distributionchange_',SCENARIO,'.fig']);

function [] = draw_arrow(P1,P2)
Pos = get(gca(),'position');
Xlim = xlim();
Ylim = ylim();
X_conv(1)=Pos(1)+(Pos(3))/(Xlim(2)-Xlim(1))*(P1(1)-Xlim(1));
X_conv(2)=Pos(1)+(Pos(3))/(Xlim(2)-Xlim(1))*(P2(1)-Xlim(1));
Y_conv(1)=Pos(2)+(Pos(4))/(Ylim(2)-Ylim(1))*(P1(2)-Ylim(1));
Y_conv(2)=Pos(2)+(Pos(4))/(Ylim(2)-Ylim(1))*(P2(2)-Ylim(1));
annotation('arrow', X_conv, Y_conv);
end
end


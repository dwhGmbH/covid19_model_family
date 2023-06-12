% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Copyrighht (C) 2023 Martin Bicher - All Rights Reserved
% You may use, distribute and modify this code under the 
% terms of the MIT license.
% 
% You should have received a copy of the MIT license with
% this file. If not, please write to: 
% martin.bicher@tuwien.ac.at or visit 
% https://github.com/dwhGmbH/covid19_model_family/LICENSE.txt
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [] = make_heatmap_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal)
%Plots a age-time heatmap of simulation result and the validation reference 
%for the infectious individuals
%   SCENARIO   -> (string) simulation scenario
%   T0         -> (datetime) start date
%   DAYS       -> (int) number of days
%   POPAUSTRIA -> ([int]) population
%   ageFunSimINon -> (@(t,x)) simulated I compartment for non vaccinated
%   ageFunSimIVacc -> (@(t,x)) simulated I compartment for vaccinated
%   IReal      -> ([double]) reference I comparment
cmap2 = @(quantity) jet(quantity);

width = 100/size(IReal,2);
agevec = (0:width:100-width);
Tsolnew = (0:DAYS)';
figure(position=[100,100,900,500]);
t = tiledlayout(1,9, 'Padding', 'none', 'TileSpacing', 'compact'); 
t.Title.String = SCENARIONAME;
t.Title.Interpreter = 'latex';
for ind = 1:2
    if ind == 1
        nexttile([1,4]);
        values = zeros(length(Tsolnew),length(agevec));
        for i = 1:length(Tsolnew)
            fun = @(a) ageFunSimIAll(Tsolnew(i),a);
            for j=1:length(agevec)
                values(i,j) = 0;
                for k = 0:9 %integrate over ageclass
                    values(i,j) = values(i,j) + 1/10*fun(agevec(j)+k/10*width);
                end
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
    else
        nexttile([1,4]);
        INormedReal = IReal;
        for i = 1:size(IReal,1)
            INormedReal(i,:)=IReal(i,:)/sum(IReal(i,:));
        end
        valuesNormed = INormedReal;
    end
    ba = bar(Tsolnew,valuesNormed,1.0,'stacked','FaceColor','flat');
    mp = cmap2(length(ba));
    for i = 1:length(ba)
        ba(i).CData = mp(i,:);
    end
    ylim([0,1])
    xlim([Tsolnew(1),Tsolnew(end)]);
    if ind == 1
        ylabel('fraction of active cases per ageclass');
    end
    xlabel('days');
    set(gca(),'TickLabelInterpreter','latex');
    set(gca(),'FontSize',10);
    if ind==1
        title('simulation result','FontSize', 11);
    else
        title('case data','FontSize', 11);
    end
end
nexttile();
hold on
for i = 1:size(mp,1)
   fill([0,0,1,1,0],[i-1,i,i,i-1,i-1],mp(i,:));
   if sum(mp(i,1:3))>1.5
       c = 'k';
   else
       c = 'w';
   end
   text(0.5,i-0.5,sprintf('%d-%d',width*(i-1),width*(i)-1),'color',c,'HorizontalAlignment','center','VerticalAlignment', 'middle');
end
ylim([0,size(mp,1)])
xlim([0,1])
axis off;

savefig(['results/stacked_',SCENARIO,'.fig']);

h = gcf();
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
exportgraphics(h,['results/stacked_',SCENARIO,'.pdf'],'ContentType','vector');
end


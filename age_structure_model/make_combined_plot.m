function [] = make_combined_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimINone,ageFunSimIVacc,IReal)
%Plots a number of different views into one compact figure
%between
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
figure(position=[100,100,800,600]);

t = tiledlayout(2,10, 'Padding', 'none', 'TileSpacing','compact'); 
t.Title.String = SCENARIONAME;
t.Title.Interpreter = 'latex';

nexttile([2,3]);
Tsolnew2 = (0:0.1:DAYS)';
values = zeros(length(Tsolnew2),length(agevec));
for i = 1:length(Tsolnew2)
    fun = @(a) ageFunSimINone(Tsolnew2(i),a);
    values(i,1)=0;
    for j=0.5:1.0:99.5
        values(i,1) = values(i,1) + fun(j);
    end
    fun = @(a) ageFunSimIVacc(Tsolnew2(i),a);
    values(i,2)=0;
    for j=0.5:1.0:99.5
        values(i,2) = values(i,2) + fun(j);
    end
end
hold on;
ba = bar(Tsolnew2,values,1.0,'stacked','FaceColor','flat','EdgeColor','flat');
ba(1).CData = [0.4,0.4,0.4];
ba(2).CData = [0.8,0.8,0.8];
pl1 = plot(Tsolnew2,sum(values,2),'k');
count2 = sum(IReal,2);
pl2 = plot(Tsolnew,count2,'r.');
legend([pl1,pl2,ba(1),ba(2)],{'sim result','data','vaccinated','unvaccinated'},'Location','south');
xlim([Tsolnew(1),Tsolnew(end)]);
ylabel('active cases');
xlabel('days');
set(gca(),'TickLabelInterpreter','latex');
set(gca(),'FontSize',10);

for ind = 1:2
    if ind == 1
        nexttile([1,3]);
        values = zeros(length(Tsolnew),length(agevec));
        for i = 1:length(Tsolnew)
            fun = @(a) ageFunSimIVacc(Tsolnew(i),a) + ageFunSimINone(Tsolnew(i),a);
            for j=2:length(agevec)
                values(i,j) = 0;
                for k = 0:width-1 %integrate over ageclass
                    values(i,j) = values(i,j) + fun(agevec(j)+k);
                end
            end
            values(i,1)= 0.02/(1-0.02)*sum(values(i,2:end));
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
        nexttile([1,3]);
        INormedReal = IReal;
        for i = 1:size(IReal,1)
            INormedReal(i,:)=IReal(i,:)/sum(IReal(i,:));
        end
        valuesNormed = INormedReal;
    end
    mp = makebar(Tsolnew,valuesNormed,cmap2);
    if ind == 1
        ylabel('fraction of active cases per ageclass');
    end
    set(gca(),'TickLabelInterpreter','latex');
    set(gca(),'FontSize',10);
    if ind==1
        title('simulation result overall','FontSize', 11);
    else
        title('case data overall','FontSize', 11);
    end
end
nexttile([2,1]);
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

%{
nexttile([1,3]);
values = zeros(length(Tsolnew),length(agevec));
for i = 1:length(Tsolnew)
    fun = @(a) ageFunSimINone(Tsolnew(i),a);
    values(i,1)=0;
    for j=0.5:1.0:99.5
        values(i,1) = values(i,1) + fun(j);
    end
    fun = @(a) ageFunSimIVacc(Tsolnew(i),a);
    values(i,2)=0;
    for j=0.5:1.0:99.5
        values(i,2) = values(i,2) + fun(j);
    end
    sm = sum(values(i,:));
    values(i,1) = values(i,1)/sm;
    values(i,2) = values(i,2)/sm;
end

ba = bar(Tsolnew,values,1.0,'stacked','FaceColor','flat','EdgeColor','flat');
ba(1).CData = [0.4,0.4,0.4];
ba(2).CData = [0.8,0.8,0.8];
xlim([Tsolnew(1),Tsolnew(2)]);
ylim([0,1]);
ylabel('fraction of unvaccinated cases');
xlabel('days');
set(gca(),'TickLabelInterpreter','latex');
set(gca(),'FontSize',10);
%}

for ind = 1:2
    if ind == 1
        nexttile([1,3]);
        values = zeros(length(Tsolnew),length(agevec));
        for i = 1:length(Tsolnew)
            fun = @(a) ageFunSimINone(Tsolnew(i),a);
            for j=1:length(agevec)
                values(i,j) = 0;
                for k = 0:width-1 %integrate over ageclass
                    values(i,j) = values(i,j) + fun(agevec(j)+k);
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
        nexttile([1,3]);
        values = zeros(length(Tsolnew),length(agevec));
        for i = 1:length(Tsolnew)
            fun = @(a) ageFunSimIVacc(Tsolnew(i),a);
            for j=1:length(agevec)
                values(i,j) = 0;
                for k = 0:width-1 %integrate over ageclass
                    values(i,j) = values(i,j) + fun(agevec(j)+k);
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
    end
    mp =  makebar(Tsolnew,valuesNormed,cmap2);
    if ind == 1
        ylabel('fraction of active cases per ageclass');
    end
    xlabel('days');
    set(gca(),'TickLabelInterpreter','latex');
    set(gca(),'FontSize',10);
    if ind==1
        title('simulation result non-vaccinated','FontSize', 11);
    else
        title('simulation result vaccinated','FontSize', 11);
    end
end

savefig(['results/stacked_combined_2_',SCENARIO,'.fig']);

h = gcf();
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
exportgraphics(h,['results/stacked_combined_2_',SCENARIO,'.pdf'],'ContentType','vector');

    function[mp] = makebar(Tsolnew,valuesNormed,cmap2)
        ba = bar(Tsolnew,valuesNormed,1.0,'stacked','FaceColor','flat','EdgeColor','flat');
        mp = cmap2(length(ba));
        for i = 1:length(ba)
            ba(i).CData = mp(i,:);
        end
        hold on;
        ys = zeros(2*size(valuesNormed,1),1);
        for i = 1:size(valuesNormed,2)
            y = [valuesNormed(:,i)';valuesNormed(:,i)'];
            x = [Tsolnew';Tsolnew'];
            ys=ys+y(:);
            x=x(:);
            x=[x(2:end)-0.5;x(end)+0.5];
            plot(x(:),ys(:),'k');
        end
        ylim([0,1]);
        xlim([Tsolnew(1),Tsolnew(end)]);
    end
end


%% PlotDeepeningCurves
% Plots the depth of the leading edge (+-SEM) of mutants/ablations and make
% Welch tests for each timepoint to compare with control condition

% Written in 2021 by Aurélien Villedieu

clear all
close all

%% Parameters

% Need to be adjusted by the user to run //////////////////////////////////
% Input folder
Path='D:\NeckDeepeningQuantification\Data\Values'; % Needs to end with 'NeckDeepeningQuantification\Data\Values'


% No need to be adjusted by the user to run ///////////////////////////////
% Names of the conditions
Conditions={'DfdControl' 'EcadGFPControl'...
    'Dfd2daysRokRNAi' 'Dfd2dayssqhRNAi' 'Dfd2daysMbsRNAi'...
    'DfdDfdRNAi' 'DysMutant' 'DgMutant'...
    'DfdToll8RNAi' 'Tollo' 'DysDfdTolloRNAi' 'DfdDgRNAi'...
    'DfdDiap' 'DoubleAblation' 'DoubleAblationLate'...
    'NoFlattening' 'PerpendicularAblations' 'PerpendicularAblationCurved'};

% Associated colors
blue=[58/255,67/255,186/255];
red=[208/255,49/255,45/255];
green=[59/255,177/255,67/255];
orange=[237/255,112/255,20/255];
purple=[163/255,44/255,196/255];
pink=[255/255,22/255,149/255];
peanut=[121/255,92/255,52/255];
grey=[108/255,98/255,109/255];
seaweed=[53/255,74/255,33/255];
sky=[98/255,197/255,218/255];
silver=[173/255,173/255,199/255];
magenta=[161/255,5/255,89/255];
seafoam=[60/255,236/255,151/255];
ColorsConditions={blue' blue'...
    red' orange' purple'...
    peanut' green'  seaweed'...
    grey' magenta'  seafoam'  green'...
    silver' [163/255,44/255,196/255]' [246/255,154/255,205/255]'...
    [21/255,30/255,61/255]' [121/255,92/255,52/255]' [252/255,161/255,114/255]'};

% Associated names
Names={'Dfd-GAL4 Control' 'wt'...
    '\itDfd>Rok^{RNAi}' '\itDfd>sqh^{RNAi}' '\itDfd>Mbs^{RNAi}'...
    '\itDfd>Dfd^{RNAi}' '\itDys^{mutant}' '\itDg^{mutant}'...
    '\itDfd>Toll8^{RNAi}' 'Toll8^{mutant}' '\itDys^{-/-}Dfd>Toll8^{RNAi}' '\itDfd>Dg^{RNAi}'...
    '\itDfd>Diap1' 'Ablations_{parallel} 17hAPF' 'Ablations_{parallel} 21hAPF'...
    'Control_{no flattening}' 'Ablations_{perpendicular}' 'Ablation_{perpendicular no flattening}'};

% Which conditions do we plot together? Select by ID of the condition
Plots={[1 3 4 5] [1 6 9] [2 7 8]...
    [2 14 15] [2 16 17 18] [1 13] [2 10] [1 6 7 9 11] [1 12]};
% To which control should we compare? Choose nan if no comparison, and put
% the ID of the control in the list if comparison needed
Controls={[nan 1 1 1] [nan 1 1] [nan 1 1]...
    [nan 1 1] [nan nan 1 2] [nan 1] [nan 1] [nan 1 1 1] [nan 1]};
% Associated names with the groups of conditions
TitlePlots={'DfdMyosin' 'UpstreamRegulatorsDfdGAL4' 'UpstreamRegulatorsMutant'...
    'ParallelAblations' 'PerpendicularAblations' 'ApoptosisInhibition' 'TolloMutant' 'DoubleMutant' 'DfdDgRNAi'};

% Axes parameters
tmin=14;
tmax=28;
tstep=0.25;

xmin=-400;
xmax=+400;
xstep=10;

% PValue bar height (µm/h)
height=1.5;

% Parameter for ML averaging
step=8; % 8 corresponds to an average of PositionML from -240% to +240%

%% Loading data
for condition=1:length(Conditions)
    load([Path filesep Conditions{condition} '(Curvatures)'],'Curvatures');
    load([Path filesep Conditions{condition} '(Speeds)'],'Speeds');
    load([Path filesep Conditions{condition} '(Depths)'],'Depths');
    PoolCurvatures{condition}=Curvatures;
    PoolSpeeds{condition}=Speeds;
    PoolDepths{condition}=Depths;
end

%% Calculate depth curves

% Average depth value along ML axis ///////////////////////////////////////
for condition=1:length(Conditions)
    Depths=PoolDepths{condition};
    temp2=[];
    for animal=1:size(Depths,3)
        temp=Depths(:,:,animal);
        % First, average left and right sides
        Left=temp(1:41,:);
        Right=temp(41:end,:);
        Right=flipud(Right);
        LeftRight=nanmean(cat(3,Left,Right),3);
        % Then, average for Position ML from -240% to 240%
        temp2(:,animal)=nanmean(LeftRight(41-3*step:41,:),1);
    end
    DepthsAverageML{condition}=temp2;
end


% Set Depth(t0=15.75hAPF) to 0 to remove effect of initial drifting
for condition=1:length(Conditions)
    Curves=DepthsAverageML{condition};
    for animal=1:size(Curves,2)
        Curve=Curves(:,animal);
        % Detecting minimal depth and setting it to 0
        indexmini=(16-tmin)/tstep;
        if isnan(Curve(indexmini))
            Curve=Curve;
        else
            Curve=Curve-Curve(indexmini);
        end
        DepthsAverageML{condition}(:,animal)=Curve;
    end
end

% % OPTIONAL: Visualization of all curves for a condition
% condition=3; % Pick the condition you want to visualize
% for Animal=1:size(DepthsAverageML{condition},2)
%     figure(Animal)
%     for animal=1:size(DepthsAverageML{condition},2)
%         plot(tmin:tstep:tmax,DepthsAverageML{condition}(:,animal),'LineWidth',2,'Color','black')
%         hold on
%     end
%     for animal=1:size(DepthsAverageML{1},2)
%        plot(tmin:tstep:tmax,DepthsAverageML{1}(:,animal),'LineWidth',2,'Color','blue')
%     end
%     plot(tmin:tstep:tmax,DepthsAverageML{condition}(:,Animal),'LineWidth',3,'Color','red')
%     hold off
%     grid on
%     grid minor
% end

% Curves calculation
AverageDepth=[];
SemDepth=[];
for condition=1:length(Conditions)
    Map=DepthsAverageML{condition};
    AverageSpeed=nan(1,size(Map,1));
    StdSpeed=nan(1,size(Map,1));
    for x=1:size(Map,1)
        Vect=Map(x,:);
        index=find(~isnan(Vect));
        if length(index)>=3
            AverageSpeed(x)=mean(Vect(index));
            StdSpeed(x)=std(Vect(index))./sqrt(length(index));
        end
    end
    AverageDepth(:,condition)=AverageSpeed;
    SemDepth(:,condition)=StdSpeed;
end


%% Plot

close all

for p=1:length(Plots)
    
    figure(p)

    % Load the info of the group
    Group=Plots{p};
    Colors=[];
    for condition=1:length(Group)
        Colors=cat(2,Colors,ColorsConditions{Group(condition)});
    end
    Colors=Colors';
    % Plot the depths
    hold on
    for g=1:length(Group)
        condition=Group(g);
        plot(16:tstep:24,AverageDepth(9:41,condition),'Color',Colors(g,:),'LineWidth',2)
    end
    % Plot the sem as a filled area
    for g=1:length(Group)
        condition=Group(g);
        % Find depth(t) boundaries (some timings may not be sampled)
        Vect=AverageDepth(9:41,condition);
        index=find(~isnan(Vect));
        Fork=[min(index):max(index)];
        % Plotting the area
        BinTime=16:tstep:24;
        BinTime=BinTime(Fork);
        x2=[BinTime,fliplr(BinTime)];
        Std=SemDepth(9:41,condition);
        inBetween=[(Vect(Fork)+Std(Fork))', fliplr((Vect(Fork)-Std(Fork))')];
        h=fill(x2,inBetween,Colors(g,:),'LineStyle','none');
        set(h,'facealpha',.25)
    end
    hold off
    
    ylabel('Depth_{leading edge} (µm)')
    xlabel('Time (hAPF)')
    xlim([16 24])
    %grid on
    ylim([-5-height*sum(~isnan(Controls{p})) 45])
    set(gca, 'YDir','reverse')
    set(gcf,'Position',[50, 50, 500, 400]);
    % Pvalue bars
    hold on
    NumberTests=sum(~isnan(Controls{p}));
    for testing=1:NumberTests
        PValue=[];
        % Calculation of PValue
        Temp=find(~isnan(Controls{p}));
        cond=Temp(testing);
        condition=Group(cond);
        Control=Controls{p}(cond);
        BinTime=16:tstep:24;
        for t=1:length(BinTime)
            pix=(BinTime(t)-tmin)/tstep+1;
            Vect1=squeeze(DepthsAverageML{Group(Control)}(pix,:));
            Vect2=squeeze(DepthsAverageML{condition}(pix,:));
            if sum(~isnan(Vect1))>2 && sum(~isnan(Vect2))>2
                [h,pval]=ttest2(Vect1(~isnan(Vect1)),Vect2(~isnan(Vect2)),'VarType','unequal');
                PValue(t)=pval;
            else
                PValue(t)=nan;
            end
        end
        
        % Print PValue bar with increasing hatch, pooling similar hatched
        % regions together
        % Converting PValue into PValue code (0ns, 1*, 2**, 3***)
        PValueCode=[];
        PValueCode(PValue>0.05)=0;
        PValueCode(PValue<=0.05)=1;
        PValueCode(PValue<=0.01)=2;
        % Initialization
        Temp1=PValueCode(1);
        Pool=1;
        count=2;
        Fill=[-5-height*(NumberTests-testing+1) -5-height*(NumberTests-testing) -5-height*(NumberTests-testing) -5-height*(NumberTests-testing+1)];
        
        while count<=length(PValueCode)
            Temp2=PValueCode(count);
            if Temp1==Temp2 % If 2 successive time have the same PValue code
                % We pool with the next timing
                Pool=cat(1,Pool,count);
            elseif count~=length(PValueCode) % If the timepoint PValue code is different from previous one AND it's not the last timepoint
                % We plot previous PValue segment
                if PValueCode(count-1)==2
                    cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,Colors(cond,:),'EdgeColor','none');
                elseif PValueCode(count-1)==1
                    cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                    hatch(cb,-45,Colors(cond,:),'-',3,1);
                elseif PValueCode(count-1)==0
                    cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                end
                % We initialize a new loop
                Pool=count;
            end
            if count==length(PValueCode)
                % We plot the last PValue segment
                Pool=cat(1,Pool,count);
                if PValueCode(count)==2
                    cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,Colors(cond,:),'EdgeColor','none');
                elseif PValueCode(count)==1
                    cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                    hatch(cb,-45,Colors(cond,:),'-',3,1);
                elseif PValueCode(count)==0
                    cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                end
            end
            count=count+1;
            Temp1=Temp2;
        end
    end
    % Make the countours of the PValue bar for the condition
    for cond=1:NumberTests
        Temp=find(~isnan(Controls{p}));
        condition=Temp(cond);
        %rectangle('Position',[BinTime(1) -5-height*(NumberTests-cond+1) BinTime(end)-BinTime(1) -5-height*(cond-1)-(-5-height*(cond))],'EdgeColor',Colors(condition,:),'LineWidth',1.5,'FaceColor','none');
        rectangle('Position',[BinTime(1) -5-height*(NumberTests-cond+1) BinTime(end)-BinTime(1) -5-height*(cond-1)-(-5-height*(cond))],'EdgeColor','black','LineWidth',1,'FaceColor','none');
    end
    hold off
    legend(Names{Group},'Location','best')
    set(findall(gcf,'-property','FontSize'),'FontSize',13)
    set(0, 'DefaultFigureRenderer', 'painters');
    yticks(0:10:45);
    if p==6
        yticks(0:10:55);
        ylim([-5-height*sum(~isnan(Controls{p})) 55])
    end
    set(gcf,'Position',[50, 50, 400, 400]);

end

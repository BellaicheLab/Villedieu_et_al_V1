%% PloRecoilVelocities
% (i) Plot apical and basal recoil velocities as a function of time for all
% conditions
% (ii) Plot apical VS basal recoil velocities for wild type
% (iii) Plot apical and recoil velocities for all conditions for a given
% timepoint

clear all
close all


%% Parameters

% Need to be changed by the user //////////////////////////////////////////
% Folder where values are stored
Path='D:\RecoilVelocityWtAndMutants\Data\Values'; % Needs to end with 'RecoilVelocityWtAndMutants\Data\Values'
% /////////////////////////////////////////////////////////////////////////

% No need to be changed by the user //////////////////////////////////////
% Names of the conditions
Names={'Control' 'DfdGAL4Control'...
    'DfdRokRNAi' 'DfdsqhRNAi' 'DfdMbsRNAi'...
    'DfdDfdRNAi' 'DfdToll8RNAi' 'DysMutant' 'DgMutant'...
    'NonFlattened' 'ControlLateral' 'LateralAblated'};
% Names displayed in plots
LegendNames={'Control' '{\itDfd}-GAL4'...
    '{\itDfd}>{\itRok}^{RNAi}' '{\itDfd}>{\itsqh}^{RNAi}' '{\itDfd}>{\itMbs}^{RNAi}'...
    '{\itDfd}>{\itDfd}^{RNAi}' '{\itDfd}>{\itToll8}^{RNAi}' '{\itDys}^{mutant}' '{\itDg}^{mutant}'...
    'Non-flattened' 'Lateral' 'Ablated laterally'};
% Colors associated with conditions
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
ColorsSource=[blue' blue'...
    red' orange' purple'...
    peanut' grey' green' seaweed'...
    red' sky' red']';
% /////////////////////////////////////////////////////////////////////////

%% Load data
for condition=1:length(Names)
    Timing{condition}=csvread([Path filesep 'Timing(' Names{condition} ').csv']);
    Apical{condition}=csvread([Path filesep 'Apical(' Names{condition} ').csv']);
    Basal{condition}=csvread([Path filesep 'Basal(' Names{condition} ').csv']);
    
    % Identifying NaN
    Vect=Apical{condition};
    Vect(Vect==666)=nan;
    Apical{condition}=Vect;
    Vect=Basal{condition};
    Vect(Vect==666)=nan;
    Basal{condition}=Vect;  
end

%% Bin the data by timing

% Define time bins (in hAPF)
BinTime=14:0.25:24;
% Each bin is considered +/- step (in hAPF)
step=1;

% Calculate bins
for condition=1:length(Names)
    for t=1:length(BinTime)
        index=find(Timing{condition}<=BinTime(t)+step & Timing{condition}>=BinTime(t)-step);
        Covering(t)=length(index);
        if Covering(t)<2 % A time bin is considered only if it contains enough points
            ApicalBin{condition}(t)=nan;
            ApicalStd{condition}(t)=nan;
            BasalBin{condition}(t)=nan;
            BasalStd{condition}(t)=nan;            
        else
            Napical=length(find(Timing{condition}<=BinTime(t)+step & Timing{condition}>=BinTime(t)-step & ~isnan(Apical{condition})));
            Nbasal=length(find(Timing{condition}<=BinTime(t)+step & Timing{condition}>=BinTime(t)-step & ~isnan(Basal{condition})));
            ApicalBin{condition}(t)=nanmean(Apical{condition}(index));
            ApicalStd{condition}(t)=nanstd(Apical{condition}(index));
            ApicalPool{condition}{t}=Apical{condition}(index);
            BasalBin{condition}(t)=nanmean(Basal{condition}(index));
            BasalStd{condition}(t)=nanstd(Basal{condition}(index));
            BasalPool{condition}{t}=Basal{condition}(index);
        end
    end
end

% Count numbers of ablation per condition
Counts=[];
for condition=1:length(Names)
    Counts(condition,1)=length(find(~isnan(Apical{condition})));
    Counts(condition,2)=length(find(~isnan(Basal{condition})));
end


%% Plot wild type recoil velocities as a function of time

% PLOT1: Wild type ApicalRecoilVelocity as a function of time
figure(1)
set(gca,'YColor','blue')
plot(BinTime,ApicalBin{1},'Color','blue','LineWidth',2)
hold on
x2=[BinTime,fliplr(BinTime)];
inBetween=[ApicalBin{1}+ApicalStd{1}, fliplr(ApicalBin{1}-ApicalStd{1})];
h=fill(x2, inBetween, 'b','LineStyle','none');
set(h,'facealpha',.25)
hold off
ylabel('Apical recoil velocity (µm.sec^{-1})')
ylim([-0.1 3.25])
yticks(0:1:3)
xlim([13.5 24.5])
xlabel('Time (hAPF)')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])

% PLOT2: Wild type BasalRecoilVelocity as a function of time
figure(2)
set(gca,'YColor','magenta')
plot(BinTime,BasalBin{1},'Color','magenta','LineWidth',2)
hold on
x2=[BinTime,fliplr(BinTime)];
inBetween=[BasalBin{1}+BasalStd{1}, fliplr(BasalBin{1}-BasalStd{1})];
h=fill(x2, inBetween, 'magenta','LineStyle','none');
set(h,'facealpha',.25)
hold off
ylabel('Basal recoil velocity (µm.sec^{-1})')
ylim([-0.1 3.25])
yticks(0:1:3)
xlim([13.5 24.5])
xlabel('Time (hAPF)')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])


%% Plot wild type apical VS basal recoil velocities 

% PLOT3: Wild type apical VS basal recoil velocities color coded for time
figure(3)
temp=jet;
VectT=9:4:41;
hold on
for t=1:length(VectT)
    T=VectT(t);
    col=round(64*t/length(VectT));
    errorbar(ApicalBin{1}(T),BasalBin{1}(T),BasalStd{1}(T),BasalStd{1}(T),ApicalStd{1}(T),ApicalStd{1}(T),'Color',temp(col,:))
end
for t=1:length(VectT)
    T=VectT(t);
    col=round(64*t/length(VectT));
    plot(ApicalBin{1}(T),BasalBin{1}(T),'o','MarkerFaceColor',temp(col,:),'MarkerEdgeColor','black','MarkerSize',10)
end
xlabel('Apical recoil velocity (µm.sec^{-1})')
ylabel('Basal recoil velocity (µm.sec^{-1})')
xlim([-0.25 2.5])
ylim([0 3.25])
xticks(0:2)
yticks(0:3)
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])
mdl=fitlm(ApicalBin{1}(VectT),BasalBin{1}(VectT));
title(['R²=' num2str(round(mdl.Rsquared.Adjusted*100)/100)]);
line([0 2.25],mdl.Coefficients.Estimate(2)*[0 2.25]+mdl.Coefficients.Estimate(1),'Color','black','LineWidth',2)
hold off

%% Plot recoil velocities of the mutant conditions (and their associated control) as a function of time

% Vector associating each condition with its control
Pairs={[2 3] [2 4] [2 6] [2 7] [1 8] [1 9] [1 10] [1 11]};

% Statistics
PValuesApical=nan(length(BinTime),length(Pairs));
PValuesBasal=nan(length(BinTime),length(Pairs));
for pair=1:length(Pairs)
    Pair=Pairs{pair};
    % Apical recoils
    Data1=ApicalPool{Pair(1)};
    Data2=ApicalPool{Pair(2)};
    for t=1:length(BinTime)
        Vect1=Data1{t};
        Vect2=Data2{t};
        index1=find(~isnan(Vect1));
        index2=find(~isnan(Vect2));
        if length(index1)>2 & length(index2)>2
            [h,p]=ttest2(Vect1(index1),Vect2(index2),'VarType','unequal');
            PValuesApical(t,pair)=p;
        end
    end
    % Basal recoils
    Data1=BasalPool{Pair(1)};
    Data2=BasalPool{Pair(2)};
    for t=1:length(BinTime)
        Vect1=Data1{t};
        Vect2=Data2{t};
        index1=find(~isnan(Vect1));
        index2=find(~isnan(Vect2));
        if length(index1)>2 & length(index2)>2
            [h,p]=ttest2(Vect1(index1),Vect2(index2),'VarType','unequal');
            PValuesBasal(t,pair)=p;
        end
    end
end

% Plots
tstep=0.25;
for pair=1:length(Pairs)
    Pair=Pairs{pair};
    ColorCurve1=ColorsSource(Pair(1),:);
    ColorCurve2=ColorsSource(Pair(2),:);
    ColorPoints1=ColorsSource(Pair(1),:);
    ColorPoints2=ColorsSource(Pair(2),:);

    figure(3+pair)
    % Apical recoil ******************************************************
    subplot(1,2,1)
    title(LegendNames{Pair(2)});
    hold on        
    plot(BinTime,ApicalBin{Pair(1)},'LineWidth',2,'LineStyle','-','Color',ColorPoints1);
    plot(BinTime,ApicalBin{Pair(2)},'LineWidth',2,'LineStyle','-','Color',ColorPoints2);
    
    BinTimeTemp=BinTime;
    Vect=ApicalBin{Pair(1)};
    VectStd=ApicalStd{Pair(1)};
    BinTimeTemp(isnan(Vect))=[];
    VectStd(isnan(Vect))=[];
    Vect(isnan(Vect))=[];
    x2=[BinTimeTemp,fliplr(BinTimeTemp)];
    inBetween=[Vect+VectStd, fliplr(Vect-VectStd)];
    h=fill(x2, inBetween,ColorPoints1,'LineStyle','none');
    set(h,'facealpha',.25)
    BinTimeTemp=BinTime;
    Vect=ApicalBin{Pair(2)};
    VectStd=ApicalStd{Pair(2)};
    BinTimeTemp(isnan(Vect))=[];
    VectStd(isnan(Vect))=[];
    Vect(isnan(Vect))=[];
    x2=[BinTimeTemp,fliplr(BinTimeTemp)];
    inBetween=[Vect+VectStd, fliplr(Vect-VectStd)];
    h=fill(x2, inBetween,ColorPoints2,'LineStyle','none');
    set(h,'facealpha',.25)    
    plot(BinTime,ApicalBin{Pair(1)},'LineWidth',2,'LineStyle','-','Color',ColorPoints1);
    plot(BinTime,ApicalBin{Pair(2)},'LineWidth',2,'LineStyle','-','Color',ColorPoints2);
    xlabel('Timing (hAPF)')
    ylabel('Apical recoil velocity (µm.sec^{-1})')
    xlim([14 24])
    ylim([-0.2 3.1])
    set(findall(gcf,'-property','FontSize'),'FontSize',15)
    yticks(0:1:3)
    
    % ////////////////////////////////////////////////////////////////////
    % Pvalue bars
    PValue=PValuesApical(:,pair);
    hold on
    % Printing PValue bar with increasing hatch, pooling similar hatched
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
    Fill=[2.9 3.1 3.1 2.9];
    
    while count<=length(PValueCode)
        Temp2=PValueCode(count);
        if Temp1==Temp2 % If 2 successive time have the same PValue code
            % We pool with the next timing
            Pool=cat(1,Pool,count);
        elseif count~=length(PValueCode) % If the timepoint PValue code is different from previous one AND it's not the last timepoint
            % We plot previous PValue segment
            if PValueCode(count-1)==2
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,ColorPoints2,'EdgeColor','none');
            elseif PValueCode(count-1)==1
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                hatch(cb,45,ColorPoints2,'-',3,1);
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
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,ColorPoints2,'EdgeColor','none');
            elseif PValueCode(count)==1
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                hatch(cb,45,ColorPoints2,'-',3,1);
            elseif PValueCode(count)==0
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
            end
        end
        count=count+1;
        Temp1=Temp2;
    end

    % Making the countours of the PValue bar for the condition
     rectangle('Position',[BinTime(1) 2.9 BinTime(end)-BinTime(1) 3.1-2.9],'EdgeColor','black','LineWidth',1,'FaceColor','none');

    hold off
    
    % Basal recoils ******************************************************
    subplot(1,2,2)
    hold on
    plot(BinTime,BasalBin{Pair(1)},'LineWidth',2,'LineStyle','-','Color',ColorPoints1);
    plot(BinTime,BasalBin{Pair(2)},'LineWidth',2,'LineStyle','-','Color',ColorPoints2);
    BinTimeTemp=BinTime;
    Vect=BasalBin{Pair(1)};
    VectStd=BasalStd{Pair(1)};
    BinTimeTemp(isnan(Vect))=[];
    VectStd(isnan(Vect))=[];
    Vect(isnan(Vect))=[];
    x2=[BinTimeTemp,fliplr(BinTimeTemp)];
    inBetween=[Vect+VectStd, fliplr(Vect-VectStd)];
    h=fill(x2, inBetween,ColorPoints1,'LineStyle','none');
    set(h,'facealpha',.25)
    BinTimeTemp=BinTime;
    Vect=BasalBin{Pair(2)};
    VectStd=BasalStd{Pair(2)};
    BinTimeTemp(isnan(Vect))=[];
    VectStd(isnan(Vect))=[];
    Vect(isnan(Vect))=[];
    x2=[BinTimeTemp,fliplr(BinTimeTemp)];
    inBetween=[Vect+VectStd, fliplr(Vect-VectStd)];
    h=fill(x2, inBetween,ColorPoints2,'LineStyle','none');
    set(h,'facealpha',.25)
    plot(BinTime,BasalBin{Pair(1)},'LineWidth',2,'LineStyle','-','Color',ColorPoints1);
    plot(BinTime,BasalBin{Pair(2)},'LineWidth',2,'LineStyle','-','Color',ColorPoints2);
    xlabel('Timing (hAPF)')
    ylabel('Basal recoil velocity (µm.sec^{-1})')
    xlim([14 24])
    ylim([-0.2 3.1])
    yticks(0:1:3)
   
    % ////////////////////////////////////////////////////////////////////
    % Pvalue bars
    PValue=PValuesBasal(:,pair);
    hold on
    % Printing PValue bar with increasing hatch, pooling similar hatched
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
    Fill=[2.9 3.1 3.1 2.9];
    
    while count<=length(PValueCode)
        Temp2=PValueCode(count);
        if Temp1==Temp2 % If 2 successive time have the same PValue code
            % We pool with the next timing
            Pool=cat(1,Pool,count);
        elseif count~=length(PValueCode) % If the timepoint PValue code is different from previous one AND it's not the last timepoint
            % We plot previous PValue segment
            if PValueCode(count-1)==2
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,ColorPoints2,'EdgeColor','none');
            elseif PValueCode(count-1)==1
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                hatch(cb,45,ColorPoints2,'-',3,1);
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
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,ColorPoints2,'EdgeColor','none');
            elseif PValueCode(count)==1
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                hatch(cb,45,ColorPoints2,'-',3,1);
            elseif PValueCode(count)==0
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
            end
        end
        count=count+1;
        Temp1=Temp2;
    end

    % Making the countours of the PValue bar for the condition
    rectangle('Position',[BinTime(1) 2.9 BinTime(end)-BinTime(1) 3.1-2.9],'EdgeColor','black','LineWidth',1,'FaceColor','none');
    hold off
    
    set(findall(gcf,'-property','FontSize'),'FontSize',15)
    set(gcf,'Position',[10, 10, 700, 325]);
end


% PATCH for Dfd>MbsRNAi //////////////////////////////////////////////////
% Previous code bugged as not all the timepoints are sampled in this
% condition (tissue is too deep at late timepoints)
for pair=1
    
    Pair=[2 5];
    
    figure();
    % Apical recoils
    Data1=ApicalPool{Pair(1)};
    Data2=ApicalPool{Pair(2)};
    for t=1:32
        Vect1=Data1{t};
        Vect2=Data2{t};
        index1=find(~isnan(Vect1));
        index2=find(~isnan(Vect2));
        if length(index1)>2 & length(index2)>2
            [h,p]=ttest2(Vect1(index1),Vect2(index2),'VarType','unequal');
            PValuesApical(t,pair)=p;
        end
    end
    for t=33:length(BinTime)
        PValuesApical(t,pair)=nan;
    end
    % Basal recoils
    Data1=BasalPool{Pair(1)};
    Data2=BasalPool{Pair(2)};
    for t=1:32
        Vect1=Data1{t};
        Vect2=Data2{t};
        index1=find(~isnan(Vect1));
        index2=find(~isnan(Vect2));
        if length(index1)>2 & length(index2)>2
            [h,p]=ttest2(Vect1(index1),Vect2(index2),'VarType','unequal');
            PValuesBasal(t,pair)=p;
        end
    end
    for t=33:length(BinTime)
        PValuesBasal(t,pair)=nan;
    end
    % Pair=Pairs{pair};
    ColorCurve1=ColorsSource(Pair(1),:);
    ColorCurve2=ColorsSource(Pair(2),:);
    ColorPoints1=ColorsSource(Pair(1),:);
    ColorPoints2=ColorsSource(Pair(2),:);
    
    
    % Apical recoil ******************************************************
    subplot(1,2,1)
    title(LegendNames{Pair(2)});
    hold on
    plot(BinTime,ApicalBin{Pair(1)},'LineWidth',2,'LineStyle','-','Color',ColorPoints1);
    plot(BinTime(1:32),ApicalBin{Pair(2)}(1:32),'LineWidth',2,'LineStyle','-','Color',ColorPoints2);
    
    BinTimeTemp=BinTime;
    Vect=ApicalBin{Pair(1)};
    VectStd=ApicalStd{Pair(1)};
    BinTimeTemp(isnan(Vect))=[];
    VectStd(isnan(Vect))=[];
    Vect(isnan(Vect))=[];
    x2=[BinTimeTemp,fliplr(BinTimeTemp)];
    inBetween=[Vect+VectStd, fliplr(Vect-VectStd)];
    h=fill(x2, inBetween,ColorPoints1,'LineStyle','none');
    set(h,'facealpha',.25)  
    BinTimeTemp=BinTime(1:32);
    Vect=ApicalBin{Pair(2)}(1:32);
    VectStd=ApicalStd{Pair(2)}(1:32);
    BinTimeTemp(isnan(Vect))=[];
    VectStd(isnan(Vect))=[];
    Vect(isnan(Vect))=[];
    x2=[BinTimeTemp,fliplr(BinTimeTemp)];
    inBetween=[Vect+VectStd, fliplr(Vect-VectStd)];
    h=fill(x2, inBetween,ColorPoints2,'LineStyle','none');
    set(h,'facealpha',.25)  
    plot(BinTime,ApicalBin{Pair(1)},'LineWidth',2,'LineStyle','-','Color',ColorPoints1);
    plot(BinTime(1:32),ApicalBin{Pair(2)}(1:32),'LineWidth',2,'LineStyle','-','Color',ColorPoints2);
    xlabel('Timing (hAPF)')
    ylabel('Apical recoil velocity (µm.sec^{-1})')
    xlim([14 24])
    ylim([-0.2 3.1])
    yticks(0:1:3)
    set(findall(gcf,'-property','FontSize'),'FontSize',15)
    % ////////////////////////////////////////////////////////////////////
    % Pvalue bars
    PValue=PValuesApical(:,pair);
    hold on
    % Printing PValue bar with increasing hatch, pooling similar hatched
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
    Fill=[2.9 3.1 3.1 2.9];
    
    while count<=length(PValueCode)
        Temp2=PValueCode(count);
        if Temp1==Temp2 % If 2 successive time have the same PValue code
            % We pool with the next timing
            Pool=cat(1,Pool,count);
        elseif count~=length(PValueCode) % If the timepoint PValue code is different from previous one AND it's not the last timepoint
            % We plot previous PValue segment
            if PValueCode(count-1)==2
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,ColorPoints2,'EdgeColor','none');
            elseif PValueCode(count-1)==1
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                hatch(cb,45,ColorPoints2,'-',3,1);
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
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,ColorPoints2,'EdgeColor','none');
            elseif PValueCode(count)==1
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                hatch(cb,45,ColorPoints2,'-',3,1);
            elseif PValueCode(count)==0
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
            end
        end
        count=count+1;
        Temp1=Temp2;
    end
    
    % Making the countours of the PValue bar for the condition
    rectangle('Position',[BinTime(1) 2.9 BinTime(end)-BinTime(1) 3.1-2.9],'EdgeColor','black','LineWidth',1,'FaceColor','none');
    
    hold off
    
    % Basal recoils ******************************************************
    subplot(1,2,2)
    hold on
    plot(BinTime,BasalBin{Pair(1)},'LineWidth',2,'LineStyle','-','Color',ColorPoints1);
    plot(BinTime(1:32),BasalBin{Pair(2)}(1:32),'LineWidth',2,'LineStyle','-','Color',ColorPoints2);
    BinTimeTemp=BinTime;
    Vect=BasalBin{Pair(1)};
    VectStd=BasalStd{Pair(1)};
    BinTimeTemp(isnan(Vect))=[];
    VectStd(isnan(Vect))=[];
    Vect(isnan(Vect))=[];
    x2=[BinTimeTemp,fliplr(BinTimeTemp)];
    inBetween=[Vect+VectStd, fliplr(Vect-VectStd)];
    h=fill(x2, inBetween,ColorPoints1,'LineStyle','none');
    set(h,'facealpha',.25)  
    BinTimeTemp=BinTime(1:32);
    Vect=BasalBin{Pair(2)}(1:32);
    VectStd=BasalStd{Pair(2)}(1:32);
    BinTimeTemp(isnan(Vect))=[];
    VectStd(isnan(Vect))=[];
    Vect(isnan(Vect))=[];
    x2=[BinTimeTemp,fliplr(BinTimeTemp)];
    inBetween=[Vect+VectStd, fliplr(Vect-VectStd)];
    h=fill(x2, inBetween,ColorPoints2,'LineStyle','none');
    set(h,'facealpha',.25)  
    plot(BinTime,BasalBin{Pair(1)},'LineWidth',2,'LineStyle','-','Color',ColorPoints1);
    plot(BinTime(1:32),BasalBin{Pair(2)}(1:32),'LineWidth',2,'LineStyle','-','Color',ColorPoints2);
    xlabel('Timing (hAPF)')
    ylabel('Basal recoil velocity (µm.sec^{-1})')
    xlim([14 24])
    ylim([-0.2 3.1])
    set(findall(gcf,'-property','FontSize'),'FontSize',15)
    set(gcf,'Position',[10, 10, 700, 400]);
    % ////////////////////////////////////////////////////////////////////
    % Pvalue bars
    PValue=PValuesBasal(:,pair);
    hold on
    % Printing PValue bar with increasing hatch, pooling similar hatched
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
    Fill=[2.9 3.1 3.1 2.9];
    
    while count<=length(PValueCode)
        Temp2=PValueCode(count);
        if Temp1==Temp2 % If 2 successive time have the same PValue code
            % We pool with the next timing
            Pool=cat(1,Pool,count);
        elseif count~=length(PValueCode) % If the timepoint PValue code is different from previous one AND it's not the last timepoint
            % We plot previous PValue segment
            if PValueCode(count-1)==2
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,ColorPoints2,'EdgeColor','none');
            elseif PValueCode(count-1)==1
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                hatch(cb,45,ColorPoints2,'-',3,1);
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
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,ColorPoints2,'EdgeColor','none');
            elseif PValueCode(count)==1
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
                hatch(cb,45,ColorPoints2,'-',3,1);
            elseif PValueCode(count)==0
                cb=fill([BinTime(min(Pool))-tstep/2 BinTime(min(Pool))-tstep/2 BinTime(max(Pool))+tstep/2 BinTime(max(Pool))+tstep/2],Fill,'white','EdgeColor','none');
            end
        end
        count=count+1;
        Temp1=Temp2;
    end
    
    % Making the countours of the PValue bar for the condition
    rectangle('Position',[BinTime(1) 2.9 BinTime(end)-BinTime(1) 3.1-2.9],'EdgeColor','black','LineWidth',1,'FaceColor','none');
    
    set(findall(gcf,'-property','FontSize'),'FontSize',15)
    set(gcf,'Position',[10, 10, 700, 325]);
end




%% Plot apical and basal recoil velocities of all conditions for a given timepoint

% Chosen timepoint (in hAPF)
ChosenTimepoint=20;
% The chosen time point is considered +/- step (in hAPF)
TimepointStep=2;

% Considered time fork
TimeFork=[ChosenTimepoint-TimepointStep ChosenTimepoint+TimepointStep];


% ************************************************************************
% Dfd>Myosin conditions***************************************************
% ************************************************************************
% Index of the conditions that are plotted
Group=[2 3 4 5];
% Index in the Group vector of the control to compare to
Test=[nan 1 1 1];
% Colors associated with the conditions
Colors=ColorsSource(Group,:);
% Plot-vectors initialization
PoolConditionApical=[];
PoolConditionBasal=[];
PoolApical=[];
PoolBasal=[];
OneTimeApical=[];
OneTimeBasal=[];
MaxApical=[];
MaxBasal=[];
% Fill plot-vectors
for cond=1:length(Group)
    condition=Group(cond);
    VectTime=Timing{condition};
    VectApical=Apical{condition};
    VectBasal=Basal{condition};
    index1=find(VectTime<=TimeFork(2) & VectTime>=TimeFork(1) & ~isnan(VectApical));
    index2=find(VectTime<=TimeFork(2) & VectTime>=TimeFork(1) & ~isnan(VectBasal));
    PoolConditionApical=cat(2,PoolConditionApical,cond*ones(1,length(index1)));
    PoolConditionBasal=cat(2,PoolConditionBasal,cond*ones(1,length(index2)));
    PoolApical=cat(1,PoolApical,VectApical(index1));
    PoolBasal=cat(1,PoolBasal,VectBasal(index2));
    OneTimeApical{cond}=VectApical(index1);
    OneTimeBasal{cond}=VectBasal(index2);
    MaxApical(cond)=max(VectApical(index1));
    MaxBasal(cond)=max(VectBasal(index2));
end
% Apical /////////////////////////////////////////////////////////////
figure(13)
% Statistics
Pvalue=nan(1,length(Group));
Change=nan(1,length(Group));
NumberAblations=nan(1,length(Group));
Average=nan(1,length(Group));
Error=nan(1,length(Group));
for a=1:length(Group)
    NumberAblations(a)=length(~isnan(OneTimeApical{a}));
    Average(a)=nanmean(OneTimeApical{a});
    Error(a)=nanstd(OneTimeApical{a});
    if ~isnan(Test(a))
        Vect1=OneTimeApical{Test(a)};
        Vect2=OneTimeApical{a};
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(a)=p;
        Change(a)=-10*round(10*(nanmean(Vect1)-nanmean(Vect2))/nanmean(Vect1));
    end
end
%Beeswarm plot
xlim([0 5])
ylim([0 3.75])
set(gcf,'Position',[50, 50, 350, 400]);
beeswarm(PoolConditionApical',PoolApical,'sort_style','up','overlay_style','none','dot_size',0.5,'use_current_axes',true,'colormap',Colors);
ylabel('Apical recoil velocity (µm.sec^{-1})')
xticks(1:length(Group));
for a=1:length(Group)
    Legend{a}=LegendNames{Group(a)};
end
xticklabels(Legend);
xtickangle(30);
% Plot average and error
hold on
for cond=1:length(Group)
    line([cond cond], [Average(cond)-Error(cond) Average(cond)+Error(cond)],'Color',Colors(cond,:),'LineWidth',3)
end
for cond=1:length(Group)
    line([cond-0.4 cond+0.4], [Average(cond) Average(cond)],'Color','black','LineWidth',5)
end
hold off
% Adding statistics results
for a=1:length(Group)
    if ~isnan(Pvalue(a))
        if Pvalue(a)<0.001
            text(a,MaxApical(a)+0.15,'***','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.01
            text(a,MaxApical(a)+0.15,'**','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.05
            text(a,MaxApical(a)+0.15,'*','HorizontalAlignment','Center','FontSize',15)
        else
            text(a,MaxApical(a)+0.15,'ns','HorizontalAlignment','Center','FontSize',15)
        end
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',15)
yticks(0:1:3);

% Basal /////////////////////////////////////////////////////////////
figure(14)
% Statistics
Pvalue=nan(1,length(Group));
Change=nan(1,length(Group));NumberAblations=nan(1,length(Group));
Average=nan(1,length(Group));
Error=nan(1,length(Group));
for a=1:length(Group)
    NumberAblations(a)=length(~isnan(OneTimeBasal{a}));
    Average(a)=nanmean(OneTimeBasal{a});
    Error(a)=nanstd(OneTimeBasal{a});
    if ~isnan(Test(a))
        Vect1=OneTimeBasal{Test(a)};
        Vect2=OneTimeBasal{a};
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(a)=p;
        Change(a)=-10*round(10*(nanmean(Vect1)-nanmean(Vect2))/nanmean(Vect1));
    end
end
%Beeswarm plot
xlim([0 5])
ylim([0 3.75])
set(gcf,'Position',[50, 50, 350, 400]);
beeswarm(PoolConditionBasal',PoolBasal,'sort_style','up','overlay_style','none','dot_size',0.5,'use_current_axes',true,'colormap',Colors);
ylabel('Basal recoil velocity (µm.sec^{-1})')
xticks(1:length(Group));
for a=1:length(Group)
    Legend{a}=LegendNames{Group(a)}
end
xticklabels(Legend);
xtickangle(30);
% Plot average and error
hold on
for cond=1:length(Group)
    line([cond cond], [Average(cond)-Error(cond) Average(cond)+Error(cond)],'Color',Colors(cond,:),'LineWidth',3)
end
for cond=1:length(Group)
    line([cond-0.4 cond+0.4], [Average(cond) Average(cond)],'Color','black','LineWidth',5)
end
hold off
% Adding statistics results
for a=1:length(Group)
    if ~isnan(Pvalue(a))
        if Pvalue(a)<0.001
            text(a,MaxBasal(a)+0.15,'***','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.01
            text(a,MaxBasal(a)+0.15,'**','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.05
            text(a,MaxBasal(a)+0.15,'*','HorizontalAlignment','Center','FontSize',15)
        else
            text(a,MaxBasal(a)+0.15,'ns','HorizontalAlignment','Center','FontSize',15)
        end
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',15)
clear yticks
yticks(0:3)



% ************************************************************************
% Dfd>Toll/Dfdi conditions************************************************
% ************************************************************************
Group=[2 6 7];
Test=[nan 1 1];
Colors=ColorsSource(Group,:);
% Plot-vectors initialization
PoolConditionApical=[];
PoolConditionBasal=[];
PoolApical=[];
PoolBasal=[];
OneTimeApical=[];
OneTimeBasal=[];
MaxApical=[];
MaxBasal=[];
% Filling plot-vectors
for cond=1:length(Group)
    condition=Group(cond);
    VectTime=Timing{condition};
    VectApical=Apical{condition};
    VectBasal=Basal{condition};
    index1=find(VectTime<=TimeFork(2) & VectTime>=TimeFork(1) & ~isnan(VectApical));
    index2=find(VectTime<=TimeFork(2) & VectTime>=TimeFork(1) & ~isnan(VectBasal));
    PoolConditionApical=cat(2,PoolConditionApical,cond*ones(1,length(index1)));
    PoolConditionBasal=cat(2,PoolConditionBasal,cond*ones(1,length(index2)));
    PoolApical=cat(1,PoolApical,VectApical(index1));
    PoolBasal=cat(1,PoolBasal,VectBasal(index2));
    OneTimeApical{cond}=VectApical(index1);
    OneTimeBasal{cond}=VectBasal(index2);
    MaxApical(cond)=max(VectApical(index1));
    MaxBasal(cond)=max(VectBasal(index2));
end
% Apical /////////////////////////////////////////////////////////////
figure(15)
% Statistics
Pvalue=nan(1,length(Group));
Change=nan(1,length(Group));
NumberAblations=nan(1,length(Group));
Average=nan(1,length(Group));
Error=nan(1,length(Group));
for a=1:length(Group)
    NumberAblations(a)=length(~isnan(OneTimeApical{a}));
    Average(a)=nanmean(OneTimeApical{a});
    Error(a)=nanstd(OneTimeApical{a});
    if ~isnan(Test(a))
        Vect1=OneTimeApical{Test(a)};
        Vect2=OneTimeApical{a};
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(a)=p;
        Change(a)=-10*round(10*(nanmean(Vect1)-nanmean(Vect2))/nanmean(Vect1));
    end
end
%Beeswarm plot
xlim([0 4])
ylim([0 3.75])
set(gcf,'Position',[50, 50, 250, 400]);
clear yticks
yticks(0:3)
beeswarm(PoolConditionApical',PoolApical,'sort_style','up','overlay_style','none','dot_size',0.5,'use_current_axes',true,'colormap',Colors);
ylabel('Apical recoil velocity (µm.sec^{-1})')
xticks(1:length(Group));
for a=1:length(Group)
    Legend{a}=LegendNames{Group(a)}
end
xticklabels(Legend);
xtickangle(30);
% Plot average and error
hold on
for cond=1:length(Group)
    line([cond cond], [Average(cond)-Error(cond) Average(cond)+Error(cond)],'Color',Colors(cond,:),'LineWidth',3)
end
for cond=1:length(Group)
    line([cond-0.4 cond+0.4], [Average(cond) Average(cond)],'Color','black','LineWidth',5)
end
hold off
% Adding statistics results
for a=1:length(Group)
    if ~isnan(Pvalue(a))
        if Pvalue(a)<0.001
            text(a,MaxApical(a)+0.15,'***','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.01
            text(a,MaxApical(a)+0.15,'**','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.05
            text(a,MaxApical(a)+0.15,'*','HorizontalAlignment','Center','FontSize',15)
        else
            text(a,MaxApical(a)+0.15,'ns','HorizontalAlignment','Center','FontSize',15)
        end
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',15)
clear yticks
yticks(0:3)

% Basal /////////////////////////////////////////////////////////////
figure(16)
% Statistics
Pvalue=nan(1,length(Group));
Change=nan(1,length(Group));NumberAblations=nan(1,length(Group));
Average=nan(1,length(Group));
Error=nan(1,length(Group));
for a=1:length(Group)
    NumberAblations(a)=length(~isnan(OneTimeBasal{a}));
    Average(a)=nanmean(OneTimeBasal{a});
    Error(a)=nanstd(OneTimeBasal{a});
    if ~isnan(Test(a))
        Vect1=OneTimeBasal{Test(a)};
        Vect2=OneTimeBasal{a};
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(a)=p;
        Change(a)=-10*round(10*(nanmean(Vect1)-nanmean(Vect2))/nanmean(Vect1));
    end
end
%Beeswarm plot
xlim([0 4])
ylim([0 3.75])
set(gcf,'Position',[50, 50, 250, 400]);
beeswarm(PoolConditionBasal',PoolBasal,'sort_style','up','overlay_style','sd','dot_size',0.5,'use_current_axes',true,'colormap',Colors);
ylabel('Basal recoil velocity (µm.sec^{-1})')
xticks(1:length(Group));
for a=1:length(Group)
    Legend{a}=LegendNames{Group(a)}
end
xticklabels(Legend);
xtickangle(30);
% Plot average and error
hold on
for cond=1:length(Group)
    line([cond cond], [Average(cond)-Error(cond) Average(cond)+Error(cond)],'Color',Colors(cond,:),'LineWidth',3)
end
for cond=1:length(Group)
    line([cond-0.4 cond+0.4], [Average(cond) Average(cond)],'Color','black','LineWidth',5)
end
hold off
% Adding statistics results
for a=1:length(Group)
    if ~isnan(Pvalue(a))
        if Pvalue(a)<0.001
            text(a,MaxBasal(a)+0.15,'***','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.01
            text(a,MaxBasal(a)+0.15,'**','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.05
            text(a,MaxBasal(a)+0.15,'*','HorizontalAlignment','Center','FontSize',15)
        else
            text(a,MaxBasal(a)+0.15,'ns','HorizontalAlignment','Center','FontSize',15)
        end
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',15)
clear yticks
yticks(0:3)


% ************************************************************************
% Dys Dg *****************************************************************
% ************************************************************************
Group=[1 8 9];
Test=[nan 1 1];
Colors=ColorsSource(Group,:);
% Plot-vectors initialization
PoolConditionApical=[];
PoolConditionBasal=[];
PoolApical=[];
PoolBasal=[];
OneTimeApical=[];
OneTimeBasal=[];
MaxApical=[];
MaxBasal=[];
% Filling plot-vectors
for cond=1:length(Group)
    condition=Group(cond);
    VectTime=Timing{condition};
    VectApical=Apical{condition};
    VectBasal=Basal{condition};
    index1=find(VectTime<=TimeFork(2) & VectTime>=TimeFork(1) & ~isnan(VectApical));
    index2=find(VectTime<=TimeFork(2) & VectTime>=TimeFork(1) & ~isnan(VectBasal));
    PoolConditionApical=cat(2,PoolConditionApical,cond*ones(1,length(index1)));
    PoolConditionBasal=cat(2,PoolConditionBasal,cond*ones(1,length(index2)));
    PoolApical=cat(1,PoolApical,VectApical(index1));
    PoolBasal=cat(1,PoolBasal,VectBasal(index2));
    OneTimeApical{cond}=VectApical(index1);
    OneTimeBasal{cond}=VectBasal(index2);
    MaxApical(cond)=max(VectApical(index1));
    MaxBasal(cond)=max(VectBasal(index2));
end
% Apical /////////////////////////////////////////////////////////////
figure(17)
% Statistics
Pvalue=nan(1,length(Group));
Change=nan(1,length(Group));
NumberAblations=nan(1,length(Group));
Average=nan(1,length(Group));
Error=nan(1,length(Group));
for a=1:length(Group)
    NumberAblations(a)=length(~isnan(OneTimeApical{a}));
    Average(a)=nanmean(OneTimeApical{a});
    Error(a)=nanstd(OneTimeApical{a});
    if ~isnan(Test(a))
        Vect1=OneTimeApical{Test(a)};
        Vect2=OneTimeApical{a};
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(a)=p;
        Change(a)=-10*round(10*(nanmean(Vect1)-nanmean(Vect2))/nanmean(Vect1));
    end
end
%Beeswarm plot
xlim([0 4])
ylim([0 3.75])
set(gcf,'Position',[50, 50, 250, 400]);
clear yticks
yticks(0:3)
beeswarm(PoolConditionApical',PoolApical,'sort_style','up','overlay_style','none','dot_size',0.5,'use_current_axes',true,'colormap',Colors);
ylabel('Apical recoil velocity (µm.sec^{-1})')
xticks(1:length(Group));
for a=1:length(Group)
    Legend{a}=LegendNames{Group(a)}
end
xticklabels(Legend);
xtickangle(30);
% Plot average and error
hold on
for cond=1:length(Group)
    line([cond cond], [Average(cond)-Error(cond) Average(cond)+Error(cond)],'Color',Colors(cond,:),'LineWidth',3)
end
for cond=1:length(Group)
    line([cond-0.4 cond+0.4], [Average(cond) Average(cond)],'Color','black','LineWidth',5)
end
hold off
% Adding statistics results
for a=1:length(Group)
    if ~isnan(Pvalue(a))
        if Pvalue(a)<0.001
            text(a,MaxApical(a)+0.15,'***','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.01
            text(a,MaxApical(a)+0.15,'**','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.05
            text(a,MaxApical(a)+0.15,'*','HorizontalAlignment','Center','FontSize',15)
        else
            text(a,MaxApical(a)+0.15,'ns','HorizontalAlignment','Center','FontSize',15)
        end
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',15)
clear yticks
yticks(0:3)

% Basal /////////////////////////////////////////////////////////////
figure(18)
% Statistics
Pvalue=nan(1,length(Group));
Change=nan(1,length(Group));NumberAblations=nan(1,length(Group));
Average=nan(1,length(Group));
Error=nan(1,length(Group));
for a=1:length(Group)
    NumberAblations(a)=length(~isnan(OneTimeBasal{a}));
    Average(a)=nanmean(OneTimeBasal{a});
    Error(a)=nanstd(OneTimeBasal{a});
    if ~isnan(Test(a))
        Vect1=OneTimeBasal{Test(a)};
        Vect2=OneTimeBasal{a};
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(a)=p;
        Change(a)=-10*round(10*(nanmean(Vect1)-nanmean(Vect2))/nanmean(Vect1));
    end
end
%Beeswarm plot
xlim([0 4])
ylim([0 3.75])
set(gcf,'Position',[50, 50, 250, 400]);
beeswarm(PoolConditionBasal',PoolBasal,'sort_style','up','overlay_style','sd','dot_size',0.5,'use_current_axes',true,'colormap',Colors);
ylabel('Basal recoil velocity (µm.sec^{-1})')
xticks(1:length(Group));
for a=1:length(Group)
    Legend{a}=LegendNames{Group(a)}
end
xticklabels(Legend);
xtickangle(30);
% Plot average and error
hold on
for cond=1:length(Group)
    line([cond cond], [Average(cond)-Error(cond) Average(cond)+Error(cond)],'Color',Colors(cond,:),'LineWidth',3)
end
for cond=1:length(Group)
    line([cond-0.4 cond+0.4], [Average(cond) Average(cond)],'Color','black','LineWidth',5)
end
hold off
% Adding statistics results
for a=1:length(Group)
    if ~isnan(Pvalue(a))
        if Pvalue(a)<0.001
            text(a,MaxBasal(a)+0.15,'***','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.01
            text(a,MaxBasal(a)+0.15,'**','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.05
            text(a,MaxBasal(a)+0.15,'*','HorizontalAlignment','Center','FontSize',15)
        else
            text(a,MaxBasal(a)+0.15,'ns','HorizontalAlignment','Center','FontSize',15)
        end
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',15)
clear yticks
yticks(0:3)






% ************************************************************************
% Lateral Ablated ********************************************************
% ************************************************************************
% Chosen timepoint (in hAPF)
ChosenTimepoint=24;
% The chosen time point is considered +/- step (in hAPF)
TimepointStep=0.5;
% Considered time fork
TimeFork=[ChosenTimepoint-TimepointStep ChosenTimepoint+TimepointStep];

Group=[1 12];
Test=[nan 1];
Colors=ColorsSource(Group,:);
% Plot-vectors initialization
PoolConditionApical=[];
PoolConditionBasal=[];
PoolApical=[];
PoolBasal=[];
OneTimeApical=[];
OneTimeBasal=[];
MaxApical=[];
MaxBasal=[];
% Filling plot-vectors
for cond=1:length(Group)
    condition=Group(cond);
    VectTime=Timing{condition};
    VectApical=Apical{condition};
    VectBasal=Basal{condition};
    index1=find(VectTime<=TimeFork(2) & VectTime>=TimeFork(1) & ~isnan(VectApical));
    index2=find(VectTime<=TimeFork(2) & VectTime>=TimeFork(1) & ~isnan(VectBasal));
    PoolConditionApical=cat(2,PoolConditionApical,cond*ones(1,length(index1)));
    PoolConditionBasal=cat(2,PoolConditionBasal,cond*ones(1,length(index2)));
    PoolApical=cat(1,PoolApical,VectApical(index1));
    PoolBasal=cat(1,PoolBasal,VectBasal(index2));
    OneTimeApical{cond}=VectApical(index1);
    OneTimeBasal{cond}=VectBasal(index2);
    MaxApical(cond)=max(VectApical(index1));
    MaxBasal(cond)=max(VectBasal(index2));
end
% Apical /////////////////////////////////////////////////////////////
figure(19);
% Statistics
Pvalue=nan(1,length(Group));
Change=nan(1,length(Group));
NumberAblations=nan(1,length(Group));
Average=nan(1,length(Group));
Error=nan(1,length(Group));
for a=1:length(Group)
    NumberAblations(a)=length(~isnan(OneTimeApical{a}));
    Average(a)=nanmean(OneTimeApical{a});
    Error(a)=nanstd(OneTimeApical{a});
    if ~isnan(Test(a))
        Vect1=OneTimeApical{Test(a)};
        Vect2=OneTimeApical{a};
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(a)=p;
        Change(a)=-10*round(10*(nanmean(Vect1)-nanmean(Vect2))/nanmean(Vect1));
    end
end
%Beeswarm plot
xlim([0 3])
ylim([0 3.15])
set(gcf,'Position',[50, 50, 250, 400]);
clear yticks
yticks(0:2)
beeswarm(PoolConditionApical',PoolApical,'sort_style','up','overlay_style','none','dot_size',0.75,'use_current_axes',true,'colormap',Colors);
ylabel('Apical recoil velocity (µm.sec^{-1})')
xticks(1:length(Group));
for a=1:length(Group)
    Legend{a}=LegendNames{Group(a)}
end
xticklabels(Legend);
xtickangle(30);
% Plot average and error
hold on
for cond=1:length(Group)
    line([cond cond], [Average(cond)-Error(cond) Average(cond)+Error(cond)],'Color',Colors(cond,:),'LineWidth',3)
end
for cond=1:length(Group)
    line([cond-0.4 cond+0.4], [Average(cond) Average(cond)],'Color','black','LineWidth',5)
end
hold off
% Adding statistics results
for a=1:length(Group)
    if ~isnan(Pvalue(a))
        if Pvalue(a)<0.001
            text(a,MaxApical(a)+0.15,'***','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.01
            text(a,MaxApical(a)+0.15,'**','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.05
            text(a,MaxApical(a)+0.15,'*','HorizontalAlignment','Center','FontSize',15)
        else
            text(a,MaxApical(a)+0.15,'ns','HorizontalAlignment','Center','FontSize',15)
        end
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',15)
clear yticks
yticks(0:2)

% Basal /////////////////////////////////////////////////////////////
figure(20)
% Statistics
Pvalue=nan(1,length(Group));
Change=nan(1,length(Group));NumberAblations=nan(1,length(Group));
Average=nan(1,length(Group));
Error=nan(1,length(Group));
for a=1:length(Group)
    NumberAblations(a)=length(~isnan(OneTimeBasal{a}));
    Average(a)=nanmean(OneTimeBasal{a});
    Error(a)=nanstd(OneTimeBasal{a});
    if ~isnan(Test(a))
        Vect1=OneTimeBasal{Test(a)};
        Vect2=OneTimeBasal{a};
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(a)=p;
        Change(a)=-10*round(10*(nanmean(Vect1)-nanmean(Vect2))/nanmean(Vect1));
    end
end
%Beeswarm plot
xlim([0 3])
ylim([0 3.15])
set(gcf,'Position',[50, 50, 250, 400]);
beeswarm(PoolConditionBasal',PoolBasal,'sort_style','up','overlay_style','sd','dot_size',0.75,'use_current_axes',true,'colormap',Colors);
ylabel('Basal recoil velocity (µm.sec^{-1})')
xticks(1:length(Group));
for a=1:length(Group)
    Legend{a}=LegendNames{Group(a)}
end
xticklabels(Legend);
xtickangle(30);
% Plot average and error
hold on
for cond=1:length(Group)
    line([cond cond], [Average(cond)-Error(cond) Average(cond)+Error(cond)],'Color',Colors(cond,:),'LineWidth',3)
end
for cond=1:length(Group)
    line([cond-0.4 cond+0.4], [Average(cond) Average(cond)],'Color','black','LineWidth',5)
end
hold off
% Adding statistics results
for a=1:length(Group)
    if ~isnan(Pvalue(a))
        if Pvalue(a)<0.001
            text(a,MaxBasal(a)+0.15,'***','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.01
            text(a,MaxBasal(a)+0.15,'**','HorizontalAlignment','Center','FontSize',15)
        elseif Pvalue(a)<0.05
            text(a,MaxBasal(a)+0.15,'*','HorizontalAlignment','Center','FontSize',15)
        else
            text(a,MaxBasal(a)+0.15,'ns','HorizontalAlignment','Center','FontSize',15)
        end
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',15)
clear yticks
yticks(0:2)
%% SpeedCurvatureTensionPlots
% Plots of deepening speed as a function of curvature
% Plots of deepening speed as a function of curvature X recoilvelocity
clear all
close all

%% Parameter to fill in //////////////////////////////////////////////////////////////
% Path where to find data
Path='D:\NeckDeepeningQuantification\Data\Values'; % Needs to end with 'NeckDeepeningQuantification\Data\Values'
% ////////////////////////////////////////////////////////////////////////


%% Other parameters

% Normal speed and curvatures *********************************************
% Names of the conditions apically tracked
Conditions={'EcadGFPControl' 'Dfd2daysRokRNAi' 'Dfd2dayssqhRNAi' 'Dfd2daysMbsRNAi' 'DfdDfdRNAi'...
    'DysMutant' 'DgMutant' 'DfdToll8RNAi' 'NoFlattening' 'SideFlattening' 'PerpendicularAblations' 'PerpendicularAblationCurved'};
% Names of the conditions basally tracked
ConditionsBasal={'EcadGFPControl' 'Dfd2daysRokRNAi' 'Dfd2dayssqhRNAi' 'Dfd2daysMbsRNAi' 'DfdDfdRNAi'...
    'DysMutant' 'DgMutant' 'DfdToll8RNAi'};
% Plot legends for each condition
Names={'Control'...
    '{\itDfd}>{\itRok}^{RNAi}' '{\itDfd}>{\itsqh}^{RNAi}' '{\itDfd}>{\itMbs}^{RNAi}' '{\itDfd}>{\itDfd}^{RNAi}'...
    '{\itDys}^{Mutant}' '{\itDg}^{Mutant}' '{\itDfd}>{\itToll8}^{RNAi}'...
    'No flattening' 'Side flattening' 'Ablations_{flattened}' 'Ablation_{non flattened}'};
% Marker code
Markers={'o','^','v','<','s','d','p','h'};
% Color code
blue=[58/255,67/255,186/255];
red=[208/255,49/255,45/255];
green=[59/255,177/255,67/255];
orange=[237/255,112/255,20/255];
purple=[163/255,44/255,196/255];
pink=[255/255,22/255,149/255];
peanut=[121/255,92/255,52/255];
grey=[108/255,98/255,109/255];
seaweed=[53/255,74/255,33/255];
ColorsSource=[blue'...
    red' orange' purple'...
    peanut' green' seaweed' grey']';
% Path where to find basal data
PathBasal=[Path filesep 'Basal'];

% Apical and basal recoils ***********************************************
PathRecoil=[Path filesep 'Recoils'];
NamesRecoil={'Control' 'DfdRokRNAi' 'DfdsqhRNAi' 'DfdMbsRNAi' 'DfdDfdRNAi'...
    'DysMutant' 'DgMutant' 'DfdToll8RNAi' 'NonFlattened' 'Control' 'Control' 'Control'};

% Axes parameters
tmin=14;
tmax=28;
tstep=0.25;
xmin=-400;
xmax=+400;
xstep=10;
NumMini=4;
% Timing vector
VectX=14:2:24;

%% Load data

% Apical leading edge data
PoolCurvatures=[];
PoolSpeeds=[];
for condition=1:length(Conditions)
    load([Path filesep Conditions{condition} '(Curvatures)'],'Curvatures');
    load([Path filesep Conditions{condition} '(Speeds)'],'Speeds');
    PoolCurvatures{condition}=Curvatures;
    PoolSpeeds{condition}=Speeds;
end

% Basal leading edge data
PoolCurvaturesBasal=[];
PoolSpeedsBasal=[];
for condition=1:length(ConditionsBasal)
    load([PathBasal filesep ConditionsBasal{condition} '(Curvatures)'],'Curvatures');
    load([PathBasal filesep ConditionsBasal{condition} '(Speeds)'],'Speeds');
    PoolCurvaturesBasal{condition}=Curvatures;
    PoolSpeedsBasal{condition}=Speeds;
end

% Loading recoil data
ApicalRecoils=[];
ApicalRecoilsStd=[];
ApicalRecoilsError=[];
BasalRecoils=[];
BasalRecoilsStd=[];
BasalRecoilsError=[];
for condition=1:length(Conditions)
    load([PathRecoil filesep NamesRecoil{condition} 'Recoil.mat']);
    ApicalRecoils{condition}=Recoil.apical;
    ApicalRecoilsStd{condition}=Recoil.apicalstd;
    ApicalRecoilsError{condition}=Recoil.apicalerror;
    BasalRecoils{condition}=Recoil.basal;
    BasalRecoilsStd{condition}=Recoil.basalstd; 
    BasalRecoilsError{condition}=Recoil.basalerror;
end


%% Plots for apical data

% Initialization of pooling vectors
PooledCurvContract=[];
PooledSpeeds=[];
Slope=[];
SlopeCI=[];
PooledCurvContractError=[];
PooledSpeedsError=[];
    
% Treatment of all conditions (excepts SideFlattening) ///////////////////
for condition=1:9
    % Load data
    Curvatures=PoolCurvatures{condition};
    Speeds=PoolSpeeds{condition};
    Contractility=ApicalRecoils{condition};
    
    % Choice of the minimal sampling:
    % (when the sample is big enough, only values covered by 5 animals are considered, otherwise, 2)
    if size(Curvatures,3)>7
        NumMini=5;
    else
        NumMini=2;
    end
    
    % Average and error calculation
    MeanCurvature=nan(size(Curvatures,1),size(Curvatures,2));
    ErrorCurvature=nan(size(Curvatures,1),size(Curvatures,2));
    for x=1:size(Curvatures,1)
        for y=1:size(Curvatures,2)
            Vect=squeeze(Curvatures(x,y,:));
            index=find(~isnan(Vect));
            if length(index)>=NumMini
                MeanCurvature(x,y)=mean(Vect(index));
                ErrorCurvature(x,y)=std(Vect(index))./sqrt(length(index));
            end
        end
    end
    MeanSpeed=nan(size(Curvatures,1),size(Curvatures,2));
    ErrorSpeed=nan(size(Curvatures,1),size(Curvatures,2));
    for x=1:size(Speeds,1)
        for y=1:size(Speeds,2)
            Vect=squeeze(Speeds(x,y,:));
            index=find(~isnan(Vect));
            if length(index)>=NumMini
                MeanSpeed(x,y)=mean(Vect(index));
                ErrorSpeed(x,y)=std(Vect(index))./sqrt(length(index));
            end
        end
    end
    
    % Filter curvature that are too noisy
    MeanCurvature(ErrorCurvature>0.002)=nan;
    MeanSpeed(ErrorCurvature>0.002)=nan;
    ErrorSpeed(ErrorCurvature>0.002)=nan;
    ErrorCurvature(ErrorCurvature>0.002)=nan;
    
    % Calculate Curvature*Contractility map and truncated maps
    CurvContractMap=nan(size(MeanCurvature,1),length(Contractility));
    SpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
    CurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
    ErrorSpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
    ErrorCurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
    for t=1:length(Contractility)
        IndexT=(VectX(t)-tmin)/tstep+1;
        Vect=MeanCurvature(:,IndexT);
        CurvContractMap(:,t)=Vect.*Contractility(t)*3600; % Express in h-1
        SpeedSubset(:,t)=MeanSpeed(:,IndexT);
        CurvatureSubset(:,t)=MeanCurvature(:,IndexT);
        ErrorSpeedSubset(:,t)=ErrorSpeed(:,IndexT);
        ErrorCurvatureSubset(:,t)=ErrorCurvature(:,IndexT);
    end
    
    
    % Plot deepening speed as a function of curvature ////////////////////
    figure()
    temp=jet;
    stepx=5;
    % Plotting points
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        plot(CurvatureSubset(1:stepx:end,t),SpeedSubset(1:stepx:end,t),'o','MarkerFaceColor',temp(col,:),'MarkerEdgeColor',temp(col,:),'MarkerSize',5)
        hold on
    end
    % Plotting standard error to the mean
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        errorbar(CurvatureSubset(1:stepx:end,t),SpeedSubset(1:stepx:end,t),ErrorCurvatureSubset(1:stepx:end,t),'horizontal','o','Color',temp(col,:),'Marker','none');
        errorbar(CurvatureSubset(1:stepx:end,t),SpeedSubset(1:stepx:end,t),ErrorSpeedSubset(1:stepx:end,t),'vertical','o','Color',temp(col,:),'Marker','none');
    end
    % Plotting linear trend
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        mdl=fitlm(CurvatureSubset(:,t),SpeedSubset(:,t),'linear','Intercept',false);
        minX=min(CurvatureSubset(:,t));
        if minX>0
            minX=0;
        end
        maxX=max(CurvatureSubset(:,t));
        plot([minX maxX],mdl.Coefficients.Estimate*[minX maxX],'Color',temp(col,:),'LineWidth',1.5,'LineStyle','--');
        %text(0.001,14-t-1,['R²=' num2str(round(100*mdl.Rsquared.Adjusted)/100)],'Color',temp(col,:));
    end
    hold off
    legend({'16hAPF' '18hAPF' '20hAPF' '22hAPF' '24hAPF'},'Location','NorthWest')
    xlabel('Curvature (µm^{-1})')
    ylabel('Speed (µm.h^{-1})');
    ax=gca;
    ax.XRuler.Exponent=-3;
    xlim([-0.0015 0.008])
    ylim([-2 15])
    xticks(0:0.002:0.008)
    yticks(0:5:15)
    set(findall(gcf,'-property','FontSize'),'FontSize',13)
    title(Names{condition})
    set(gcf,'Position',[100 100 400 350])
    
    
    
    % Plot deepening speed as a function of curvature X recoil velocity ////////////////////
    figure()
    stepx=5;
    ErrorCurvContract=nan(size(CurvContractMap));
    for t=1:size(CurvContractMap,2)
        MeanRecoil=ApicalRecoils{condition}(t);
        ErrorRecoil=ApicalRecoilsError{condition}(t);
        for x=1:size(CurvContractMap,1)
            ErrorCurvContract(x,t)=MeanRecoil*ErrorCurvatureSubset(x,t)+CurvatureSubset(x,t)*ErrorRecoil+ErrorRecoil*ErrorCurvatureSubset(x,t);
            ErrorCurvContract(x,t)=ErrorCurvContract(x,t)*3600; % converted in h-1
        end
    end
    temp=jet;
    % Plotting points
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        plot(CurvContractMap(1:stepx:end,t),SpeedSubset(1:stepx:end,t),'o','MarkerFaceColor',temp(col,:),'MarkerEdgeColor',temp(col,:),'MarkerSize',5)
        hold on
    end
    % Plotting standard error to the mean
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        errorbar(CurvContractMap(1:stepx:end,t),SpeedSubset(1:stepx:end,t),ErrorCurvContract(1:stepx:end,t),'horizontal','o','Color',temp(col,:),'Marker','none');
        errorbar(CurvContractMap(1:stepx:end,t),SpeedSubset(1:stepx:end,t),ErrorSpeedSubset(1:stepx:end,t),'vertical','o','Color',temp(col,:),'Marker','none');
    end
    xlabel('Curvature\timesRecoil_{velocity} (h^{-1})')
    ylabel('Speed (µm.h^{-1})');
    xlim([-0.001*3600 0.012*3600])
    ylim([-2 15])
    xticks(0:10:0.012*3600)
    yticks(0:5:15)
    set(findall(gcf,'-property','FontSize'),'FontSize',13)
    mdl=fitlm(CurvContractMap(:),SpeedSubset(:),'linear','Intercept',false);
    Coeffs(condition)=mdl.Coefficients.Estimate;
    CIs(:,condition)=coefCI(mdl);
    title(['R²=' num2str(1/100*round(mdl.Rsquared.Adjusted*100))]);
    minX=min(CurvContractMap(:));
    if minX>0
        minX=0;
    end
    maxX=max(CurvContractMap(:));
    plot([minX maxX],mdl.Coefficients.Estimate*[minX maxX],'Color','black','LineWidth',1.5,'LineStyle','--');
    legend({'16hAPF' '18hAPF' '20hAPF' '22hAPF' '24hAPF'},'Location','NorthWest')
    hold off
    set(gcf,'Position',[100 100 400 350])
    

    % Pooling all points
    PooledCurvContract=cat(3,PooledCurvContract,CurvContractMap);
    PooledSpeeds=cat(3,PooledSpeeds,SpeedSubset);
    PooledCurvContractError=cat(3,PooledCurvContractError,ErrorCurvContract);
    PooledSpeedsError=cat(3,PooledSpeedsError,ErrorSpeedSubset);
end
% ////////////////////////////////////////////////////////////////////////


% Treatment of SideFlattening ////////////////////////////////////////////
% Choice of a threshold value for curvature, to use either recoil velocity data for flattened or non-flattened
ThresholdFlatNonFlat=0.002;
for condition=10
    % Load data
    Curvatures=PoolCurvatures{condition};
    Speeds=PoolSpeeds{condition};
    ContractilityFlat=ApicalRecoils{1};
    ContractilityNonFlat=ApicalRecoils{9};
    
    % Choice of the minimal sampling:
    % (when the sample is big enough, only values covered by 5 animals are considered, otherwise, 2)
    if size(Curvatures,3)>7
        NumMini=4;
    else
        NumMini=2;
    end
    
    % Average and error calculation
    MeanCurvature=nan(size(Curvatures,1),size(Curvatures,2));
    ErrorCurvature=nan(size(Curvatures,1),size(Curvatures,2));
    for x=1:size(Curvatures,1)
        for y=1:size(Curvatures,2)
            Vect=squeeze(Curvatures(x,y,:));
            index=find(~isnan(Vect));
            if length(index)>=NumMini
                MeanCurvature(x,y)=mean(Vect(index));
                ErrorCurvature(x,y)=std(Vect(index))./sqrt(length(index));
            end
        end
    end
    MeanSpeed=nan(size(Curvatures,1),size(Curvatures,2));
    ErrorSpeed=nan(size(Curvatures,1),size(Curvatures,2));
    for x=1:size(Speeds,1)
        for y=1:size(Speeds,2)
            Vect=squeeze(Speeds(x,y,:));
            index=find(~isnan(Vect));
            if length(index)>=NumMini
                MeanSpeed(x,y)=mean(Vect(index));
                ErrorSpeed(x,y)=std(Vect(index))./sqrt(length(index));
            end
        end
    end
    
    % Filter curvature that are too noisy
    MeanCurvature(ErrorCurvature>0.002)=nan;
    MeanSpeed(ErrorCurvature>0.002)=nan;
    ErrorSpeed(ErrorCurvature>0.002)=nan;
    ErrorCurvature(ErrorCurvature>0.002)=nan;
    
    % Calculate Curvature*Contractility map and truncated maps
    CurvContractMap=nan(size(MeanCurvature,1),length(Contractility));
    SpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
    CurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
    ErrorSpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
    ErrorCurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
    % Identify non-flattened positions using curvature at the first
    % timepoint
    % Identify first timepoint
    temp=nanmean(MeanCurvature,1);
    FirstTimepoint=min(find(~isnan(temp)));
    Vect=MeanCurvature(:,FirstTimepoint);
    indexNonFlattened=find(Vect>ThresholdFlatNonFlat);
    indexNonFlattened(indexNonFlattened>41)=[]; % Restrict the search to the non-flattened side 
    indexFlattened=1:81;
    indexFlattened=setdiff(indexFlattened,indexNonFlattened);
    for t=1:length(Contractility)
        IndexT=(VectX(t)-tmin)/tstep+1;
        Vect=MeanCurvature(:,IndexT);
        CurvContractMap(indexFlattened,t)=Vect(indexFlattened).*ContractilityFlat(t)*3600; % Express in h-1
        CurvContractMap(indexNonFlattened,t)=Vect(indexNonFlattened).*ContractilityNonFlat(t)*3600; % Express in h-1
        SpeedSubset(:,t)=MeanSpeed(:,IndexT);
        CurvatureSubset(:,t)=MeanCurvature(:,IndexT);
        ErrorSpeedSubset(:,t)=ErrorSpeed(:,IndexT);
        ErrorCurvatureSubset(:,t)=ErrorCurvature(:,IndexT);
    end
    
    
    % Plot deepening speed as a function of curvature ////////////////////
    figure()
    temp=jet;
    stepx=5;
    % Plotting points
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        plot(CurvatureSubset(1:stepx:end,t),SpeedSubset(1:stepx:end,t),'o','MarkerFaceColor',temp(col,:),'MarkerEdgeColor',temp(col,:),'MarkerSize',5)
        hold on
    end
    % Plotting standard error to the mean
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        errorbar(CurvatureSubset(1:stepx:end,t),SpeedSubset(1:stepx:end,t),ErrorCurvatureSubset(1:stepx:end,t),'horizontal','o','Color',temp(col,:),'Marker','none');
        errorbar(CurvatureSubset(1:stepx:end,t),SpeedSubset(1:stepx:end,t),ErrorSpeedSubset(1:stepx:end,t),'vertical','o','Color',temp(col,:),'Marker','none');
    end
    % Plotting linear trend
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        mdl=fitlm(CurvatureSubset(:,t),SpeedSubset(:,t),'linear','Intercept',false);
        minX=min(CurvatureSubset(:,t));
        if minX>0
            minX=0;
        end
        maxX=max(CurvatureSubset(:,t));
        plot([minX maxX],mdl.Coefficients.Estimate*[minX maxX],'Color',temp(col,:),'LineWidth',1.5,'LineStyle','--');
        %text(0.001,14-t-1,['R²=' num2str(round(100*mdl.Rsquared.Adjusted)/100)],'Color',temp(col,:));
    end
    hold off
    legend({'16hAPF' '18hAPF' '20hAPF' '22hAPF' '24hAPF'},'Location','NorthWest')
    xlabel('Curvature (µm^{-1})')
    ylabel('Speed (µm.h^{-1})');
    ax=gca;
    ax.XRuler.Exponent=-3;
    xlim([-0.0015 0.008])
    ylim([-2 15])
    xticks(0:0.002:0.008)
    yticks(0:5:15)
    set(findall(gcf,'-property','FontSize'),'FontSize',13)
    title(Names{condition})
    set(gcf,'Position',[100 100 400 350])
    
    
    
    % Plot deepening speed as a function of curvature X recoil velocity ////////////////////
    figure()
    stepx=5;
    ErrorCurvContract=nan(size(CurvContractMap));
    for t=1:size(CurvContractMap,2)
        MeanRecoil=ApicalRecoils{condition}(t);
        ErrorRecoil=ApicalRecoilsError{condition}(t);
        for x=1:size(CurvContractMap,1)
            ErrorCurvContract(x,t)=MeanRecoil*ErrorCurvatureSubset(x,t)+CurvatureSubset(x,t)*ErrorRecoil+ErrorRecoil*ErrorCurvatureSubset(x,t);
            ErrorCurvContract(x,t)=ErrorCurvContract(x,t)*3600; % converted in h-1
        end
    end
    temp=jet;
    % Plotting points
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        plot(CurvContractMap(1:stepx:end,t),SpeedSubset(1:stepx:end,t),'o','MarkerFaceColor',temp(col,:),'MarkerEdgeColor',temp(col,:),'MarkerSize',5)
        hold on
    end
    % Plotting standard error to the mean
    for t=2:length(Contractility)
        col=round(64*(t-1)/(length(Contractility)-1));
        errorbar(CurvContractMap(1:stepx:end,t),SpeedSubset(1:stepx:end,t),ErrorCurvContract(1:stepx:end,t),'horizontal','o','Color',temp(col,:),'Marker','none');
        errorbar(CurvContractMap(1:stepx:end,t),SpeedSubset(1:stepx:end,t),ErrorSpeedSubset(1:stepx:end,t),'vertical','o','Color',temp(col,:),'Marker','none');
    end
    xlabel('Curvature\timesRecoil_{velocity} (h^{-1})')
    ylabel('Speed (µm.h^{-1})');
    xlim([-0.001*3600 50])
    ylim([-2 15])
    xticks(0:10:50)
    yticks(0:5:15)
    set(findall(gcf,'-property','FontSize'),'FontSize',13)
    mdl=fitlm(CurvContractMap(:),SpeedSubset(:),'linear','Intercept',false);
    Coeffs(condition)=mdl.Coefficients.Estimate;
    CIs(:,condition)=coefCI(mdl);
    title(['R²=' num2str(1/100*round(mdl.Rsquared.Adjusted*100))]);
    minX=min(CurvContractMap(:));
    if minX>0
        minX=0;
    end
    maxX=max(CurvContractMap(:));
    plot([minX maxX],mdl.Coefficients.Estimate*[minX maxX],'Color','black','LineWidth',1.5,'LineStyle','--');
    legend({'16hAPF' '18hAPF' '20hAPF' '22hAPF' '24hAPF'},'Location','NorthWest')
    hold off
    set(gcf,'Position',[100 100 400 350])
    

    % Pooling all points
    PooledCurvContract=cat(3,PooledCurvContract,CurvContractMap);
    PooledSpeeds=cat(3,PooledSpeeds,SpeedSubset);
    PooledCurvContractError=cat(3,PooledCurvContractError,ErrorCurvContract);
    PooledSpeedsError=cat(3,PooledSpeedsError,ErrorSpeedSubset);
end
% ////////////////////////////////////////////////////////////////////////

% Condensed CurvXTension plots
Bin=0:0.001*3600:0.010*3600;
temp=jet;
stepx=10;
for condition=2:8
    figure()
    tempX=PooledCurvContract(1:stepx:end,:,condition);
    tempY=PooledSpeeds(1:stepx:end,:,condition);
    tempErrorX=PooledCurvContractError(1:stepx:end,:,condition);
    tempErrorY=PooledSpeedsError(1:stepx:end,:,condition);
    plot(tempX(:),tempY(:),'o','MarkerFaceColor',ColorsSource(condition,:),'MarkerEdgeColor',ColorsSource(condition,:),'MarkerSize',3)
    hold on
    errorbar(tempX(:),tempY(:),tempErrorX(:),'horizontal','o','Color',ColorsSource(condition,:),'Marker','none');
    errorbar(tempX(:),tempY(:),tempErrorY(:),'vertical','o','Color',ColorsSource(condition,:),'Marker','none');
    xlim([-0.001*3600 0.012*3600])
    ylim([-2 15])
    plot(Bin,Bin*Coeffs(condition),'Color',[173/255,173/255,199/255],'LineWidth',2);
    hold off
    xlabel('Curvature\timesVelocity_{recoil} (h^{-1})')
    ylabel('Speed (µm.h^{-1})');
    set(gcf,'Position',[100 100 300 300])
    title(Names{condition})
    
    mdl=fitlm(tempX(:),tempY(:),'linear','Intercept',false);
    Rsquared=round(100*mdl.Rsquared.Adjusted)/100;
    
    text(0.005,2.5,['R²=' num2str(Rsquared)],'Color',ColorsSource(condition,:));
    set(findall(gcf,'-property','FontSize'),'FontSize',13)
end

% Global model
figure()
Bin=0:50;
mdl=fitlm(PooledCurvContract(:),PooledSpeeds(:),'linear','Intercept',false);
for condition=1:8
    tempX=PooledCurvContract(1:stepx:end,:,condition);
    tempY=PooledSpeeds(1:stepx:end,:,condition);
    plot(tempX(:),tempY(:),'o','MarkerFaceColor',ColorsSource(condition,:),'MarkerEdgeColor',ColorsSource(condition,:),'MarkerSize',5,'Marker',Markers{condition})
    hold on
end
hold on
plot(Bin,Bin*mdl.Coefficients.Estimate,'Color',[173/255,173/255,199/255],'LineWidth',2)
hold off
title(['R²=' num2str(1/100*round(mdl.Rsquared.Adjusted*100))]);
xlabel('Curvature\timesRecoilvelocity(h-1)')
ylabel('Speed (µm.h^{-1})')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 550 300])
xlim([-0.002*3600 0.011*3600])
ylim([-2 15])
xticks(0:10:30)
yticks(0:5:15)
for i=1:8
    TempLegend{i}=Names{i};
end
TempLegend{9}='Linear fit';
legend(TempLegend,'Location','WestOutside')

%% Extracting the slope of Speed=f(CurvatureXRecoilVelocity) curve for apical

% Initialization of pooling vectors
AverageSlopes=nan(1,10);
StdSlopes=nan(1,10);
ErrorSlopes=nan(1,10);
RsquaredPooled=[];
SlopesPooled=[];

    
% Condition treatment
for condition=1:9
    % Loading data
    Curvatures=PoolCurvatures{condition};
    Speeds=PoolSpeeds{condition};
    Contractility=ApicalRecoils{condition};

    
    % Sampling factor along the ML axis (x)
    SamplingX=1:5:size(Curvatures,1);
    % Sampling for time (t)
    SamplingT=14:2:24;
    
    % For each animal, calculation of CurvatureXTension and extraction of
    % the slope of the Speed=f(CurvatureXTension) curve
    SlopesAnimal=nan(1,size(Curvatures,3));
    RsquaredAnimal=nan(1,size(Curvatures,3));
    for animal=1:size(Curvatures,3)
        % Calculation of CurvatureXTension and extraction of associated
        % speeds
        CurvTension=nan(length(SamplingX),length(SamplingT));
        SpeedSubset=nan(length(SamplingX),length(SamplingT));
        for t=1:length(SamplingT)
            Tpix=(SamplingT(t)-tmin)/tstep+1;
            for x=1:length(SamplingX)
                Xpix=SamplingX(x);
                CurvTension(x,t)=Curvatures(Xpix,Tpix,animal)*Contractility(t)*3600; % Express in h-1
                SpeedSubset(x,t)=Speeds(Xpix,Tpix,animal);
            end
        end
        index=find(~isnan(CurvTension) & ~isnan(SpeedSubset));
        mdl=fitlm(CurvTension(index),SpeedSubset(index),'linear','Intercept',false);
        RsquaredAnimal(animal)=mdl.Rsquared.Adjusted;
        SlopesAnimal(animal)=mdl.Coefficients.Estimate;
    end
    
    % Saving average slope, std/error of slope and Rsquared
    AverageSlopes(condition)=mean(SlopesAnimal);
    StdSlopes(condition)=std(SlopesAnimal);
    ErrorSlopes(condition)=std(SlopesAnimal)/sqrt(length(SlopesAnimal));
    RsquaredPooled{condition}=RsquaredAnimal;
    SlopesPooled{condition}=SlopesAnimal;
end
for condition=10
    % Loading data
    Curvatures=PoolCurvatures{condition};
    Speeds=PoolSpeeds{condition};
    ContractilityFlat=ApicalRecoils{1};
    ContractilityNonFlat=ApicalRecoils{9};

    % Sampling factor along the ML axis (x)
    SamplingX=1:5:size(Curvatures,1);
    % Sampling for time (t)
    SamplingT=14:2:24;
    
    % For each animal, calculation of CurvatureXTension and extraction of
    % the slope of the Speed=f(CurvatureXTension) curve
    SlopesAnimal=nan(1,size(Curvatures,3));
    RsquaredAnimal=nan(1,size(Curvatures,3));
    for animal=1:size(Curvatures,3)
        % Calculation of CurvatureXTension and extraction of associated
        % speeds
        CurvTension=nan(length(SamplingX),length(SamplingT));
        SpeedSubset=nan(length(SamplingX),length(SamplingT));
        for t=1:length(SamplingT)
            Tpix=(SamplingT(t)-tmin)/tstep+1;
            for x=1:length(SamplingX)
                Xpix=SamplingX(x);
                if Curvatures(Xpix,Tpix,animal)>=ThresholdFlatNonFlat && Xpix<41
                    CurvTension(x,t)=Curvatures(Xpix,Tpix,animal)*ContractilityNonFlat(t)*3600; % Express in h-1
                else
                    CurvTension(x,t)=Curvatures(Xpix,Tpix,animal)*ContractilityFlat(t)*3600; % Express in h-1
                end
                SpeedSubset(x,t)=Speeds(Xpix,Tpix,animal);
            end
        end
        index=find(~isnan(CurvTension) & ~isnan(SpeedSubset));
        mdl=fitlm(CurvTension(index),SpeedSubset(index),'linear','Intercept',false);
        RsquaredAnimal(animal)=mdl.Rsquared.Adjusted;
        SlopesAnimal(animal)=mdl.Coefficients.Estimate;
    end
    
    % Saving average slope, std/error of slope and Rsquared
    AverageSlopes(condition)=mean(SlopesAnimal);
    StdSlopes(condition)=std(SlopesAnimal);
    ErrorSlopes(condition)=std(SlopesAnimal)/sqrt(length(SlopesAnimal));
    RsquaredPooled{condition}=RsquaredAnimal;
    SlopesPooled{condition}=SlopesAnimal;
end


% Plotting the slopes of the models with sem
figure()
silver=[173/255,173/255,199/255];
hold on
errorbar(1:8,AverageSlopes(1:8),StdSlopes(1:8),'o','MarkerFaceColor',silver','MarkerSize',7,'Color',silver')
hold off
xticks(1:8)
xticklabels(Names);
xtickangle(30)
ylim([0 0.65])
ylabel('Slope (µm^{-1})')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 600 350])
xlim([0 9])

figure()
hold on
silver=[173/255,173/255,199/255];
errorbar(1:3,AverageSlopes([1 9 10]),StdSlopes([1 9 10]),'o','MarkerFaceColor',silver','MarkerSize',7,'Color',silver')
hold off
xticks(1:8)
Names2={'Flattened' 'Non-flattened' 'Lateral flattening'};
xticklabels(Names2);
xtickangle(30)
ylim([0 0.65])
ylabel('Slope (µm^{-1})')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 300 350])
xlim([0.5 3.5])

%% Plotting Curvature*Contractility for basal

% Initialization of pooling vectors
PooledCurvContractBasal=[];
PooledSpeedsBasal=[];
SlopeBasal=[];
SlopeCIBasal=[];
PooledCurvContractErrorBasal=[];
PooledSpeedsError=[];

for condition=1:8
    % Loading data
    Curvatures=PoolCurvaturesBasal{condition};
    Speeds=PoolSpeedsBasal{condition};
    Contractility=BasalRecoils{condition};
    
    if size(Curvatures,3)>7
        NumMini=5;
    else
        NumMini=2;
    end
    
    % Averaging and std calculation
    MeanCurvature=nan(size(Curvatures,1),size(Curvatures,2));
    StdCurvature=nan(size(Curvatures,1),size(Curvatures,2));
    ErrorCurvature=nan(size(Curvatures,1),size(Curvatures,2));
    for x=1:size(Curvatures,1)
        for y=1:size(Curvatures,2)
            Vect=squeeze(Curvatures(x,y,:));
            index=find(~isnan(Vect));
            if length(index)>=NumMini
                MeanCurvature(x,y)=mean(Vect(index));
                StdCurvature(x,y)=std(Vect(index));
                ErrorCurvature(x,y)=std(Vect(index))./sqrt(length(index));
            end
        end
    end
    
    MeanSpeed=nan(size(Curvatures,1),size(Curvatures,2));
    StdSpeed=nan(size(Curvatures,1),size(Curvatures,2));
    ErrorSpeed=nan(size(Curvatures,1),size(Curvatures,2));
    for x=1:size(Speeds,1)
        for y=1:size(Speeds,2)
            Vect=squeeze(Speeds(x,y,:));
            index=find(~isnan(Vect));
            if length(index)>=NumMini
                MeanSpeed(x,y)=mean(Vect(index));
                StdSpeed(x,y)=std(Vect(index));
                ErrorSpeed(x,y)=std(Vect(index))./sqrt(length(index));
            end
        end
    end
    
    % Filtering curvature that are too noisy
    MeanCurvature(ErrorCurvature>0.002)=nan;
    StdCurvature(ErrorCurvature>0.002)=nan;
    MeanSpeed(ErrorCurvature>0.002)=nan;
    StdSpeed(ErrorCurvature>0.002)=nan;
    ErrorSpeed(ErrorCurvature>0.002)=nan;
    ErrorCurvature(ErrorCurvature>0.002)=nan;
    
    % Calculating Curvature*Contractility map and truncated maps
    CurvContractMap=nan(size(MeanCurvature,1),length(Contractility));
    SpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
    CurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
    StdSpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
    StdCurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
    ErrorSpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
    ErrorCurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
    for t=1:length(Contractility)
        IndexT=(VectX(t)-tmin)/tstep+1;
        Vect=MeanCurvature(:,IndexT);
        CurvContractMap(:,t)=Vect.*Contractility(t);
        SpeedSubset(:,t)=MeanSpeed(:,IndexT);
        CurvatureSubset(:,t)=MeanCurvature(:,IndexT);
        StdSpeedSubset(:,t)=StdSpeed(:,IndexT);
        StdCurvatureSubset(:,t)=StdCurvature(:,IndexT);
        ErrorSpeedSubset(:,t)=ErrorSpeed(:,IndexT);
        ErrorCurvatureSubset(:,t)=ErrorCurvature(:,IndexT);
    end
    % Pooling all points
    PooledCurvContractBasal=cat(3,PooledCurvContractBasal,CurvContractMap);
    PooledSpeedsBasal=cat(3,PooledSpeedsBasal,SpeedSubset);
    PooledCurvContractErrorBasal=cat(3,PooledCurvContractErrorBasal,ErrorCurvContract);
    PooledSpeedsError=cat(3,PooledSpeedsError,ErrorSpeedSubset);
end


% Global model
figure()
Bin=0:50;
mdl=fitlm(PooledCurvContractBasal(:)*3600,PooledSpeedsBasal(:),'linear','Intercept',false);
SubsetConditions=[1:8];
modelsubsetX=[];
modelsubsetY=[];
for condition=1:8
    tempX=PooledCurvContractBasal(1:stepx:end,:,condition)*3600;
    tempY=PooledSpeedsBasal(1:stepx:end,:,condition);
    plot(tempX(:),tempY(:),'o','MarkerFaceColor',ColorsSource(condition,:),'MarkerEdgeColor',ColorsSource(condition,:),'MarkerSize',5,'Marker',Markers{condition})
    hold on
    modelsubsetX=cat(1,modelsubsetX,tempX(:));
    modelsubsetY=cat(1,modelsubsetY,tempY(:));
end
mdl=fitlm(modelsubsetX,modelsubsetY,'linear','Intercept',false);
hold on
plot(Bin,Bin*mdl.Coefficients.Estimate,'Color',[173/255,173/255,199/255],'LineWidth',2)
hold off
title(['R²=' num2str(1/100*round(mdl.Rsquared.Adjusted*100))]);
xlabel('Curvature\timesRecoilvelocity(h-1)')
ylabel('Speed (µm.h^{-1})')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 550 300])
xlim([-0.002*3600 55])
ylim([-2 10])
xticks(0:10:50)
yticks(0:5:15)
for i=1:9
    TempLegend{i}=Names{i};
end
TempLegend{10}='Linear fit';
legend(TempLegend,'Location','WestOutside')


%% Compare speed(t) of flattened and non-flattened
% Data near the midline, where flattening is maximal, are chosen (PositionML from -50% to 50%)

% Flattened /////////////////////////////////////////////////////////////
condition=1;
Curvatures=PoolCurvatures{condition};
Speeds=PoolSpeeds{condition};
step=5;
PoolVectSpeed=[];
PoolVectCurvature=[];
for animal=1:size(Speeds,3)
    Map1=Speeds(:,:,animal);
    Vect=nanmean(Map1(41-step:41+step,:),1);
    PoolVectSpeed(:,animal)=Vect(:);
    
    Map2=Curvatures(:,:,animal);
    Vect=nanmean(Map2(41-step:41+step,:),1);
    PoolVectCurvature(:,animal)=Vect(:);
end

% Animal average/sem
AverageSpeed=nan(size(PoolVectSpeed,1),1);
SEMSpeed=nan(size(PoolVectSpeed,1),1);
AverageCurvature=nan(size(PoolVectSpeed,1),1);
SEMCurvature=nan(size(PoolVectSpeed,1),1);
for t=1:size(PoolVectSpeed,1)
    Vect=PoolVectSpeed(t,:);
    index=find(~isnan(Vect));
    if length(index)>=NumMini
        AverageSpeed(t)=nanmean(Vect);
        SEMSpeed(t)=nanstd(Vect(index))./sqrt(length(index));
    end
    
    Vect=PoolVectCurvature(t,:);
    index=find(~isnan(Vect));
    if length(index)>=NumMini
        AverageCurvature(t)=nanmean(Vect);
        SEMCurvature(t)=nanstd(Vect(index))./sqrt(length(index));
    end
end

% Non flattened /////////////////////////////////////////////////////////
condition=9;
Curvatures=PoolCurvatures{condition};
Speeds=PoolSpeeds{condition};
step=5;
PoolVectSpeed2=[];
PoolVectCurvature2=[];
for animal=1:size(Speeds,3)
    Map1=Speeds(:,:,animal);
    Vect=nanmean(Map1(41-step:41+step,:),1);
    PoolVectSpeed2(:,animal)=Vect(:);
    
    Map2=Curvatures(:,:,animal);
    Vect=nanmean(Map2(41-step:41+step,:),1);
    PoolVectCurvature2(:,animal)=Vect(:);
end

% Animal average/sem
AverageSpeedCurved=nan(size(PoolVectSpeed2,1),1);
SEMSpeedCurved=nan(size(PoolVectSpeed2,1),1);
AverageCurvatureCurved=nan(size(PoolVectSpeed2,1),1);
SEMCurvatureCurved=nan(size(PoolVectSpeed2,1),1);
for t=1:size(PoolVectSpeed2,1)
    Vect=PoolVectSpeed2(t,:);
    index=find(~isnan(Vect));
    if length(index)>=NumMini
        AverageSpeedCurved(t)=nanmean(Vect);
        SEMSpeedCurved(t)=nanstd(Vect(index))./sqrt(length(index));
    end
    
    Vect=PoolVectCurvature2(t,:);
    index=find(~isnan(Vect));
    if length(index)>=NumMini
        AverageCurvatureCurved(t)=nanmean(Vect);
        SEMCurvatureCurved(t)=nanstd(Vect(index))./sqrt(length(index));
    end
end

% Stats for comparing speeds
Pvalue=nan(1,size(PoolVectSpeed2,1));
for t=1:size(PoolVectSpeed,1)
    Vect1=PoolVectSpeed(t,:);
    Vect2=PoolVectSpeed2(t,:);
    if length(Vect1)>3 & length(Vect2)>3
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(t)=p;
    end
end

figure()
BinTime=16:tstep:24;
plot(BinTime,AverageSpeed(9:41),'Color','blue','LineWidth',2)
hold on
plot(BinTime,AverageSpeedCurved(9:41),'Color','red','LineWidth',2)
x2=[BinTime,fliplr(BinTime)];
inBetween=[AverageSpeed(9:41)'+SEMSpeed(9:41)', fliplr(AverageSpeed(9:41)'-SEMSpeed(9:41)')];
h=fill(x2,inBetween,'blue','LineStyle','none');
set(h,'facealpha',.25)
x2=[BinTime,fliplr(BinTime)];
inBetween=[AverageSpeedCurved(9:41)'+SEMSpeedCurved(9:41)', fliplr(AverageSpeedCurved(9:41)'-SEMSpeedCurved(9:41)')];
h=fill(x2,inBetween,'red','LineStyle','none');
set(h,'facealpha',.25)
xlim([16 24])
ylim([0 15])
% ////////////////////////////////////////////////////////////////////
% Pvalue bars
hold on
PValue=Pvalue(1:41);
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
Fill=[14 15 15 14];
BinTime=14:0.25:24;
ColorPoints2='red';
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
rectangle('Position',[16 14 BinTime(end)-16 15-14],'EdgeColor','black','LineWidth',1,'FaceColor','none');
% ///////////////////////////////////////////////////////////////////////
legend({'Flattened' 'Non-flattened'},'Location','best')
xlabel('Time (hAPF)')
ylabel('Speed (µm.h^{1})')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])
yticks(0:4:12)



% Stats for comparing curvatures
Pvalue=nan(1,size(PoolVectSpeed2,1));
for t=1:size(PoolVectSpeed,1)
    Vect1=PoolVectCurvature(t,:);
    Vect2=PoolVectCurvature2(t,:);
    if length(Vect1)>3 & length(Vect2)>3
        [h,p]=ttest2(Vect1,Vect2,'VarType','unequal');
        Pvalue(t)=p;
    end
end

figure()
BinTime=16:tstep:24;
plot(BinTime,AverageCurvature(9:41),'Color','blue','LineWidth',2)
hold on
plot(BinTime,AverageCurvatureCurved(9:41),'Color','red','LineWidth',2)
x2=[BinTime,fliplr(BinTime)];
inBetween=[AverageCurvature(9:41)'+SEMCurvature(9:41)', fliplr(AverageCurvature(9:41)'-SEMCurvature(9:41)')];
h=fill(x2,inBetween,'blue','LineStyle','none');
set(h,'facealpha',.25)
x2=[BinTime,fliplr(BinTime)];
inBetween=[AverageCurvatureCurved(9:41)'+SEMCurvatureCurved(9:41)', fliplr(AverageCurvatureCurved(9:41)'-SEMCurvatureCurved(9:41)')];
h=fill(x2,inBetween,'red','LineStyle','none');
set(h,'facealpha',.25)
xlim([16 24])
ylim([-0.001 0.0055])
% ////////////////////////////////////////////////////////////////////
% Pvalue bars
hold on
PValue=Pvalue(1:41);
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
Fill=[0.005 0.0055 0.0055 0.005];
BinTime=14:0.25:24;
ColorPoints2='red';
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
rectangle('Position',[16 0.005 BinTime(end)-16 0.0005],'EdgeColor','black','LineWidth',1,'FaceColor','none');
% ///////////////////////////////////////////////////////////////////////
legend({'Flattened' 'Non-flattened'},'Location','SouthEast')
xlabel('Time (hAPF)')
ylabel('Curvature (µm^{-1})')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])
yticks(0:.001:0.005)


%% Compare speed(t) (and curvature(t)) of flattened and non-flattened sides in the SideFlattened condition
condition=10;
ThresholdFlat=0.001;
ThresholdCurved=.0025;

Curvatures=PoolCurvatures{condition};
Speeds=PoolSpeeds{condition};
FlatAsymmetric=[];
CurvedAsymmetric=[];
FlatAsymmetricCurvature=[];
CurvedAsymmetricCurvature=[];
for animal=1:size(Curvatures,3)
    Curvature=Curvatures(:,:,animal);
    Speed=Speeds(:,:,animal);
    Vect=nanmean(Curvature(:,13:21),2);
    index=find(Vect<ThresholdFlat);
    index(index<41)=[];
    SpeedAnimal=squeeze(nanmean(Speed(index,:),1));
    CurvatureAnimal=squeeze(nanmean(Curvature(index,:),1));
    FlatAsymmetric(:,animal)=SpeedAnimal;
    FlatAsymmetricCurvature(:,animal)=CurvatureAnimal;
    
    index=find(Vect>ThresholdCurved);
    index(index>41)=[];
    SpeedAnimal=squeeze(nanmean(Speed(index,:),1));
    CurvatureAnimal=squeeze(nanmean(Curvature(index,:),1));
    CurvedAsymmetric(:,animal)=SpeedAnimal;
    CurvedAsymmetricCurvature(:,animal)=CurvatureAnimal;
end
% Binning
FlatAsymmetricAverage=[];
FlatAsymmetricError=[];
CurvedAsymmetricAverage=[];
CurvedAsymmetricError=[];
FlatAsymmetricCurvatureAverage=[];
FlatAsymmetricCurvatureError=[];
CurvedAsymmetricCurvatureAverage=[];
CurvedAsymmetricCurvatureError=[];
VectT=tmin:tstep:24;
Pvalue=nan(1,length(VectT));
PvalueCurvature=nan(1,length(VectT));
for t=1:length(VectT)
    % Speed //////////////////////////////////////////////////////////////
    Vect=FlatAsymmetric(t,:);
    if sum(~isnan(Vect))>=3
        FlatAsymmetricAverage(t)=nanmean(Vect);
        FlatAsymmetricError(t)=nanstd(Vect)./sqrt(sum(~isnan(Vect)));
        temp1=Vect(~isnan(Vect));
    end
    
    Vect=CurvedAsymmetric(t,:);
    if sum(~isnan(Vect))>=3
        CurvedAsymmetricAverage(t)=nanmean(Vect);
        CurvedAsymmetricError(t)=nanstd(Vect)./sqrt(sum(~isnan(Vect)));
        temp2=Vect(~isnan(Vect));
    end
    
    if length(temp1)>=3 & length(temp2)>=3
        [h,p]=ttest2(temp1,temp2,'VarType','unequal');
        Pvalue(t)=p;
    end

    % Curvature //////////////////////////////////////////////////////////
    Vect=FlatAsymmetricCurvature(t,:);
    if sum(~isnan(Vect))>=3
        FlatAsymmetricCurvatureAverage(t)=nanmean(Vect);
        FlatAsymmetricCurvatureError(t)=nanstd(Vect)./sqrt(sum(~isnan(Vect)));
        %FlatAsymmetricStd(t)=nanstd(Vect);
        temp1=Vect(~isnan(Vect));
    end
    
    Vect=CurvedAsymmetricCurvature(t,:);
    if sum(~isnan(Vect))>=3
        CurvedAsymmetricCurvatureAverage(t)=nanmean(Vect);
        CurvedAsymmetricCurvatureError(t)=nanstd(Vect)./sqrt(sum(~isnan(Vect)));
        %CurvedAsymmetricStd(t)=nanstd(Vect);
        temp2=Vect(~isnan(Vect));
    end
    
    if length(temp1)>=3 & length(temp2)>=3
        [h,p]=ttest2(temp1,temp2,'VarType','unequal');
        PvalueCurvature(t)=p;
    end
end

figure()
plot(VectT,FlatAsymmetricAverage,'Color','blue','LineWidth',2)
hold on
plot(VectT,CurvedAsymmetricAverage,'Color','red','LineWidth',2)
x2=[VectT,fliplr(VectT)];
inBetween=[FlatAsymmetricAverage+FlatAsymmetricError, fliplr(FlatAsymmetricAverage-FlatAsymmetricError)];
h=fill(x2,inBetween,'blue','LineStyle','none');
set(h,'facealpha',.25)
x2=[VectT,fliplr(VectT)];
inBetween=[CurvedAsymmetricAverage+CurvedAsymmetricError, fliplr(CurvedAsymmetricAverage-CurvedAsymmetricError)];
h=fill(x2,inBetween,'red','LineStyle','none');
set(h,'facealpha',.25)
xlim([16 24])
ylim([0 15])
% ////////////////////////////////////////////////////////////////////
% Pvalue bars
hold on
PValue=Pvalue;
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
Fill=[14 15 15 14];
BinTime=14:0.25:24;
ColorPoints2='red';
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
rectangle('Position',[16 14 BinTime(end)-16 15-14],'EdgeColor','black','LineWidth',1,'FaceColor','none');
% ///////////////////////////////////////////////////////////////////////
%legend({'Flattened side' 'Non-flattened side'},'Location','NorthWest')
xlabel('Time (hAPF)')
ylabel('Speed (µm.h^{1})')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])
yticks(0:4:14)


figure()
plot(VectT,FlatAsymmetricCurvatureAverage,'Color','blue','LineWidth',2)
hold on
plot(VectT,CurvedAsymmetricCurvatureAverage,'Color','red','LineWidth',2)
x2=[VectT,fliplr(VectT)];
inBetween=[FlatAsymmetricCurvatureAverage+FlatAsymmetricCurvatureError, fliplr(FlatAsymmetricCurvatureAverage-FlatAsymmetricCurvatureError)];
h=fill(x2,inBetween,'blue','LineStyle','none');
set(h,'facealpha',.25)
x2=[VectT,fliplr(VectT)];
inBetween=[CurvedAsymmetricCurvatureAverage+CurvedAsymmetricCurvatureError, fliplr(CurvedAsymmetricCurvatureAverage-CurvedAsymmetricCurvatureError)];
h=fill(x2,inBetween,'red','LineStyle','none');
set(h,'facealpha',.25)
xlim([16 24])
ylim([-0.001 0.008])
% ////////////////////////////////////////////////////////////////////
% Pvalue bars
hold on
PValue=PvalueCurvature;
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
Fill=[0.0075 0.008 0.008 0.0075];
BinTime=14:0.25:24;
ColorPoints2='red';
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
rectangle('Position',[16 0.0075 BinTime(end)-16 0.0005],'EdgeColor','black','LineWidth',1,'FaceColor','none');
% ///////////////////////////////////////////////////////////////////////
legend({'Flattened side' 'Non-flattened side'},'Location','SouthEast')
xlabel('Time (hAPF)')
ylabel('Curvature (µm^{-1})')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])
yticks(0:0.001:0.007)

%% Plot kymograph of curvature for control flattened

% Calculation of the quantities
condition=1;
% Loading data
Curvatures=PoolCurvatures{condition};
Speeds=PoolSpeeds{condition};
Contractility=ApicalRecoils{condition};
NumMini=3;

% Averaging and std calculation
MeanCurvature=nan(size(Curvatures,1),size(Curvatures,2));
StdCurvature=nan(size(Curvatures,1),size(Curvatures,2));
ErrorCurvature=nan(size(Curvatures,1),size(Curvatures,2));
for x=1:size(Curvatures,1)
    for y=1:size(Curvatures,2)
        Vect=squeeze(Curvatures(x,y,:));
        index=find(~isnan(Vect));
        if length(index)>=NumMini
            MeanCurvature(x,y)=mean(Vect(index));
            StdCurvature(x,y)=std(Vect(index));
            ErrorCurvature(x,y)=std(Vect(index))./sqrt(length(index));
        end
    end
end

MeanSpeed=nan(size(Curvatures,1),size(Curvatures,2));
StdSpeed=nan(size(Curvatures,1),size(Curvatures,2));
ErrorSpeed=nan(size(Curvatures,1),size(Curvatures,2));
for x=1:size(Speeds,1)
    for y=1:size(Speeds,2)
        Vect=squeeze(Speeds(x,y,:));
        index=find(~isnan(Vect));
        if length(index)>=NumMini
            MeanSpeed(x,y)=mean(Vect(index));
            StdSpeed(x,y)=std(Vect(index));
            ErrorSpeed(x,y)=std(Vect(index))./sqrt(length(index));
        end
    end
end

% Calculating Curvature*Contractility map and truncated maps
CurvContractMap=nan(size(MeanCurvature,1),length(Contractility));
SpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
CurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
ErrorSpeedSubset=nan(size(MeanCurvature,1),length(Contractility));
ErrorCurvatureSubset=nan(size(MeanCurvature,1),length(Contractility));
for t=1:length(Contractility)
    IndexT=(VectX(t)-tmin)/tstep+1;
    Vect=MeanCurvature(:,IndexT);
    CurvContractMap(:,t)=Vect.*Contractility(t);
    SpeedSubset(:,t)=MeanSpeed(:,IndexT);
    CurvatureSubset(:,t)=MeanCurvature(:,IndexT);
    StdSpeedSubset(:,t)=StdSpeed(:,IndexT);
    StdCurvatureSubset(:,t)=StdCurvature(:,IndexT);
    ErrorSpeedSubset(:,t)=ErrorSpeed(:,IndexT);
    ErrorCurvatureSubset(:,t)=ErrorCurvature(:,IndexT);
end

% Kymograph of curvature(x,t) ////////////////////////////////////////////
figure()
Map=MeanCurvature;
imagesc(Map,'AlphaData',~isnan(Map))
colormap jet
cb=colorbar;
colormap jet
xlabel('Time (hAPF)')
ylabel('Position_{ML} (%)')
line([1 size(Map,1)], [41,41],'Color','black','LineWidth',2,'LineStyle','--');
xticklabels = tmin:2:tmax;
xticks = linspace(1, size(Map, 2), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
set(findall(gcf,'-property','FontSize'),'FontSize',14)
% On met les valeurs réelles en % sur l'axe des y
yticklabels = xmin:100:xmax;
yticks=(yticklabels-xmin)/xstep+1;
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels); 
title(cb,'Curvature (µm^{-1})')
cb.Ticks=([0:0.002:0.008]);
xlim([1 (24-tmin)/tstep+1])
camroll(-90)
ylim([(-300-xmin)/xstep+1 (300-xmin)/xstep+1])
    

%% Dual plot curvature(t) and speed(t) of the flattened region of flattened controls

% Loading data
condition=1;
Curvatures=PoolCurvatures{condition};
Speeds=PoolSpeeds{condition};
Contractility=ApicalRecoils{condition};
Contractility=interp1(14:2:24,Contractility,tmin:tstep:tmax);
NumMini=3;

% Calculating midline curves
step=5;
PoolVectSpeed=[];
PoolVectCurvature=[];
PoolVectProduct=[];
for animal=1:size(Speeds,3)
    Map1=Speeds(:,:,animal);
    Vect=nanmean(Map1(41-step:41+step,:),1);
    PoolVectSpeed(:,animal)=Vect(:);
    
    Map2=Curvatures(:,:,animal);
    Vect=nanmean(Map2(41-step:41+step,:),1);
    PoolVectCurvature(:,animal)=Vect(:);
    
    for t=1:size(Speeds,2)
        Vect=Map1(:,t)*Contractility(t);
        Map3(:,t)=Vect(:);
    end
    Vect=nanmean(Map3(41-step:41+step,:),1);
    PoolVectProduct(:,animal)=Vect(:);
end

% Animal average/sem
AverageSpeed=nan(size(PoolVectProduct,1),1);
SEMSpeed=nan(size(PoolVectProduct,1),1);
AverageCurvature=nan(size(PoolVectProduct,1),1);
SEMCurvature=nan(size(PoolVectProduct,1),1);
AverageProduct=nan(size(PoolVectProduct,1),1);
SEMProduct=nan(size(PoolVectProduct,1),1);
for t=1:size(PoolVectProduct,1)
    Vect=PoolVectSpeed(t,:);
    index=find(~isnan(Vect));
    if length(index)>=NumMini
        AverageSpeed(t)=nanmean(Vect);
        SEMSpeed(t)=nanstd(Vect(index))./sqrt(length(index));
    end
    
    Vect=PoolVectCurvature(t,:);
    index=find(~isnan(Vect));
    if length(index)>=NumMini
        AverageCurvature(t)=nanmean(Vect);
        SEMCurvature(t)=nanstd(Vect(index))./sqrt(length(index));
    end
    
        Vect=PoolVectProduct(t,:);
    index=find(~isnan(Vect));
    if length(index)>=NumMini
        AverageProduct(t)=nanmean(Vect);
        SEMProduct(t)=nanstd(Vect(index))./sqrt(length(index));
    end
end

% Plot
clear yticks
figure()
yyaxis left
set(gca,'YColor','green')
BinTime=16:tstep:24;
x2=[BinTime,fliplr(BinTime)];
inBetween=[AverageSpeed(9:41)'+SEMSpeed(9:41)', fliplr(AverageSpeed(9:41)'-SEMSpeed(9:41)')];
h=fill(x2, inBetween, 'green','LineStyle','none');
set(h,'facealpha',.25)
hold on
plot(16:tstep:24,AverageSpeed(9:41),'LineWidth',2,'LineStyle','-','Color','green')
hold off
ylabel('Deepening speed (µm/h)')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
ylim([0 11])
yticks(0:5:15)

yyaxis right
set(gca,'YColor','blue')
BinTime=16:tstep:24;
x2=[BinTime,fliplr(BinTime)];
inBetween=[(AverageCurvature(9:41)+SEMCurvature(9:41))', fliplr((AverageCurvature(9:41)-SEMCurvature(9:41))')];
h=fill(x2, inBetween, 'blue','LineStyle','none');
set(h,'facealpha',.25)
hold on
plot(16:tstep:24,AverageCurvature(9:41),'LineWidth',2,'LineStyle','-','Color','blue');
hold off
ylim([-0.0005 0.005])
yticks(0:0.001:0.005)
ylabel('Curvature (µm^{1})')
xlabel('Time (hAPF)');
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[50, 50, 400, 350]);



%% Plot speed(t) and curvature (t) in the animals in which medial tissue is mechanically isolated by laser ablations

% Parameters ************************************************************
Removing=8; % Exclusion of n Xsteps next to the ablations

% Curved *****************************************************************
condition=12;

% Loading data
Curvatures=PoolCurvatures{condition};
Speeds=PoolSpeeds{condition};
Contractility=ApicalRecoils{condition};

% For each animal, averaging speed and curvature filtering out ablation
% neighborhood
PoolAverageCurvature=[];
PoolAverageSpeed=[];
for animal=1:size(Curvatures,3)
    % Loading maps
    Curvature=Curvatures(:,:,animal);
    Speed=Speeds(:,:,animal);
    
    % Removing ablation neighborhood
    Vect=Curvatures(:,16,animal);% Taking values at 18hAPF
    index=find(~isnan(Vect));
    MiniX=min(index)+Removing;
    MaxiX=max(index)-Removing;
    
    % Averaging curvature and Speed
    AverageCurvature=squeeze(nanmean(Curvature(MiniX:MaxiX,:),1));
    AverageSpeed=squeeze(nanmean(Speed(MiniX:MaxiX,:),1));
    
    % Pooling animal data
    PoolAverageCurvature(:,animal)=AverageCurvature;
    PoolAverageSpeed(:,animal)=AverageSpeed;
end

% Binning
VectT=tmin:tstep:tmax;
SpeedMean=nan(1,length(VectT));
CurvatureMean=nan(1,length(VectT));
SpeedError=nan(1,length(VectT));
CurvatureError=nan(1,length(VectT));
CurvaturePool=[];
SpeedPool=[];
for t=1:length(VectT)
    Vect=PoolAverageCurvature(t,:);
    index=~isnan(Vect);
    if length(index)>3
        CurvatureMean(t)=mean(Vect(index));
        CurvatureError(t)=std(Vect(index))./sqrt(length(index));
        CurvaturePool{t}=Vect(index);
    end
    
    Vect=PoolAverageSpeed(t,:);
    index=~isnan(Vect);
    if length(index)>3
        SpeedMean(t)=mean(Vect(index));
        SpeedError(t)=std(Vect(index))./sqrt(length(index));
        SpeedPool{t}=Vect(index);
    end
end

% Plotting curvature(t) and speed(t)
figure()
CurvatureMean=CurvatureMean(1:45);
CurvatureError=CurvatureError(1:45);
SpeedMean=SpeedMean(1:45);
SpeedError=SpeedError(1:45);
VectT=VectT(1:45);
yyaxis left
hold on
x2=[VectT,fliplr(VectT)];
inBetween=[CurvatureMean+CurvatureError, fliplr(CurvatureMean-CurvatureError)];
h=fill(x2,inBetween,'blue','LineStyle','none');
set(h,'facealpha',.25);
plot(VectT,CurvatureMean,'Color','blue','LineWidth',2,'LineStyle','-')
hold off
yyaxis right
hold on
x2=[VectT,fliplr(VectT)];
inBetween=[SpeedMean+SpeedError, fliplr(SpeedMean-SpeedError)];
h=fill(x2,inBetween,'red','LineStyle','none');
set(h,'facealpha',.25);
plot(VectT,SpeedMean,'Color','red','LineWidth',2,'LineStyle','-')
hold off
xlim([16 24])

yyaxis left
ylabel('Curvature (µm^{-1})')
ylim([-0.001 0.005])
yyaxis right
ylabel('Speed (µm.h^{-1})')
ylim([0 7])
xlabel('Time (hAPF)')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])
ylabel('Curvature (µm^{-1})')
yyaxis right
ylabel('Speed (µm.h^{-1})')
xlabel('Time (hAPF)')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])




% Flat *****************************************************************
condition=11;

% Loading data
Curvatures=PoolCurvatures{condition};
Speeds=PoolSpeeds{condition};
Contractility=ApicalRecoils{condition};

% For each animal, averaging speed and curvature filtering out ablation
% neighborhood
PoolAverageCurvature=[];
PoolAverageSpeed=[];
for animal=1:size(Curvatures,3)
    % Loading maps
    Curvature=Curvatures(:,:,animal);
    Speed=Speeds(:,:,animal);
    
    % Removing ablation neighborhood
    Vect=Curvatures(:,16,animal);% Taking values at 18hAPF
    index=find(~isnan(Vect));
    MiniX=min(index)+Removing;
    MaxiX=max(index)-Removing;
    
    % Averaging curvature and Speed
    AverageCurvature=squeeze(nanmean(Curvature(MiniX:MaxiX,:),1));
    AverageSpeed=squeeze(nanmean(Speed(MiniX:MaxiX,:),1));
    
    % Pooling animal data
    PoolAverageCurvature(:,animal)=AverageCurvature;
    PoolAverageSpeed(:,animal)=AverageSpeed;
end

% Binning
VectT=tmin:tstep:tmax;
SpeedMean=nan(1,length(VectT));
CurvatureMean=nan(1,length(VectT));
SpeedError=nan(1,length(VectT));
CurvatureError=nan(1,length(VectT));
CurvaturePool=[];
SpeedPool=[];
for t=1:length(VectT)
    Vect=PoolAverageCurvature(t,:);
    index=~isnan(Vect);
    if length(index)>3
        CurvatureMean(t)=mean(Vect(index));
        CurvatureError(t)=std(Vect(index))./sqrt(length(index));
        CurvaturePool{t}=Vect(index);
    end
    
    Vect=PoolAverageSpeed(t,:);
    index=~isnan(Vect);
    if length(index)>3
        SpeedMean(t)=mean(Vect(index));
        SpeedError(t)=std(Vect(index))./sqrt(length(index));
        SpeedPool{t}=Vect(index);
    end
end

% Plotting curvature(t) and speed(t)
figure()
CurvatureMean=CurvatureMean(1:45);
CurvatureError=CurvatureError(1:45);
SpeedMean=SpeedMean(1:45);
SpeedError=SpeedError(1:45);
VectT=VectT(1:45);
yyaxis left
hold on
x2=[VectT,fliplr(VectT)];
inBetween=[CurvatureMean+CurvatureError, fliplr(CurvatureMean-CurvatureError)];
h=fill(x2,inBetween,'blue','LineStyle','none');
set(h,'facealpha',.25);
plot(VectT,CurvatureMean,'Color','blue','LineWidth',2,'LineStyle','-')
hold off
yyaxis right
hold on
x2=[VectT,fliplr(VectT)];
inBetween=[SpeedMean+SpeedError, fliplr(SpeedMean-SpeedError)];
h=fill(x2,inBetween,'red','LineStyle','none');
set(h,'facealpha',.25);
plot(VectT,SpeedMean,'Color','red','LineWidth',2,'LineStyle','-')
hold off
xlim([16 24])

yyaxis left
ylabel('Curvature (µm^{-1})')
ylim([-0.001 0.005])
yyaxis right
ylabel('Speed (µm.h^{-1})')
ylim([0 7])
xlabel('Time (hAPF)')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])
ylabel('Curvature (µm^{-1})')
yyaxis right
ylabel('Speed (µm.h^{-1})')
xlabel('Time (hAPF)')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
set(gcf,'Position',[100 100 400 350])
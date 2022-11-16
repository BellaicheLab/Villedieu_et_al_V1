%% Collect basal network data

clear all
close all

%% Parameters
% Need to be changed by the user /////////////////////////////////////////
Path='D:\BasalNetworkFibersOrientation\Data\Values'; % Needs to end with 'BasalNetworkFibersOrientation\Data\Values'

% No need to be changed by the user //////////////////////////////////////
Conditions={'Control' 'Dys' 'DfdRNAi' 'Dg' 'DfdTollo'};
Legend={'Control' ['\itDys' '^{mutant}'] ['\itDfd' '>' '\itDfd' '^{RNAi}'] ['\itDg' '^{mutant}'] ['\itDfd' '>' '\itTollo' '^{RNAi}']};
Indexes={[1:9] [1:7] [1:9] [1:9] [1:6]};


%% Load data

% Load all orientations and lengths
for condition=1:length(Conditions)
    Name=Conditions{condition};
    Index=Indexes{condition};
    
    for animal=1:length(Index)
        HeadLengths{condition}{animal}=csvread([Path filesep Name num2str(animal) filesep 'LengthsHead.csv']);
        HeadAngles{condition}{animal}=csvread([Path filesep Name num2str(animal) filesep 'AnglesHead.csv']);
        ThoraxLengths{condition}{animal}=csvread([Path filesep Name num2str(animal) filesep 'LengthsThorax.csv']);
        ThoraxAngles{condition}{animal}=csvread([Path filesep Name num2str(animal) filesep 'AnglesThorax.csv']);
    end
end

% Calculate the average orientation of each animal (for the neck region)
HeadAverageAngle=[];
for condition=1:length(Conditions)
    Name=Conditions{condition};
    Index=Indexes{condition};
    
    for animal=1:length(Index)
        AngleAnimal=[];
        Vect=HeadLengths{condition}{animal};
        % Creation of a vector AngleAnimal containing all the angles of all
        % the junctions, repeated Length(junction) times.
        for i=1:length(Vect)
            Angle=HeadAngles{condition}{animal}(i);
            % Angles varies from 0° to 180°. Theyr are now set to vary 
            % from 0° (parallel to M-L) to 90° (perpendicular to M-L)
            if Angle>90
                Angle=180-Angle;
            end
            Length=round(Vect(i));
            AngleAnimal=cat(2,AngleAnimal,Angle*ones(1,Length));         
        end
        % Averaging of the vector AngleAnimal, to get an average value of
        % orientation ponderated by the lengths of the junctions
        HeadAverageAngle{condition}(animal)=nanmean(AngleAnimal);
    end
end


% Calculate the average orientation of each animal (for the thorax region)
ThoraxAverageAngle=[];
for condition=1:length(Conditions)
    Name=Conditions{condition};
    Index=Indexes{condition};
    
    for animal=1:length(Index)
        AngleAnimal=[];
        Vect=ThoraxLengths{condition}{animal};
        % Creation of a vector AngleAnimal containing all the angles of all
        % the junctions, repeated Length(junction) times.        
        for i=1:length(Vect)
            Angle=ThoraxAngles{condition}{animal}(i);
            % Angles varies from 0° to 180°. Theyr are now set to vary 
            % from 0° (parallel to M-L) to 90° (perpendicular to M-L)
             if Angle>90
                Angle=180-Angle;
            end
            Length=round(Vect(i));
            AngleAnimal=cat(2,AngleAnimal,Angle*ones(1,Length));         
        end
        % Averaging of the vector AngleAnimal, to get an average value of
        % orientation ponderated by the lengths of the junctions
        ThoraxAverageAngle{condition}(animal)=nanmean(AngleAnimal);
    end
end



%% Plot Control, DysMutant and Dfd>DfdRNAi////////////////////////////////

% Generate vectors for plotting
PoolHeadAverage=[];
PoolThoraxAverage=[];
Class=[];
for condition=1:length(Conditions)-2
    PoolHeadAverage=cat(2,PoolHeadAverage,HeadAverageAngle{condition});
    PoolThoraxAverage=cat(2,PoolThoraxAverage,ThoraxAverageAngle{condition});
    Class=cat(2,Class,condition*ones(1,length(HeadAverageAngle{condition})));
end

% Plot for the neck region
figure(1)
xlim([0.5 3.5])
ylim([15 42])
set(gcf,'Position',[50, 50, 200, 300]);
set(findall(gcf,'-property','FontSize'),'FontSize',13)
blue=[58/255,67/255,186/255];
peanut=[121/255,92/255,52/255];
green=[59/255,177/255,67/255];
seaweed=[53/255,74/255,33/255];
Colors=[blue' green' peanut']';
beeswarm(Class',PoolHeadAverage','sort_style','up','overlay_style','none','dot_size',1,'use_current_axes',true,'colormap',Colors)
hold on
for cond=1:length(Conditions)-2
    Average=nanmean(HeadAverageAngle{cond});
    Error=nanstd(HeadAverageAngle{cond});
    line([cond cond], [Average-Error Average+Error],'Color',Colors(cond,:),'LineWidth',4)
end
for cond=1:length(Conditions)-2
    Average=nanmean(HeadAverageAngle{cond});
    line([cond-0.4 cond+0.4], [Average Average],'Color','black','LineWidth',6)
end
[h,p1]=ttest2(HeadAverageAngle{1},HeadAverageAngle{2},'Vartype','unequal');
[h,p2]=ttest2(HeadAverageAngle{1},HeadAverageAngle{3},'Vartype','unequal');
Pvalue=[0 p1 p2];
% Adding statistics results
for a=2:length(Legend)-2
    MaxApical=max(HeadAverageAngle{a});
    if Pvalue(a)<0.001
        text(a,MaxApical+1,'***','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.01
        text(a,MaxApical+1,'**','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.05
        text(a,MaxApical+1,'*','HorizontalAlignment','Center','FontSize',15)
    else
        text(a,MaxApical+1,'ns','HorizontalAlignment','Center','FontSize',15)
    end
end
ylabel('Average orientation (°)')
xticks(1:3);
xticklabels({Legend{1} Legend{2} Legend{3}});
xtickangle(30);
title('Head side')
set(findall(gcf,'-property','FontSize'),'FontSize',13)


% Plot for the thorax region
figure(2)
xlim([0.5 3.5])
ylim([15 42])
set(gcf,'Position',[50, 50, 200, 300]);
set(findall(gcf,'-property','FontSize'),'FontSize',13)
blue=[58/255,67/255,186/255];
peanut=[121/255,92/255,52/255];
green=[59/255,177/255,67/255];
seaweed=[53/255,74/255,33/255];
Colors=[blue' green' peanut']';
beeswarm(Class',PoolThoraxAverage','sort_style','up','overlay_style','none','dot_size',1,'use_current_axes',true,'colormap',Colors)
hold on
for cond=1:length(Conditions)-2
    Average=nanmean(ThoraxAverageAngle{cond});
    Error=nanstd(ThoraxAverageAngle{cond});
    line([cond cond], [Average-Error Average+Error],'Color',Colors(cond,:),'LineWidth',4)
end
for cond=1:length(Conditions)-2
    Average=nanmean(ThoraxAverageAngle{cond});
    line([cond-0.4 cond+0.4], [Average Average],'Color','black','LineWidth',6)
end
[h,p1]=ttest2(ThoraxAverageAngle{1},ThoraxAverageAngle{2},'Vartype','unequal');
[h,p2]=ttest2(ThoraxAverageAngle{1},ThoraxAverageAngle{3},'Vartype','unequal');
Pvalue=[0 p1 p2];
% Adding statistics results
for a=2:length(Legend)-2
    MaxApical=max(ThoraxAverageAngle{a});
    if Pvalue(a)<0.001
        text(a,MaxApical+1,'***','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.01
        text(a,MaxApical+1,'**','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.05
        text(a,MaxApical+1,'*','HorizontalAlignment','Center','FontSize',15)
    else
        text(a,MaxApical+1,'ns','HorizontalAlignment','Center','FontSize',15)
    end
end
ylabel('Average orientation (°)')
xticks(1:3);
xticklabels({Legend{1} Legend{2} Legend{3}});
xtickangle(30);
title('Thorax side')
set(findall(gcf,'-property','FontSize'),'FontSize',13)




%% Plot Control and Dg mutant ////////////////////////////////////////////

% Generate vectors for plotting
PoolHeadAverage=[];
PoolThoraxAverage=[];
Class=[];
VectTemp=[1 4];
for cond=1:length([VectTemp])
    condition=VectTemp(cond);
    PoolHeadAverage=cat(2,PoolHeadAverage,HeadAverageAngle{condition});
    PoolThoraxAverage=cat(2,PoolThoraxAverage,ThoraxAverageAngle{condition});
    Class=cat(2,Class,cond*ones(1,length(HeadAverageAngle{condition})));
end


% Plot for the neck region
figure(3)
xlim([0.5 2.5])
ylim([15 42])
set(gcf,'Position',[50, 50, 200, 200]);
set(findall(gcf,'-property','FontSize'),'FontSize',13)
blue=[58/255,67/255,186/255];
seaweed=[53/255,74/255,33/255];
Colors=[blue' seaweed']';
beeswarm(Class',PoolHeadAverage','sort_style','up','overlay_style','none','dot_size',1,'use_current_axes',true,'colormap',Colors)
hold on
for cond=1:length(VectTemp)
    Average=nanmean(HeadAverageAngle{VectTemp(cond)});
    Error=nanstd(HeadAverageAngle{VectTemp(cond)});
    line([cond cond], [Average-Error Average+Error],'Color',Colors(cond,:),'LineWidth',4)
end
for cond=1:length(VectTemp)
    Average=nanmean(HeadAverageAngle{VectTemp(cond)});
    line([cond-0.4 cond+0.4], [Average Average],'Color','black','LineWidth',6)
end
[h,p1]=ttest2(HeadAverageAngle{1},HeadAverageAngle{4},'Vartype','unequal');
Pvalue=[0 p1];
% Adding statistics results
for a=2:length(VectTemp)
    MaxApical=max(HeadAverageAngle{4});
    if Pvalue(a)<0.001
        text(a,MaxApical+1,'***','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.01
        text(a,MaxApical+1,'**','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.05
        text(a,MaxApical+1,'*','HorizontalAlignment','Center','FontSize',15)
    else
        text(a,MaxApical+1,'ns','HorizontalAlignment','Center','FontSize',15)
    end
end
ylabel('Average orientation (°)')
xticks(1:2);
xticklabels({Legend{1} Legend{4}});
title('Head side')
set(findall(gcf,'-property','FontSize'),'FontSize',13)



% Plot for the thorax region
figure(4)
xlim([0.5 2.5])
ylim([15 42])
set(gcf,'Position',[50, 50, 200, 200]);
set(findall(gcf,'-property','FontSize'),'FontSize',13)
blue=[58/255,67/255,186/255];
seaweed=[53/255,74/255,33/255];
Colors=[blue' seaweed']';
beeswarm(Class',PoolThoraxAverage','sort_style','up','overlay_style','none','dot_size',1,'use_current_axes',true,'colormap',Colors)
hold on
for cond=1:length(VectTemp)
    Average=nanmean(ThoraxAverageAngle{VectTemp(cond)});
    Error=nanstd(ThoraxAverageAngle{VectTemp(cond)});
    line([cond cond], [Average-Error Average+Error],'Color',Colors(cond,:),'LineWidth',4)
end
for cond=1:length(VectTemp)
    Average=nanmean(ThoraxAverageAngle{VectTemp(cond)});
    line([cond-0.4 cond+0.4], [Average Average],'Color','black','LineWidth',6)
end
[h,p1]=ttest2(ThoraxAverageAngle{1},ThoraxAverageAngle{4},'Vartype','unequal');
Pvalue=[0 p1];
% Adding statistics results
for a=2:length(VectTemp)
    MaxApical=max(ThoraxAverageAngle{4});
    if Pvalue(a)<0.001
        text(a,MaxApical+1,'***','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.01
        text(a,MaxApical+1,'**','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.05
        text(a,MaxApical+1,'*','HorizontalAlignment','Center','FontSize',15)
    else
        text(a,MaxApical+1,'ns','HorizontalAlignment','Center','FontSize',15)
    end
end
ylabel('Average orientation (°)')
xticks(1:2);
xticklabels({Legend{1} Legend{4}});
title('Thorax side')
set(findall(gcf,'-property','FontSize'),'FontSize',13)


%% Plotting control and DfdTollo //////////////////////////////////////////

% Generate vectors for plotting
PoolHeadAverage=[];
PoolThoraxAverage=[];
Class=[];
VectTemp=[1 5];
for cond=1:length([VectTemp])
    condition=VectTemp(cond);
    PoolHeadAverage=cat(2,PoolHeadAverage,HeadAverageAngle{condition});
    PoolThoraxAverage=cat(2,PoolThoraxAverage,ThoraxAverageAngle{condition});
    Class=cat(2,Class,cond*ones(1,length(HeadAverageAngle{condition})));
end

% Plot for the neck region
figure(5)
xlim([0.5 2.5])
ylim([15 42])
set(gcf,'Position',[50, 50, 200, 200]);
set(findall(gcf,'-property','FontSize'),'FontSize',13)
blue=[58/255,67/255,186/255];
seaweed=[53/255,74/255,33/255];
Colors=[blue' seaweed']';
beeswarm(Class',PoolHeadAverage','sort_style','up','overlay_style','none','dot_size',1,'use_current_axes',true,'colormap',Colors)
hold on
for cond=1:length(VectTemp)
    Average=nanmean(HeadAverageAngle{VectTemp(cond)});
    Error=nanstd(HeadAverageAngle{VectTemp(cond)});
    line([cond cond], [Average-Error Average+Error],'Color',Colors(cond,:),'LineWidth',4)
end
for cond=1:length(VectTemp)
    Average=nanmean(HeadAverageAngle{VectTemp(cond)});
    line([cond-0.4 cond+0.4], [Average Average],'Color','black','LineWidth',6)
end
[h,p1]=ttest2(HeadAverageAngle{1},HeadAverageAngle{5},'Vartype','unequal');
Pvalue=[0 p1];
% Adding statistics results
for a=2:length(VectTemp)
    MaxApical=max(HeadAverageAngle{5});
    if Pvalue(a)<0.001
        text(a,MaxApical+1,'***','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.01
        text(a,MaxApical+1,'**','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.05
        text(a,MaxApical+1,'*','HorizontalAlignment','Center','FontSize',15)
    else
        text(a,MaxApical+1,'ns','HorizontalAlignment','Center','FontSize',15)
    end
end
ylabel('Average orientation (°)')
xticks(1:2);
xticklabels({Legend{1} Legend{5}});
title('Head side')
set(findall(gcf,'-property','FontSize'),'FontSize',13)


% Plot for the thorax region
figure(6)
xlim([0.5 2.5])
ylim([15 42])
set(gcf,'Position',[50, 50, 200, 200]);
set(findall(gcf,'-property','FontSize'),'FontSize',13)
blue=[58/255,67/255,186/255];
seaweed=[53/255,74/255,33/255];
Colors=[blue' seaweed']';
beeswarm(Class',PoolThoraxAverage','sort_style','up','overlay_style','none','dot_size',1,'use_current_axes',true,'colormap',Colors)
hold on
for cond=1:length(VectTemp)
    Average=nanmean(ThoraxAverageAngle{VectTemp(cond)});
    Error=nanstd(ThoraxAverageAngle{VectTemp(cond)});
    line([cond cond], [Average-Error Average+Error],'Color',Colors(cond,:),'LineWidth',4)
end
for cond=1:length(VectTemp)
    Average=nanmean(ThoraxAverageAngle{VectTemp(cond)});
    line([cond-0.4 cond+0.4], [Average Average],'Color','black','LineWidth',6)
end
[h,p1]=ttest2(ThoraxAverageAngle{1},ThoraxAverageAngle{5},'Vartype','unequal');
Pvalue=[0 p1];
% Adding statistics results
for a=2:length(VectTemp)
    MaxApical=max(ThoraxAverageAngle{4});
    if Pvalue(a)<0.001
        text(a,MaxApical+1,'***','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.01
        text(a,MaxApical+1,'**','HorizontalAlignment','Center','FontSize',15)
    elseif Pvalue(a)<0.05
        text(a,MaxApical+1,'*','HorizontalAlignment','Center','FontSize',15)
    else
        text(a,MaxApical+1,'ns','HorizontalAlignment','Center','FontSize',15)
    end
end
ylabel('Average orientation (°)')
xticks(1:2);
xticklabels({Legend{1} Legend{5}});
title('Thorax side')
set(findall(gcf,'-property','FontSize'),'FontSize',13)
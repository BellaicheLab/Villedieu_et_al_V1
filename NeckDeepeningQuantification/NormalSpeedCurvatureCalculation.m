%% NormalSpeedCurvatureCalculation
% Calculates neck leading edge deepening, local normal deepening speed and curvature along the m-l axis

clear all
close all

%% Adjustable parameters  ////////////////////////////////////////////////////////////
% Need to be adjusted by the user to run as an example ////////////////////
% Folder where animal subfolders are stored
Path='D:\NeckDeepeningQuantification\Data'; % Need to end with 'NeckDeepeningQuantification\Data'
% Output folder
PathOut='D:\NeckDeepeningQuantification\Output';

% No need to be adjusted by the user to run as an example /////////////////
% Name of each condition
Conditions={'Control'};
% Indexes associated with each condition
Indexes={1};
Names={'Control'};


%% Fixed parameters ////////////////////////////////////////////////////////
% Pixel size (x,y) in µm
Pixelsize=0.322;

% Plots parameters
tmin=14; % Minimum considered timing
tmax=28; % Maximum considered timing
tstep=0.25; % Timestep on the plot (in h)
xmin=-400; % Minimum considered ML position (in %)
xmax=+400; % Maximum considered ML position (in %)
xstep=10; % ML position step on the plot (in %)

% Radius used for curvature calculation (in pixels/2)
Step=140;

% Length of temporal smoothing (in number of tstep)
SmoothT=7;

%% Code ///////////////////////////////////////////////////////////////////

% Create ouput folders
mkdir(PathOut);
PathCurves1=[PathOut filesep 'Plots'];
mkdir(PathCurves1);

% For each condition
for condition=1:length(Conditions)
    % Load the name of the condition and the indexes corresponding to
    % the condition
    Name=Conditions{condition};
    Index=Indexes{condition};
    
    % Choice of DepthCenter, the length (in pixels) between the
    % midline/leading edge(t0) intersection and the center. DepthCenter is
    % higher whether there is coverslip flattening or not.
    if strcmp(Name,'NoPressure40X') % If there is no coverslip flattening
        DepthCenter=750; % DepthCenter is approximately 240µm
    else % otherwise
        DepthCenter=625; % DepthCenter is approximately 200µm
    end
    
    % For each animal of the condition
for animal=1:length(Index)
    tic
    % Load animal index
    Animal=Index(animal);
    
    % Create output folder
    PathCurves=[PathCurves1 filesep Name num2str(Animal)];
    mkdir(PathCurves)
    
    %% Animal data downloading
    
    % Detect length of tracking (how many timepoints are tracked?)
    MaxTime=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'LengthTracking.csv']);
    % Detect field dimension
    DimensionsField=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'ResliceDimension.csv']);
    % Open drift correction files
    XDrift=csvread([Path filesep Name num2str(Animal) filesep 'DriftX.csv']);
    YDrift=csvread([Path filesep Name num2str(Animal) filesep 'DriftY.csv']);
    % Read timing info
    Timing=csvread([Path filesep Name num2str(Animal) filesep 'timing.csv']);
    % Download sample deviation from horizontal (in degres)
    if isfile([Path filesep Name num2str(Animal) filesep 'Angle.csv'])
        Angle=csvread([Path filesep Name num2str(Animal) filesep 'Angle.csv']);
    else
        Angle=0;
    end
    % Download angle of deviation of midline from horizontal
    AngleRotation=csvread([Path filesep Name num2str(Animal) filesep 'AngleRotation.csv']);
    % PATCH: Looking whether rotation has been done before transverse view
    % generation or not
    if DimensionsField(1)==1024 && AngleRotation~=0
        RotationMissing=1;
    else
        RotationMissing=0;
    end
    % Download alignment information
    if RotationMissing==0
        Alignment=csvread([Path filesep Name num2str(Animal) filesep 'alignement.csv']);
    else % If rotation was not done beforehand
        % Loading coordinates without rotation
        Alignment=csvread([Path filesep Name num2str(Animal) filesep 'alignementWithoutRotation.csv']);
        % Dilate X coordinates for reintroducing the effect of rotation
        Alignment(2)=Alignment(2)*abs(cosd(AngleRotation));
        Alignment(4)=Alignment(4)*abs(cosd(AngleRotation));
        Alignment(6)=Alignment(6)*abs(cosd(AngleRotation));
    end
    
    
    
    %% Calculation of the position of the center (the point of convergence of deepening)
    
    % Find the coordinates of midline position ///////////////////////
    % Load initial leading edge position
    X=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'X_t' num2str(1) '.csv']);
    Y=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'Y_t' num2str(1) '.csv']);
    % Correct for deviation of the midline
    if RotationMissing==1
       X=X*abs(cosd(AngleRotation));
    end
    % Interpolation with a fine step
    LengthLeadingEdge=0;
    for x=1:length(X)-1
        LengthLeadingEdge=LengthLeadingEdge+pdist([X(x),Y(x);X(x+1),Y(x+1)],'euclidean');
    end
    NumberPoints=round(LengthLeadingEdge);
    Interp=interparc(NumberPoints,X,Y,'spline');
    
    % Determination of the position of the midline in the interpolated
    % leading edge
    if Alignment(4)==0 | Alignment(6)==0 % If only 1 visible macrochaete, take manually estimated midline position
        Vect=abs(Interp(:,1)-(DimensionsField(1)-Alignment(2)));
        MidlineIndex=min(find(Vect==min(Vect)));
    else % If 2 macrochaetes are visible, midline is defined in the middle of the 2 macrochaetes
        % Determination of the position of the left macro
        Vect=abs(Interp(:,1)-(DimensionsField(1)-max(Alignment([4 6]))));
        Macro1Index=min(find(Vect==min(Vect)));
        % Determination of the position of the right macro
        Vect=abs(Interp(:,1)-(DimensionsField(1)-min(Alignment([4 6]))));
        Macro2Index=min(find(Vect==min(Vect)));
        % Midline is defined as the middle of Macro1-Macro2
        MidlineIndex=round((Macro1Index+Macro2Index)/2);
    end
    
    % Extract the coordinates of midline
    XMidline=Interp(MidlineIndex,1);
    YMidline=Interp(MidlineIndex,2);
    
    % Calculation of the center based on Midline(x,y) and angle
    % Download angle of the side view
    CenterCalculation=csvread([Path filesep Name num2str(Animal) filesep 'CenterCalculation.csv']);
    if strcmp(Name,'NoPressure40X')
        Center(1)=XMidline+775*sin(pi*CenterCalculation(3)/180);
        Center(2)=YMidline+775*cos(pi*CenterCalculation(3)/180);
    else
        Center(1)=XMidline+DepthCenter*sin(pi*CenterCalculation(3)/180);
        Center(2)=YMidline+DepthCenter*cos(pi*CenterCalculation(3)/180);
    end
    % Correction of the center for deviation from horizontal
    Center(2)=Center(2)/cosd(Angle);

    %% Calculation of spatio-temporal alignement vectors

    AlignmentVector=[];
    % Seperate the case where (i) 2 landmark macrochaetes are visibles VS
    % (ii) 1 landmark macrochaete is visible
    if Alignment(4)==0 | Alignment(6)==0
        Vect=abs(Interp(:,1)-(DimensionsField(1)-max(Alignment([4 6]))));
        MacroIndex=min(find(Vect==min(Vect)));
        Vect=1:NumberPoints;
        Vect=Vect-MidlineIndex;
        Vect(Vect>0)=100*Vect(Vect>0)/abs(MacroIndex-MidlineIndex);
        Vect(Vect<0)=100*Vect(Vect<0)/abs(MacroIndex-MidlineIndex);
        AlignmentVector=Vect;
    else
        % Determination of the position of the left macro
        Vect=abs(Interp(:,1)-(DimensionsField(1)-max(Alignment([4 6]))));
        Macro1Index=min(find(Vect==min(Vect)));
        % Determination of the position of the right macro
        Vect=abs(Interp(:,1)-(DimensionsField(1)-min(Alignment([4 6]))));
        Macro2Index=min(find(Vect==min(Vect)));
        Vect=1:NumberPoints;
        Vect=Vect-MidlineIndex;
        Vect(Vect>0)=100*Vect(Vect>0)/(Macro2Index-MidlineIndex);
        Vect(Vect<0)=100*Vect(Vect<0)/(MidlineIndex-Macro1Index);
        AlignmentVector=Vect;
        clear Vect;
    end
    
    % Temporal alignment
    AlignementTime=[];
    for time=1:MaxTime-1
        AlignementTime(time)=mean([Timing(time) Timing(time+1)]);
    end
    
    %% Lagrangian tracking of deepening
    % Each point along the leading edge is associated with a coordinate
    % PositionML (in %) for all timepoints
    
    % Initial timepoint
    X=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'X_t' num2str(1) '.csv']);
    Y=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'Y_t' num2str(1) '.csv']);
    % Drift correction
    X=X-XDrift(1);
    Y=Y-YDrift(1);
    % Correcting for deviation of the midline
    if RotationMissing==1
       X=X*abs(cosd(AngleRotation));
    end
    % Correction for deviation from horizontal
    Y=Y/cosd(Angle);
    % Calculation of the length of the tracked leading edge to calculate number
    % of interpolated points
    LengthLeadingEdge=0;
    for x=1:length(X)-1
        LengthLeadingEdge=LengthLeadingEdge+pdist([X(x),Y(x);X(x+1),Y(x+1)],'euclidean');
    end
    NumberPoints=round(LengthLeadingEdge/20);
    % Interpolation of NumberPoints points across the leading edge at time t0
    Interp=interparc(NumberPoints,X,Y,'spline');
    
    
    % Initializing arrays
    Xs=nan(NumberPoints,MaxTime);
    Ys=nan(NumberPoints,MaxTime);
    Xs(:,1)=Interp(:,1);
    Ys(:,1)=Interp(:,2);
    Interp=[];
    
    % Loading leading edge position at initial time
    X1=Xs(:,1);
    Y1=Ys(:,1);
    % Loop to track each point in time at t+1
    parfor t=1:MaxTime-1
        % Opening X and Y of the next timepoint
        X=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'X_t' num2str(t+1) '.csv']);
        Y=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'Y_t' num2str(t+1) '.csv']);
        % Drift correction
        X=X-XDrift(t+1);
        Y=Y-YDrift(t+1);
        % Correction for deviation from horizontal
        Y=Y/cosd(Angle);
        % Correcting for deviation of the midline
        if RotationMissing==1
            X=X*abs(cosd(AngleRotation));
        end
        % Estimation of the number of points required for interpolation
        LengthLeadingEdge=0;
        for x=1:length(X)-1
            LengthLeadingEdge=LengthLeadingEdge+pdist([X(x),Y(x);X(x+1),Y(x+1)],'euclidean');
        end
        NumberPointsFine=round(LengthLeadingEdge*2);
        
        % Interpolation with very fine step of the curve
        Interp=interparc(NumberPointsFine,X,Y,'spline');
        X2=Interp(:,1);
        Y2=Interp(:,2);
        Interp=[];
        X=[];
        Y=[];
        
        % For each point of the leading edge at time t
        for pos=1:NumberPoints
            if ~isnan(X1(pos)) & ~isnan(Y1(pos))
                % Equation of the line Point(t)-Center (y=ax+b)
                x1=X1(pos);
                y1=Y1(pos);
                x2=Center(1);
                y2=Center(2);
                a=(y2-y1)/(x2-x1);
                b=(x2*y1-y2*x1)/(x2-x1);
                % Equation in the form (Ax+By+C=0)
                A=1;
                B=-a;
                C=-b;
                
                % Calculation of the distance between this line and each points
                % at t+1
                Dist=abs(A*Y2+B*X2+C)/sqrt(A*A+B*B);
                % Identification of the intersection
                VectMin=find(Dist<0.5);
                if ~isempty(VectMin)
                    DistMin=[];
                    for v=1:length(VectMin)
                        DistMin(v)=pdist([x1,y1;X2(VectMin(v)),Y2(VectMin(v))],'euclidean');
                    end
                    index=find(DistMin==min(DistMin)); % We choose the point minimizing the distance (Point(t)-Point(t+1))
                    index=VectMin(index);
                    
                    % Update of the vectors
                    Xs(pos,t+1)=X2(index);
                    Ys(pos,t+1)=Y2(index);
                end
            end
        end
        
    end
    
    
    
    %% Calculation of neck depth as a function of x and t
    
    % Initialization
    Depth=nan(size(Xs,1),MaxTime-1);
    % Calculation
    for t=1:MaxTime-1
        for pos=1:size(Depth,1)
            % Absolute value
            temp=pdist([Xs(pos,t),Ys(pos,t);Xs(pos,t+1),Ys(pos,t+1)],'euclidean');
            % Sign
            if pdist([Xs(pos,t),Ys(pos,t);Center(1),Center(2)],'euclidean')-pdist([Xs(pos,t+1),Ys(pos,t+1);Center(1),Center(2)],'euclidean')<0
                temp=-temp;
            end
            % Conversion in µm/h
            Depth(pos,t)=temp*Pixelsize;
        end
    end
    indexDepth=isnan(Depth);
    Depth(isnan(Depth))=0;
    Depth=cumsum(Depth,2);
    Depth(indexDepth)=nan;
    
    % Reduce AlignmentVector to the number of sampled points afterwards
    AlignmentVector=AlignmentVector(1:20:end);
    AlignmentVector=AlignmentVector(1:size(Depth,1));
    
    % Interpolation
    X=[];
    T=[];
    [X,T] = meshgrid(AlignementTime,AlignmentVector);
    [Xq,Tq] = meshgrid(tmin:tstep:tmax,xmin:xstep:xmax);
    Depthinterp=interp2(X,T,Depth,Xq,Tq);
    
    % Save deepening speed map
    PoolDepths{condition}(:,:,animal)=Depthinterp;
    Depthinterp=[];
    
    %% Calculation of local curvature and normal speed
    
    % Initializing arrays
    Curvatures=nan(NumberPoints,MaxTime);
    Speeds=nan(NumberPoints,MaxTime);
    
    % For each timepoint time :
    for t=1:MaxTime
        % Loading leading edge position at time t
        % Opening raw positions X and Y
        X=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'X_t' num2str(t) '.csv']);
        Y=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'Y_t' num2str(t) '.csv']);
        % Drift correction
        X=X-XDrift(t);
        Y=Y-YDrift(t);
        % Correcting for deviation of the midline
        if RotationMissing==1
            X=X*abs(cosd(AngleRotation));
        end
        % Correction for deviation from horizontal
        Y=Y/cosd(Angle);
        % Finely interpolating the leading edge line (every 0.5 pixel)
        % Calculation of the length of the tracked leading edge to calculate number
        % of interpolated points
        LengthLeadingEdge=0;
        for x=1:length(X)-1
            LengthLeadingEdge=LengthLeadingEdge+pdist([X(x),Y(x);X(x+1),Y(x+1)],'euclidean');
        end
        PointsNumber=round(LengthLeadingEdge*2);
        % Interpolation
        Interp=interparc(PointsNumber,X,Y,'spline');
        Xq=Interp(:,1);
        Vect=Interp(:,2);
        Interp=[];
        
        % Loading leading edge position at time t+1
        % Only load it when it exists
        if t<MaxTime
            % Opening raw positions
            X2=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'X_t' num2str(t+1) '.csv']);
            Y2=csvread([Path filesep Name num2str(Animal) filesep 'Tracking' filesep 'Y_t' num2str(t+1) '.csv']);
            % Drift correction
            X2=X2-XDrift(t+1);
            Y2=Y2-YDrift(t+1);
            % Correcting for deviation of the midline
            if RotationMissing==1
                X=X*abs(cosd(AngleRotation));
            end
            % Correction for deviation from horizontal
            Y=Y/cosd(Angle);
            % Calculation of the length of the tracked leading edge to calculate number
            % of interpolated point (every 0.5 pixel)
            LengthLeadingEdge=0;
            for x=1:length(X2)-1
                LengthLeadingEdge=LengthLeadingEdge+pdist([X2(x),Y2(x);X2(x+1),Y2(x+1)],'euclidean');
            end
            PointsNumber=round(LengthLeadingEdge*2);
            % Interpolation
            Interp=interparc(PointsNumber,X2,Y2,'spline');
            X2=Interp(:,1);
            Y2=Interp(:,2);
            Interp=[];
        end
        
        % For each tracked point of the given time :
        parfor pos=1:NumberPoints
            % Only consider the point if it is sampled
            if ~isnan(Xs(pos,t))
                % Find the closest point in the finely interpolated
                % leading edge position
                % Calculation of the distance between finely
                % interpolated points and the tracked point
                VectDist=nan(1,length(Xq));
                for pos2=1:length(Xq)
                    if ~isnan(Xq(pos2))
                        VectDist(pos2)=pdist([Xs(pos,t),Ys(pos,t);Xq(pos2),Vect(pos2)],'euclidean');
                    end
                end
                index=min(find(VectDist==min(VectDist)));
                
                
                % Only consider the point if is is far enough to the edge to
                % calculate curvature and normal direction
                if index>Step & index<length(Xq)-Step
                    
                    % Check whether the points to calculate the curvature
                    % are sampled
                    if ~isnan(Xq(index-Step)) & ~isnan(Xq(index+Step))
                        
                        % Caculation of the equation of the perpendicular bisector of the first segment
                        XA=Xq(index-Step);
                        XB=Xq(index);
                        YA=Vect(index-Step);
                        YB=Vect(index);
                        A=(XA-XB)/(YB-YA);
                        B=( (XB-XA)*(XA+XB) ) / ( 2*(YB-YA) ) + (YA+YB)/2;
                        % Caculation of the equation of the perpendicular bisector of the first segment
                        XA=Xq(index);
                        XB=Xq(index+Step);
                        YA=Vect(index);
                        YB=Vect(index+Step);
                        A2=(XA-XB)/(YB-YA);
                        B2=( (XB-XA)*(XA+XB) ) / ( 2*(YB-YA) ) + (YA+YB)/2;
                        % Caculation of the intersection of the 2 perpendicular bisectors (i.e. the center of the circumscribed circle)
                        XCenter=(B2-B)/(A-A2);
                        YCenter=A*XCenter+B;
                        
                        % Calculation of the local curvarture
                        % (1/dist(point-center)) in µm-1
                        Curvatures(pos,t)=1/pdist([Xq(index),Vect(index);XCenter,YCenter],'euclidean')/Pixelsize;
                        % Searching for concavity/convexity
                        % Calculating vectorial product of the vectors point-center.point-center of the circumscribed circle
                        % Formula (xcenter-x)*(xcircumscribed-x)+(ycenter-y)*(ycircumscribed-y)
                        VectorialProduct=(Center(1)-Xq(index))*(XCenter-Xq(index))+(Center(2)-Vect(index))*(YCenter-Vect(index));
                        % if VectorialProduct is negative, curvature has to be negative
                        if VectorialProduct<0
                            Curvatures(pos,t)=-Curvatures(pos,t);
                        end
                        
                        % Calculation of normal speed
                        % Only calculate speed if it is not the last
                        % timepoint
                        if t<MaxTime
                            % Calculating the equation of the local normal line
                            x1=Xq(index);
                            y1=Vect(index);
                            x2=XCenter;
                            y2=YCenter;
                            a=(y2-y1)/(x2-x1);
                            b=(x2*y1-y2*x1)/(x2-x1);
                            % Equation in the form (Ax+By+C=0)
                            A=1;
                            B=-a;
                            C=-b;
                            
                            % Calculation of the distance between this line and each points
                            % at t+1
                            Dist=abs(A*Y2+B*X2+C)/sqrt(A*A+B*B);
                            % Identification of the intersection
                            VectMin=find(Dist<0.5);
                            if ~isempty(VectMin)
                                DistMin=[];
                                for v=1:length(VectMin)
                                    DistMin(v)=pdist([x1,y1;X2(VectMin(v)),Y2(VectMin(v))],'euclidean');
                                end
                                index2=find(DistMin==min(DistMin)); % We choose the point minimizing the distance (Point(t)-Point(t+1))
                                index2=VectMin(index2);
                                
                                % Calculate the normal speed
                                Speedtemp=pdist([x1,y1;X2(index2),Y2(index2)],'euclidean')*Pixelsize/(Timing(t+1)-Timing(t));
                                % Checking the sign of the speed
                                if pdist([x1,y1;Center(1),Center(2)],'euclidean')-pdist([X2(index2),Y2(index2);Center(1),Center(2)],'euclidean')<0
                                    Speedtemp=-Speedtemp;
                                end
                                Speeds(pos,t)=Speedtemp;
                            end
                        end
                    end
                end
            end
        end
    end
    
   
    % Temporal smoothing
    flag=isnan(Curvatures);
    Curvatures=movmean(Curvatures,SmoothT,2,'omitnan');
    Curvatures(flag)=nan;
    flag=isnan(Speeds);
    Speeds=movmean(Speeds,SmoothT,2,'omitnan');
    Speeds(flag)=nan;
    
    % Time and space registration
    X=[];
    T=[];
    [X,T] = meshgrid(Timing(1:MaxTime),AlignmentVector);
    [Xq,Tq] = meshgrid(tmin:tstep:tmax,xmin:xstep:xmax);
    Curvaturesinterp=interp2(X,T,Curvatures,Xq,Tq);
    Speedsinterp=interp2(X,T,Speeds,Xq,Tq);
    
    % Saving curvature and normal speed maps
    PoolCurvatures{condition}(:,:,animal)=Curvaturesinterp;
    Curvaturesinterp=[];
    PoolSpeeds{condition}(:,:,animal)=Speedsinterp;
    Speedsinterp=[];

end
    
    
    %% Saving values for a given condition
    PathOutValues=[PathOut filesep 'Values'];
    mkdir(PathOutValues);
    Curvatures=PoolCurvatures{condition};
    Speeds=PoolSpeeds{condition};
    Depths=PoolDepths{condition};
    save([PathOutValues filesep Conditions{condition} '(Curvatures)'],'Curvatures');
    save([PathOutValues filesep Conditions{condition} '(Speeds)'],'Speeds');
    save([PathOutValues filesep Conditions{condition} '(Depths)'],'Depths');
    clear Curvatures Speeds Depths

end
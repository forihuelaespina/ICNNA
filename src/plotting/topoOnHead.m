function [f,ha]=topoOnHead(dataVectors,pose,options)
%Displays spatial representation of NIRS measurement in a reference head
%
%       +==============================================+
%       | As from ICNA version 1.1.0 this function     |
%       | has been temporally disabled and is not      |
%       | currently working. Please use alternatives   |
%       | functions plotTopo and topoOptodeArray       |
%       |instead.                                      |
%       +==============================================+
%
%
% [figureHandle]=topoOnHead(dataVector,pose) Displays a spatial
%   representation of NIRS measurement on top of a reference head.
%
% [figureHandle]=topoOnHead(dataVector,pose,options) Displays a 2D 
%   spatial representation of an Optode Array in figure h and allow some
%   options to be selected.
%
% [figureHandle,optodeArraysAxisHandles]=topoOnHead(...)
%
%
%A reference head (possibly generated with the program MakeHuman)
%is displayed as a background image.
%
%       +==============================================+
%       | Actually the background image does not       |
%       | need to be a head!! It can be any image!!    |
%       +==============================================+
%
%% Pose
%
% A pose determines 2 things:
%   + The point of view of the reference head, and
%   + The number, type, orientation and location of the optode arrays
%
%The pose can be indicated with a struct with the following fields
%
%   .backgroundImage - Filename of the background image in TIF format
%       Leave empty if you do not want any image on the background
%   .units - Units in which the position of the optode Arrays are
%       indicated
%   .displayColorbar - Display the colorbar
%   .colorbarPosition - Position of the color bar in normalized units.
%   .optodeArrays - A cell array of struct where each struct identifies
%       one optode array. Each optode array struct must include
%       the following information:
%           .arrayType - As available in the function topoOptodeArray
%           .channelSpatialCoordinates - As available in the
%                   function topoOptodeArray.
%           .orientation - DEPRECATED. As available in the
%                   function topoOptodeArray
%           .position - As available in the function topoOptodeArray
%           .labels - Channel labels as available in the function
%               topoOptodeArray
%
%
%
%
%Some premade poses are already available. They can be selected using
%an integer number. Here are the one availables:
%
%
% 1) Flat view from top with 2 HITACHI ETG-4000 3x3 optode arrays
%   placed on the PFC
% 2) Front view with the camera looking from high position
%   with 2 HITACHI ETG-4000 3x3 optode arrays placed on the PFC
% 3) Face view with 2 HITACHI ETG-4000  3x3 optode arrays
%   placed on the PFC
% 4) Frontal topograms with no background image of
%   2 HITACHI ETG-4000 3x3 optode arrays
% 5) Frontal topograms with no background image of
%   1 HITACHI ETG-4000 4x4 optode arrays
% 6) Frontal topograms with no background image of
%   1 HITACHI ETG-4000 3x5 optode arrays
%
%% Options
%
% == Attended by this function
%
% .mainTitle - The main title of the figure. By default is a
%   empty string.
% .scale - By default, it will simply display the values as such
%   (i.e. assign color scale automatically). But it can accept
%   a row vector [min max] to rescale the colors.
%
%       +==============================================+
%       | This function ensures that the same scale is |
%       | used for ALL optode arrays in the pose       |
%       +==============================================+
%
% == Directly passed to lower level function topoOptodeArray
%   .displayChannelLabels - Add a label to the channels. True by default
%   .displayChannelMarkers - Add a markers to the channels. True by default
%   .colormap - Assign a colormap. By default the colour map goes
%     from blue (lowest) to red (highest), but a different color map
%     can be assigned.
%
%% Parameters
%
%   dataVectors - A cell array of vectors with signal
%       values at the channels. Note that if the pose
%       involves more than 1 optode array, the total number of
%       vectors (length of the cell array) must match the
%       TOTAL number of optode arrays
%       in the pose, and furthermore the number of values 
%       provided MUST match the number of channels
%       expected according to the corresponding optode array
%       in the pose. 
%
%
%       +==============================================+
%       | This function DOES NOT understand the nature |
%       | of the data. It does not know which type of  |
%       | signal or chromophore is being displayed, or |
%       | where it was collected. It does not know     |
%       | either whether the data represents average   |
%       | values or simple time samples. It simply     |
%       | displays a 2D topographical map out of the   |
%       | provided data regardless of its meaning.     |
%       +==============================================+
%
%
%   pose -  The pose . Either a struct or
%       a number to refer to premade poses (see sectionPose above).
%
%   options - If indicated a struct with a variable set of fields
%       See section Options below.
%
%% Output
%
% The handle of the figure representing the optode arrays
%on the reference head
%
% ...and the handle of the axis corresponding to the optode arrays 
%
%
%
%
% Copyright 2008-13
% @date 3-Oct-2008
% @author Felipe Orihuela-Espina
% @modified 3-Jan-2013
%
% See also topoOptodeArray
%

error('ICNA:plotting:topoOnHead:DisabledFunction',...
    ['As from ICNA version 1.1.0 this function ' ...
     'has been temporally disabled and is not ' ...
     'currently working. Please use alternatives ' ...
     'functions plotTopo and topoOptodeArray ' ...
     'instead.']);




%Deal with options
opt.mainTitle='';
opt.scale=[];
% == Pass to lower level function topoOptodeArray
% load('./plotting/fNIRSColorMapHitachi.mat')
% opt2.colormap=fNIRSColorMap;
% %The above loads a 64 color colormap, but that is too coarse;
% %here I generate the equivalent colormap but with as many colors
% %as I want
nColors=256;
tmpUp =linspace(0,1,nColors/2)';
tmpDown =linspace(1,0,1+nColors/2)';
    %Note that there is 1 more step "down" than "up",
    %but that will be ignored when concatenating
cmap = [tmpUp tmpUp ones(nColors/2,1); ...
    ones(nColors/2,1) tmpDown(2:end) tmpDown(2:end)];
opt2.colormap=cmap;

opt2.displayChannelLabels=true;
opt2.displayChannelMarkers=true;
if (nargin==3)
    if(isfield(options,'mainTitle'))
        opt.mainTitle=options.mainTitle;
    end
    if(isfield(options,'scale'))
        opt.scale=options.scale;
    end
    if(isfield(options,'colormap'))
        % == Pass to lower level function topoOptodeArray
        opt2.colormap=options.colormap;
    end
end



%% Obtain pose in struct format
if ~isstruct(pose)
    pose=getPose(pose);
end

assert(length(dataVectors)==length(pose.optodeArrays),...
      'ICNA:plotting:topoOnHead',...
      ['Number of data vectors do not match number of ' ...
      'optode arrays in the pose.']);    


%% Deal with the scale
if isempty(opt.scale)
    %Attemp to figure out the best scale for all optodeArrays
    nData=length(dataVectors);
    tmpData=zeros(1,0);
    for ii=1:nData
        tmpData=[tmpData ...
                 reshape(dataVectors{ii},1,numel(dataVectors{ii}))];
    end
    opt.scale(1)=min(tmpData);
    opt.scale(2)=max(tmpData);
    
    if all(isnan(opt.scale))
        opt.scale=[0 0+2*eps];
    elseif isnan(opt.scale(1))
        opt.scale(1)=opt.scale(1)-2*eps;
    elseif isnan(opt.scale(2))
        opt.scale(2)=opt.scale(2)+2*eps;
    end
    
else
    opt2.scale=opt.scale;
end


%% Now plot
f=figure;
%Set Figure screen size
set(gcf,'Units','normalized');
set(gcf,'Position',[0.2, 0.05, 0.6, 0.85]);
set(gcf,'Units','pixels'); %Return to default

%%==BEGIN Background figure ================
% This creates the 'background' axes
ha = axes('units','normalized', 'position',[0 0 1 1]);
% Move the background axes to the bottom
uistack(ha,'bottom');
if isempty(pose.backgroundImage)
    pose.backgroundImage='./plotting/TopographicMapBackground0005.tif';
end
% Load in a background image and display it using the correct colors
I=imread(pose.backgroundImage); 
hi = imagesc(I);
colormap gray

if ~isempty(opt.mainTitle)
    %text(50,50,opt.mainTitle,'FontSize',14);
    text(10,10,opt.mainTitle,'FontSize',14);
end

% Turn the handlevisibility off so that we don't inadvertently plot into the axes again
% Also, make the axes invisible
set(ha,'handlevisibility','off', ...
'visible','off')

%%==END Background figure ================

nOptodeArrays=length(pose.optodeArrays);
for ii=1:nOptodeArrays
    tmpOptodeArray=pose.optodeArrays{ii};
    opt3=opt2; %Common fields
    opt3.arrayType=tmpOptodeArray.arrayType;
    if isfield(tmpOptodeArray,'channelSpatialCoordinates')
        opt3.channelSpatialCoordinates=...
                tmpOptodeArray.channelSpatialCoordinates;
    else
        opt3.orientation=tmpOptodeArray.orientation;
    end
    opt3.position=tmpOptodeArray.position;
    opt3.labels=tmpOptodeArray.labels;
    ha(ii)=topoOptodeArray(f,dataVectors{ii},opt3);
end

if pose.displayColorbar
    %Fictitious axes for the colorbar, so the color bar does
    %not distort anything
    cbarA = axes('units','normalized','position',pose.colorbarPosition);
    caxis([opt.scale(1) opt.scale(2)]);
    set(cbarA,'visible','off')
    colorbar('peer',cbarA,'location','south')
end

end

%% AUXILIAR FUNCTIONS
function pose=getPose(poseId)
%Get an pre-made pose

pose.displayColorbar=true;
switch(poseId)
    case 1 %flat view from top with 2 3x3 optode arrays
        pose.backgroundImage='./plotting/TopographicMapBackground002b.tif';
        pose.colorbarPosition=[0.35 0.35 0.3 0.1];
        
        %OptodeArray 1 (Hitachi ETG-4000 3x3)
        tmpOptodeArray.arrayType=1;
        tmpOptodeArray.orientation='NorthLeft';
        tmpOptodeArray.position=[0.52 0.45 0.3 0.3];
        tmpOptodeArray.labels=1:12;
        optodeArrays(1)={tmpOptodeArray};
        
        %OptodeArray 2 (Hitachi ETG-4000 3x3)
        tmpOptodeArray.arrayType=1;
        tmpOptodeArray.orientation='NorthLeft';
        tmpOptodeArray.position=[0.18 0.45 0.3 0.3];
        tmpOptodeArray.labels=13:24;
        optodeArrays(2)={tmpOptodeArray};
        
        pose.optodeArrays=optodeArrays;
        
        
    case 2 %front view with the camera looking from high position
            % with 2 3x3 optode arrays
        pose.backgroundImage='./plotting/TopographicMapBackground003.tif';
        pose.colorbarPosition=[0.35 0.35 0.3 0.1];
        
        %OptodeArray 1 (Hitachi ETG-4000 3x3)
        tmpOptodeArray.arrayType=1;
        tmpOptodeArray.orientation='SouthRight';
        tmpOptodeArray.position=[0.18 0.45 0.3 0.3];
        tmpOptodeArray.labels=1:12;
        optodeArrays(1)={tmpOptodeArray};
        
        %OptodeArray 2 (Hitachi ETG-4000 3x3)
        tmpOptodeArray.arrayType=1;
        tmpOptodeArray.orientation='SouthRight';
        tmpOptodeArray.position=[0.52 0.45 0.3 0.3];
        tmpOptodeArray.labels=13:24;
        optodeArrays(2)={tmpOptodeArray};
        
        pose.optodeArrays=optodeArrays;
        
    case 3 %face view  with 2 3x3 optode arrays
        pose.backgroundImage='./plotting/TopographicMapBackground004.tif';
        %pose.displayColorbar=false;
        pose.colorbarPosition=[0.35 0.9 0.3 0.1];
        %OptodeArray 1 (Hitachi ETG-4000 3x3)
        tmpOptodeArray.arrayType=1;
        tmpOptodeArray.orientation='SouthRight';
        tmpOptodeArray.position=[0.18 0.55 0.3 0.3];
        tmpOptodeArray.labels=1:12;
        optodeArrays(1)={tmpOptodeArray};
        
        %OptodeArray 2 (Hitachi ETG-4000 3x3)
        tmpOptodeArray.arrayType=1;
        tmpOptodeArray.orientation='SouthRight';
        tmpOptodeArray.position=[0.52 0.55 0.3 0.3];
        tmpOptodeArray.labels=13:24;
        optodeArrays(2)={tmpOptodeArray};
        
        pose.optodeArrays=optodeArrays;
       
    case 4 %Frontal (no background) of 2 3x3 optode arrays
        pose.backgroundImage=[];
        pose.displayColorbar=true;
        pose.colorbarPosition=[0.35 0.7 0.3 0.1];
        %OptodeArray 1 (Hitachi ETG-4000 3x3)
        tmpOptodeArray.arrayType=1;
        tmpOptodeArray.orientation='NorthLeft';
        tmpOptodeArray.position=[0.04 0.25 0.42 0.42];
        tmpOptodeArray.labels=1:12;
        optodeArrays(1)={tmpOptodeArray};
        
        %OptodeArray 2 (Hitachi ETG-4000 3x3)
        tmpOptodeArray.arrayType=1;
        tmpOptodeArray.orientation='NorthLeft';
        tmpOptodeArray.position=[0.54 0.25 0.42 0.42];
        tmpOptodeArray.labels=13:24;
        optodeArrays(2)={tmpOptodeArray};
        
        pose.optodeArrays=optodeArrays;
       
    case 5 %Frontal (no background) of 1 4x4 optode arrays
        pose.backgroundImage=[];
        pose.displayColorbar=true;
        pose.colorbarPosition=[0.35 0.9 0.3 0.1];
        %OptodeArray 1 (Hitachi ETG-4000 4x4)
        tmpOptodeArray.arrayType=2;
        tmpOptodeArray.orientation='NorthLeft';
        tmpOptodeArray.position=[0.1 0.05 0.8 0.8];
        tmpOptodeArray.labels=1:24;
        optodeArrays(1)={tmpOptodeArray};
        
        pose.optodeArrays=optodeArrays;
       
    case 6 %Frontal (no background) of 1 3x5 optode arrays
        pose.backgroundImage=[];
        pose.displayColorbar=true;
        pose.colorbarPosition=[0.35 0.9 0.3 0.1];
        %OptodeArray 1 (Hitachi ETG-4000 3x5)
        tmpOptodeArray.arrayType=3;
        tmpOptodeArray.orientation='NorthLeft';
        tmpOptodeArray.position=[0.1 0.05 0.8 0.8];
        tmpOptodeArray.labels=1:22;
        optodeArrays(1)={tmpOptodeArray};
        
        pose.optodeArrays=optodeArrays;
       
    otherwise
        error('ICNA:plotting:topoOnHead:getPose',...
              'Unexpected pre-made pose identifier.');
end

end
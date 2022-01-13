function [axisHandle]=topoOptodeArray(h,dataVector,oaInfo,options)
%Displays a spatial representation of an Optode Array
%
%
% [axisHandle]=topoOptodeArray(h,dataVector,oaInfo) Displays a spatial
%   representation of an Optode Array in figure or axis h.
%
% [axisHandle]=topoOptodeArray(h,dataVector,oaInfo,options) Displays a
%   spatial representation of an Optode Array in figure or axis h
%   and allow some options to be selected (see options below).
%
% This function callure/signature has been modified. See remarks
%section for details
%
%
%   +=================================================+
%   | IMPORTANT: This function currently only         |
%   |visualizes the output in 2D!                     |
%   | Although the code actually works in 3D (e.g.    |
%   |rotation of the topographical arrangement), the  |
%   |3D interpolation in MATLAB using                 |
%   |TriScatteredInterp will fail indicating that the |
%   |underlying triangulation is empty as points are  |
%   |coplanar, regardless of whether this is truly the|
%   |case.                                            |
%   +=================================================+
%
%
%
%% Optode Arrays
%
% Near Infrared Spectroscopy optodes in neuroimage are commonly
%disposed in optode arrays coupling light emitters and detectors
%to form channels at specific places.
%   The size and type of the optode array and hence the number
%of channels that the optode array can accommodate and their spatial
%disposition (topological arrangement) vary with every device. This
%information is encoded in the class ChannelLocationMap, which hold
%the information about the topological arrangement of the channels
%for the optode array.
%
% Following, a few examples of the topological disposition of channels
%for some known optode arrays are illustrated. Note however that the
%function does not need to know the optode array type in advance, as
%this information is part of the input parameter oaInfo.
%
%   Example: HITACHI ETG-4000 3x3 optode array
%
%   S - Light Source           S---1---D---2---S
%   D - Light Detector         |       |       |
%   1,..,12 - Channel          3       4       5
%                              |       |       |
%                              D---6---S---7---D
%                              |       |       |
%                              8       9      10
%                              |       |       |
%                              S--11---D--12---S
%
%
%   Example: HITACHI ETG-4000 4x4 optode array
%
%   S - Light Source           S---1---D---2---S---3---D
%   D - Light Detector         |       |       |       |
%   1,..,24 - Channel          4       5       6       7
%                              |       |       |       |
%                              D---8---S---9---D--10---S
%                              |       |       |       |
%                             11      12      13      14
%                              |       |       |       |
%                              S--15---D--16---S--17---D
%                              |       |       |       |
%                             18      19      20      21
%                              |       |       |       |
%                              S--22---D--23---S--24---D
%
%
%           3 -  HITACHI ETG-4000 3x5 optode array
%
%   S - Light Source        S---1---D---2---S---3---D---4---S
%   D - Light Detector      |       |       |       |       |
%   1,..,24 - Channel       5       6       7       8       9
%                           |       |       |       |       |
%                           D--10---S--11---D--12---S--13---D
%                           |       |       |       |       |
%                           14      15      16      17      18
%                           |       |       |       |       |
%                           S--19---D--20---S--21---D--22---S
%
%
%% Remarks
%
% From ICNA version 1.1.0 this function call/signature has been
%modified from previous versions. It now requires the optode
%array information as the third parameter.
%
%
%% Parameters
%
%   h - Figure handle (a new axes for the optode array will be inserted)
%       or the axis handle where the optode array is to be inserted.
%
%   dataVector - Values at each of the channels. The number of
%       provided values MUST match the number of channels
%       expected according to the optode array type 
%
%       +==============================================+
%       | This function DOES NOT understand the nature |
%       | of the data. It does not know which type of  |
%       | signal or chromophore is being displayed, or |
%       | where it was collected. It does not know     |
%       | either whether the data represents average   |
%       | values or simple time samples. It simply     |
%       | displays a topographical map out of the      |
%       | provided data regardless of its meaning.     |
%       +==============================================+
%
%
%   oaInfo - A struct with the information of the optode array. This
%       can be obtained from a channelLocationMap object using method
%       getOptodeArraysInfo(obj,idx).
%         The struct has the following fields:
%           .mode - A string describing the optode array.
%               Valid modes depend on the neuroimage type. Each neuroimage
%               subclass should check the validity of the modes.
%           .type - A string describing whether the optode array is for
%               adults, infants or neonates.
%           .topoArrangement - Topographical arrangement of the channels
%               within the optode array. These are 3D coordinates which
%               locate the channels internally to the optode array. The
%               XY plane will be the surface plane (i.e. over the scalp)
%               with arbitrary rotation and axis origin, and the Z
%               coordinate indicates the depth (with Z=0 being the scalp
%               plane and positive values indicating deeper layers into
%               the head. 
%                   The coordinates in this property are assigned to the
%               channels associated to this optode array in order from
%               the lowest channel number (i.e. 1) to the highest.
%                   The channel number here is the internal order
%               in which the vector of data is interpreted, and
%               does not necessarily match the "original" channel
%               number, which for instance may range from 13 to 24.
%               Please see option .labels below.
% 
%   options - A struct of options with the following fields.
%       .flipVertical - Set to true if you want to flip the topological
%           arrangement vertically. False by default.
%               A vertical flip is equivalent to a 180 degrees
%           rotation over the X axes (gamma). See option .rotation
%       .flipHorizontal - Set to true if you want to flip the topological
%           arrangement horizontally (around its center). False by default.
%               A horizontal flip is equivalent to a 180 degrees
%           rotation over the Y axes (beta). See option .rotation
%       .rotation - Angle/s (in degrees) to rotate the topological
%           arrangement (around its center). By default is set to 0.
%           It can be an scalar (rotate along the plane XY over the
%           Z axis) or a vector for rotating over the three axis
%           [alpha beta gamma] where:
%               + alpha rotates over the Z axis along the XY plane (yaw).
%               + beta rotates over the Y axis along the XZ plane (pitch).
%               + gamma rotates over the X axis along the YZ plane (roll).
%           The center of the rotation is the center of the topological
%           arrangement.
%
%       .scale - This function is unable to estimate a nice scale for
%           the values. By default, it will simply display the values
%           as such (i.e. assign color scale automatically). But it
%           can accept a row vector [min max] to rescale the colors.
%
%       .colormap - Assign a colormap. By default the colour map goes
%           from blue (lowest) to red (highest), a different color map
%           can be assigned.
%
%       .position - [x y width height] vector with the position of the
%           axis. By default the optode array will be centered in
%           the figure. This option is only valid if the figure handle,
%           rather than the axis handle has been passed as the first
%           argument. See also units.
%
%       .units -  Units in which the position is expressed. Units can
%           be 'pixels' or 'normalize'. Default units are those of MATLAB.
%           See also position.
%
%       .displayChannelLabels - Add a label to the channels. True
%           by default
%       .displayChannelMarkers - Add a marker to the channels. True
%           by default
%       .labels - The label of the channels. Only valid if
%           the option displayChannelLabels is set to true. By default,
%           the channels will be labelled numerically starting on 1 to
%           the number of channels held by the optode arrya. This option
%           allow the user to modify these labels. The channel labels
%           can be indicated in several ways:
%               + As a numerical array. Each number will be considered
%           a channel label.
%               + As a string. Each character is used as a label for
%           a channel.
%               + As a cell array of string. Each position of the
%           cell array is expected to contain a label for
%           a channel.
%               In all cases the number of elements in this
%           vector must be at least the number of channels
%           held by the optode array. If more elements are indicated
%           they are simply ignored.
%       
%
%
%% Output
%
% The handle of the axis representing the optode array
%
%
% Copyright 2008-2013
% @date: 3-Oct-2008
% @author: Felipe Orihuela-Espina
% @modified: 3-Jan-2013
%
% See also plotTopo, topoOnHead, channelLocationMap
%


oaInfo.topoArrangement = oaInfo.chTopoArrangement;

%Deal with options
opt.flipHorizontal=false;
opt.flipVertical=false;
opt.rotation=[0 0 0]; %[alpha beta gamma] angles
opt.scale=[]; %If empty, automatic scale is used
% load('./plotting/fNIRSColorMapHitachi.mat')
% opt.colormap=fNIRSColorMap;
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
opt.colormap=cmap;
opt.position=[];
opt.units=[];
opt.displayChannelLabels=true;
opt.displayChannelMarkers=true;
nChannels = size(oaInfo.chTopoArrangement,1);
opt.labels=1:nChannels; %See auxiliar function below;
if exist('options','var')
    if(isfield(options,'flipHorizontal'))
        opt.flipHorizontal=options.flipHorizontal;
    end
    if(isfield(options,'flipVertical'))
        opt.flipVertical=options.flipVertical;
    end
    if(isfield(options,'rotation'))
        if isscalar(options.rotation)
            opt.rotation=[options.rotation 0 0];
        else
            opt.rotation=options.rotation;
        end
    end
    if(isfield(options,'scale'))
        opt.scale=options.scale;
    end
    if(isfield(options,'colormap'))
        opt.colormap=options.colormap;
    end
    if(isfield(options,'position'))
        opt.position=options.position;
    end
    if(isfield(options,'units'))
        opt.units=options.units;
    end
    if(isfield(options,'displayChannelLabels'))
        opt.displayChannelLabels=options.displayChannelLabels;
    end
    if(isfield(options,'displayChannelMarkers'))
        opt.displayChannelMarkers=options.displayChannelMarkers;
    end
    if(isfield(options,'labels'))
        opt.labels=options.labels;
    end
end



%% Ensure that I'm working in the right figure/axis
if (ismember(h,findobj('type','axes')))
    axes(h);
else %if (ismember(h,findobj('type','figure'))) or handle does not exist
    figure(h);
    tmpAxes=axes; %Create a new axes
    if ~isempty(opt.position)
        if ~isempty(opt.units)
            set(tmpAxes,'Position',opt.position,'Units',opt.units);
        else
            set(tmpAxes,'Position',opt.position);
        end
    end
end
hold on

%% Ensure dataVector is a column
dataVector=reshape(dataVector,numel(dataVector),1);

assert(length(dataVector)==nChannels,...
    ['ICNA:plotting:topoOptodeArray ',...
     'Number of elements in the data vector does not match ' ...
     'the number of channels in the optode array.']);

 
%% Reconvert labels to string
labels=cell(nChannels,1);
if ischar(opt.labels)
    for ii=1:nChannels
        labels(ii)={opt.labels(ii)};
    end
elseif isnumeric(opt.labels)
    for ii=1:nChannels
        labels(ii)={num2str(opt.labels(ii))};
    end
elseif iscell(opt.labels)
    labels=opt.labels;
else
    error('ICNA:plotting:topoOptodeArray',...
            'Unexpected channel labels.');
end     
    
%% Flip/Rotate topological arrangement as necessary

%%%Uncomment for testing
% plot3(oaInfo.topoArrangement(:,1),...
%     oaInfo.topoArrangement(:,2),...
%     oaInfo.topoArrangement(:,3),'r.')
% plot3(oaInfo.topoArrangement(1,1),...
%     oaInfo.topoArrangement(1,2),...
%     oaInfo.topoArrangement(1,3),'g.')
alpha = opt.rotation(1);
beta = opt.rotation(2);
gamma = opt.rotation(3);
if opt.flipHorizontal
    beta = beta+180;
end
if opt.flipVertical
    gamma = gamma+180;
end
%rotation matrices
%See wikipedia: http://en.wikipedia.org/wiki/Rotation_matrix
Rx = [1 0 0; 0 cosd(gamma) -sind(gamma); 0 sind(gamma) cosd(gamma)];
Ry = [cosd(beta) 0 sind(beta); 0 1 0; -sind(beta) 0 cosd(beta)];
Rz = [cosd(alpha) -sind(alpha) 0; sind(alpha) cosd(alpha) 0; 0 0 1];
tArr_center = repmat(mean(oaInfo.topoArrangement),nChannels,1);
oaInfo.topoArrangement = oaInfo.topoArrangement - tArr_center;
oaInfo.topoArrangement = (Rx*Ry*Rz*oaInfo.topoArrangement')';
oaInfo.topoArrangement = oaInfo.topoArrangement + tArr_center;
%%%Uncomment for testing
% [alpha beta gamma]
% plot3(oaInfo.topoArrangement(:,1),...
%     oaInfo.topoArrangement(:,2),...
%     oaInfo.topoArrangement(:,3),'bo')
% plot3(oaInfo.topoArrangement(1,1),...
%     oaInfo.topoArrangement(1,2),...
%     oaInfo.topoArrangement(1,3),'go')




%% Interpolate values
% [X,Y,Z] = meshgrid(linspace(min(oaInfo.topoArrangement(:,1)),...
%                           max(oaInfo.topoArrangement(:,1)),50),...
%                    linspace(min(oaInfo.topoArrangement(:,2)),...
%                           max(oaInfo.topoArrangement(:,2)),50),...
%                    linspace(min(oaInfo.topoArrangement(:,3)),...
%                           max(oaInfo.topoArrangement(:,3)),50));
[X,Y] = meshgrid(linspace(min(oaInfo.topoArrangement(:,1)),...
                          max(oaInfo.topoArrangement(:,1)),30),...
                   linspace(min(oaInfo.topoArrangement(:,2)),...
                          max(oaInfo.topoArrangement(:,2)),30));
                      
H=oaInfo.topoArrangement;
%F = TriScatteredInterp(H(:,1),H(:,2),H(:,3),dataVector,'linear');
%HZ = F(X,Y,Z);
F = TriScatteredInterp(H(:,1),H(:,2),dataVector,'linear');
HZ = F(X,Y);

%% Adjust the isolines levels to the nearest decade (upwards and downwards).
minLim=10*(floor(min(min(min(HZ)))/10)); % Default - 'automatic'
maxLim=10*ceil(max(max(max(HZ)))/10);
if ~isempty(opt.scale)
    minLim=opt.scale(1);
    maxLim=opt.scale(2);
end
if minLim > maxLim
    temp = minLim;
    minLim = maxLim;
    maxLim = temp;
end
nSteps=size(opt.colormap,1); %Number of steps for the interpolation
            %Note that the best visualization is obtained when
            %the number of steps matches the number of colors
            %in the colormap
v=linspace(minLim,maxLim,nSteps);


%% Finally, plot...
%Watch out! surface and surf do not respect the properties of the figure
%and thus the surface will appear on top of everything else (i.e. channel
%markers and labels).
%h=surface(X,Y,HZ); %Step size depends on meshgrid. Can ran out of memory very quickly
%h=surf(gca,X,Y,HZ); %Step size depends on meshgrid. Can ran out of memory very quickly
[~,h]=contourf(gca,X,Y,HZ,v); %Step size depends on v. Mesh grid can be coarse.
set(h,'LineStyle','none'); %Display (or not) the contour lines
%set(h,'ShowText','on'); %Display (or not) the contour lines

%Plot Channel markers.
if (opt.displayChannelMarkers)
    plot3(oaInfo.topoArrangement(:,1),...
         oaInfo.topoArrangement(:,2),...
         oaInfo.topoArrangement(:,3),'ys',...
            'MarkerSize',28,'MarkerFaceColor','y');
end
if (opt.displayChannelLabels)
    for ch=1:nChannels %Label the channel markers
        text(oaInfo.topoArrangement(ch,1),...
            oaInfo.topoArrangement(ch,2),...
            oaInfo.topoArrangement(ch,3),...
            labels{ch},...
            'FontSize',18,'FontWeight','bold',...
            'HorizontalAlignment','center');
    end
end


set(gca,'XLim',[min(oaInfo.topoArrangement(:,1)) ...
                max(oaInfo.topoArrangement(:,1))]);
set(gca,'XTick',[]);
set(gca,'YLim',[min(oaInfo.topoArrangement(:,2)) ...
                max(oaInfo.topoArrangement(:,2))]);
set(gca,'YTick',[]);
% set(gca,'ZLim',[min(oaInfo.topoArrangement(:,3)) ...
%                 max(oaInfo.topoArrangement(:,3))]);
% set(gca,'ZTick',[]);
% 
set(gca,'Visible','off');

set(gcf,'Colormap',opt.colormap);

%%Crop the colormap to allow only for the used levels 
%%If this is not done, MATLAB try to use the whole colourmap in the
%%contourf (attempting to maximize the constrast between levels). This
%%result in the effect of the scale being "lost"
%%(Help topic: "Example -- Simulating Multiple Colormaps in a Figure")
%%See also the axes properties CData, CLim and CLimMode
%Determining the portion of the colormap to use relative to the total
%colormap size
%Scale Clim range accordingly to the portion of the colormap to use
newCLim=[v(1) v(end)];
if ~any(isnan(newCLim))
  %Set the new CLim
  set(gca,'CLim',newCLim);
end

% if (opt.colorbar)
%     colorbar;
% end


axisHandle=gca;


end







function [f]=plotStructuredData(sd,options)
%Display the data in a structuredData
%
% [f]=plotStructuredData(sd,options) Display the data in a structuredData.
%	 See options below
%
%
%% Options
%
% options - Struct. A struct of options with the following fields.
%   .mainTitle - Char array. By default is set to the structuredData.name
%       The main title of the figure as a string. 
%
%   .scale - Boolean. Default is true.
%       True if you want all channels to share the same scale (default).
%       False if each channel is to be displayed on a different scale.
%
%   .scaleLimits - double(1,2) or double(2,1) [min max] 
%       Default is set to empty (not defined) i.e. matlab will
%       automatically choose the best limits.
%       Determine the Y scale limits of the plots.
%       It is only taken into account if option .scale=True, otherwise
%       they are ignored.
%
%   .fontSize - double. Default is 13.
%       The font size used in the plots.
%
%   .lineWidth - double. Default is 1.5.
%       The line width used in the plots.
%
%   .displayLegend - Boolean. Default is true.
%       True if you want to display the legend.
%
%   .legendLocation - char array. Default 'NorthEast'.
%       The location of the legend.
%
%   .whichChannels - Int[]. Vector of channel numbers
%       + If empty, all channels will be rendered.
%       + If not empty, only the chosen channels will be rendered.
%
%   .whichSignals - Int[]. Vector of signal numbers
%       + If empty, all signals will be rendered.
%       + If not empty, only the chosen signals will be rendered.
%
%    .whichConditions - Either vector of ids or cell array of condition
%       tags. By default is empty.
%       + If empty, all conditions will be rendered.
%       + If not empty, only the chosen conditions will be rendered.
%
%% Parameters
%
%   sd - A structuredData
%   options-  [Optional] A struct of options. See section options
%
%% Output
%
% f - The figure handle.
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also structuredData, plotChannel, shadeTimeline
%



%% Log
%
% File created: 25-June-2025
%
% -- ICNNA v1.3.1
%
% 25-June-2025: FOE
%   + File created. Reused some code from plotStructuredData.
%
%
% -- ICNNA v1.4.0
%
% 14-Dec-2025: FOE
%   + Adjustments to icnna.data.core.timeline class version '1.2'.
%   + Bug fixed: When translating conditions tags/names to ids,
%       and the option .whichConditions was passed as a cell array,
%       an inexistent method of class timeline, getConditionId, was
%       being called. Also, this case was not considering the class
%       icnna.data.core.timeline
%



if ~isa(sd,'structuredData')
    error('ICNA:plotStructuredData:InvalidInput',...
        'Invalid input parameter.');
end


%% Deal with options
try
    opt.mainTitle = sd.name;
catch
    warning('icnna:plot:plotStructuredData',...
        'Deprecated object version.');
    opt.mainTitle = sd.description;
end
opt.scale         = true;
opt.scaleLimits   = [];
opt.fontSize      = 13;
opt.lineWidth     = 1.5;
opt.displayLegend = true;
opt.legendLocation= 'NorthEast';
opt.whichChannels  =[];
opt.whichSignals   =[];
opt.whichConditions=[];
if(exist('options','var'))
    %Options provided
    if(isfield(options,'mainTitle'))
        opt.mainTitle=options.mainTitle;
    end
    if(isfield(options,'scale'))
        opt.scale=options.scale;
    end
    if(isfield(options,'scaleLimits') && numel(options.scaleLimits) == 2)
        opt.scaleLimits=options.scaleLimits;
    end
    if(isfield(options,'fontSize'))
        opt.fontSize=options.fontSize;
    end
    if(isfield(options,'lineWidth'))
        opt.lineWidth=options.lineWidth;
    end
    if(isfield(options,'displayLegend'))
        opt.displayLegend=options.displayLegend;
    end
    if(isfield(options,'legendLocation'))
        opt.legendLocation=options.legendLocation;
    end
    if(isfield(options,'whichChannels'))
        opt.whichChannels=sort(options.whichChannels);
    end
    if(isfield(options,'whichSignals'))
        opt.whichSignals=sort(options.whichSignals);
    end
    if(isfield(options,'whichConditions'))
        opt.whichConditions=options.whichConditions;
    end
end



%Unfold channels if needed
if isempty(opt.whichChannels)
    opt.whichChannels = 1:sd.nChannels;
end
tmpData = sd.data;
tmpData = tmpData(:,opt.whichChannels,:); 

%Unfold signals if needed
if isempty(opt.whichSignals)
    opt.whichSignals = 1:sd.nSignals;
end
tmpData = tmpData(:,:,opt.whichSignals); 


[~,tmpNChannels,tmpNSignals] = size(tmpData);


%Translate conditions tags/names to ids if needed
if isempty(opt.whichConditions)
    opt.whichConditions = nan(1,t.nConditions);
    if isa(t,'timeline')
        opt.whichConditions = 1:t.nConditions;
    else %icnna.data.core.timeline
        if icnna.util.compareVersions(classVersion(t),'1.1','<=')
            for iCond = 1:t.nConditions
                opt.whichConditions(iCond) = t.conditions(iCond).id;
            end
        if icnna.util.compareVersions(classVersion(t),'1.2','>=')
            opt.whichConditions = [t.conditions.id];
        end
    end
elseif iscell(opt.whichConditions)
    tmpWhichConditions  = opt.whichConditions;
    if isa(t,'timeline')
        opt.whichConditions = [];
        for iCond = 1:t.nConditions
            tmpCond = t.getCondition(tmpWhichConditions{iCond});
            opt.whichConditions(iCond) = tmpCond.id;
        end
    else %icnna.data.core.timeline
        tmpConds = getConditions(t,tmpWhichConditions);
        opt.whichConditions = [tmpConds.id];
    end
    clear tmpWhichConditions
end







%% Initialize the figure
f=figure('Visible','off','Units','normalized',...
         'Position',[0.05 0.05 0.9 0.9]);


%Decide whether to use 1 or 2 columns
nCols = 1;
nRows = tmpNChannels;
if nRows > 10
    nCols = 2;
    nRows = ceil(tmpNChannels/2);
end


%% Generate 1 axes per channel
chAxes = gobjects(tmpNChannels,1); % Preallocate array of axes
for iAxes = 1:length(chAxes)
    chAxes(iAxes) = axes();
end
for ch=1:tmpNChannels
    set(chAxes(ch),...
        'Tag',['axesCh' num2str(opt.whichChannels(ch))],...
		'FontSize',opt.fontSize,...
        'Color','w',...
        'YTick',0,...
        'Units','normalize');

    set(get(chAxes(ch),'YLabel'),'String',['#' num2str(opt.whichChannels(ch))])   
    %Set the Y label location
    if ch <= nRows
        set(chAxes(ch),'YAxisLocation','left');
    else
        set(chAxes(ch),'YAxisLocation','right');
    end
    

    %Set the position (2 columns for more than 2 channels; or
    %one column if there is only 1 channel)
    offsetMargin=0.05;
    height = (1-4*offsetMargin)/nRows;
    width  = (1-2*offsetMargin)/nCols;
    yPos   = (1-2*offsetMargin)-(mod(ch-1,nRows)+1)*height;

    xPos=0.05;
    if ch > nRows
        xPos=0.52;
    end
    set(chAxes(ch),'Position',[xPos yPos width height])

    if (ch==1) || (ch==nRows+1)
        set(chAxes(ch),'XAxisLocation','top')
    end
    if (ch==nRows) || (ch==tmpNChannels)
        if isa(sd.timeline,'icnna.data.core.timeline')
            set(get(chAxes(ch),'XLabel'),'String',...
                    ['Time [' sd.timeline.unit ']']);
        else
            set(get(chAxes(ch),'XLabel'),'String',...
                    'Time [samples]');
        end
    end

    set(chAxes(ch),'XLim',[1 sd.nSamples]);
    if(opt.scale)
        if ~isempty(opt.scaleLimits)
            set(chAxes(ch),'YLim',opt.scaleLimits);
        end
    end

    box on
end
linkaxes(chAxes,'x');

cMap = jet(tmpNSignals);
if isa(sd,'nirs_neuroimage') && (tmpNSignals >= 2)
    %Find the oxy and deoxy and set those to red and blue
    try
        cMap(nirs_neuroimage.OXY,:)   = [1 0 0];
        cMap(nirs_neuroimage.DEOXY,:) = [0 0 1];
        if (sd.nSignals >= nirs_neuroimage.TOTALHB)
            cMap(nirs_neuroimage.TOTALHB,:) = [0 1 0];
        end
    catch
        %Do nothing
    end
end

%% Plot the signals
HH = gobjects(tmpNChannels,tmpNSignals); %Preallocate line handlers
hTimelineEvents = cell(sd.nChannels,1);
for ch=1:tmpNChannels
    axes(chAxes(ch));
    cla(chAxes(ch));

    for ss=1:tmpNSignals
        HH(ch,ss)=line('XData',1:sd.nSamples,...
            'YData',tmpData(:,ch,ss),...
            'LineStyle','-',...
            'LineWidth',opt.lineWidth,...
            'Color',cMap(ss,:));
    end

    %Shade the regions of stimulus
    %%%IMPORTANT NOTE: If I try to first paint stimulus regions and
    %%%later the signal, at the moment will not work...
    opt2.whichConditions = opt.whichConditions;
    hTimelineEvents(ch)={shadeTimeline(gca,sd.timeline,opt2)};
end


end
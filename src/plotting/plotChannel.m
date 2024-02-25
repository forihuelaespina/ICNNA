function [h]=plotChannel(sd,ch,options)
%Display the temporal course of signals in a channel
%
% [h]=plotChannel(sd,ch,options) Display the temporal course of
%   signals in a channel, either with or without block averaging.
%   See options below
%
%
%% Options
%
%   .axesHandle: An axes handle if you want the plot in a particular
%       existing handle. By default the image will be a new figure.
%   
%   .mainTitle: The main title of the figure as a string. By default
%       is set to the structuredData Description followed by the
%       selected channel.
%   
%   .whichSignals - A row vector indicating which signals to plot. By
%   default all signals in the channel will be displayed. If indicated
%   the number elements must correspond with the number of signals
%   in the structured data.
%       length(whichSignals)==get(sd,'NSignals')
%
%   .scale - True if you want to fix the Y axis scale
%   (default). False if the scale is to be automatically computed.
%   This is useful if this function is call for several
%   channels, and you want all the plots to share the same scale.
%
%   .scaleLimits - [min max] Determine the Y scale limits of the plots.
%   It is only taken into account if option .scale=True. Otherwise
%   they are ignored. When not provided, the function will automatically
%   look for the "best" limits.
%
%   .shadeTimeline - True (default) if you want timeline events
%       to be shaded. False otherwise.
%
%   .fontSize - The font size used in the plots. Size 13 points used by
%   default
%
%   .lineWidth - The line width used in the plots. Size 1.5 used by
%   default
%
%   .lineStyle - A cell array of line styles. It should contain
%   one style per signal. By default is set to {'-',...,'-'}, i.e.
%   all signals are plotted as continuous lines.
%
%   .displayLegend - True (default) if you want ot display the legend.
%
%   .legendLocation - The location of the legend. Default 'NorthEast'.
%
%    ==== Block Averaging related options ==============
%
%   .blockAveraging - Indicates wether averaging across blocks must be
%       performed. False by default i.e. the whole unaveraged signal
%       will be displayed.
%
%   .blockCondTag - Condition for which averaging occurs. Default
%       value is 'A'.
%
%   .blockBaseline - Baseline length in samples for the block
%
%   .blockMaxRest - Maximum rest samples for the block
%
%   .blockResampling - Indicates wether resample each block.
%       False by default.
%
%   .blockResamplingBaseline - Baseline chunk resampled length
%       in samples for the block. By default equals to .blockBaseline
%
%   .blockResamplingTask - Task chunk resampled length
%       in samples for the block
%
%   .blockResamplingRest - Rest chunk resampled length
%       in samples for the block
%
%   .blockDisplayStd - Shade a region of the standard deviation
%       obtained across blocks.
%
%% Parameters
%
%   sd - A structuredData
%
%   ch - The channel to display. If the channel does not exist
%       an error is thrown.
%
%   options-  [Optional] A struct of options. See section options
%
%% Output
%
% A figure/axis handle.
%
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also structuredData, timeline, shadeTimeline,
%   structuredData.getBlock
%



%% Log
%
% File created: 13-Nov-2008
% Previous last modification: 4-Jan-2013
%
% 17-Mar-2021: FOE
%   * this log created and removed the tag @modified
%   * shading the timeline now occurs before setting the legend
%   to avoid the plotting of timeline to change the legend.
%
% 27-May-2023: FOE
%   + Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%



channelData = getChannel(sd,ch);
t = sd.timeline;
nSamples = sd.nSamples;
if isempty(channelData)
    error('ICNNA:plotChannel:InvalidChannel',...
        'Invalid selected channel.');
end


%% Deal with options
opt.mainTitle=[sd.description '; Ch:' num2str(ch)];
opt.whichSignals=1:sd.nSignals;
opt.scale=true;
%Calculate an appropriate Y scale (rounding to the nearest decade)
maxY = ceil(max(max(real(channelData)))/10)*10;
minY = floor(min(min(real(channelData)))/10)*10;
opt.scaleLimits=[minY maxY];
opt.shadeTimeline=true;
opt.fontSize=13;
opt.lineWidth=1.5;
opt.lineStyle={'-'};
opt.displayLegend=true;
opt.legendLocation='NorthEast';
%Block splitting parameters if block averaging
opt.blockAveraging=false;
opt.blockCondTag='A';
opt.blockBaseline=15;
opt.blockMaxRest=20;
%Block resampling parameters if block averaging
opt.blockResampling = false;
opt.blockResamplingBaseline = opt.blockBaseline;
opt.blockResamplingTask = 30;
opt.blockResamplingRest = opt.blockMaxRest;

opt.blockDisplayStd=true;
opt.axesHandle=[];
if(exist('options','var'))
    %%Options provided
    if(isfield(options,'mainTitle'))
        opt.mainTitle=options.mainTitle;
    end
    if(isfield(options,'whichSignals'))
        opt.whichSignals=options.whichSignals;
    end
    if(isfield(options,'scale'))
        opt.scale=options.scale;
    end
    if(isfield(options,'scaleLimits'))
        opt.scaleLimits=options.scaleLimits;
    end
    if(isfield(options,'shadeTimeline'))
        opt.shadeTimeline=options.shadeTimeline;
    end
    if(isfield(options,'fontSize'))
        opt.fontSize=options.fontSize;
    end
    if(isfield(options,'lineWidth'))
        opt.lineWidth=options.lineWidth;
    end
    if(isfield(options,'lineStyle'))
        opt.lineStyle=options.lineStyle;
    end
    if(isfield(options,'displayLegend'))
        opt.displayLegend=options.displayLegend;
    end
    if(isfield(options,'legendLocation'))
        opt.legendLocation=options.legendLocation;
    end
    if(isfield(options,'blockAveraging'))
        opt.blockAveraging=options.blockAveraging;
    end
    if(isfield(options,'blockCondTag'))
        opt.blockCondTag=options.blockCondTag;
    end
    if(isfield(options,'blockBaseline'))
        opt.blockBaseline=options.blockBaseline;
    end
    if(isfield(options,'blockMaxRest'))
        opt.blockMaxRest=options.blockMaxRest;
    end
    if(isfield(options,'blockResampling'))
        opt.blockResampling=options.blockResampling;
    end
    if(isfield(options,'blockResamplingBaseline'))
        opt.blockResamplingBaseline=options.blockResamplingBaseline;
    end
    if(isfield(options,'blockResamplingTask'))
        opt.blockResamplingTask=options.blockResamplingTask;
    end
    if(isfield(options,'blockResamplingRest'))
        opt.blockResamplingRest=options.blockResamplingRest;
    end
    if(isfield(options,'blockDisplayStd'))
        opt.blockDisplayStd=options.blockDisplayStd;
    end
    if(isfield(options,'axesHandle'))
        opt.axesHandle=options.axesHandle;
    end
end


%Block averaging if neccessary
if opt.blockAveraging
    cevents=getConditionEvents(t,opt.blockCondTag);
    nBlocks=size(cevents,1);
    if nBlocks==0
        tmpSd=sd;
        tmpChannelData = nan(tmpSd.nSamples,tmpSd.nSignals,1);
    end
    for bb=1:nBlocks
        tmpSd=getBlock(sd,opt.blockCondTag,bb,...
                          'NBaselineSamples',opt.blockBaseline,...
                          'NRestSamples',opt.blockMaxRest);
        % Resampling
        if (opt.blockResampling)
            nRSSamples=[opt.blockResamplingBaseline ...
                opt.blockResamplingTask ...
                opt.blockResamplingRest];
            tmpSd=blockResample(tmpSd,nRSSamples);
        end
        tmpChannelData(:,:,bb)=getChannel(tmpSd,ch);
    end
    channelData=mean(tmpChannelData,3);
    channelDataSTD = std(tmpChannelData,0,3);
    t= tmpSd.timeline;
    nSamples=size(channelData,1);
    
    
    if opt.scale
        maxY = ceil(max(max(real(channelData)))/10)*10;
        minY = floor(min(min(real(channelData)))/10)*10;
        if opt.blockDisplayStd
            maxY = ceil(max(max(real(channelData+channelDataSTD)))/10)*10;
            minY = floor(min(min(real(channelData-channelDataSTD)))/10)*10;
        end
        opt.scaleLimits=[minY maxY];
    end
end


if all(isnan(opt.scaleLimits))
    opt.scaleLimits=[-1 1];
elseif isnan(opt.scaleLimits(1))
    opt.scaleLimits(1)=opt.scaleLimits(2)-(2*eps);
elseif isnan(opt.scaleLimits(2))
    opt.scaleLimits(2)=opt.scaleLimits(1)-(2*eps);
end

if opt.scaleLimits(1)>opt.scaleLimits(2)
    opt.scaleLimits=[opt.scaleLimits(2) opt.scaleLimits(1)];
elseif opt.scaleLimits(1)==opt.scaleLimits(2)
    opt.scaleLimits(1)=opt.scaleLimits(1)-(2*eps);
end
    

colormap=[1 0 0; ...
    0 0 1; ...
    0 1 0; ...
    1 1 0; ...
    1 0 1; ...
    0 1 1; ...
    0 0 0];

%% Figure set up

if isempty(opt.axesHandle)
    h=figure;
    %Set Figure screen size
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    movegui('center');
else
    axes(opt.axesHandle);
    h=gcf;
end

%% Plot signals
hold on
pos=1;
legendTags=cell(length(opt.whichSignals),1);
for ss=opt.whichSignals
    lstyle=opt.lineStyle{mod(ss-1,length(opt.lineStyle))+1};
    hLegend(pos)=plot(channelData(:,ss),'Color',colormap(ss,:),...
            'LineStyle',lstyle,'LineWidth',opt.lineWidth);
    if (any(imag(channelData(:,ss))))
        plot(real(channelData(:,ss)),'Color',colormap(ss+3,:),...
            'LineStyle',lstyle,'LineWidth',opt.lineWidth);
    end
    
    if opt.blockAveraging && opt.blockDisplayStd
        X=[1:nSamples nSamples:-1:1]';
        tmp=channelData(:,ss)-channelDataSTD(:,ss);
        Y=[channelData(:,ss)+channelDataSTD(:,ss); ...
            tmp(end:-1:1)];
        patch(X,Y,colormap(ss,:),'EdgeColor','none','FaceAlpha',0.2)
    end

    legendTags(pos)={getSignalTag(sd,ss)};
    pos=pos+1;
end


%% Plot the Timeline
if (opt.shadeTimeline)
    %%Shade the regions of stimulus
    %%%IMPORTANT NOTE: If I try to first paint stimulus regions and
    %%%later the signal, at the moment will not work...
    shadeTimeline(gca,t);
end


%% Polish the plot
grid on
set(gca,'XLim',[0 nSamples]);
if (opt.scale)
    set(gca,'YLim',opt.scaleLimits);
end
xlabel('Time (samples)','FontSize',opt.fontSize);
ylabel('\Delta Hb [\mu M \times cm]','FontSize',opt.fontSize);
title(opt.mainTitle,'FontSize',opt.fontSize+2);
set(gca,'FontSize',opt.fontSize);

if opt.displayLegend
    legend(hLegend,legendTags,'Location',opt.legendLocation);
end




end %function

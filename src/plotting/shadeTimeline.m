function [H]=shadeTimeline(axesHandle,t,options)
%Shades the region of the stimulus in an axis
%
% [H]=shadeTimeline(axesHandle,timeline,options) Shades the region of the
% stimulus contained in the timeline in an axis
%
%%IMPORTANT NOTE: If I try to first paint stimulus regions and
%%later the signal, at the moment it does not work...
%
% You are advised to better adjust you YLim before calling this
%function.
%
%
%% Parameters
%
% axesHandle - The handle of the figure to be modified. This
%       is expected to be a time course representation of some
%       (or all) of the signals present in the channel.
%
% timeline - A timeline
%
% options - [Optional] Struct. A struct of options with the following
%   options
%    .edgeColor - Edge color. 'none' by default
%    .faceAlpha - double. Default value is 0.3
%       Transparency from 0 (transparent) to 1 (opaque).
%    .whichConditions - Either vector of ids or cell array of condition
%       tags. By default is empty.
%       + If empty, all conditions will be rendered.
%       + If not empty, only the chosen conditions will be rendered.
%
%% Output
%
% The axis is modified, so the stimulus regions are shaded.
%
% H - a cell array of handles to all events. Each position of the cell
%   array represents a different condition.
%
%
%
% Copyright 2008-25
% @author Felipe Orihuela-Espina
%
% See also timeline, plotChannel
%







%% Log
%
% File created: 13-Nov-2008
% File last modified (before creation of this log): 1-Jan-2013
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added get/set methods support for struct like access to attributes.
%
% 13-May-2023: FOE
%   + Slightly modify behaviour so that the shading does not alter
%   the Y axes scaling.
%
% 25-Jun-2025: FOE
%   + Added option to pick the conditions to shade.
%






%%Deal with options
opt.edgeColor='none';
opt.faceAlpha=0.3;
opt.whichConditions=[];
if(exist('options','var'))
    %%Options provided
    if(isfield(options,'edgeColor'))
        opt.edgeColor=options.edgeColor;
    end
    if(isfield(options,'faceAlpha'))
        opt.faceAlpha=options.faceAlpha;
    end
    if(isfield(options,'whichConditions'))
        opt.whichConditions=options.whichConditions;
    end
end


%Translate conditions tags/names to ids if needed
if isempty(opt.whichConditions)
    opt.whichConditions = nan(1,t.nConditions);
    if isa(t,'timeline')
        opt.whichConditions = 1:t.nConditions;
    else %icnna.data.core.timeline
        for iCond = 1:t.nConditions
            opt.whichConditions(iCond) = t.conditions(iCond).id;
        end
    end
elseif iscell(opt.whichConditions)
    tmpWhichConditions  = opt.whichConditions;
    opt.whichConditions = [];
    for iCond = 1:t.nConditions
        opt.whichConditions(iCond) = t.getConditionId(...
                                            tmpWhichConditions{iCond});
    end
    clear tmpWhichConditions
end

%% Display the timeline
axes(axesHandle);
hold on

switch (t.nConditions) %this switch is not strictly necessary but makes things
                %more aesthetically beautiful... ;)
    case 1
        cmap=[0 1 0]; 
    otherwise
        cmap=colormap(hsv(t.nConditions));
end



% Get limits of Y-axis
tmpYLims = get(gca,'YLim');
getY=axis;
limits=[getY(3) getY(4) getY(4) getY(3)];

%hold on;

H=cell(t.nConditions,1);
for condID = 1:t.nConditions

    tmpVisible = 'off';
    if ismember (condID,opt.whichConditions)
        tmpVisible = 'on';
    end

    condTag   = t.getConditionTag(condID);
    condEvents= t.getConditionEvents(condTag);
    nEvents   = t.getNEvents(condTag);
%%Shade the regions of stimulus
%%Get the time marks indicating where the task start and finish
onsets=condEvents(:,1);
durations=condEvents(:,2);
endingMarks=onsets+durations;

tmpH=zeros(1,nEvents);
for ee=1:nEvents
    tmph=patch([onsets(ee) onsets(ee) ...
            endingMarks(ee) endingMarks(ee)],...
        limits,0.1,...
        'EdgeColor',opt.edgeColor,...
        'FaceAlpha',opt.faceAlpha,...
        'FaceColor','flat',...
        'Visible',tmpVisible);
    set(tmph,'FaceColor',cmap(condID,:));
    
    tmpH(ee)=tmph;
end
H(condID)={tmpH};
end



%Make sure we keep the original Y axes scale limits
set(gca,'YLim',tmpYLims);

end %function

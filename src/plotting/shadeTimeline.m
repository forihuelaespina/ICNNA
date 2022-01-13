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
%% Options
%
% edgeColor - Edge color. 'none' by default
%
% faceAlpha - Transparency from 0 (transparent) to 1 (opaque). Default
%   value is 0.3
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
% options - [Optional] A struct of options. See section options
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
% Copyright 2008-13
% @date: 13-Nov-2008
% @author Felipe Orihuela-Espina
% @modified: 1-Jan-2013
%
% See also timeline, plotChannel
%

%%Deal with options
opt.edgeColor='none';
opt.faceAlpha=0.3;
if(exist('options','var'))
    %%Options provided
    if(isfield(options,'edgeColor'))
        opt.edgeColor=options.edgeColor;
    end
    if(isfield(options,'faceAlpha'))
        opt.faceAlpha=options.faceAlpha;
    end
end

%% Display the timeline
axes(axesHandle);

hold on


nConds=get(t,'NConditions');
switch (nConds) %this switch is not strictly necessary but makes things
                %more aesthetically beautiful... ;)
    case 1
        cmap=[0 1 0]; 
    otherwise
        cmap=colormap(hsv(nConds));
end

H=cell(nConds,1);
for condID=1:nConds
    condTag=getConditionTag(t,condID);
    condEvents=getConditionEvents(t,condTag);
    nEvents=getNEvents(t,condTag);
%%Shade the regions of stimulus
%%Get the time marks indicating where the task start and finish
onsets=condEvents(:,1);
durations=condEvents(:,2);
endingMarks=onsets+durations;

% Get limits of Y-axis
getY=axis;
limits=[getY(3) getY(4) getY(4) getY(3)];
tmpH=zeros(1,nEvents);
for ee=1:nEvents
    tmph=patch([onsets(ee) onsets(ee) ...
            endingMarks(ee) endingMarks(ee)],...
        limits,0.1,...
        'EdgeColor',opt.edgeColor,...
        'FaceAlpha',opt.faceAlpha,...
        'FaceColor','flat');
    set(tmph,'FaceColor',cmap(condID,:));
    hold on;
    tmpH(ee)=tmph;
end
H(condID)={tmpH};
end

end %function

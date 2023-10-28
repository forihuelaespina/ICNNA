function obj=cut(obj,winInit,winEnd)
%STRUCTUREDDATA/CUT Cut a temporal window
%
% obj=cut(obj,winInit,winEnd) Cut a temporal window from a
%   structuredData. winInit and winEnd determines the starting
%   and ending sample indexes location of the window to be
%   eliminated. Samples at both, winInit and winEnd, are part
%   of the eliminated temporal segment.
%
%% Remarks
%
% winInit must be larger or equal than 1 and smaller or equal than winEnd.
%
% winEnd must be larger or equal than winInit and smaller or equal to
%the number of samples in the structuredData.
%
%Timeline will be shifted/corrected accordingly for ALL existing
%conditions and events. At the end of the window selection
%the timeline will still contains all the conditions but
%the events definition may have changed with some events
%being removed or even disappearing.
%
%
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also structuredData, crop, windowSelection, getBlock,
% experimentSpace, analysis, blockResample, blocksTemporalAverage
%




%% Log
%
% File created: 16-Aug-2008
% File last modified (before creation of this log): 3-Jan-2013
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%




if (winInit<1)
    error('ICNA:structuredData:cut:InvalidParameter',...
        'Wrong parameter value winInit.');
end
if (winInit>winEnd)
    error('ICNA:structuredData:cut:InvalidParameter',...
        ['Wrong parameter value; ' ...
        'winInit should be minor or equal than winEnd.']);
end
if (winEnd>obj.nSamples)
    error('ICNA:structuredData:cut:InvalidParameter',...
        ['Wrong parameter value; ' ...
        'winEnd should be minor or equal than data length.']);
end

t = obj.timeline;
data= obj.data;

s = warning('off', 'ICNA:timeline:set:Length:EventsCropped');

%Crop the temporal window between winInit and winEnd samples
data(winInit:winEnd,:,:)=[];
nCutSamples=(winEnd-winInit)+1;
                
%Adjust the timeline appropiately accordingly
nCond= t.nConditions;
for cc=1:nCond
    tmpCondTag=getConditionTag(t,cc);
    [events,eventsInfo]=getConditionEvents(t,tmpCondTag);
    %And correct or remove episodes if necessary
    nEvents=size(events,1);
    for ee=nEvents:-1:1
        
        if (events(ee,1)<winInit)
            %Events starting before the window
            if ((events(ee,1)+events(ee,2)>=winInit) ...
                && (events(ee,1)+events(ee,2)<=winEnd))
                %The event finishes "during" the window, so
                %shorten its duration. It should now finished
                %right where the window start (one sample earlier)
                events(ee,2)=winInit-1;
            elseif (events(ee,1)+events(ee,2)>winEnd)
                %The event lasts beyond the window. New duration
                %needs to be decrease by the length of the window
                events(ee,2)=events(ee,2)-nCutSamples;
            end
            
        elseif ((events(ee,1)>=winInit) && (events(ee,1)<=winEnd))
            %Events starting during the window
            if ((events(ee,1)+events(ee,2)>=winInit) ...
                && (events(ee,1)+events(ee,2)<=winEnd))
                %The event finishes before the end of the
                %window, so remove the event
                events(ee,:)=[];
                eventsInfo(ee)=[];
            elseif (events(ee,1)+events(ee,2)>winEnd)
                %The event lasts beyond the window. The
                %onset must be shifted to the first sample
                %after the window and the duration must be
                %shortened so that the event still finishes
                %at the "same time"
                tmpnCutSamples=winEnd-events(ee,1);
                events(ee,1)=winEnd+1;
                events(ee,2)=events(ee,2)-tmpnCutSamples;
            end
            
        else
            %Events starting after the window
            %Duration does not need to be modified at all
            %but onsets needs to be shifted by a number
            %of samples equal to the removed window
            events(ee,1)=events(ee,1)-nCutSamples;
                
        end
        
    end
    
    t=setConditionEvents(t,tmpCondTag,events,eventsInfo);
end
%...and reduce the length appropriately
t.length = obj.nSamples-nCutSamples;

%%Finally update the object
obj.data = data;
obj.timeline = t;
warning(s);

end


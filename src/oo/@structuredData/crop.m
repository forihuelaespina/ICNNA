function obj=crop(obj,winInit,winEnd)
%STRUCTUREDDATA/CROP Crop a temporal window
%
% obj=crop(obj,winInit,winEnd) Crop a temporal window from a
%   structuredData. winInit and winEnd determines the starting
%   and ending sample indexes location of the cropped window.
%   Samples at both, winInit and winEnd, will still be part
%   of the cropped window. The rest will be discarded.
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
%being cropped or even disappearing.
%
%
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also structuredData, cut, windowSelection, getBlock,
% experimentSpace, analysis, blockResample, blocksTemporalAverage
%




%% Log
%
% File created: 16-Jul-2008
% File last modified (before creation of this log): 3-Jan-2013
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%




if (winInit<1)
    error('ICNNA:structuredData:crop:InvalidParameter',...
        'Wrong parameter value winInit.');
end
if (winInit>winEnd)
    error('ICNNA:structuredData:crop:InvalidParameter',...
        ['Wrong parameter value; ' ...
        'winInit should be minor or equal than winEnd.']);
end
if (winEnd>obj.nSamples)
    error('ICNNA:structuredData:crop:InvalidParameter',...
        ['Wrong parameter value; ' ...
        'winEnd should be minor or equal than data length.']);
end

t=obj.timeline;
data=obj.data;

s = warning('off', 'ICNNA:timeline:set:Length:EventsCropped');

%Crop the first winInit-1 samples
data(1:winInit-1,:,:)=[];
%Shift the onsets accordingly
nCond=t.nConditions;
newt=timeline(t.length);
for cc=1:nCond
    tmpCondTag=getConditionTag(t,cc);
    [events,eventsInfo]=getConditionEvents(t,tmpCondTag);
    %And correct or remove episodes if necessary
    nEvents=size(events,1);
    for ee=nEvents:-1:1
        if ((events(ee,1)+events(ee,2)-1) < winInit)
            %remove event
            events(ee,:)=[];
            eventsInfo(ee)=[];
        elseif (events(ee,1)< winInit)
            %correct event
            events(ee,2)=events(ee,2)-(winInit-events(ee,1));
            events(ee,1)=winInit;
        end
    end
    %Shift the onsets
    events(:,1)=events(:,1)-(winInit-1);
%    t=setConditionEvents(t,tmpCondTag,events,eventsInfo);
    newt=addCondition(newt,tmpCondTag,events,eventsInfo,0); %temporally add non-overlapping
end

%Replicate the overlapping behaviour
for cc1=1:nCond
    tagA=getConditionTag(newt,cc1);
for cc2=cc1:nCond
    tagB=getConditionTag(newt,cc2);
    newt=setExclusory(newt,tagA,tagB,getExclusory(t,tagA,tagB));
end    
end
t=newt;

%...and reduce the length appropriately
t.length = obj.nSamples-(winInit-1);

winEnd=(winEnd+1)-winInit;
%Deal with the window end
%Note that now it is simply a matter of cropping
%and the set function takes care of
%cropping the timeline appropriately
data=data(1:winEnd,:,:);
obj.data = data;
t.length = winEnd;
obj.timeline = t;
warning(s);



end

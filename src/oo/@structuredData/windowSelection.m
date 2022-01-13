function obj=windowSelection(obj,condTag,eventNum,...
                                   windowOnset,windowDuration)
%STRUCTUREDDATA/WINDOWSELECTION Crop a temporal window
%
% obj=windowSelection(obj,condTag,eventNum,windowOnset,windowDuration)
%       Crop a temporal window from a structuredData,
%       starting windowOnset samples before the task
%       onset, and lasting for the indicated windowDuration.
%
%A negative windowOnset indicates that the window starts
%before the task onset. A windowOnset equals to 0 means that
%the window starta exactly at the task onset.
%Duration must always be positive
%integer or 0 (but in this last case, an empty matrix is returned).
%
%% Remarks
%
%If the condition or experimental stimulus indicated by
%the condition tag has not been defined, then a warning
%('ICNA:structuredData:windowSelection:UndefinedCondition')
%is issued and an empty value is returned.
%
%If the condition or experimental stimulus indicated by
%the condition tag has been defined, but not the event,
%then a warning
%('ICNA:structuredData:windowSelection:UndefinedEvent')
%is issued and an empty value is returned.
%
%
%If windowDuration equals 0, then an structuredData
%with empty Data is returned.
%
%If the object is not long enough to accomodate the window
%requirements, then the window will be padded with 0s accordingly.
%   - If the windowOnset is negative (i.e. the window selection
%   starts earlier than the task onset), but there is not enough
%   samples in the object, then the window will be padded with
%   zeros at the beggining.
%   - If the windowOnset is beyond the length of the block,
%   then the window will be full of zeros.
%   - If the windowDuration makes the window to last beyond the
%   length of the block, then the window will be padded with
%   zeros at the end.
%
%Timeline will be shifted/corrected accordingly for ALL existing
%conditions and events. At the end of the window selection
%the timeline will still contains all the conditions but
%the events definition may have changed with some events
%being cropped or even disappearing (this may include the event
%being used as alignment).
%
%
%
% Copyright 2008-13
% @date: 4-Jul-2008
% @author Felipe Orihuela-Espina
% @modified: 3-Jan-2013
%
% See also structuredData, crop, getBlock, experimentSpace, analysis,
%   blockResample, blocksTemporalAverage
%

if (windowDuration<0)
    error('Wrong parameter value; negative window duration')
end
if (floor(windowDuration)~=windowDuration)
    error('Wrong parameter value; duration must be positive integer or 0.')
end
if (floor(windowOnset)~=windowOnset)
    error('Wrong parameter value; windowOnset must be integer.')
end
if (floor(eventNum)~=eventNum)
    error(['Wrong parameter value; ' ...
            'event number must be a positive integer.']);
end

%Get some initial values
t=get(obj,'Timeline');
events = getConditionEvents(t,condTag);
if ((eventNum<=0) || (getNEvents(t,condTag)<eventNum))
    warning('ICNA:structuredData:windowSelection:UndefinedEvent',...
            'Undefined event for the seleted condition.');
    obj=[];
    return
end
onset = events(eventNum,1);
duration = events(eventNum,2);
data=get(obj,'Data');
[nSamples,nChannels,nSignals]=size(data);


winStart=onset+windowOnset;
s = warning('off', 'ICNA:timeline:set:Length:EventsCropped');

if (winStart > nSamples)
    %The window is beyond the current data limits
    winStart=1;
    winEnd=windowDuration;
    data(winStart:winEnd,:,:)=0;
    tmpT=timeline(windowDuration);
    %...and replicate the conditions...
    nCond=get(t,'NConditions');
    for cc=1:nCond
        tmpCondTag=getConditionTag(t,cc);
        tmpT=addCondition(tmpT,tmpCondTag);
    end
    t=tmpT;
else

    %Deal with the window start
    if (winStart==0)
        %No crop nor pad at the beginning
        %Everything remains the same
        %Do nothing
    elseif (winStart<0)
        %Pad some zeros at the beginning
        data=[zeros(1:-winStart,nChannels,nSignals); ...
            data];
        t=set(t,'Length',nSamples-winStart);
        %And shift the onsets accordingly
        %...no need to remove or correct any event.
        nCond=get(t,'NConditions');
        for cc=1:nCond
            tmpCondTag=getConditionTag(t,cc);
            [events,eventsInfo]=getConditionEvents(t,tmpCondTag);
            events(:,1)=events(:,1)-winStart;
            t=setConditionEvents(t,tmpCondTag,events,eventsInfo);
        end
    elseif (winStart>0)
        %Crop the first winStart-1 samples
        data(1:winStart-1,:,:)=[];
        t=set(t,'Length',nSamples-(winStart-1));
        %Shift the onsets accordingly
        nCond=get(t,'NConditions');
        for cc=1:nCond
            tmpCondTag=getConditionTag(t,cc);
            [events,eventsInfo]=getConditionEvents(t,tmpCondTag);
            events(:,1)=events(:,1)-(winStart-1);
            %And correct or remove episodes if necessary
            nEvents=size(events,1);
            for ee=nEvents:-1:1
                if ((events(ee,1)+events(ee,2)-1) < winStart)
                    %remove event
                    events(ee,:)=[];
                    eventsInfo(ee)=[];
                elseif (events(ee,1)< winStart)
                    %correct event
                    events(ee,2)=events(ee,2)-(winStart-events(ee,1));
                    events(ee,1)=1;
                end
            end
            t=setConditionEvents(t,tmpCondTag,events,eventsInfo);
        end
    end
    
    %Deal with the window end
    [nSamples,nChannels,nSignals]=size(data);
    assert(nSamples==get(t,'Length'),...
            'Problem found while arrangeing window start.');
    if (nSamples < windowDuration)
        %Pad some zeros at the end
        data=[data; ...
              zeros(windowDuration-nSamples,nChannels,nSignals)];
    elseif (nSamples > windowDuration)
        %Note that now it is simply a matter of cropping
        %and the set function takes care of
        %cropping the timeline appropriately
        data=data(1:windowDuration,:,:);
    end
    t=set(t,'Length',windowDuration);
        
end

obj=set(obj,'Data',data);
obj=set(obj,'Timeline',t);
warning(s);


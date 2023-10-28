function obj=decimate(obj,r)
%NIRS_NEUROIMAGE/DECIMATE Decrease sampling rate
%
%   obj2 = decimate(obj,r) reduces the sampling rate of the
%image by a factor r. The decimated image obj2 is r times shorter
%in length than the input image obj. By default r=10.
%
%It uses an order 30 samples long FIR filter.
%
%
%% Remarks
%
%This method is basically a wrap for decimate applied to all
%channels and signals.
%
%The image timeline is updated accordingly.
%Some events may collapse to length 0 but this is
%theoretically ok. Initial and final rest may dissapear.
%
%Ideally, 'round' is used to calculate
%the new onsets and durations, but then two events
%which are very close could then merge, which obviously
%is wrong. In those situations, the methods attempt to force
%an in-between rest of at least 1 sample.
%Note however, that the merging maybe unavoidable since the final
%timeline may be shorter than the number of events!
%Having said that, at least this method will try to make a best
%guess.
%
%
% Copyright 2007-23
% @author Felipe Orihuela-Espina
%
% See also detrend, rawData.convert, decimate
%
%



%% Log
%
%
% File created: 29-May-2008
% File last modified (before creation of this log): 31-Dec-2012
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%




if (~exist('r','var'))
    r=10;
end

%First decimate the image data
data=obj.data;
[nSamples,nChannels,nSignals]=size(data);
%wwait=waitbar(0,'Decimating nirs\_neuroimage... 0%');
for ss=1:nSignals
    for pe=1:nChannels
        %waitbar((pe+nChannels*ss-nChannels)/(nSignals*nChannels), ...
            %wwait,['Decimating nirs\_neuroimage...',...
            %sprintf('%2.0f',(pe+nChannels*ss-nChannels)/(nSignals*nChannels)*100),'%']);
        tempData(:,pe,ss)=decimate(data(:,pe,ss)',r)';
    end
end
tline=obj.timeline;
warning('off','ICNNA:timeline:set:EventsCropped');
obj.data = tempData;
warning('on','ICNNA:timeline:set:EventsCropped');
data=obj.data;

%Now readjust the timeline

newLength=size(data,1);
%Note that for the timeline is not as simple as directly
%calling the decimate function since events marks positions do not
%need to be considered as a signal to be smoothed. Event marks just
%need to be rearranged to the correct position.

%To avoid overlapping of events "temporally" during the loop,
%work on a fresh timeline. I can either:
%
%   a) start completely from afresh (e.g.
%dest_tline=timeline(newLength);), adding one condition
%at a time during the loop below and reconstruct the
%exclusory behaviour after the loop
%
%or
%
% b) use the current timeline as master with all conditions
%and exclusory behaviour already declared, but "temporally"
%pre-empty their events, to prevent the overlapping of events
%
%I'll go with this second option...
dest_tline=timeline(tline); %Use the current timeline as template
nConds=dest_tline.nConditions;
for con=1:nConds, %Pre-empty events
    tag=getConditionTag(dest_tline,con);
    dest_tline=setConditionEvents(dest_tline,tag,[]);
end
dest_tline.length = newLength;


nConds=tline.nConditions;
% Re-arrange the events onsets and durations
for con=1:nConds,
    tag=getConditionTag(tline,con);
    events=getConditionEvents(tline,tag);
    if (~isempty(events))
        %First simply try a general case relocation of events
        newOnsets=round(events(:,1)/r);
        newDurations=round(events(:,2)/r);
        %Some events may collapse to length 0 but this is
        %theoretically ok.

        %Now address possible problems
        %A) Crop the last event if it has go beyond the new length
        lastEventOnset = newOnsets(end);
        if (lastEventOnset>newLength)
            newOnsets(end)=newLength;
            newDurations(end)=0;
        end
        lastEventEnd = newOnsets(end)+newDurations(end);
        if (lastEventEnd>newLength)
            newDurations(end)=0;
        end

        %B) Check whether merging has occur
        nEvents=size(events,1);
        if (nEvents>1)
            for ii=nEvents-1:-1:1
                thisEventInit=events(ii,1);
                thisEventEnd=events(ii,1)+events(ii,2);
                nextEventInit=events(ii+1,1);
                nextEventEnd=events(ii+1,1)+events(ii+1,2);

                if (thisEventEnd >= nextEventInit)
                    %Attemp to eliminate merging if possible

                    %First, try to reduce the length of this event
                    %if still larger than 0
                    if (newDurations(ii,2)>0)
                        newDurations(ii,2)=newDurations(ii,2)-1;
                    else
                        %If that doesn't work, try to shift the onset
                        %of the second event by 1 sample...
                        if (newDurations(ii+1,2)>0)
                            newOnsets(ii+1,2)=newOnsets(ii+1,2)+1;
                            newDurations(ii+1,2)=newDurations(ii+1,2)-1;
                        else
                            %If that neither work, then we have a problem!
                            %We MUST merge the two events involved
                            warning('ICNNA:nirs_neuroimage:decimate',...
                                'Merging of events has ocurred.');
                            %Remove the old two events and insert the new one
                            newOnsets(ii+1,:)=[]; %This actually remove the "second" event
                            newDurations(ii+1,:)=[]; %This actually remove the "second" event
                            newOnsets(ii,:)=thisEventInit; %This overwrite the "first" event
                            newDurations(ii,:)=max(thisEventEnd,...
                                nextEventEnd); %This overwrite the "first" event

                        end
                    end
                end
            end %for
        end %if

        %Finally update the events for this condition
        events=[newOnsets newDurations];
        dest_tline=setConditionEvents(dest_tline,tag,events);
    end %if
end %for

%Generate the new (decimated) timestamps
%The new timestamps depend on the new length and the previously available
%timestamps
tmpTimestamps = tline.timestamps;
if newLength == 0
    %Do nothing
elseif newLength == 1
    if isempty(tmpTimestamps)
        %Do nothing (the new timestamp will have been automatically
        %generated)
    else
        tmpTimestamps = tmpTimestamps(end);
        %dest_tline = set(dest_tline,'Timestamps',tmpTimestamps);
        dest_tline.timestamps = tmpTimestamps;
    end
else %newLength > 1
    if isempty(tmpTimestamps)
        %Do nothing (the new timestamps will have been automatically
        %generated)
    else
        tmpTimestamps = linspace(tmpTimestamps(1),tmpTimestamps(end),newLength);
        %dest_tline = set(dest_tline,'Timestamps',tmpTimestamps);
        dest_tline.timestamps = tmpTimestamps;
    end
end

%Finally, update the timeline
obj.timeline = dest_tline;

assertInvariants(obj);
%close(wwait);


end
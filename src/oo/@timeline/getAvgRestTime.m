function [tSamples,tSeconds]=getAvgRestTime(obj,flag)
%TIMELINE/GETAVGRESTTIME Gets the average rest time in the timeline
%
% [tSamples,tSeconds]=getAvgRestTime(obj) Gets the average rest time
%   for the indicated condition.
%
% [tSamples,tSeconds]=getAvgRestTime(...,flag) Controls whether initial
%   rest is accouted for.
%   By default (flag==1) any initial rest prior to the first
%   stimulus onset is accounted. Set flag to 0 to ignore the initial
%   rest. Final rest if present is ALWAYS accounted for.
%
%
% Differently to getAvgTaskTime, the rest time is not calculated
%on a single condition basis. The rest time during the timeline
%is that which is not affected by any event of any condition!.
%
%Consider the following example:
%
%    Start ---+-----------
%	      |
%     Initial |
%	Rest  |
%	      |
%	   ---+-----------
%	      |//////////
%     Event of|//////////
%      Cond A |//////////
%	      |//////////
%	   ---+-----------
%	      |
%             |
%	Rest  |
%	      |
%	   ---+-----------
%	      |//////////
%     Event of|//////////
%      Cond A |//////////
%	      |//////////
%	   ---+-----------
%	      |
%             |
%	Rest  |
%	      |
%	   ---+-----------
%	      |//////////
%     Event of|//////////
%      Cond B |//////////
%	      |//////////
%	   ---+-----------
%	      |
%       Final |
%	Rest  |
%	      |
%      End ---+-----------
%
% Only those periods marked as Rest can be considered to compute the
%average rest time.
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getAvgTaskTime
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 30-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


if (~exist('flag','var'))
    flag=1;
end

%First collect all the existing events across all different
%conditions.
events=zeros(0,2);
for cc=1:getNConditions(obj)
    events=[events; obj.conditions{cc}.events];
end
events=sortrows(events);
%Merge events if overlap
%
%   Overlap occur if A.end >= B.init where A.end=A.onset+A.duration
%   and B.init = B.onset.
%   There are 5 type of possible overlaps (note that events are
%   sorted by their onsets, i.e. A.init <= B.init)
%
%   Event A   |///////////|				  New Merged Event
%       ------+-------+---+-------+     A.end > B.init => [A.init max(A.end,B.end)]
%   Event B           |///////////|
%
%   Event A   |///////////|				  
%       ------+---+---+---+--------     A.end > B.init => [A.init max(A.end,B.end)]
%   Event B       |///|
%
%   Event A   |///////////|				  
%       ------+-----------+--------     A.end = B.init => [A.init max(A.end,B.end)]
%   Event B   |///////////|
%
%   Event A   |///////////|				  
%       ------+-----+-----+--------     A.end = B.init => [A.init max(A.end,B.end)]
%   Event B   |/////|
%
%   Event A   |/////|				  
%       ------+-----+-----+--------     A.end = B.init => [A.init max(A.end,B.end)]
%   Event B   |///////////|
%
%
%

nEvents=size(events,1);
if (nEvents>1)
    for ee=nEvents:-1:2
	Ainit = events(nEvents-1,1);
	Aend = events(nEvents-1,1)+events(nEvents-1,2);
	Binit = events(nEvents,1);
	Bend = events(nEvents,1)+events(nEvents,2);
	if (Aend >= Binit)
		%Remove the old two events and insert the new one
		events(end,:)=[]; %This actually remove the "last" event
			%and reduce the size of events by one line
		events(end,:)=[Ainit max(Aend,Bend)]; %This overwrite the
			%"A" event
	end
    end
end

%Finally compute the average rest time
onsets=events(:,1);
durations=events(:,2);
endings=onsets+durations;
temp=[onsets; obj.length];
restDurations=temp(2:end)-endings;
if flag
    %Add initial rest
    restDurations=[onsets(1); restDurations];
end
tSamples=round(mean(restDurations));
tSeconds = tSamples * obj.samplingRate;

end
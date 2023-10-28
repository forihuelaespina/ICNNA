function [tSamples,tSeconds]=getAvgTaskTime(obj,tag)
%TIMELINE/GETAVGTASKTIME Gets the average task time for the indicated
%condition
%
% [tSamples,tSeconds]=getAvgTaskTime(obj,tag) Gets the average task time
%   for the indicated condition. If the condition has not been
%   defined, a warning is issued and t=0 is returned.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getAvgRestTime
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 29-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



idx=findCondition(obj,tag);
t=0;
if (isempty(idx))
    warning('ICNA:timeline:getAvgTaskTime',...
        ['Condition ' tag ' not defined. Returning t=0.'])
else
    events=obj.conditions{idx}.events;
    durations=events(:,2);
    tSamples=round(mean(durations));
    tSeconds = tSamples * obj.samplingRate;
end
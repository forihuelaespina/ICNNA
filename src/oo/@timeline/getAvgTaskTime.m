function [tSamples,tSeconds]=getAvgTaskTime(obj,tag)
%TIMELINE/GETAVGTASKTIME Gets the average task time for the indicated
%condition
%
% [tSamples,tSeconds]=getAvgTaskTime(obj,tag) Gets the average task time
%   for the indicated condition. If the condition has not been
%   defined, a warning is issued and t=0 is returned.
%
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @date: 29-Dec-2012
%
% See also getAvgRestTime
%

idx=findCondition(obj,tag);
t=0;
if (isempty(idx))
    warning('ICNA:tmieline:getAvgTaskTime',...
        ['Condition ' tag ' not defined. Returning t=0.'])
else
    events=obj.conditions{idx}.events;
    durations=events(:,2);
    tSamples=round(mean(durations));
    tSeconds = tSamples * get(obj,'SamplingRate');
end
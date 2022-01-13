function [max,tags,idxs]=getMaxEvents(obj)
%TIMELINE/GETMAXEVENTS Get the maximum number of events for a sigle condition
%
% max = getMaxEvents(obj) Get the maximum number of events defined
%   for a single condition. If no conditions have been defined
%   then this function returns an empty matrix. Note that
%   although conditions may exist there is still the
%   possibility that no events have been declared for any conditions
%   and hence a value 0 will be returned.
%
% [max,tags, idxs] = getMaxEvents(...) Also return the tags
%   and indexes of those conditions holding the maximum number
%   of events. Tags are returned in a cell array.
%   
%
%
% Copyright 2008
% @date: 18-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also setConditionEvents, addConditionEvents, removeConditionEvents,
%   getNEvents, getTotalEvents
%
max=[];
tags=cell(1,0);
idxs=zeros(1,0);

if ~isempty(obj.conditions)
    max=0;
    for ii=1:length(obj.conditions)
        n=size(obj.conditions{ii}.events,1);
        if (n<max)
            %Ignore this condition
        elseif (n==max)
            %Add the tag and idx
            tags(end+1)={obj.conditions{ii}.tag};
            idxs=[idxs ii];
        elseif (n>max)
            %Update max and reset the tags and idxs.
            max=n;
            tags=cell(1,0);
            idxs=zeros(1,0);
            tags(end+1)={obj.conditions{ii}.tag};
            idxs=[idxs ii];
        end
    end
end
function n=getNEvents(obj, tag)
%TIMELINE/GETNEVENTS Get the number of events defined for a condition or across all conditions
%
% n = getNEvents(obj) Get the number of events defined across all
%   defined conditions. If no conditions have been defined
%   then this function returns an empty matrix. Note that
%   although conditions may exist, there is still the
%   possibility that no events have been declared for any conditions
%   and hence a value 0 will be returned.
%
% n = getNEvents(obj,tag) Get the number of events defined for the
%   selected condition. If the condition has not been defined
%   then this function returns an empty matrix. Note that
%   although the condition may exist, there is still the
%   possibility that no events have been defined for this conditions
%   and hence a value 0 will be returned.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also setConditionEvents, addConditionEvents, removeConditionEvents,
%   getMaxEvents, getTotalEvents
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 28-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%


n=[];
if exist('tag','var')
    idx=findCondition(obj,tag);
    if (~isempty(idx))
        n=size(obj.conditions{idx}.events,1);
    end
    
else %Total number of events across all conditions
    if ~isempty(obj.conditions)
        n=0;
        for ii=1:length(obj.conditions)
            n=n+size(obj.conditions{ii}.events,1);
        end
    end
end
    
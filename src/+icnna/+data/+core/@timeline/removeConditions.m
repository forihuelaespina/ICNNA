function removeConditions(obj,tags)
%Removes the selected @icnna.data.core.conditions from the @icnna.data.core.timeline
%
% addConditions(obj,id) - Remove the conditions identified by |id|
% addConditions(obj,name) - Remove the conditions identified by |name|
% obj.addConditions(...)
%
%
%
%% Parameters
%
% id  - Int or Int[]. The |id| of the conditions being removed.
% name - String or String{}. The |name| of the conditions being removed.
%   The search for the name is case sensitive.
%
%% Output
%
% obj - @icnna.data.core.timeline
%   The updated timeline
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%


%% Log
%
% File created: 26-Jun-2025
%
% -- ICNNA v1.3.1
%
% 25-Jun-2025: FOE 
%   + File created. Reused some comments from previous code on
%       timeline.addCondition
%
% 28-Jun-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions (from array of objects to 1 dictionary and 1 table).
%
%
% 9-Jul-2025: FOE. 
%   + Adapted to reflect the new handle status e.g. no object return.
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%


idx = obj.findConditions(tags);
    %Note that this takes care of whether is is truly and |id| or a |name|
    %as well as whether there is more than 1 condition.
ids = obj.conds.id(idx);


if ~isempty(idx)
    tmp = obj.exclusory;
    
    obj.conds(idx,:) = [];
    obj.cevents(ismember(obj.cevents.id,ids),:) = [];
    
    tmp(idx,:) = [];
    tmp(:,idx) = [];
    obj.exclusory = tmp;
end

end

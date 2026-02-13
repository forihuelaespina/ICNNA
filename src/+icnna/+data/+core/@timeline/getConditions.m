function [conds] = getConditions(obj,id)
%Gets the selected @icnna.data.core.condition(s) from the @icnna.data.core.timeline
%
% [conds] = obj.getConditions() - Gets ALL conditions.
% [conds] = obj.getConditions(id) - Gets the conditions identified by |id|
% [conds] = obj.getConditions(name) - Gets the conditions identified by |name|
% [conds] = getConditions(obj,...)
%
%
%% Remarks
%
% Note that 
%
%   [conds] = obj.conditions(idx)
% 
% ...is different from:
%
%   [conds] = getConditions(obj,id)
%
% The first retrieves the conditions by their positions in the array
%of conditions (regardless of their |id|) and further, cannot be used
%to retrieve a condition by its |name|.
%
% The second retrieves the conditions by their |id| or |name| (if they
% exist), regardles of their positions in the array of conditions.
%
% However, these two calls shpuld be the same;
%
% [conds] = obj.conditions
% [conds] = getConditions(obj)
%
%
%% Parameters
%
% id  - Int or Int[].
%   The |id| of the conditions being searched.
% name - String or String{}.
%   The |name| of the conditions being searched.
%   The search for the name is case sensitive.
%
%% Output
%
% [conds] - icnna.data.core.conditions[]
%   The array of found conditions. Empty if no conditions are found.
%   The conditions are sorted by |id|. Note that the length
%   of the output may not match the lengths of the input even
%   if conditions are found, e.g. repeated id/names.
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
% 7-Jul-2025: FOE
%   + Added option to retrieve ALL conditions.
%
% 9-Jul-2025: FOE
%   + Added support for new property |nominalSamplingRate| for
%   the @icnna.data.core.condition objects.
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%
% 20-Jul-2025: FOE
%   + Bug fixed: when the conditions output is empty, it now correctly
%   return an empty array of objects.
%
%
% -- ICNNA v1.4.0
%
% 10-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Change .conds to .conditions, and updated from a table to a
%   struct array of conditions.
%	+ Revert .cevents to a derived property (extracted on the fly from
%       .conditions) |condEvents|.
%   + Improved some comments.
%


if ~exist('id','var')
    [id,~] = obj.getConditionsList();
end

idx = obj.findConditions(id);
    %Note that this takes care of whether id is truly an |id| or a |name|
    %as well as whether the search is for one or multiple.
%Ignore repeated ids and NaNs
idx = unique(idx);
idx(isnan(idx)) = [];

if isempty(idx)
    conds = icnna.data.core.condition.empty;
else
    conds = obj.conditions(idx);
end

end

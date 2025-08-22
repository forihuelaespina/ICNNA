function [idx] = findConditions(obj,tags)
%Retrieves the indexes of the conditions with the given |id|(s) or |name|(s)
%
% [idx] = obj.findConditions(ids)   - Search for conditions by |id|
% [idx] = obj.findConditions(names) - Search for conditions by |name|
%
%
%% Remarks
%
% Note that the length of output idx may be different from the length of
%the input id or name as not all conditions may be found.
%
%% Parameters
%
% ids  - Int or Int[].
%   The |id|(s) of the conditions being searched.
% names - String OR String{}.
%   The |name|(s) of the conditions being searched.
%   The search for the name is case sensitive.
%
%% Outputs
%
% idx - Returns the indexes to the conditions with the given |id| or 
%   |name| or empty if there are no matching conditions.
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%



%% Log
%
% 12-Apr-2025: FOE
%   + File created.
%
% 25-Apr-2025: FOE
%   + Update use of |name| instead of deprecated |tag|.
%
% 26-Apr-2025: FOE
%   + Added support to retrieve several conditions at once.
%
% 28-Jun-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions (from array of objects to 1 dictionary and 1 table).
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%



idx = [];
if iscell(tags) %List of names

    idx = find(ismember(obj.conds.name,tags));

elseif ischar(tags) %single name provided

    idx = find(tags == obj.conds.name);

else %List of IDs

    idx = find(ismember(obj.conds.id,uint32(tags)));

end


end


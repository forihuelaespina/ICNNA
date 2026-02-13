function [idList,namesList] = getConditionsList(obj)
%Get a list of IDs of defined conditions
%
% [condList] = obj.getConditionsList() - Only 1 output oargument
% [condList] = getConditionsList(obj)
%
% [idList,namesList] = obj.getConditionsList()
% [idList,namesList] = getConditionsList(obj)
%
% It is possible to iterate through the conditions using the idList
%
%
%% Output parameters
%
% condList - Table
%   A table of 2 columns, id and name.
%
% idList - Int[]
%   List of |id| of defined conditions.
% namesList - cell array of char[]
%   List of |name| of defined conditions.
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
% 
% See also icnna.data.core.timeline, icnna.data.core.condition
%

%% Log
%
%
% File created: 30-Jun-2025
%
% -- ICNNA v1.3.1
%
% 30-Jun-2025: FOE. 
%   + File created
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%
%
% 18-Jul-2025: FOE. 
%   + Depending on the number of output arguments it can return a table
%   or 2 lists.
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

idList = [obj.conditions.id]';
if nargout > 1
    namesList = {obj.conditions.name}';
end

end
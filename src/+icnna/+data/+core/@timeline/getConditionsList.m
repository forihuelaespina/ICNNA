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
% namesList - String{}
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


if nargout < 1
    idList = obj.conds;
else
    idList    = obj.conds.id;
    namesList = obj.conds.name;
end

end
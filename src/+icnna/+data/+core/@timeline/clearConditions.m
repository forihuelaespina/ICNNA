function obj = clearConditions(obj)
%Delete all @icnna.data.core.conditions from the @icnna.data.core.timeline
%
% obj.clearConditions()
% clearConditions(obj)
%
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
% File created: 26-Jun-2025
%
% -- ICNNA v1.3.1
%
% 26-Apr-2025: FOE. 
%   + File created
%
% 28-Jun-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions (from array of objects to 1 dictionary and 1 table).
%
% 9-Jul-2025: FOE. 
%   + Adapted to reflect the new handle status e.g. no object return.
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%
% -- ICNNA v1.4.0
%
% 10-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Change .conds to .conditions, and updated from a table to a
%   struct array of conditions.
%	+ Revert .cevents to a derived property (extracted on the fly from
%       .conditions) |condEvents|.
%
 
obj.conditions = icnna.data.core.condition.empty;
obj.exclusory  = false(0,0);


end
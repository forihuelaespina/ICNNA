function obj = clearEvents(obj)
%Delete all events from the condition.
%
% obj = clearEvents(obj)
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
% 
% See also icnna.data.core.condition, addEvents
%

%% Log
%
%
% File created: 25-Jun-2025
%
% -- ICNNA v1.3.1
%
% 25-Apr-2025: FOE. 
%   + File created
%
% 9-Jul-2025: FOE. 
%   + Adapted to reflect the new handle status e.g. no object return.
%
% 5-Dec-2025: FOE. 
%   + Revert back to value class status, i.e. object return
%

obj.cevents = struct( ...
            'onsets', [], ...
            'durations', [], ...
            'amplitudes', [], ...
            'info', {} );

end
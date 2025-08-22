function clearEvents(obj)
%Delete all events from the condition
%
% obj.clearEvents()
% clearEvents(obj)
%
%% Remarks
%
% icnna.data.core.condition is a handle object. Therefore,
% calling this method does modify this object.
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

obj.cevents = table('Size',[0 4],...
                    'VariableTypes',{'double','double','double','cell'},...
                    'VariableNames',{'onsets','durations','amplitudes','info'});

end
function [flag] = assertExclusory(obj)
%Asserts whether the exclusory behaviour is respected
%
% [flag] = obj.assertExclusory()
% [flag] = assertExclusory(obj)
%
% Under exclusory behaviour two conditions cannot have overlapping events.
%
% This is also valid "within" a condition. If a condition is exclusory
%with itself, then it cannot have overlapping events.
%
%% Output
%
% flag - Logical
%   true (i.e. it will pass an assert statement) if the exclusory behaviour
%       is being respected.
%   false otherwise.
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
%
% 28-Jun-2025: FOE
%   + Bug fixed: When extracting the evCond matrix, I was using the
%   index rather than the condition's id.
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%
%

ids = obj.conds.id;

flag = true;
for iCond1 = 1:obj.nConditions
    id1 = ids(iCond1);
    for iCond2 = iCond1:obj.nConditions
        id2 = ids(iCond2);
        tmpExc = obj.exclusory(iCond1,iCond2);
            %Note that the matrix is symmetric, so no need to check
            %both directions
        if tmpExc == true %Only check exclusory cases
            if iCond2 == iCond1
                evCond = [obj.cevents(obj.cevents.id == id1,{'onsets','durations'})];
            else
                evCond = [obj.cevents(obj.cevents.id == id1,{'onsets','durations'}); ...
                          obj.cevents(obj.cevents.id == id2,{'onsets','durations'})];
            end
            evCond.ends = evCond.onsets + evCond.durations;   
            evCond = sortrows(evCond);

            flag = all(evCond.ends(1:end-1) < evCond.onsets(2:end));
            if ~flag
                return
            end
            clear evCond
        end
    end
end


end
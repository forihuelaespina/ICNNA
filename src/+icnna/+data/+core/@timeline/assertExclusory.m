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
% -- ICNNA v1.4.0 (Class version 1.2)
%
% 9-Dec-2025: FOE
%   + Refactored to value (non-handle) class.
%   + Adapted to re-implementation using array of
%   @icnna.data.core.condition objects.
%

ids = [obj.conditions.id];

flag = true;
for iCond1 = 1:obj.nConditions
    for iCond2 = iCond1:obj.nConditions
        tmpExc = obj.exclusory(iCond1,iCond2);
            %Note that the matrix is symmetric, so no need to check
            %both directions
        if tmpExc == true %Only check exclusory cases
            if iCond2 == iCond1
                evCond = obj.conditions(iCond1).eventTimes;
                                %[onsets durations ends]
            else
                evCond = [obj.conditions(iCond1).eventTimes; ...
                          obj.conditions(iCond2).eventTimes];
                                %[onsets durations ends]
            end
            evCond = sortrows(evCond);

            nEvents = size(evCond,1); %There cannot be overlap with only
                                        %one event.
            if nEvents > 1
                flag = all(evCond(1:end-1,3) < evCond(2:end,1));
                if ~flag
                    return
                end
            end
            clear evCond
        end
    end
end


end
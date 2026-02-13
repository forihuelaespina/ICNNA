function obj = addConditions(obj,conds,exclusoryState)
%Add @icnna.data.core.condition(s) to the @icnna.data.core.timeline
%
% obj = obj.addConditions(conds)
% obj = addConditions(obj,conds) 
% obj = addConditions(...,exclusoryState)
%
% Add experimental conditions to the timeline. By default the
% new conditions are exclusory with every other existent condition
% including themselves.
%
% This method is an ALL or NONE; either all new conditions can
%be added or none will be added.
% 
%
%% Remarks
%
% Exclusory behaviuor can be manipulated more finely
% with the method setExclusory.
%
%
%
%% Parameters
%
% conds - icnna.data.core.condition[]
%   Array of conditions to be added. If empty, nothing is added.
% exclusoryState - Optional. Logical/Int. Default true.
%   If exclusoryState is equal to true (or 1) then the conditions
%   are exclusory with every other existent condition. If exclusoryState
%   is equal to false (or 0) then the conditions are non exclusory with
%   every other existent condition.
%  
%% Output
%
% obj - @icnna.data.core.timeline
%   The timeline with conditions updated.
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.conditions
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
% 26-Jun-2025: FOE
%   + Bug fixed. Resizing of |exclusory| was not being done.
%
% 27-Jun-2025: FOE
%   + Added control to crop events lasting beyond the timeline length.
%
% 28-Jun-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions (from array of objects to 1 dictionary and 1 table).
%
% 7-Jul-2025: FOE
%   + Bug fixed: The function can now handle when parameter conds is
%   empty.
%
% 9-Jul-2025: FOE. 
%   + Adapted to reflect the new handle status e.g. no object return.
%   + Adapted to reflect that icnna.data.core are now handles as well.
%   + Added support for new property |nominalSamplingRate| for
%   the @icnna.data.core.condition objects.
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%
% -- ICNNA v1.4.0 (Class version 1.2)
%
% 9-Dec-2025: FOE
%   + Refactored to value (non-handle) class.
%   + Adapted to re-implementation using array of
%   @icnna.data.core.condition objects.
%


if ~exist('exclusoryState','var')
    exclusoryState = true;
end


if isempty(conds)
    %Do nothing
    return
end

tmpIDs = [[obj.conditions.id]'; [conds.id]'];
assert(numel(tmpIDs) == numel(unique(tmpIDs)),...
        ['icnna:data:core:timeline:addConditions:InvalidEvent ', ...
        'Repeated condition |id|.']);

tmpNames = [{obj.conditions.name}'; {conds.name}'];
assert(numel(tmpNames) == numel(unique(tmpNames)),...
        ['icnna:data:core:timeline:addConditions:InvalidEvent ', ...
        'Repeated condition |name|.']);


nConds    = obj.nConditions;
nNewConds = numel(conds);


% Ensure all conditions are expressed in the same time units
%than the timeline.
for iCond = 1:nNewConds
    conds(iCond).unit = obj.unit;
    conds(iCond).timeUnitMultiplier  = obj.timeUnitMultiplier;
    conds(iCond).nominalSamplingRate = obj.nominalSamplingRate;
end


%Check that no new event last beyond the timeline length
if strcmpi(obj.unit,'samples')
    assert(all([conds.ends] <= obj.length),...
        ['icnna:data:core:timeline:addConditions:InvalidEvent ', ...
        'Events cannot last beyond the length of the timeline.']);
else %|unit| == 'seconds'
    assert(all([conds.ends] <= obj.timestamps(end)),...
        ['icnna:data:core:timeline:addConditions:InvalidEvent ', ...
        'Events cannot last beyond the length of the timeline.']);
end



%NOTE: In MATLAB the try catch does NOT prevent the potential sequential
% modifications before the error occurs! Specifically (Copilot):
%
%"In MATLAB, when a try-catch block is used, the code inside the try
% section is executed until an error occurs. If an error is encountered,
% the catch block is executed. However, any modifications made to
% variables or objects in the try block before the error occurs will
% persist, even if the error causes the program to jump to the catch
% block.
%
% This behavior can lead to unexpected modifications to your object
% if the error occurs after some changes have already been applied.
% Here's why this happens:
%
% * Partial Execution: The try block executes sequentially. If an error
%   occurs midway, any changes made to variables or objects up to that
%   point are not automatically reverted.
% * No Automatic Rollback: MATLAB does not have a built-in mechanism
%   to "rollback" changes made to objects or variables when an error
%   occurs. You would need to handle this explicitly.
%
% -- How to Prevent Unintended Modifications
% To avoid unintended modifications to our object, we can use one
% of the following strategies:
%
% * Backup and Restore: Create a backup of the object before making
% changes, and restore it in the catch block if an error occurs.
% * Validation Before Modification: Validate all conditions before
% making changes to the object to minimize the chance of errors.
% * Encapsulation: Use methods within a class to encapsulate changes,
% ensuring that modifications are only applied if all operations succeed.
%
% By carefully managing how and when changes are applied, you can
% mitigate the risk of unintended modifications to your object when
% using try-catch.


%NOW, in the following, if the error is in the exclusory behaviour, by
%that time, the timeline has already been changed... So I need to back up
%and restore.
tmp.conditions   = obj.conditions;
tmp.exclusory    = obj.exclusory;

try
    %Add the conditions
    [~,idx] = sort(tmpIDs);

    obj.conditions = [obj.conditions; conds];
    obj.conditions = obj.conditions(idx); %Sort by condition ID
    
    %Update the exclusory behaviuour
    tmpExclusory  = [obj.exclusory exclusoryState*true(nConds,nNewConds); ...
        exclusoryState*true(nNewConds,nConds+nNewConds)];
    %...but note that when adding the condition above, that will sort the
    % conditions, i.e. the indexing of the new conditions is NOT necessarily
    % at the end.
    obj.exclusory = tmpExclusory(idx,idx); %Sort according to conditions.id


catch ME
    %Restore
    obj.conditions = tmp.conditions;
    obj.exclusory  = tmp.exclusory;

    rethrow(ME)
end

end

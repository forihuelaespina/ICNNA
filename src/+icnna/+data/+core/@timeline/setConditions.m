function obj = setConditions(obj,conds)
% Updates the selected @icnna.data.core.conditions from the @icnna.data.core.timeline
%   
%  obj = setConditions(obj,conds)
%
%
% @li Conditions must exist. If any id correspond to a non-defined
%   condition nothing is done.
%
%
%% Remarks
%
% List are paired by |id| only, i.e. you can use this method to change the
% |name| (as well as other properties) but NOT the id. To change the
% |id| of a condition, you need to get/remove/add the condition.
%
% This function does NOT reset the complete conditions list. It only
% replaces some existing conditions (based on |id| pairing). To reset
% the complete list of conditions, you need to clear/add the conditions.
%
% This function does NOT alter the exclusory behaviour among the
% the conditions. Changes to the events still needs to be compliant 
% with the exclusory behaviour.
%
% All conditions will be "converted" to the timeline current |unit|,
% |timeUnitMultiplier| and |nominalSamplingRate| upon importing.
%
%
%% Error handling
%
% + There cannot be conditions with repeated |id| among the updating
%   conditions.
% + All of the updating conditions do match one existing conditions.
% + There cannot be conditions with repeated |name| among the updating
%   conditions, nor with existing conditions.
% + Condition |name|s cannot be empty.
% + After replacement, the exclusory behaviour must still hold.
%
%% Input parameters
%
% conds - icnna.data.core.condition[]
%   The list of @icnna.data.core.conditions to be updated.
%
%
%% Output
%
% obj - @icnna.data.core.timeline
%   The updated object
%
%




%% Log
%
% File created: 26-Jun-2025
%
% -- ICNNA v1.3.1
%
% 25-Jun-2025: FOE 
%   + Function originally created as a getter/setter method for conds.
%
%
% -- ICNNA v1.4.0
%
% 10-Dec-2025: FOE
%   + Separated method (no longer part of the getter/setter pair)
%   + Revert back to regular value (non-handle) class.
%	+ Change .conds to .conditions, and updated from a table to a
%   struct array of conditions.
%	+ Revert .cevents to a derived property (extracted on the fly from
%       .conditions) |condEvents|.
%   + Improved some comments.
%


%Assert that there aren't conditions sharing the same id
ids = uint32([conds.id]);
assert(numel(ids) == numel(unique(ids)),...
    'icnna:data:core:timeline:setConditions:RepeatedConditionIDs',...
    'Repeated conditions ids.');
%Assert that there aren't conditions sharing the same name
names = {conds.name}';
assert(numel(names) == numel(unique(names)),...
    'icnna:data:core:timeline:setConditions:RepeatedConditionNames',...
    'Repeated conditions names.');
tmp = cellfun(@(val) isempty(val), names);
assert(~any(tmp),...
    'icnna:data:core:timeline:setConditions:EmptyConditionNames',...
    'Empty condition name');

idx = obj.findConditions(ids);
assert(~any(isnan(idx)),...
    'icnna:data:core:timeline:setConditions:UnmatchedCondition',...
    'Id not found. There is at least one unmatched condition.');


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



%Finally make the replacement
obj.conditions(idx) = conds;
assert(obj.assertExclusory(), ...
    ['icnna:data:core:timeline:setConditions:ViolatedInvariant: ' ...
    'Inconsistent exclusory behaviour.']);



end
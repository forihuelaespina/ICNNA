function obj = setCriteria(obj, crit)
%Replaces an existing criterion
%
%   obj = setCriteria(obj, crit)
%
%   + Match by name is case sensitive i.e. 'john' is different
%   from 'John'
%
%
% @li The QC criteria in crit must exist. If any id correspond
%   to a non-defined criterion nothing is done.
%
%
%% Remarks
%
% List are paired by |id| only, i.e. you can use this method to change the
% |name| (as well as other properties) but NOT the id. To change the
% |id| of a QC criterion, you need to get/remove/add the QC criterion.
%
% This function does NOT reset the complete list of QC criteria. It only
% replaces some existing QC criteria (based on |id| pairing). To reset
% the complete list of QC criterion, you need to clear/add the criteria.
%
%
%% Error handling
%
% + There cannot be QC criteria with repeated |id| among the updating
%   criteria.
% + All of the updating QC criteria do match one existing criterion.
% + There cannot be criteria with repeated |name| among the updating
%   criteria, nor with existing criteria.
% + Criteria |name|s cannot be empty.
% + After replacement, class invariants must still hold.
%
%% Input parameters
%
% crit - icnna.data.core.qcCriterion[]
%   The list of @icnna.data.core.qcCriterion to be updated.
%
%% Output:
%
% obj -  @icnna.data.core.qc
%   Updated @icnna.data.core.qc object.
%
%
%
%
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.qc, icnna.data.core.qcCriterion,
%   getCriterion, setCriterion, removeCriterion, listCriteria
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 3-Mar-2026: FOE
%   + File isolated from initial code in main class icnna.data.core.qc.
%   + Method generalised to deal with any number of criteria at once.
%


%Assert that there aren't conditions sharing the same id
ids = uint32([crit.id]);
assert(numel(ids) == numel(unique(ids)),...
    'icnna:data:core:qc:setCriteria:RepeatedCriteriaIDs',...
    'Repeated criteria ids.');
%Assert that there aren't conditions sharing the same name
names = {crit.name}';
assert(numel(names) == numel(unique(names)),...
    'icnna:data:core:qc:setCriteria:RepeatedCriteriaNames',...
    'Repeated criteria names.');
tmp = cellfun(@(val) isempty(val), names);
assert(~any(tmp),...
    'icnna:data:core:qc:setCriteria:EmptyCriteriaNames',...
    'Empty criteria name');

% Validate that all IDs exist in this container
idx = obj.findConditions(ids);
assert(~any(isnan(idx)),...
    'icnna:data:core:qc:setCriteria:UnmatchedCriteria',...
    'Id not found. There is at least one unmatched criterion.');

%Finally make the replacement
obj.criteria(idx) = crit;
% Ensure invariants still hold after replacement
obj.assertExclusory();

end

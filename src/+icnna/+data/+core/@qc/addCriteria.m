function obj = addCriteria(obj, crit)
% Add a QC criterion.
%
%   obj = addCriteria(obj,crit);
%
% Adds a new @qcCriterion to this QC manager.
%
% If a criterion with the same |id| or |name| than crit
% already exists in obj, an error will be thrown and
% nothing will be added.
%
% Example:
%   obj = addCriterion(obj,qcMotion);
%
%
% Behavior:
%
%   + If this is the first criterion, its layer size defines
%     the reference size for all subsequent criteria.
%
%   + If other criteria already exist, the new criteria
%     must have identical layer size.
%
%   + The internal properties |crit.id| and |crit.name| must
%   be unique across all stored criteria.
%
%   + Match by name is case sensitive i.e. 'john' is different
%   from 'John'
%
%% Error handling:
%
%   + Error if crit has an id or name already defined.
%   + Error if crit is not a @qcCriterion object.
%   + Error if layer sizes mismatch.
%
%
%% Input parameters:
%
% crit - @icnna.data.core.qcCriterion[]
%   Array of QC criteria object to be added. If empty, nothing is added.
%
%
%% Output:
%
% obj -  @icnna.data.core.qc
%   Updated @icnna.data.core.qc object containing the newly added criteria.
%
%
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.qc, icnna.data.core.qcCriterion,
%   getCriteria, setCriteria, removeCriteria, getCriteriaList
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


% Check if crit is empty
if isempty(crit)
    % If no criteria are provided, do nothing and return
    return
end


% Enforce size consistency
% If there are existing criteria, check that the new criteria have the
% same layer size
if ~isempty(obj.criteria)
    refLayer = obj.criteria(1).layer; % If there are existing criteria,
                                      % use the first stored criteria
                                      % as reference.

else
    %Still check that all new criteria have the same size
    refLayer = crit(1).layer; % If there are no criteria,
                                      % use the first new criteria
                                      % as reference.

    
end
for newiQc = 1:numel(crit)
    if ~isequal(size(refLayer), size(crit(newiQc).layer))
        error('icnna:data:core:qc:addCriterion:SizeMismatch', ...
            'All criteria must share identical layer size.');
    end
end




% Combine existing and new criterion IDs
tmpIDs = [[obj.criteria.id]'; [crit.id]'];
% Assert that no repeated IDs exist
assert(numel(tmpIDs) == numel(unique(tmpIDs)),...
        ['icnna:data:core:qc:addCriteria:InvalidCriterion ', ...
        'Repeated criterion |id|.']);

% Combine existing and new criterion names
tmpNames = [{obj.criteria.name}'; {crit.name}'];
% Assert that no repeated names exist
assert(numel(tmpNames) == numel(unique(tmpNames)),...
        ['icnna:data:core:qc:addCriteria:InvalidCriterion ', ...
        'Repeated criterion |name|.']);


%Add the criteria
[~,idx] = sort(tmpIDs);  % Sort the combined criteria by ID

% Append the new criteria to the existing ones and re-sort them
obj.criteria = [obj.criteria; crit];
obj.criteria = obj.criteria(idx); %Sort by condition ID

% Ensure invariants of the object are maintained (e.g., consistency checks)
obj.assertInvariants();
end

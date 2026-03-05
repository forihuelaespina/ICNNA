function obj = assertInvariants(obj)
% Validate internal invariants.
%
%   obj = assertInvariants(obj)
%
% Ensures that the @icnna.data.core.qc object satisfies
% structural and semantic invariants.
%
% Enforced invariants:
%
%   Enumeration:
%       * all criteria IDs are unique
%       * all criteria names are unique
%       * all criteria layers have the same size
%
%
%% Error handling
%
%   Throws error if any invariant is not complied, i.e. object is corrupt.
%
%% Input parameters
%
% obj - icnna.data.core.qc
%   This object.
%
%% Output
% obj - icnna.data.core.qc
%   This object.
%
%
% See also:
%   icnna.data.core.qc, icnna.data.core.qcCriterion
%




%% Log
%
%
% -- ICNNA v1.4.0
%
% 3-Mar-2026: FOE
%   + Method created
%


% ------------------------------------------------------------------------
% Ensure that all criteria IDs are unique
% -------------------------------------------------------------------------
ids = [obj.criteria.id];
assert(numel(ids) == numel(unique(ids)), ...
    'icnna:data:core:qc:assertInvariants:RepeatedIDs', ...
    'Repeated criterion IDs found.');

% ------------------------------------------------------------------------
% Ensure that all criteria names are unique
% -------------------------------------------------------------------------
names = {obj.criteria.name};
assert(numel(names) == numel(unique(names)), ...
    'icnna:data:core:qc:assertInvariants:RepeatedNames', ...
    'Repeated criterion names found.');

% ------------------------------------------------------------------------
% Ensure that all criteria layers have the same size
% -------------------------------------------------------------------------
% Initialize the first layer size for comparison
firstLayerSize = size(obj.criteria(1).layer);

% Loop through each criterion and check if the layer sizes match
for iQC = 2:numel(obj.criteria)
    if ~isequal(size(obj.criteria(iQC).layer), firstLayerSize)
        error('icnna:data:core:qc:assertInvariants:LayerSizeMismatch', ...
       'Mismatch in criterion layer sizes. First size: %s, Failed size: %s.', ...
       mat2str(firstLayerSize), mat2str(size(obj.criteria(iQC).layer))); 
            % Error if sizes do not match
    end
end


end
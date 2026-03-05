function obj = assertInvariants(obj)
% Validate internal invariants.
%
%   obj = assertInvariants(obj)
%
% Ensures that the @icnna.data.core.signalSet object satisfies
% structural and semantic invariants.
%
% Enforced invariants:
%
%   Enumeration:
%       * all signal descriptor IDs are unique
%       * all signal descriptor names are unique
%       * no descriptor has an empty name
%
%
%% Error handling
%
%   Throws error if any invariant is not complied, i.e. object is corrupt.
%
%% Input parameters
%
% obj - @icnna.data.core.signalSet
%   This object.
%
%% Output
%
% obj - @icnna.data.core.signalSet
%   The same object.
%
%
% See also:
%   icnna.data.core.signalSet, icnna.data.core.signalDescriptor
%
%
%% Log
%
% -- ICNNA v1.4.0
%
% 4-Mar-2026: FOE
%   + File created.

% ------------------------------------------------------------------------
% Ensure that all descriptor IDs are unique
% ------------------------------------------------------------------------
ids = [obj.descriptors.id];
assert(numel(ids) == numel(unique(ids)), ...
    'icnna:data:core:signalSet:assertInvariants:RepeatedIDs', ...
    'Repeated signal descriptor IDs found.');

% ------------------------------------------------------------------------
% Ensure that all descriptor names are unique
% ------------------------------------------------------------------------
names = {obj.descriptors.name};
assert(numel(names) == numel(unique(names)), ...
    'icnna:data:core:signalSet:assertInvariants:RepeatedNames', ...
    'Repeated signal descriptor names found.');

% ------------------------------------------------------------------------
% Ensure that no descriptor has an empty name
% ------------------------------------------------------------------------
emptyNameMask = cellfun(@(val) isempty(val), names);
assert(~any(emptyNameMask), ...
    'icnna:data:core:signalSet:assertInvariants:EmptyNames', ...
    'At least one signal descriptor has an empty name.');

end
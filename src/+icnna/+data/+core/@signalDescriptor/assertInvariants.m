function obj = assertInvariants(obj)
% icnna.data.core.signalDescriptor:assertInvariants - Validate and fix internal metadata invariants.
%
%   sd = sd.assertInvariants()
%
% This method ensures that the @icnna.data.core.signalDescriptor
% object satisfies key structural invariants for its metadata entries.
%
% Specifically, it enforces that:
%   * All metaEntry IDs in |additional| are unique at this time.
%   * Each metaEntry.name matches the corresponding field name in |additional|.
%   * ID consistency
%   * No duplicate IDs
%   * Structural consistency
%
% This method should be called after any structural modifications
% (adding, removing, or renaming metadata fields) to maintain consistency.
%
%
% Note:
%   - This approach allows metaEntry IDs to be reused or reassigned.
%   - IDs are guaranteed to be unique at the time of this check,
%     but are not required to be sequential.
%   - This method may be slow for very large numbers of metadata fields,
%     but in practice this is negligible compared to typical signal operations.
%
%% Error handling
%
%   Throws error if any invariant is not complied, i.e. object is corrupt.
%
%% Input parameters
%
% obj - icnna.data.core.signalDescriptor
%   This object.
%
%% Output
% obj - icnna.data.core.signalDescriptor
%   This object.
%
%
% See also:
%   setField, removeField, metaEntry
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 10-Jan-2026: FOE
%   Method created
%
% 27-Feb-2026: FOE
%   + Improved comments
%


f = fieldnames(obj.additional);
ids = zeros(1, numel(f), 'uint32');

for i = 1:numel(f)
    entry = obj.additional.(f{i});

    % Ensure the metaEntry name matches the field name
    if ~isa(entry, 'icnna.data.core.metaEntry')
        error('icnna:data:core:signalDescriptor:assertInvariants:InvalidMetaEntry', ...
            'MetaEntry at field "%s" is not of type metaEntry.', f{i});
    end
    
    % Update the name if it differs from the field name
    if ~strcmp(entry.name, f{i})
        entry.name = f{i};
        obj.additional.(f{i}) = entry;
    end

    % Collect ID
    ids(i) = entry.id;
end

% Check that all IDs are unique
[uniqueIDs, ~, ic] = unique(ids);
if numel(ids) ~= numel(uniqueIDs)
    counts = accumarray(ic, 1);
    dupIDs = uniqueIDs(counts > 1);
    error('icnna:data:core:signalDescriptor:assertInvariants:DuplicateMetaEntryIds', ...
          'MetaEntry IDs must be unique within the signalDescriptor. Duplicate IDs: %s.', ...
          mat2str(dupIDs));
end


end

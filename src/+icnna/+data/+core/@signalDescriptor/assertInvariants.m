function obj = assertInvariants(obj)
% icnna.data.core.signalDescriptor:assertInvariants - Validate and fix internal metadata invariants.
%
% This method ensures that the @icnna.data.core.signalDescriptor
% object satisfies key structural invariants for its metadata entries.
%
% Specifically, it enforces that:
%   * All metaEntry IDs in |additional| are unique at this time.
%   * Each metaEntry.name matches the corresponding field name in |additional|.
%
% This method should be called after any structural modifications
% (adding, removing, or renaming metadata fields) to maintain consistency.
%
% Usage:
%   sd = sd.assertInvariants();
%
% Note:
%   - This approach allows metaEntry IDs to be reused or reassigned.
%   - IDs are guaranteed to be unique at the time of this check,
%     but are not required to be sequential.
%   - This method may be slow for very large numbers of metadata fields,
%     but in practice this is negligible compared to typical signal operations.
%
% See also:
%   setField, removeField, metaEntry

f = fieldnames(obj.additional);
ids = zeros(1, numel(f));

for i = 1:numel(f)
    entry = obj.additional.(f{i});

    % Ensure the metaEntry name matches the field name
    entry.name = f{i};
    obj.additional.(f{i}) = entry;

    % Collect ID
    ids(i) = entry.id;
end

% Check that all IDs are unique
if numel(ids) ~= numel(unique(ids))
    error('icnna.data.core.signalDescriptor:assertInvariants:DuplicateMetaEntryIds', ...
        'MetaEntry IDs must be unique within the signalDescriptor.');
end
end

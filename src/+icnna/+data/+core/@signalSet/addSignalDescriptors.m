function obj = addSignalDescriptors(obj, desc)
% Add signal descriptor(s).
%
%   obj = addSignalDescriptors(obj, desc);
%
% Adds one or more @icnna.data.core.signalDescriptor objects
% to this @icnna.data.core.signalSet manager.
%
% If a descriptor with the same |id| or |name| than any element
% in desc already exists in obj, an error will be thrown and
% nothing will be added.
%
%
% Example:
%
%   obj = addSignalDescriptors(obj, sdHbO);
%
%
% Behavior:
%
%   + Signal descriptors are sorted internally by ascending |id|.
%
%   + The internal properties |desc.id| and |desc.name|
%     must be unique across all stored descriptors.
%
%   + Match by name is case sensitive i.e. 'HbO' is different
%     from 'hbo'.
%
%   + This method does NOT validate compatibility with
%     structuredData. That responsibility belongs to
%     @icnna.data.core.structuredData.
%
%
%% Error handling:
%
%   + Error if desc is not a @signalDescriptor object.
%   + Error if desc has an |id| already defined in obj.
%   + Error if desc has a |name| already defined in obj.
%
%
%% Input parameters:
%
% desc - @icnna.data.core.signalDescriptor[]
%   Array of signalDescriptor objects to be added.
%   If empty, nothing is added.
%
%
%% Output:
%
% obj - @icnna.data.core.signalSet
%   Updated object containing the newly added signal descriptors.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.signalSet,
%   icnna.data.core.signalDescriptor,
%   getSignalDescriptors,
%   removeSignalDescriptors,
%   findSignalDescriptors
%


%% Log
%
% -- ICNNA v1.4.0
%
% 04-Mar-2026: FOE
%   + File created.
%


% Check if desc is empty
if isempty(desc)
    % If no descriptors are provided, do nothing and return
    return
end


% Validate input type
if ~isa(desc, 'icnna.data.core.signalDescriptor')
    error('icnna:data:core:signalSet:addSignalDescriptors:InvalidInput', ...
        'Input must be an array of signalDescriptor objects.');
end


% Combine existing and new descriptor IDs
tmpIDs = [[obj.descriptors.id]'; [desc.id]'];

% Assert that no repeated IDs exist
assert(numel(tmpIDs) == numel(unique(tmpIDs)), ...
    ['icnna:data:core:signalSet:addSignalDescriptors:InvalidDescriptor ', ...
     'Repeated descriptor |id|.']);


% Combine existing and new descriptor names
tmpNames = [{obj.descriptors.name}'; {desc.name}'];

% Assert that no repeated names exist
assert(numel(tmpNames) == numel(unique(tmpNames)), ...
    ['icnna:data:core:signalSet:addSignalDescriptors:InvalidDescriptor ', ...
     'Repeated descriptor |name|.']);


% Add the descriptors
obj.descriptors = [obj.descriptors; desc];

% Sort internally by ID
[~, idx] = sort([obj.descriptors.id]);
obj.descriptors = obj.descriptors(idx);


% Ensure invariants of the object are maintained
obj.assertInvariants();

end
function obj = setSignalDescriptors(obj, desc)
% Replaces existing @icnna.data.core.signalDescriptor object(s).
%
%   obj = setSignalDescriptors(obj, desc)
%
%   + Match by name is case sensitive i.e. 'HbO' is different
%     from 'hbo'.
%
%
% @li The signal descriptors in desc must already exist in obj.
%     If any |id| does not correspond to a defined descriptor,
%     an error is thrown and nothing is replaced.
%
%
%% Remarks
%
% Lists are paired by |id| only, i.e. you can use this method to change
% the |name| (as well as other properties) but NOT the |id|.
%
% To change the |id| of a @icnna.data.core.signalDescriptor,
% you must get/remove/add the descriptor.
%
% This function does NOT reset the complete list of descriptors.
% It only replaces existing descriptors (based on |id| pairing).
%
% To reset the complete list, you need to clear/add the descriptors.
%
%
%% Error handling
%
%   + There cannot be descriptors with repeated |id| among
%     the updating descriptors.
%   + All updating descriptors must match an existing descriptor.
%   + There cannot be repeated |name| among the updating descriptors.
%   + Descriptor |name|s cannot be empty.
%   + After replacement, class invariants must still hold.
%
%
%% Input parameters
%
% desc - @icnna.data.core.signalDescriptor[]
%   List of signalDescriptor objects to be updated.
%
%
%% Output:
%
% obj - @icnna.data.core.signalSet
%   Updated object.
%
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
%   getSignalDescriptorList
%


%% Log
%
% -- ICNNA v1.4.0
%
% 4-Mar-2026: FOE
%   + File created.
%



%Assert that there aren't conditions sharing the same id
ids = uint32([desc.id]);
assert(numel(ids) == numel(unique(ids)), ...
    'icnna:data:core:signalSet:setSignalDescriptors:RepeatedDescriptorIDs', ...
    'Repeated signal descriptor ids.');


%Assert that there aren't conditions sharing the same name
names = {desc.name}';
assert(numel(names) == numel(unique(names)), ...
    'icnna:data:core:signalSet:setSignalDescriptors:RepeatedDescriptorNames', ...
    'Repeated signal descriptor names.');

tmp = cellfun(@(val) isempty(val), names);
assert(~any(tmp), ...
    'icnna:data:core:signalSet:setSignalDescriptors:EmptyDescriptorNames', ...
    'Empty signal descriptor name.');


% Validate that all IDs exist in current container
idx = obj.findSignalDescriptors(ids);
assert(~any(isnan(idx)), ...
    'icnna:data:core:signalSet:setSignalDescriptors:UnmatchedDescriptor', ...
    'Id not found. There is at least one unmatched signal descriptor.');


% Perform replacement
obj.descriptors(idx) = desc;
% Ensure invariants still hold after replacement
obj.assertInvariants();

end
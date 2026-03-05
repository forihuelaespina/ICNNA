function obj = removeSignalDescriptors(obj, tags)
% Remove stored @icnna.data.core.signalDescriptor object(s).
%
%   obj = removeSignalDescriptors(obj,id);
%   obj = obj.removeSignalDescriptors(id);
%   obj = removeSignalDescriptors(obj,name);
%   obj = obj.removeSignalDescriptors(name);
%
%
% Behavior:
%
%   + Any matching @icnna.data.core.signalDescriptor is removed.
%   + Match by name is case sensitive i.e. 'HbO' is different
%     from 'hbo'.
%   + Multiple descriptors may be removed in a single call.
%
%
%% Error handling
%
%   + If no tags (whether ids or names) are provided, a warning is issued.
%   + If no matching descriptors are found, a warning is issued.
%
%
%% Input parameters:
%
% ids  - Int or Int[1xk] or Int[kx1]
%   The |id|(s) of the @icnna.data.core.signalDescriptor
%   being searched.
%
% names - String OR String{}
%   The |name|(s) of the @icnna.data.core.signalDescriptor
%   being searched.
%   The search for the name is case sensitive.
%
%
%% Output:
%
% obj - @icnna.data.core.signalSet
%   Updated object without the removed descriptors.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.signalSet,
%   icnna.data.core.signalDescriptor,
%   addSignalDescriptors,
%   getSignalDescriptors,
%   getSignalDescriptorList
%


%% Log
%
% -- ICNNA v1.4.0
%
% 4-Mar-2026: FOE
%   + File created.
%



% Validate input
if isempty(tags)
    warning('icnna:data:core:signalSet:removeSignalDescriptors:EmptyInput', ...
        'No tags were provided for removal.');
    return;
end


% Find matching descriptor whether by ids or names.
idx = obj.findSignalDescriptors(tags);
    %Note that this takes care of whether it is truly an |id| or a |name|
    %as well as whether there is more than 1 condition.

idx = unique(idx);
idx(isnan(idx)) = [];


% Perform removal
if isempty(idx)
    warning('icnna:data:core:signalSet:removeSignalDescriptors:NotFound', ...
        'No signal descriptors found for the provided id(s) or name(s).');
else
    obj.descriptors(idx) = [];
end

end
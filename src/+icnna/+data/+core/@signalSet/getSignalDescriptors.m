function desc = getSignalDescriptors(obj, val)
% Retrieves stored @icnna.data.core.signalDescriptor object(s).
%
%   desc = getSignalDescriptors(obj)       - Get all descriptors
%   desc = getSignalDescriptors(obj, id)   - Get descriptor(s) by |id|
%   desc = getSignalDescriptors(obj, name) - Get descriptor(s) by |name|
%
%   Retrieves stored @icnna.data.core.signalDescriptor either by:
%       - Numerical identifier (|id|)
%       - Descriptor name (|name|)
%
%   + Match by name is case sensitive i.e. 'HbO' is different
%     from 'hbo'.
%
%
%% Error handling
%
%   If no descriptors are found, a warning is thrown.
%
%
%% Input parameters:
%
% id  - Int or Int[]
%   The |id|(s) of the @icnna.data.core.signalDescriptor being searched.
%
% name - String or String{}
%   The |name|(s) of the @icnna.data.core.signalDescriptor being searched.
%   The search for the name is case sensitive.
%
%
%% Output:
%
% desc - @icnna.data.core.signalDescriptor[]
%   Array of found signalDescriptor objects.
%
%   Empty if no descriptors are found.
%
%   The descriptors are sorted by |id|.
%
%   Note that the length of the output may not match the
%   length of the input (e.g., repeated id/names in query).
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.signalSet,
%   icnna.data.core.signalDescriptor,
%   addSignalDescriptors,
%   removeSignalDescriptor,
%   findSignalDescriptors
%


%% Log
%
% -- ICNNA v1.4.0
%
% 4-Mar-2026: FOE
%   + File created.
%



% If no query provided, retrieve all descriptors
if ~exist('val','var')
    [val, ~] = obj.getSignalDescriptorList();
end


% Find matching descriptors (whether by id or name)
idx = obj.findSignalDescriptors(val);
    %Note that this takes care of whether id is truly an |id| or a |name|
    %as well as whether the search is for one or multiple.


% Ignore repeated descriptors and NaNs
idx = unique(idx);
idx(isnan(idx)) = [];


% Prepare output
if isempty(idx)
    desc = icnna.data.core.signalDescriptor.empty;
    warning('icnna:data:core:signalSet:getSignalDescriptors:NotFound', ...
        'No signal descriptors found for the provided id(s) or name(s).');
else
    desc = obj.descriptors(idx);
    
    % Sort by id
    [~, idx2] = sort(desc.id);
    desc = desc(idx2);
end

end
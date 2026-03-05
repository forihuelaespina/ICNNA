function [idx] = findSignalDescriptors(obj,tags)
% Retrieves the |id|(s) of the @icnna.data.core.signalDescriptor matching the given |id|(s) or |name|(s).
%
%   [idx] = obj.findSignalDescriptors(ids)   - Search by |id|
%   [idx] = obj.findSignalDescriptors(names) - Search by |name|
%
%
%% Remarks
%
% The output matches the length and order of the query and is returned
% as a column vector.
%
% For instance, assume that this @icnna.data.core.signalSet contains
% 6 @icnna.data.core.signalDescriptor objects with ids:
%
%   [1 2 3 4 8 12]
%
% and the query is:
%
%   ids = [5 8 2 8];
%
% Then this function returns:
%
%   idx = [NaN; 8; 2; 8];
%
% i.e., the returned values correspond to the descriptor |id|
% (not the positional index inside the container).
%
%
% If you wish to retrieve the unique found ids sorted in ascending
% order, you may use:
%
%   idx = unique(idx);
%   idx(isnan(idx)) = [];
%
%
%
%% Input Parameters
%
% ids  - Int or Int[1xk] or Int[kx1]
%   The |id|(s) of the @icnna.data.core.signalDescriptor being searched.
%
% names - String OR String{}
%   The |name|(s) of the @icnna.data.core.signalDescriptor being searched.
%   The search for names is case sensitive.
%
%
%% Outputs
%
% idx - double[kx1]
%   Column vector matching the number of elements and order
%   of the query tags (whether ids or names).
%
%   If a descriptor is not found, the corresponding entry
%   is returned as NaN.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.signalSet,
%   icnna.data.core.signalDescriptor
%


%% Log
%
% -- ICNNA v1.4.0
%
% 4-Mar-2026: FOE
%   + File created.
%



%% Prepare the query
if ischar(tags)
    % If single name -> convert to 1×1 cell
    tags = {tags};
end

if iscell(tags)
    % Name query (and typecast tags to string)
    queryType = 'name';
    tags = string(tags);
else
    % ID query (and typecast tags to uint32)
    queryType = 'id';
    tags = uint32(tags);
end


%% Perform search
descIds = [obj.descriptors.id];
switch queryType
    case 'id'
        [tf, loc] = ismember(tags, descIds);
    case 'name'
        [tf, loc] = ismember(tags, string({obj.descriptors.name}));
end


%% Prepare output
idx     = nan(numel(tags),1);
idx(tf) = descIds(loc(tf));   % Return descriptor IDs, not positions, missing -> NaN

end
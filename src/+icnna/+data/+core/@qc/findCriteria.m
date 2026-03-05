function [idx] = findCriteria(obj,tags)
%Retrieves the indexes of the QC criteria with the given |id|(s) or |name|(s)
%
% [idx] = obj.findCriteria(ids)   - Search for QC criteria by |id|
% [idx] = obj.findCriteria(names) - Search for QC criteria by |name|
%
%
%% Remarks
%
% The output matches the length and order of the query is a column
% vector. For instance, say that the @icnna.data.core.qc
% has 6 @icnna.data.core.qcCriterion with ids with ids [1 2 3 4 8 12]
% and parameter ids = [5 8 2 8]. Then, this function return
% 
% idx = [NaN; 5; 2; 5];
%
% Note that you can easily get the idx returned sorted according to
% (found) ids and not in the queried order using:
%
%   idx = unique(idx);
%   idx(isnan(idx)) = [];
% 
%
%
%% Input Parameters
%
% ids  - Int or Int[1xk] or Int[kx1].
%   The |id|(s) of the QC criteria being searched.
%
% names - String OR String{}.
%   The |name|(s) of the QC criteria being searched.
%   The search for the name is case sensitive.
%
%% Outputs
%
% idx - double[kx1].
%   Column vector matching the number of elements
%   and order of the query tags (whether ids or names).
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.qc
%



%% Log
%
%
% -- ICNNA v1.4.0
%
% 3-Mar-2026: FOE
%   + File created.
%



%Prepare the query
if ischar(tags)
    % If single name -> convert to 1×1 cell
    tags = {tags};
end

if iscell(tags) % Name query (and typecast tags to string)
    queryType = 'name';
    tags = string(tags);
else % ID query (and typecast tags to uint32)
    queryType = 'id';
    tags = uint32(tags);
end

%Make the search/query
critIds = [obj.criteria.id];
switch (queryType)
    case 'id'
        [tf, loc] = ismember(tags, critIds);
    case 'name'
        [tf, loc] = ismember(tags, string({obj.criteria.name}));
end

%Prepare the output
idx     = nan(numel(tags),1);
idx(tf) = critIds(loc(tf)); % Convert location -> ID values, missing -> NaN

end


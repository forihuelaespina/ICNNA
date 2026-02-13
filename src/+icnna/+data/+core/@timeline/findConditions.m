function [idx] = findConditions(obj,tags,options)
%Retrieves the indexes of the conditions with the given |id|(s) or |name|(s)
%
% [idx] = obj.findConditions(ids)   - Search for conditions by |id|
% [idx] = obj.findConditions(names) - Search for conditions by |name|
% [idx] = obj.findConditions(...,options)
%
%
%% Remarks
%
% -- ICNNA v1.3.1 (or earlier)
%
% Note that the length of output idx may be different from the length of
%the input id or name as not all conditions may be found.
%
% The idx are returned sorted according to (found) ids and not in the
% queried order. For instance, say that the timeline has 6 conditions
% with ids [1 2 3 4 8 12] and parameter ids = [5 8 2]. Then, this function return
% 
% idx = [2 5];
%
% ..so DO NOT assume that the order of found idx correspond to the order
%of the ids or names. You may need to sort your ids in advance or 
%rearrange your idx afterwards.
%
% -- Since ICNNA v1.4.0
%
% From v1.4.0, the behaviour of this method has changed. Now the
% output matches the length and order of the query and it is now
% a column vector. For instance, say
% that the timeline has 6 conditions with ids with ids [1 2 3 4 8 12]
% and parameter ids = [5 8 2 8]. Then, this function return
% 
% idx = [NaN; 5; 2; 5];
%
% Note that you can easily get the past behaviour either using
% the legacy option or as well:
%
%   idx = unique(idx);
%   idx(isnan(idx)) = [];
% 
%
%
%% Parameters
%
% ids  - Int or Int[1xk] or Int[kx1].
%   The |id|(s) of the conditions being searched.
%
% names - String OR String{}.
%   The |name|(s) of the conditions being searched.
%   The search for the name is case sensitive.
%
% options - struct.
%   A struct of options with the following (optional) fields.
%       .legacy - char[].
%           The version for which behaviour should be matched
%           if not the present behaviour e.g.
%               options.legacy = '1.3.1'
%
%% Outputs
%
% idx - Depends on version;
%   Present behaviour:
%       double[kx1]. Column vector matching the number of elements
%       and order of the query tags (whether ids or names).
%   Legacy behaviour:
%       double[]. Returns the indexes to the conditions found with the
%   given |id| or |name| or empty if there are no matching conditions.
%   Conditions not found will not have an associated idx.
%   The order of the idx does NOT necessarily match the order of the
%   query.
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%



%% Log
%
% 12-Apr-2025: FOE
%   + File created.
%
% 25-Apr-2025: FOE
%   + Update use of |name| instead of deprecated |tag|.
%
% 26-Apr-2025: FOE
%   + Added support to retrieve several conditions at once.
%
% 28-Jun-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions (from array of objects to 1 dictionary and 1 table).
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%
% -- ICNNA v1.4.0
%
% 10-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Change .conds to .conditions, and updated from a table to a
%   struct array of conditions.
%	+ Revert .cevents to a derived property (extracted on the fly from
%       .conditions) |condEvents|.
%   + Improve some comments.
%   + Changed behaviour; the output now matches the length
%   and order of the input tags. For instance; say that the
%   timeline has 6 conditions with ids with ids [1 2 3 4 8 12] and
%   parameter ids = [5 8 2 8]. Then,
%       BEFORE: idx = [2 5]
%       NOW:    idx = [NaN; 5; 2; 5]
%    Legacy behaviour is still provided using option
%    'legacy'.
%


%% Deal with options
opt.legacy = [];
if exist('options','var')
    if isfield(options,'legacy')
        opt.legacy = options.legacy;
    end
end


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
condIds = [obj.conditions.id];
switch (queryType)
    case 'id'
        [tf, loc] = ismember(tags, condIds);
    case 'name'
        [tf, loc] = ismember(tags, string({obj.conditions.name}));
end

%Prepare the output
idx     = nan(numel(tags),1);
idx(tf) = condIds(loc(tf)); % Convert location -> ID values, missing -> NaN

if ~isempty(opt.legacy)
    switch(opt.legacy)
        case '1.3.1'
            idx = unique(idx);
            idx(isnan(idx)) = [];
        otherwise
            error('icnna:data:core:timeline:findConditions:InvalidParameterValue',...
                'Unexpected option legacy value.');
    end
end

end


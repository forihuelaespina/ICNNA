function obj = removeCriteria(obj, tags)
% Remove a QC criterion.
%
%   obj = removeCriteria(obj,id);
%   obj = obj.removeCriteria(id);
%   obj = removeCriteria(obj,name);
%   obj = obj.removeCriteria(name);
%
% Behavior:
%
%   + Any QC criterion that exists is removed.
%   + Match by name is case sensitive i.e. 'john' is different
%   from 'John'
%
%
%% Error handling
%
%   + If no QC criteria exist, a warning is issued.
%   + If no tags (whether ids or names are provided) then
%   a warning is issued.
%
%% Input parameters:
%
% ids  - Int or Int[1xk] or Int[kx1].
%   The |id|(s) of the QC criteria being searched.
%
% names - String OR String{}.
%   The |name|(s) of the QC criteria being searched.
%   The search for the name is case sensitive.
%
%% Output:
%
% obj -  @icnna.data.core.qc
%   Updated @icnna.data.core.qc object without the eliminated criteria.
%
%
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.qc, icnna.data.core.qcCriterion,
%   addCriterion, setCriterion, getCriterion, listCriteria
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 3-Mar-2026: FOE
%   + File isolated from initial code in main class icnna.data.core.qc.
%   + Method generalised to deal with any number of criteria at once.
%


% Validate input
if isempty(tags)
    warning('icnna:data:core:qc:removeCriteria:EmptyInput', ...
        'No tags were provided for removal.');
    return;  % Exit the method early if input is empty
end

% Find matching QC criteria whether by ids or names.
idx = obj.findCriteria(tags);
    %Note that this takes care of whether it is truly an |id| or a |name|
    %as well as whether there is more than 1 condition.
idx = unique(idx);
idx(isnan(idx)) = [];

if isempty(idx)
    warning('icnna:data:core:qc:removeCriteria:NotFound', ...
        'No criteria found for the provided id(s) or name(s).');
else
    obj.criteria(idx) = [];
end
end

function crit = getCriteria(obj, val)
% Retrieves a stored QC criterion.
%
%   crit = getCriteria(obj) - Get all criteria
%   crit = getCriteria(obj,id) - Get the criteria identified by |id|
%   crit = getCriteria(obj,name) - Get the criteria identified by |name|
%
%   Retrieves the stored @icnna.data.core.qcCriterion either by:
%       - Numerical identifier (id)
%       - Criterion name
%
%   + Match by name is case sensitive i.e. 'john' is different
%   from 'John'
%
%% Error handling
%
%  If no criteria are found, a warning is thrown.
% 
%% Input parameters:
%
% id  - Int or Int[].
%   The |id| of the QC criteria being searched.
%
% name - String or String{}.
%   The |name| of the QC criteria being searched.
%   The search for the name is case sensitive.
%
%% Output:
%
% crit - @icnna.data.core.qcCriterion[]
%   The array of found QC criteria. Empty if no criteria are found.
%   The criteria are sorted by |id|. Note that the length
%   of the output may not match the lengths of the input even
%   if criteria are found, e.g. repeated id/names.
%
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.qc, icnna.data.core.qcCriterion,
%   addCriterion, setCriterion, hasCriterion, listCriteria
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

% If no query provided, retrieve all QC criteria
if ~exist('val','var')
    [val,~] = obj.getCriteriaList();
end

idx = obj.findCriteria(val);
    %Note that this takes care of whether id is truly an |id| or a |name|
    %as well as whether the search is for one or multiple.

%Ignore repeated ids and NaNs
idx = unique(idx);
idx(isnan(idx)) = [];

if isempty(idx)
    crit = icnna.data.core.criteria.empty;
    warning('icnna:data:core:qc:getCriteria:NotFound', ...
          'No criteria found for the provided id(s) or name(s).');
else
    crit = obj.criteria(idx);

    %Sort by id
    [~,idx2] = sort(crit.id);
    crit = crit(idx2);
end

end

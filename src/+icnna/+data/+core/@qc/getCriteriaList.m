function [ids,names] = getCriteriaList(obj)
% List stored QC criteria.
%
%   [ids,names] = getCriteriaList(obj)
%
%   Returns the ids and names of all stored QC criteria.
%
%% Output:
%
% ids - int[nCriteria]
%   Numerical identifiers of the criteria.
%   This may be empty if no QC criteria is currently defined in obj.
%
% names - cell array[nCriteria] of char
%   Names of the criteria.
%   The returned names correspond to the internal property:
%       crit.name
%   This may be empty if no QC criteria is currently defined in obj.
%
%
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.qc, icnna.data.core.qcCriterion,
%   addCriterion, getCriterion, setCriterion, removeCriterion
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 3-Mar-2026: FOE
%   + File isolated from initial code in main class icnna.data.core.qc.
%

ids = [obj.criteria.id];
if nargout > 1
    names = {obj.criteria.name};
end
end



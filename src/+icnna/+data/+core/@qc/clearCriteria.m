function obj = clearCriteria(obj)
% Clears all existing criteria
%
%   obj = clearCriteria(obj)
%   obj = obj.clearCriteria()
%
% Behavior:
%   + Removes all criteria from the QC manager.
%   + No warning or error if no criteria exist.
%
%% Output:
%
% obj -  @icnna.data.core.qc
%   Updated @icnna.data.core.qc object with no QC criteria defined.
%
%
%
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.qc, icnna.data.core.qcCriterion,
%   getCriteria, setCriteria, removeCriteria, getCriteriaList
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 3-Mar-2026: FOE
%   + File isolated from initial code in main class icnna.data.core.qc.
%

obj.criteria = icnna.data.core.qcCriterion.empty;
end

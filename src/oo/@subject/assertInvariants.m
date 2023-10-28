function assertInvariants(obj)
%SUBJECT/ASSERTINVARIANTS Ensures the invariants of the subject is met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: For all sessions s, their ID is different
%       s(i).ID~=s(j).ID
%
%
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
% See also subject
%



%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%



nElements=length(obj.sessions);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    tmp = obj.sessions{ii};
    tmpSessDef = tmp.definition;
    ids(ii)= tmpSessDef.id;
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
         'ICNNA:subject:assertInvariants: Repeated session IDs.');


end

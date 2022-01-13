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
% Copyright 2008
% date: 23-Apr-2008
% Author: Felipe Orihuela-Espina
%
% See also subject
%
nElements=length(obj.sessions);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    ids(ii)=get(get(obj.sessions{ii},'Definition'),'ID');
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
         'ICNA:subject:assertInvariants: Repeated session IDs.');

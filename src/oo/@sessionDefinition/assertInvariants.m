function assertInvariants(obj)
%SESSIONDEFINITION/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: For all sources, their expected id is different
%       sourceList(i).id~=sourceList(j).id
%
%
%   Invariant: For all sources, their expected type is a non-empty string
%       i.e. non generic.
%
%
% Copyright 2008
% date: 10-Jul-2008
% Author: Felipe Orihuela-Espina
%
% See also sessionDefinition, dataSourceDefinition, experiment, session
%
%

nElements=length(obj.sources);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    ids(ii)=get(obj.sources{ii},'ID');
    
    %...take advantage to ensure that the type is valid
    s=get(obj.sources{ii},'Type');
    assert((~isempty(s) && ischar(s)),...
            'sessionDefinition.assertInvariants: Invalid type found.');
    
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        'sessionDefinition.assertInvariants: Repeated source IDs.');


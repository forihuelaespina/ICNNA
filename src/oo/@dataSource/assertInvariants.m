function assertInvariants(obj)
%DATASOURCE/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%
%% Invariants
%
%   Invariant: If rawData is empty and object lock, then
%       no structuredData are defined.
%
%   Invariant: For all structured data pd, their ID is different
%       pd(i).ID~=pd(j).ID
%
%   Invariant: activeStructuredData is always pointing to the ID of
%       an existing structured data or 0, if none have been defined.
%
%   Invariant: All defined structuredData share the same Type
%
% Copyright 2008
% date: 23-Apr-2008
% Author: Felipe Orihuela-Espina
%
% See also dataSource, structuredData, get, set
%

if (obj.lock && isempty(obj.rawData))
    assert(isempty(obj.structured), ['dataSource.assertInvariants: '...
            'Data lock violation. ' ...
            'Structured data exist but no raw data has been defined.']);
end

nElements=length(obj.structured);
if (nElements>0)
    type=get(obj,'Type');
end
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    ids(ii)=get(obj.structured{ii},'ID');
    
    %...take advantage and check the type
    assert(strcmp(class(obj.structured{ii}),type),...
            'dataSource.assertInvariants: Mismatch type found.');
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        'dataSource.assertInvariants: Repeated structured data IDs.');


if (nElements>0)
    assert(~isempty(findStructuredData(obj,obj.activeStructured)),...
            'Non existing active data %d.',obj.activeStructured);
else
    assert(obj.activeStructured==0,...
            'Non existing active data %d.',obj.activeStructured);
end    

end
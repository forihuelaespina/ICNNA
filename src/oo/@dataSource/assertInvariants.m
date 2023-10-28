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
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
% See also dataSource, structuredData, get, set
%




%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%   + Some class invariants have been relaxed to warnings or removed.
%   + Error codes using 'ICNA' have been updated to 'ICNNA'
%   + Improved some comments.
%





if (obj.lock && isempty(obj.rawData))
    assert(isempty(obj.structured), ['ICNNA:dataSource:assertInvariants:InvariantViolation ' ...
            'Data lock violation. ' ...
            'Structured data exist but no raw data has been defined.']);
end

nElements=length(obj.structured);
if (nElements>0)
    type=obj.type;
end
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    tmp = obj.structured{ii};
    ids(ii)=tmp.id;
    
    %...take advantage and check the type
    assert(strcmp(class(tmp),type),...
            ['ICNNA:dataSource:assertInvariants:InvariantViolation ' ...
            'Mismatch type found.']);
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        ['ICNNA:dataSource:assertInvariants:InvariantViolation ' ...
           'Repeated structured data IDs.']);


if (nElements>0)
    assert(~isempty(findStructuredData(obj,obj.activeStructured)),...
            ['ICNNA:dataSource:assertInvariants:InvariantViolation ' ...
            'Non existing active data %d.'],obj.activeStructured);
else
    assert(obj.activeStructured==0,...
            ['ICNNA:dataSource:assertInvariants:InvariantViolation ' ...
            'Non existing active data %d.'],obj.activeStructured);
end    

end
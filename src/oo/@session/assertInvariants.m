function assertInvariants(obj)
%SESSION/ASSERTINVARIANTS Ensures the invariants of a session is met
%
% assertInvariants(obj) Asserts the invariants
%
%
%% Invariants
%
%   Invariant: sessionDefinition is never empty
%
%   Invariant: session always comply with its definition
%       - length(sources) <= getNSources(sessionDefinition)
%       - sources are coherent with definition.
%
%
%   Invariant: For all dataSource ds, their ID is different
%       ds(i).ID~=ds(j).ID
%
%
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
% See also session
%




%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Error codes updated to 'ICNNA'
%   + Improved some comments.
%





%sessionDefinition is never empty
assert(~isempty(obj.definition) ...
        && isa(obj.definition,'sessionDefinition'),...
        ['ICNNA:session:assertInvariants:InvariantViolation ' ...
        'Undefined session definition']);
    

%Invariant: session always comply with its definition
%   - length(sources) <= sessionDefinition.nDataSources
%   - IDs and type of sources are coherent with definition.
%               (Checked on the next loop)
tmp = obj.definition;
assert(length(obj.sources) <= tmp.nDataSources,...
    ['ICNNA:session:assertInvariants:InvariantViolation ' ...
        'Corrupted number of sources.']);
IDList=getSourceList(obj.definition);


nElements=length(obj.sources);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    tmpSrc = obj.sources{ii};
    ids(ii)=tmpSrc.id;
    
    %Check that it comply with the definition
    assert(ismember(ids(ii),IDList),...
            ['ICNNA:session:assertInvariants:InvariantViolation ' ...
            'Invalid ID found.']);
    sessDeff  = obj.definition;
    tmpSource = sessDeff.getSource(ids(ii));
%    assert(strcmp(get(getSource(obj.definition,ids(ii)),'Type'),...
%                  get(obj.sources{ii},'Type')),...
    assert(strcmp(tmpSource.type,tmpSrc.type),...
            ['ICNNA:session:assertInvariants:InvariantViolation ' ...
            'Invalid Type found.']);
%    assert(get(getSource(obj.definition,ids(ii)),'DeviceNumber')...
%            ==get(obj.sources{ii},'DeviceNumber'),...
    assert(tmpSource.deviceNumber==tmpSrc.deviceNumber,...
            ['ICNNA:session:assertInvariants:InvariantViolation ' ...
            'Invalid device number found.']);
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        ['ICNNA:session:assertInvariants:InvariantViolation ' ...
            'Repeated dataSource IDs.']);



end

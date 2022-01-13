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
% Copyright 2008
% date: 23-Apr-2008
% Author: Felipe Orihuela-Espina
%
% See also session
%

%sessionDefinition is never empty
assert(~isempty(obj.definition) ...
        && isa(obj.definition,'sessionDefinition'),...
        'session.assertInvariants: Undefined session definition');
    

%Invariant: session always comply with its definition
%   - length(sources) <= getNSources(sessionDefinition)
%   - IDs and type of sources are coherent with definition.
%               (Checked on the next loop)
assert(length(obj.sources) <= getNSources(obj.definition),...
    'session.assertInvariants: Corrupted number of sources.');
IDList=getSourceList(obj.definition);


nElements=length(obj.sources);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    ids(ii)=get(obj.sources{ii},'ID');
    
    %Check that it comply with the definition
    assert(ismember(ids(ii),IDList),...
            'session.assertInvariants: Invalid ID found.');
    assert(strcmp(get(getSource(obj.definition,ids(ii)),'Type'),...
                  get(obj.sources{ii},'Type')),...
            'session.assertInvariants: Invalid Type found.');
    assert(get(getSource(obj.definition,ids(ii)),'DeviceNumber')...
            ==get(obj.sources{ii},'DeviceNumber'),...
            'session.assertInvariants: Invalid device number found.');
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        'session.assertInvariants: Repeated dataSource IDs.');

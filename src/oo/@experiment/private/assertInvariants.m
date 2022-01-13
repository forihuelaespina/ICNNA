function assertInvariants(obj)
%EXPERIMENT/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%=======
%INVARIANTS
%=======
%
%   Invariant: For all dataSourceDefinitions s, their ID is different
%       s(i).ID~=s(j).ID
%
%   Invariant: For all sessionDefinitions s, their ID is different
%       s(i).ID~=s(j).ID
%
%   Invariant: For all sessionDefinitions s, their dataSourceDefinitions
%       are defined in the experiment dataSourceDefinitions
%
%   Invariant: For all subjects s, their ID is different
%       s(i).ID~=s(j).ID
%
%   Invariant: For all subjects s, their sessions
%       are defined in the experiment sessionDefinitions
%
%
% Copyright 2008
% date: 20-Apr-2008
% Author: Felipe Orihuela-Espina
%
% See also experiment
%

nElements=length(obj.dataSourceDefinitions);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    ids(ii)=get(obj.dataSourceDefinitions{ii},'ID');
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        ['experiment.assertInvariants: ' ...
         'IDs repeated for data source definitions.']);


nElements=length(obj.sessionDefinitions);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    ids(ii)=get(obj.sessionDefinitions{ii},'ID');

    %Take advantage and check that all its dataSource definitions
    %are defined in the experiment
    srcID=getSourceList(obj.sessionDefinitions{ii});
    for src=srcID
        def=getSource(obj.sessionDefinitions{ii},src);
        tmpSrcDefIdx=findDataSourceDefinition(obj,get(def,'ID'));
        assert(~isempty(tmpSrcDefIdx),...
                ['experiment.assertInvariants: ' ...
                 'Undefined data source definitions ' ...
                 num2str(get(def,'ID')) ...
                'for session definition ' num2str(ids(ii))]);
        assert(def==getDataSourceDefinition(obj,get(def,'ID')),...
                ['experiment.assertInvariants: ' ...
                'Undefined data source definitions ' ...
                num2str(get(def,'ID')) ...
                'for session definition ' num2str(ids(ii))]);
    end
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        ['experiment.assertInvariants: ' ...
         'IDs repeated for session definitions.']);


nElements=length(obj.subjects);
ids=zeros(1,nElements);
%Collect Subjects IDs
for ii=1:nElements
    ids(ii)=get(obj.subjects{ii},'ID');
    
    %Take advantage and check that all the subject sessions
    %are defined in the experiment
    sessID=getSessionList(obj.subjects{ii});
    for sess=sessID
        def=get(getSession(obj.subjects{ii},sess),'Definition');
        tmpSessDefIdx=findSessionDefinition(obj,get(def,'ID'));
        assert(~isempty(tmpSessDefIdx),...
                ['experiment.assertInvariants: ' ...
                'Undefined session definitions ' num2str(get(def,'ID')) ...
                'for subject ' num2str(ids(ii))]);
        assert(def==getSessionDefinition(obj,get(def,'ID')),...
                ['experiment.assertInvariants: ' ...
                'Undefined session definitions ' num2str(get(def,'ID')) ...
                'for subject ' num2str(ids(ii))]);
    end    
    
    
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        'experiment.assertInvariants: IDs repeated for subjects.');
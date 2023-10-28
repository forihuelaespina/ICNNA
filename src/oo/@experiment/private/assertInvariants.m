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
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
% See also experiment
%




%% Log
%
% File created: 20-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date .
%   + Updated calls to get attributes using the struct like syntax
%   + Some class invariants have been relaxed to warnings or removed.
%   + Error codes using 'ICNA' have been updated to 'ICNNA'
%   + Improved some comments.
%





nElements=length(obj.dataSourceDefinitions);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    tmp = obj.dataSourceDefinitions{ii};
    ids(ii)=tmp.id;
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        ['ICNNA:experiment:assertInvariants:InvariantViolation: ' ...
         'IDs repeated for data source definitions.']);


nElements=length(obj.sessionDefinitions);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    sessDef = obj.sessionDefinitions{ii};
    ids(ii)=sessDef.id;

    %Take advantage and check that all its dataSource definitions
    %are defined in the experiment
    srcID=getSourceList(sessDef);
    for src=srcID
        def=getSource(sessDef,src);
        tmpSrcDefIdx=findDataSourceDefinition(obj,def.id);
        assert(~isempty(tmpSrcDefIdx),...
                ['ICNNA:experiment:assertInvariants:InvariantViolation: ' ...
                 'Undefined data source definitions ' ...
                 num2str(def.id) ...
                'for session definition ' num2str(ids(ii))]);
        assert(def==getDataSourceDefinition(obj,def.id),...
                ['ICNNA:experiment:assertInvariants:InvariantViolation: ' ...
                'Undefined data source definitions ' num2str(def.id) ...
                'for session definition ' num2str(ids(ii))]);
    end
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        ['ICNNA:experiment:assertInvariants:InvariantViolation: ' ...
         'IDs repeated for session definitions.']);


nElements=length(obj.subjects);
ids=zeros(1,nElements);
%Collect Subjects IDs
for ii=1:nElements
    tmpSubject = obj.subjects{ii};
    ids(ii)=tmpSubject.id;
    
    %Take advantage and check that all the subject sessions
    %are defined in the experiment
    sessID=getSessionList(tmpSubject);
    for sess=sessID
        tmpSess = getSession(tmpSubject,sess);
        def=tmpSess.definition;
        tmpSessDefIdx=findSessionDefinition(obj,def.id);
        assert(~isempty(tmpSessDefIdx),...
                ['ICNNA:experiment:assertInvariants:InvariantViolation: ' ...
                'Undefined session definitions ' num2str(def.id) ...
                'for subject ' num2str(ids(ii))]);
        assert(def==getSessionDefinition(obj,def.id),...
                ['ICNNA:experiment:assertInvariants:InvariantViolation: ' ...
                'Undefined session definitions ' num2str(def.id) ...
                'for subject ' num2str(ids(ii))]);
    end    
    
    
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        'ICNNA:experiment:assertInvariants:InvariantViolation: IDs repeated for subjects.');



end
function obj=removeDataSourceDefinition(obj,id)
% EXPERIMENT/REMOVEDATASOURCEDEFINITION Removes a dataSource definition
%
% obj=addDataSourceDefinition(obj,id) Removes dataSourceDefinition
%   whose ID==id from the experiment.
%   If the dataSource definition does not exist, nothing is done.
%
%
%
%----------------------------
%Remarks
%----------------------------
%
%In removing a dataSource definition from the experiment, all
%sessions will be revised, and their dataSources will be removed
%in cascade. This may leave some sessions without data.
%
%Note that modifying a session definition will in turn force a
%revision of all subjects!
%
%
%
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also addDataSourceDefinition, setDataSourceDefinition,
%    clearDataSourceDefinitions
%

%This should avoid trying to remove several definitions at a time...
if (~isscalar(id) || (floor(id)~=id) || id<1)
    error('id must be a positive integer.');
end

idx=findDataSourceDefinition(obj,id);
if (~isempty(idx))
    srcDefID=get(obj.dataSourceDefinitions{idx},'ID');
    %Check all subjects
    nSubjects=length(obj.subjects);
    for ii=1:nSubjects
        sessions=getSessionList(obj.subjects{ii});
        for jj=sessions
            session=getSession(obj.subjects{ii},jj);
            def=get(session,'Definition');
            if (contains(def,srcDefID)) %see function contains below
                def=removeSource(def,srcDefID);
                session=set(session,'Definition',def);
                obj.subjects{ii}=setSession(obj.subjects{ii},...
                                           get(def,'ID'),session);    
            end
        end  
    end
    
    %Check all sessions definitions
    nElements=length(obj.sessionDefinitions);
    for ii=1:nElements
        if (contains(obj.sessionDefinitions{ii},srcDefID)) %see function contains below
            obj.sessionDefinitions{ii}=...
                removeSource(obj.sessionDefinitions{ii},srcDefID);
        end
    end
  
    %Finally remove the dataSourceDefinition from the experiment
    obj.dataSourceDefinitions(idx)=[];
    
end
assertInvariants(obj);

function bool=contains(sessDef,srcDefID)
bool=ismember(srcDefID,getSourceList(sessDef));
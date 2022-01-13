function idList=getSessionDefinitionList(obj)
%EXPERIMENT/GETSESSIONDEFINITIONLIST Get a list of IDs of defined session definitions
%
% idList=getSessionDefinitionList(obj) Get a list of IDs of
%     defined session definitions or an
%     empty list if no sessionDefinitions have been defined.
%
% It is possible to navigate through the session definitions
%using the idList
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also getNSessionDefinitions, getSessionDefinition
%

nElements=getNSessionDefinitions(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(obj.sessionDefinitions{ii},'ID');
end
idList=sort(idList);
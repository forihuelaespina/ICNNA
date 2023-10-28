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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getNSessionDefinitions, getSessionDefinition
%


%% Log
%
% File created: 10-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%


nElements=obj.nSessionDefinitions;
idList=zeros(1,nElements);
for ii=1:nElements
    tmp = obj.sessionDefinitions{ii};
    idList(ii)=tmp.id;
end
idList=sort(idList);

end
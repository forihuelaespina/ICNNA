function s=getSessionDefinition(obj,id)
%EXPERIMENT/GETSESSIONDEFINITION Get the indicated session definition
%
% s=getSessionDefinition(obj,id) gets the session definition
%	identified by id or an empty matrix if the session
%	definition has not been defined.
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also getNSessionDefinitions, getSessionDefinitionList
%

i=findSessionDefinition(obj,id);
if (~isempty(i))
    s=obj.sessionDefinitions{i};
else
    s=[];
end

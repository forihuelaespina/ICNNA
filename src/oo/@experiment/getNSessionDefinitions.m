function n=getNSessionDefinitions(obj)
%EXPERIMENT/GETNSESSIONDEFINITIONS Gets the number of session definitions
%
% n=getNSessionDefinitions(obj) Gets the number of session
%	definitions defined in the experiment dataset.
%
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also getSessionDefinitionList
%

n=length(obj.sessionDefinitions);

function obj=clearSessionDefinitions(obj)
% EXPERIMENT/CLEARSESSIONDEFINITIONS Removes all existing session definitions
%
% obj=clearSessionDefinitions(obj) Removes all existing session
%   definitions from the dataset.
%
%   +=============================================+
%   | WARNING! All subjects with sessions defined |
%   | will also be removed!                       |
%   +=============================================+
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also addSessionDefinition, setSessionDefinition,
%   removeSessionDefinition
%

obj.sessionDefinitions=cell(1,0);
%Remove affected subjects
nElements=length(obj.subjects);
for ii=nElements:-1:1
    if (getNSessions(obj.subjects{ii})>0)
        obj.subjects{ii}=[];
    end
end
assertInvariants(obj);
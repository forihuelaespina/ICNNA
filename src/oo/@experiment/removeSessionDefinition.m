function obj=removeSessionDefinition(obj,id)
% EXPERIMENT/REMOVESESSIONDEFINITION Removes a session definition
%
% obj=addSessionDefinition(obj,id) Removes sessionDefinition
%   whose ID==id from the experiment.
%   If the session definition does not exist, nothing is done.
%
%
%
%----------------------------
%Remarks
%----------------------------
%
%In removing a session definition from the experiment, all
%subjects will be revised, and their sessions will be removed
%in cascade. This may leave some subjects without data.
%
%
%
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also addSessionDefinition, setSessionDefinition,
%    clearSessionDefinitions
%

%This should avoid trying to remove several definitions at a time...
if (~isscalar(id) || (floor(id)~=id) || id<1)
    error('id must be a positive integer.');
end

idx=findSessionDefinition(obj,id);
if (~isempty(idx))
    sessDefID=get(obj.sessionDefinitions{idx},'ID');
    %Check all subjects
    nElements=length(obj.subjects);
    for ii=1:nElements
        obj.subjects(ii)={removeSession(obj.subjects{ii},sessDefID)};
    end
    %Finally remove the sessionDefinition from the experiment
    obj.sessionDefinitions(idx)=[];

end
obj
assertInvariants(obj);
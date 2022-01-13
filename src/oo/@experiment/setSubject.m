function obj=setSubject(obj,id,s)
% EXPERIMENT/SETSUBJECT Replace a subject
%
% obj=setSubject(obj,id,newSubject) Replace subject whose ID==id
%   with the new subject. If the subject whose ID==id has not been
%   defined, then nothing is done.
%
%----------------------------
%Remarks
%----------------------------
%
%In updating a new subject, the session definitions of the experiment
%may be updated.
%
% a) If the modified subject contains one or more new session definitions
%   which are not yet defined in the experiment, and that do not
%   conflict the experiment current record of session definitions,
%   the subject is modified and the new definitions are collected
%   and added to the experiment repository.
%
% b) If the subject contains one or more session whose definitions
%   may conflict with the existing session definitions a warning
%   is issued. The subject is not updated.
%
% A conflicting definition is a sessionDefinition which has the
%same ID of an existing one, but is not equal to it.
%
%
% Copyright 2008
% @date: 20-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also addSubject, removeSubject, clearSubjects
%

idx=findSubject(obj,id);
if (~isempty(idx))
    s=subject(s); %Ensuring that s is a subject
    if existSessionDefinitionConflicts(obj,s)
        warning('ICNA:experiment:setSubject:SessionDefintionConflict',...
            'Session definition conflict found. Subject not modified.');
    else
        %Collect the new session definitions
        defs=collectSessionDefinitionsFromSubject(obj,s,1);
        obj=addSessionDefinition(obj,defs);
        obj.subjects(idx)={s};
    end

end
assertInvariants(obj);
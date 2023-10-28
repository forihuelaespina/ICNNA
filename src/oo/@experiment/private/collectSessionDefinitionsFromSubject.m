function defs=collectSessionDefinitionsFromSubject(obj,s,mode)
%EXPERIMENT/COLLECTSESSIONDEFINTIONSFROMSUBJECT
%Collect session definitions from subject
%
% defs=collectSessionDefinitionsFromSubject(obj,subject) 
%   Collect the session definitions for all the sessions
%   defined in the subject. May return an empty matrix
%   if the no subject has been defined with the indicated
%   id, or if the subject contains no sessions.
%
% defs=collectSessionDefinitionsFromSubject(obj,subject,mode) 
%   Collect session definitions from sessions
%   defined in the subject. May return an empty matrix
%   if the no subject has been defined with the indicated
%   id, or if the subject contains no sessions.
%       + If mode equals 0, then definition from all
%       sessions are collected.
%       + If mode equals 1, then only non existing definitions
%       are collected (those with IDs not defined).
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experiment, subject, sessionDefinition, assertInvariants




%% Log
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%



if ~isa(s,'subject')
    error('Invalid subject parameter.');
end

m=0;
if (exist('mode','var'))
    if (mode==0) || (mode==1)
        m=mode;
    else
        warning(['ICNA:experiment:private:' ...
            'collectSessionDefinitionsFromSubject:InvalidMode'],...
            'Invalid mode. Setting mode equals to 0.');
    end
end

if m
    expDefIDs=getSessionDefinitionList(obj);
end

sessIDs=getSessionList(s);
defs=cell(1,0);
if ~m
    defs=cell(1,s.nSessions);
end
pos=1;
for sess=sessIDs
    if m %Collect only new ones
        tmpSess = getSession(s,sess);
        tmpDef=tmpSess.definition;
        if (~ismember(tmpDef.id,expDefIDs))
            defs(pos)={tmpDef};
            pos=pos+1;
        end
    else %Collect all
        tmpSess = getSession(s,sess);
        defs(pos)={tmpSess.definition};
        pos=pos+1;
    end
end




end
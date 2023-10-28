function obj=addSession(obj,s)
% SUBJECT/ADDSESSION Add a new session to the subject
%
% obj=addSession(obj,s) Add a new session to the subject. If
%   a session with the same ID has already been defined within
%   the subject, then a warning is issued
%   and nothing is done.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also removeSession, setSession
%



%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%



%Ensure that s is a session
if isa(s,'session')
    tmpSessDeff = s.definition;
    idx=findSession(obj,tmpSessDeff.id);
    if isempty(idx)
        obj.sessions(end+1)={s};
    else
        warning('ICNNA:subject:addSession:RepeatedID',...
            'A session with the same ID has already been defined.');
    end
else
    error([inputname(2) ' is not a session']);
end
assertInvariants(obj);


end
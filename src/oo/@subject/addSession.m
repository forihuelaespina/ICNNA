function obj=addSession(obj,s)
% SUBJECT/ADDSESSION Add a new session to the subject
%
% obj=addSession(obj,s) Add a new session to the subject. If
%   a session with the same ID has already been defined within
%   the subject, then a warning is issued
%   and nothing is done.
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also removeSession, setSession
%

%Ensure that s is a session
if isa(s,'session')
    idx=findSession(obj,get(get(s,'Definition'),'ID'));
    if isempty(idx)
        obj.sessions(end+1)={s};
    else
        warning('ICNA:subject:addSession:RepeatedID',...
            'A session with the same ID has already been defined.');
    end
else
    error([inputname(2) ' is not a session']);
end
assertInvariants(obj);
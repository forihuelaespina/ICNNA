function obj=setSession(obj,id,s)
% SUBJECT/SETSESSION Replace a session
%
% obj=setSession(obj,id,newSession) Replace session whose ID==id
%   with the new session. If the session whose ID==id has not been
%   defined, then nothing is done.
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also addSession, removeSession
%

idx=findSession(obj,id);
if (~isempty(idx))
    obj.sessions(idx)={session(s)}; %Ensuring that s is a session
end
assertInvariants(obj);


end
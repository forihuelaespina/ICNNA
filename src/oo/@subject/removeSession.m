function obj=removeSession(obj,id)
% SUBJECT/REMOVESESSION Removes a session from the subject
%
% obj=removeSession(obj,id) Removes session whose ID==id from the
%   subject. If the session does not exist, nothing is done.
%
% Copyright 2008
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
%
% See also addSession, setSession, clearSessions
%

idx=findSession(obj,id);
if (~isempty(idx))
    obj.sessions(idx)=[];
end
assertInvariants(obj);
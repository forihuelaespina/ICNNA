function obj=clearSessions(obj)
% SUBJECT/CLEARSESSIONS Removes all existing sessions from the subject
%
% obj=clearSessions(obj) Removes all existing sessions from the subject.
%
% Copyright 2008
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also addSession, setSession, removeSession
%

obj.sessions=cell(1,0);
assertInvariants(obj);


end
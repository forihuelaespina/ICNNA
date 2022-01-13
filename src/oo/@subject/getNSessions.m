function n=getNSessions(obj)
%SUBJECT/GETNSESSIONS Gets the number of sessions defined in the subject
%
% n=getNSessions(obj) Gets the number of sessions defined in the subject
%
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also findSession
%

n=length(obj.sessions);

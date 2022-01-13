function s=getSession(obj,id)
%SUBJECT/GETSESSION Get the session identified by id
%
% s=getSession(obj,id) gets the session identified by id or an empty
%   matrix if the session has not been defined.
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also findSession, getSessionList
%

i=findSession(obj,id);
if (~isempty(i))
    s=obj.sessions{i};
else
    s=[];
end

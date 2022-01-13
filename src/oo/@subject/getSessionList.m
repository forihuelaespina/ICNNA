function idList=getSessionList(obj)
%SUBJECT/GETSESSIONLIST Get a list of IDs of defined sessions
%
% idList=getSessionList(obj) Get a list of IDs of defined sessions or an
%     empty list if no sessions have been defined.
%
% It is possible to navigate through the sessions using the idList
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also findSession, getSession
%

nElements=getNSessions(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(get(obj.sessions{ii},'Definition'),'ID');
end
idList=sort(idList);
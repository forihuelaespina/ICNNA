function idList=getSessionList(obj)
%SUBJECT/GETSESSIONLIST Get a list of IDs of defined sessions
%
% idList=getSessionList(obj) Get a list of IDs of defined sessions or an
%     empty list if no sessions have been defined.
%
% It is possible to navigate through the sessions using the idList
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also findSession, getSession
%


%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%
% 23-May-2023: FOE
%   + Partially updated calls to get attributes using the struct like syntax
%



nElements=obj.nSessions;
idList=zeros(1,nElements);
for ii=1:nElements
    tmp = obj.sessions{ii};
    tmpSessDef = tmp.definition;
    idList(ii)=tmpSessDef.id;
end
idList=sort(idList);


end
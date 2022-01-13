function idx=findSession(obj,id)
%SUBJECT/FINDSESSION Finds a session within the subject
%
% idx=findSession(obj,id) returns the index of the session.
%   If the session has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008
% @date: 23-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subject, assertInvariants

nElements=length(obj.sessions);
idx=[];
for ii=1:nElements
    tmpID=get(get(obj.sessions{ii},'Definition'),'ID');
    if (id==tmpID)
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end
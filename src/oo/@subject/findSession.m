function idx=findSession(obj,id)
%SUBJECT/FINDSESSION Finds a session within the subject
%
% idx=findSession(obj,id) returns the index of the session.
%   If the session has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also subject, assertInvariants



%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%


nElements=length(obj.sessions);
idx=[];
for ii=1:nElements
    tmpSess    = obj.sessions{ii};
    tmpSessDef = tmpSess.definition;
    tmpID      = tmpSessDef.id;
    if (id==tmpID)
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end


end
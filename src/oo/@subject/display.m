function display(obj)
%SUBJECT/DISPLAY Command window display of an subject
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subject
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   name: ' obj.name]);
disp(['   age: ' num2str(obj.age)]);
disp(['   sex: ' obj.sex]);
disp(['   hand: ' obj.hand]);
disp(['   sessions: ' num2str(getNSessions(obj))]);
idList=getSessionList(obj);
for ii=idList
    ssd = get(getSession(obj,ii),'Definition');
    name = get(ssd,'Name');
    disp(['      *' num2str(ii) ': ' name]);
end
disp(' ');

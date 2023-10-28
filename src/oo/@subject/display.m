function display(obj)
%SUBJECT/DISPLAY Command window display of an subject
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subject
%


%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%   + Now also displays new attribute classVersion
%




disp(' ');
disp([inputname(1),'= ']);
disp(' ');
try
    disp(['   Class version: ' num2str(obj.classVersion)]);
catch
    disp(['   Class version: N/A']);
end
disp(['   ID: ' num2str(obj.id)]);
disp(['   name: ' obj.name]);
disp(['   age: ' num2str(obj.age)]);
disp(['   sex: ' obj.sex]);
disp(['   hand: ' obj.hand]);
disp(['   sessions: ' num2str(obj.nSessions)]);
idList=getSessionList(obj);
for ii=idList
    tmpSession = getSession(obj,ii);
    ssd = tmpSession.definition;
    disp(['      *' num2str(ii) ': ' ssd.name]);
end
disp(' ');


end
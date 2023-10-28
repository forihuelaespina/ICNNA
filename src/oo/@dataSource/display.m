function display(obj)
%DATASOURCE/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also dataSource, get, set
%


%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Now also displays new attribute classVersion
%


disp(' ');
disp([inputname(1),'= ']);
disp(' ');
try
    disp(['   Class version: ' num2str(obj.classVersion)]);
catch
    disp('   Class version: N/A');
end
disp(['   ID: ' num2str(obj.id)]);
disp(['   name: ' obj.name]);
disp(['   Device Number: ' num2str(obj.deviceNumber)]);
disp('   rawData: ');
type=obj.type;
if (~isempty(type))
disp(['   Type: ''' type '''']);
end
r=obj.rawData;
display(r);
if (obj.lock)
    disp('   lock: LOCKED');
else
    disp('   lock: UNLOCKED');
end
disp(['   Structured Data: ' num2str(obj.nStructuredData) ' elements']);
disp(['   active structured data: ' num2str(obj.activeStructured)]);
disp(' ');

end

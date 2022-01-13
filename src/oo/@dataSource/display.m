function display(obj)
%DATASOURCE/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also dataSource, get, set
%
disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   name: ' obj.name]);
disp(['   Device Number: ' num2str(obj.deviceNumber)]);
disp(['   rawData: ']);
type=get(obj,'Type');
if (~isempty(type))
disp(['   Type: ''' type '''']);
end
r=obj.rawData;
display(r);
if (obj.lock)
    disp(['   lock: LOCKED']);
else
    disp(['   lock: UNLOCKED']);
end
disp(['   Structured Data: ' num2str(getNStructuredData(obj)) ' elements']);
disp(['   active structured data: ' num2str(obj.activeStructured)]);
disp(' ');

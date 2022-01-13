function display(obj)
%DATASOURCEDEFINITION/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also dataSourceDefinition
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   type: ''' obj.type '''']);
disp(['   Device number: ' num2str(obj.deviceNumber)]);
disp(' ');

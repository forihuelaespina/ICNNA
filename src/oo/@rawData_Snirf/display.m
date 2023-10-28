function display(obj)
%RAWDATA_SNIRF/DISPLAY Command window display of a rawData_Snirf
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2023
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRScout, get, set
%



%% Log
%
% 20-May-2023: FOE
%   + File created
%



disp(' ');
disp([inputname(1),'= ']);
disp(' ');
try
    disp(['   Class version: ' num2str(obj.classVersion)]);
catch
    disp('   Class version: N/A');
end
%Inherited
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   Date (Reference for timestamps): ' datestr(obj.date,0)]);

%Snirf image
disp('   Snirf: ');
disp(obj.snirfImg);

disp(' ');


end

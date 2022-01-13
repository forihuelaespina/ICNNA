function display(obj)
%RAWDATA/DISPLAY Command window display of a rawData
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
%
% See also rawData, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   date: ' obj.date]);
disp(' ');

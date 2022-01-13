function display(obj)
%RAWDATA_BIOHARNESSECG/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2009
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also rawData_BioHarnessECG, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
%Inherited
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Description: ' get(obj,'Description')]);
disp(['   date: ' get(obj,'Date')]);

%Measurement Information
disp(['   Start Time: ' datestr(obj.startTime,'dd-mmm-yyyy HH:MM:SS.FFF')]);
disp(['   Sampling Rate[Hz]: ' num2str(obj.samplingRate)]);
%Data
disp(['   Data Size: ' num2str(size(obj.data,1))]);

disp(' ');

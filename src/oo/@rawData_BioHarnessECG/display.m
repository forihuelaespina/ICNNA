function display(obj)
%RAWDATA_BIOHARNESSECG/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2009-24
% @author Felipe Orihuela-Espina
%
% See also rawData_BioHarnessECG, get, set
%



%% Log:
%
% File created: 19-Jan-2009
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 12-Apr-2024: FOE
%   + Log started. Got rid of old label @date.
%   + Started to update calls to get attributes using the struct like syntax
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
%Inherited
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   date: ' obj.date]);

%Measurement Information
disp(['   Start Time: ' datestr(obj.startTime,'dd-mmm-yyyy HH:MM:SS.FFF')]);
disp(['   Sampling Rate[Hz]: ' num2str(obj.samplingRate)]);
%Data
disp(['   Data Size: ' num2str(size(obj.data,1))]);

disp(' ');

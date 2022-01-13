function display(obj)
%RAWDATA_SHIMADZULABNIRS/DISPLAY Command window display of a
%rawData_ShimadzuLabnirs
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
%
% See also rawData_ShimadzuLabnirs, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
%Inherited
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Description: ' get(obj,'Description')]);
disp(['   Date (Reference for timestamps): ' datestr(get(obj,'Date'),0)]);

%Measurement Information
disp(['   Total Number of Channels: ' num2str(get(obj,'nChannels'))]);
disp(['   Wavelengths [nm]: ' num2str(obj.wLengths)]);
disp(['   Sampling Rate [Hz]: ' num2str(get(obj,'SamplingRate'))]);

%Data
disp(['   Data Size (nSamples x nChannels): ' ...
       num2str(get(obj,'nSamples')) 'x' num2str(get(obj,'nChannels')) ]);



disp(['   PreTimeline: ' num2str(length(obj.preTimeline)) ' samples.']);
idx=find(obj.preTimeline~=0);
nEvents=length(idx);
for ee=1:nEvents
    disp(['      Event #' num2str(ee) ': '...
            ' Sample: ' num2str(idx(ee)) ', ' ...
            ' Code: ' num2str(obj.preTimeline(idx(ee)))]);
end

disp(' ');

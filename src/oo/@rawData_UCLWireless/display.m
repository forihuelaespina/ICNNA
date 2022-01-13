function display(obj)
%RAWDATA_UCLWIRELESS/DISPLAY Command window display of a
%rawData_UCLWireless
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2012-2016
% Copyright 2016
% @date: 1-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 1-Sep-2016
%
% See also rawData_UCLWireless, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
%Inherited
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Description: ' get(obj,'Description')]);
disp(['   Date (Reference for timestamps): ' datestr(get(obj,'Date'),0)]);

%Measurement Information
disp(['   Total Number of Channels: ' ]);
disp(['   Wavelengths [nm]: ' num2str(obj.wLengths)]);
disp(['   Sampling Rate [Hz]: ' num2str(get(obj,'SamplingRate'))]);

%Data
disp(['   Data Size (nSamples x nChannels): ' ...
       num2str(get(obj,'nSamples')) 'x' num2str(get(obj,'nChannels')) ]);



disp(['   PreTimeline: No. Events:' num2str(length(obj.preTimeline))]);
nEvents=length(obj.preTimeline);
for ee=1:nEvents
    eventInfo=obj.preTimeline(ee);
    disp(['      Event #' num2str(ee) ': '...
            ' Label: ' eventInfo.label ', ' ...
            ' Code: ' num2str(eventInfo.code) ', ' ...
            ' Onset: ' num2str(eventInfo.starttime) ', ' ...
            ' End: ' num2str(eventInfo.endtime) ]);
end



disp(' ');

function display(obj)
%RAWDATA_LSL/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2021
% @date: 23-Aug-2021
% @author: Felipe Orihuela-Espina
%
% See also rawData_LSL, get, set
%



%% Log
%
% 23-Aug-2021 (FOE): 
%	File created.
%



disp(' ');
disp([inputname(1),'= ']);
disp(' ');
%Inherited
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Description: ' get(obj,'Description')]);
disp(['   date: ' get(obj,'Date')]);


%Data
nStreams = length(obj.data);
disp(['   Num. Data Streams detected: ' num2str(nStreams)]);
disp(' ');
for iStr = 1:nStreams
    theStream = getStream(obj,iStr);
    
    disp(['   == Data Stream ' num2str(iStr) ' =================== ' ]);
    disp(theStream.info);
    tmpSize = size(theStream.time_series);
    disp(['     time_series: ' num2str(tmpSize(1)) ...
                   ' ch. x ' num2str(tmpSize(2)) 'samples']);
    tmpSize = size(theStream.time_stamps);
    disp(['     time_stamps: 1x' num2str(tmpSize(2)) 'samples']);
    disp(' ');
               
end
disp(' ');
end
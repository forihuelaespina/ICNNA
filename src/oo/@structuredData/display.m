function display(obj)
%STRUCTUREDDATA/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also structuredData
%


%% Log
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): N/A This method was
%   never updated since creation
%
% 13-May-2023: FOE
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
    disp(['   Class version: N/A']);
end
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   Num. Samples: ' num2str(obj.nSamples)]);
disp(['   Num. Channels: ' num2str(obj.nChannels)]);
%watch out!! Size will return 1 in the third dimension if data is empty
%see MATLAB's help on size for more info.
if (isempty(obj.data))
    disp('   Num. Signals: 0');
else
    disp(['   Num. Signals: ' num2str(obj.nSignals)]);
    for tt=1:length(obj.signalTags)
        disp(obj.signalTags{tt});
    end
end
%disp(['   Data: ']);
%disp(obj.data);
disp('   Timeline: ');
t=timeline(obj.timeline);
display(t);
disp('   Integrity: ');
disp(['     ' mat2str(double(obj.integrity))]);
disp(' ');

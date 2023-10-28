function display(obj)
%NIRS_NEUROIMAGE/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-12
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also nirs_neuroimage, get, set
%


%% Log
%
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): 22-Dec-2012
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
%disp(['   Probe Mode: ' obj.probeMode]); %DEPRECATED
disp(['   Num. Samples: ' num2str(obj.nSamples)]);
disp(['   Num. Channels: ' num2str(obj.nChannels)]);
disp(['   Num. Signals: ' num2str(obj.nSignals)]);
if (obj.nSignals~=0)
    signalTags=obj.signalTags;
    for tt=1:length(signalTags)
        disp(['    ' signalTags{tt}]);
    end
end
disp('   Timeline: ');
display(obj.timeline);
disp(' ');
disp('   Integrity: ');
disp(['     ' mat2str(double(obj.integrity))]);
disp('   Channel Location Map: ');
display(obj.chLocationMap);
disp(' ');
disp(' ');


end

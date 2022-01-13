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

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Description: ' get(obj,'Description')]);
%disp(['   Probe Mode: ' get(obj,'ProbeMode')]); %DEPRECATED
disp(['   Num. Samples: ' num2str(get(obj,'NSamples'))]);
disp(['   Num. Channels: ' num2str(get(obj,'NChannels'))]);
disp(['   Num. Signals: ' num2str(get(obj,'NSignals'))]);
if (get(obj,'NSignals')~=0)
    signalTags=get(obj,'SignalTags');
    for tt=1:length(signalTags)
        disp(['    ' signalTags{tt}]);
    end
end
disp('   Timeline: ');
display(get(obj,'Timeline'));
disp(' ');
disp('   Integrity: ');
disp(['     ' mat2str(double(get(obj,'Integrity')))]);
disp('   Channel Location Map: ');
display(get(obj,'ChannelLocationMap'));
disp(' ');
disp(' ');

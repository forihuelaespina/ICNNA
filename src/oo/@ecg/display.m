function display(obj)
%ECG/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2009
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also ecg, get, set
%

%% Log:
%
% 29-May-2019: FOE:
%   + Log started
%   + Added support for property rPeaksAlgo
%


disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Description: ' get(obj,'Description')]);
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
t=get(obj,'Timeline');
display(t);
disp('   Integrity: ');
disp(['     ' mat2str(double(get(obj,'Integrity')))]);

%Measurement Information
disp(['   Start Time: ' datestr(obj.startTime,'dd-mmm-yyyy HH:MM:SS.FFF')]);
disp(['   Sampling Rate[Hz]: ' num2str(obj.samplingRate)]);
disp(['   R Peaks Mode: ' get(obj,'RPeaksMode')]);
disp(['   R Peaks Algorithm: ' get(obj,'RPeaksAlgo')]);
disp(['   R Peaks Threshold: ' num2str(get(obj,'Threshold'))]);
if strcmp(get(obj,'RPeaksMode'),'auto')
    tmpRPeaks=get(obj,'RPeaks');
    disp(['   R Peaks: ' num2str(length(tmpRPeaks)) ' peaks']);
    disp(['   Avg. RR peaks interval: ' ...
       num2str(mean(tmpRPeaks(2:end)-tmpRPeaks(1:end-1))) ' samples']);
end

disp(' ');

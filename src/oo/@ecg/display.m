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
% File created: 19-Jan-2009
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 29-May-2019: FOE:
%   + Log started
%   + Added support for property rPeaksAlgo
%
% 12-Apr-2024: FOE
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
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   Num. Samples: ' num2str(obj.nSamples)]);
disp(['   Num. Channels: ' num2str(obj.nChannels')]);
disp(['   Num. Signals: ' num2str(obj.nSignals)]);
if (obj.nSignals~=0)
    signalTags = obj.signalTags;
    for tt=1:length(signalTags)
        disp(['    ' signalTags{tt}]);
    end
end
disp('   Timeline: ');
t=obj.timeline;
display(t);
disp('   Integrity: ');
disp(['     ' mat2str(double(obj.integrity))]);

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



end
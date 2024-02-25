function display(obj)
%RAWDATA_ETG4000/DISPLAY Command window display of a rawData_ETG4000
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also rawData_ETG4000, get, set
%


%% Log
%
% File created: 13-May-2008
% File last modified (before creation of this log): 4-Jan-2013
%
% 3-Dec-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%   + Now also displays new attribute classVersion
%


disp(' ');
disp([inputname(1),'= ']);
disp(' ');
%Inherited
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   Date (Reference for timestamps): ' datestr(obj.date,0)]);

disp(['   File Version: ' obj.fileVersion]);
%Patient Information
disp(['   User Name: ' obj.userName]);
tmpBirthDate=datestr(obj.userBirthDate,24);
if isempty(tmpBirthDate)
    disp('   User Birth Date: ');
else
    disp(['   User Birth Date: ' tmpBirthDate]);
end
disp(['   User Age: ' num2str(obj.userAge)]);
disp(['   User Sex: ' obj.userSex]);

%Analysis Information
disp(['   Analyze Mode: ' obj.analyzeMode]);
disp(['   Pre Time [s]: ' num2str(obj.preTime)]);
disp(['   Post Time [s]: ' num2str(obj.postTime)]);
disp(['   Recovery Time [s]: ' num2str(obj.recoveryTime)]);
disp(['   Base Time [s]: ' num2str(obj.baseTime)]);
disp(['   Fitting degree: ' num2str(obj.fittingDegree)]);
disp(['   HPF [Hz]: ' obj.hpf]);
disp(['   LPF [Hz]: ' obj.lpf]);
disp(['   Moving Average [s]: ' num2str(obj.movingAvg)]);

%Measurement Information
disp(['   Number of Probes: ' num2str(length(obj.probesetInfo))]);
nProbes=length(obj.probesetInfo);
for ps=1:nProbes
    pRead=obj.probesetInfo(ps).read;
    pType=obj.probesetInfo(ps).type;
    pMode=obj.probesetInfo(ps).mode;
    switch (pMode)
        case '3x3'
            nCh =24;
        case '4x4'
            nCh =24;
        case '3x5'
            nCh =22;
        otherwise
            error('ICNA:rawData_ETG4000:display:UnexpectedProbeMode',...
                  'Unexpected probe mode.');
    end
    
    if pRead==1
        disp(['      Probe #' num2str(ps) ': '...
            ' Type: ' pType ', ' ...
            ' Mode: ' pMode ' (' num2str(nCh) ' channels)']);
    else %pRead==0 %Not read
        disp(['      Probe #' num2str(ps) ': N/A']);
    end
end
disp(['   Total Number of Channels: ' num2str(obj.nChannels)]);
disp(['   Wavelengths [nm]: ' num2str(obj.wLengths)]);
disp(['   Sampling Period [s]: ' num2str(obj.samplingPeriod)]);
disp(['   Repeat Count: ' num2str(obj.repeatCount)]);

%Data
disp(['   Data Size: ' num2str(size(obj.lightRawData))]);

%Unreported properties:
% + marks
% + timestamps
% + bodyMovement
% + removalMarks
% + preScan


disp(' ');


end

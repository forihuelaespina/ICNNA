function display(obj)
%RAWDATA_ETG4000/DISPLAY Command window display of a rawData_ETG4000
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-13
% @date: 13-May-2008
% @author Felipe Orihuela-Espina
% @modified: 4-Jan-2013
%
% See also rawData_ETG4000, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
%Inherited
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Description: ' get(obj,'Description')]);
disp(['   Date (Reference for timestamps): ' datestr(get(obj,'Date'),0)]);

disp(['   File Version: ' get(obj,'FileVersion')]);
%Patient Information
disp(['   User Name: ' get(obj,'SubjectName')]);
tmpBirthDate=datestr(get(obj,'SubjectBirthDate'),24);
if isempty(tmpBirthDate)
    disp('   User Birth Date: ');
else
    disp(['   User Birth Date: ' tmpBirthDate]);
end
disp(['   User Age: ' num2str(get(obj,'SubjectAge'))]);
disp(['   User Sex: ' get(obj,'SubjectSex')]);

%Analysis Information
disp(['   Analyze Mode: ' get(obj,'AnalyzeMode')]);
disp(['   Pre Time [s]: ' num2str(get(obj,'PreTime'))]);
disp(['   Post Time [s]: ' num2str(get(obj,'PostTime'))]);
disp(['   Recovery Time [s]: ' num2str(get(obj,'RecoveryTime'))]);
disp(['   Base Time [s]: ' num2str(get(obj,'BaseTime'))]);
disp(['   Fitting degree: ' num2str(get(obj,'FittingDegree'))]);
disp(['   HPF [Hz]: ' get(obj,'HPF')]);
disp(['   LPF [Hz]: ' get(obj,'LPF')]);
disp(['   Moving Average [s]: ' num2str(get(obj,'MovingAverage'))]);

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
disp(['   Total Number of Channels: ' num2str(get(obj,'nChannels'))]);
disp(['   Wavelengths [nm]: ' num2str(obj.wLengths)]);
disp(['   Sampling Period [s]: ' num2str(get(obj,'SamplingPeriod'))]);
disp(['   Repeat Count: ' num2str(get(obj,'RepeatCount'))]);

%Data
disp(['   Data Size: ' num2str(size(obj.lightRawData))]);

%Unreported properties:
% + marks
% + timestamps
% + bodyMovement
% + removalMarks
% + preScan


disp(' ');

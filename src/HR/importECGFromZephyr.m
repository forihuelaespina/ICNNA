function [ecg,absStarttime]=importECGFromZephyr(filename)
%Reads an ECG data file as exported from the Zephyr bio harness
%
% ecg=importECGFromZephyr(filename)
%
%Reads an ECG (electrocardiogram) data file as exported from
%the Zephyr bio harness
%
%
%% Parameter
%
% filename - Source filename including the directory
%
%% Output
%
% ecg - The raw electrocardiogram signal (2nd col) with the relative timestamps
%in miliseconds (1st col).
%
% absStarttime - A time vector [Year Month Day Hour Min Sec Milisec]
%   representing the starting time of the data collection. Time
%   at which the first sample is collected.
%
%
%
%
% Copyright 2008
% Author: Felipe Orihuela-Espina
% Date: 25-Nov-2008
%
% See also getRtoR
%

% Open the data file for conversion
fidr = fopen(filename, 'r');
if fidr == -1
    error('Unable to read %s\n', filename);
end


% h = waitbar(0,'Reading header',...
%     'Name','Importing raw ECG (Zephyr BioHarness)');

%% Reading the header ================================
fgetl(fidr); %Ignore empty line
fgetl(fidr); %Ignore column description...

%% Reading the data ================================
temp=fscanf(fidr,'%d/%d/%d %d:%d:%f, %d,',Inf)';
 %Year/Month/Day Hour:Min:Sec.Milisec, ECGValue
fclose(fidr);

temp=reshape(temp,7,numel(temp)/7)';
%datenumFuncOffset=100000; %Just to compensate for MATLAB
                        %silly way of dealing with times
timestamps=datenum(temp(:,1:end-1));

relTimestamps=timestamps-timestamps(1);

%Now reconvert those silly serial date number into proper time units (ms)
relTimestamps=datevec(relTimestamps);
relTimeVectors=dateVectorsToMilliseconds(relTimestamps); %see below
relTimeVectors=round(relTimeVectors);

%Compute the outputs
ecg=[relTimeVectors temp(:,end)];
absStarttime=temp(1,1:end-1);


end


function res=dateVectorsToMilliseconds(data)
%Converts a set of datevector to milliseconds
%
%data is a nx6 set of date vectors
%
%See MATLAB function datevec
%
daysPerMonth=[31 28 31 30 31 30 31 31 30 31 30 31];
cumDaysPerMonth=data(:,2);
for mm=1:12
    cumDaysPerMonth(data(:,2)==mm)=sum(daysPerMonth(1:mm-1));
end

res=data(:,6) ...
        + 60*data(:,5) ...
        + 3600*data(:,4) ...
        + 86400*data(:,3) ...
        + 86400*(cumDaysPerMonth.*data(:,2)) ...
        + 86400*365.255*data(:,1);
res=res*1000; %from secs to ms
end

function obj=import(obj,filename)
%RAWDATA_BIOHARNESSECG/IMPORT Reads the raw ECG 
%
% obj=import(obj,filename) Reads the ECG recorded in
%   a .csv file produced by the Zephyr BioHarness system.
%
% The Zephyr BioHarness ECG data file is a plain text file with
%two columns:
%   * Timestamp, and
%   * ECG - Raw Data
% 
%% Remarks
%
% No effort is currently made in checking whether the file is
% an original Zephyr BioHarness ECG data file. This is simply assumed
% to be true.
%
%% Parameters
%
% filename - The Zephyr BioHarness ECG data file to import
%
% 
% Copyright 2009
% date: 19-Jan-2009
% Author: Felipe Orihuela-Espina
%
% See also convert
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

%%======================================
%Unnecessary; The timestamps are now generated based on the samplingRate
%Nevertheless; kept just in case...
%%======================================
% %datenumFuncOffset=100000; %Just to compensate for MATLAB
%                        %silly way of dealing with times
%timestamps=datenum(temp(:,1:end-1));
%
%relTimeVectors=timestamps-timestamps(1);
%
% %Now reconvert those silly serial date number into proper time units (ms)
%relTimeVectors=datevec(relTimeVectors);
%relTimestamps=dateVectorsToMilliseconds(relTimeVectors); %see below
%%======================================

rawEcg=temp(:,end);
absStartTime=temp(1,1:end-1);
absEndTime=temp(end,1:end-1); %Just for checking purposes

samplingRate=250; %Manually set the sampling rate to 250Hz
nSamples=length(rawEcg);
%Compute the relative timestamps
relTimestamps=getTimestamps(nSamples,samplingRate);
relTimestamps=round(relTimestamps);

%set the object fields
obj=set(obj,'SamplingRate',samplingRate);
obj=set(obj,'StartTime',absStartTime);
obj=set(obj,'Timestamps',relTimestamps);
obj=set(obj,'RawData',rawEcg);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AUXILIAR FUNCTIONS
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


function timestamps = getTimestamps(nSamples,sr)
%Generate the timestamps
% nSamples - Number of data samples
% sr - The sampling rate
    timestamps=(0+1/sr):(1/sr):(nSamples/sr);
    timestamps=timestamps'*1000; %to ms.
    timestamps=timestamps-timestamps(1);
end


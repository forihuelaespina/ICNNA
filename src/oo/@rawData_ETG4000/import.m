function obj=import(obj,filename)
%RAWDATA_ETG4000/IMPORT Reads the raw light intensities 
%
% obj=import(obj,filename) Reads the light intensities recorded in
%   a .csv file produced by the Hitachi ETG-4000 NIRS system.
%   Note that HITACHI uses one file per probes set. Thus, if you are
%   using more than one probes set (e.g. 48 channels), you will have to
%   call this method for each probes set.
%   This will overwrite any previous data in the corresponding probe set. 
%
%
%   +=================================================+
%   | NOTE: Header data will be overwritten everytime |
%   |you call this method. Although it should be      |
%   |expected that the header across different probes |
%   |sets ought to be the same. This is not currently |
%   |check.                                           |
%   +=================================================+
%
%
%
%
%% HITACHI ETG 4000 data file
%
% The HITACHI ETG4000 data file is a plain text file with two section:
%   * Header, and
%   * Data
% 
%   The header has 30+ lines (depending on the file version) each line
% holding one or more fields.
% Header section start with a line contaning the string 'Header'
% Fields are stored as:
%
%   fieldName,Value
%
%   Among the information stored in the header there is some user
% data (name, sex, age, ID, etc...), information about the wavelengths,
% the probe set mode (e.g. 3x3) and other data, filters used if any...
%
%   After the header, there are some blank lines, and then the data starts.
% Data section start with a line contaning the string 'Data'. The second
% line contains the probe set configuration, and importantly this contains
% the probe set number. And from the third line till the
% end of the file are the measurements. Each measurement line contains:
%
%   - a sample number,  (the sampling period is in the header)
%   - a nWavelengths*nChannels measurements
%           Note that each channel is measured at two different wavelengths
%   - Mark: Stimulus train marks if any.
%   - Time at wich the sample was taken in the format HH:MM:SS.CC
%   - Three more values containing information about BodyMovement,
%           RemovalMark and PreScan
%
%
%% Remarks
%
% Please note that the optode "effective" wavelengths at the different
% channels at which the optode is working might slightly differ from
% the "nominal" wavelengths. These effective wavelengths are also
% available at the Hitachi file, for each of the channels.
% However ICNA is not taking that into account at the moment, and I
% consider the nominal waveleghts to be the effective wavelengths.
%
% Currently the file is read by "brute force", reading line by line and
% discarding those of no interest. This is not very flexible, and if
% Hitachi does ever change its format, this function will not work
% properly. A more correct approach is to construct a proper parser, and
% parser the Hitachi output file. Unfortunately, I do not have the time to
% do this now...
%
% No effort is currently made in checking whether the file is
% an original HITACHI ETG-4000 data file. This is simply assumed
% to be true.
%
%% Parameters
%
% filename - The ETG-4000 data file to import
%
%
% 
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also rawData_ETG4000, convert
%



%% Log
%
% File created: 13-May-2008
% File last modified (before creation of this log): 28-Jul-2017
%
%
% 28-Jul-2017: FOE. Bug fixed. The findField method get cycled forever
%   if the field was not found.
%   + Added this log.
%
% 12-Oct-2013: A step back. The new code "forgot" how to read previous
%   versions of the HITACHI file. This has now been fixed, and different
%   file versions can be read.
%
% 3-Dec-2023 (FOE): Comments improved.
%   + Got rid of old labels @date and @modified.
%   + Started to use get/set methods for struct like access.
%   + Updated error codes to use 'ICNNA' instead of 'ICNA'
%





% Open the data file for conversion
fidr = fopen(filename, 'r');
if fidr == -1
    error('ICNNA:rawData_ETG4000:import:UnableToReadFile',...
          'Unable to read %s\n', filename);
end

% h = waitbar(0,'Reading header...',...
%     'Name','Importing raw data (ETG-4000)');
%fprintf('Importing raw data (ETG-4000) -> 0%%');

%% Reading the header ================================
temp=findField(fidr,'File Version');
tmpVersion=temp(find(temp==',')+1:end);
obj.fileVersion = tmpVersion;
    %Ignore fieldName and read the rest
%Ignore line ID

% Read Patient information
temp=findField(fidr,'Name');
obj.userName = temp(find(temp==',')+1:end);
    %Ignore fieldName and read the rest
    %Ignore line Comments
    
if version_IsHigherOrEqual(tmpVersion,'1.21')
    temp=findField(fidr,'Birth Date');
    obj.userBirthDate = datenum(temp(find(temp==',')+1:end));
    %Ignore fieldName and read the rest
else
    %Previous versions. Do nothing
end

temp=findField(fidr,'Age');
obj.userAge = str2double(temp(find(temp==',')+1:end-1));
        %Ignore fieldName and read the rest
        %ignoring the 'y' for years
temp=findField(fidr,'Sex');
obj.userSex = temp(find(temp==',')+1);
        %Ignore fieldName and read the first
        %character of the sex

%waitbar(0.05,h);
%fprintf('\b\b5%%');
                                    
% Read Analysis information
temp=findField(fidr,'AnalyzeMode');
obj.analyzeMode = temp(find(temp==',')+1:end);
temp=findField(fidr,'Pre Time[s]');
obj.preTime = str2double(temp(find(temp==',')+1:end));
temp=findField(fidr,'Post Time[s]');
obj.postTime = str2double(temp(find(temp==',')+1:end));
%waitbar(0.06,h);
%fprintf('\b\b6%%');
temp=findField(fidr,'Recovery Time[s]');
obj.recoveryTime = str2double(temp(find(temp==',')+1:end));
temp=findField(fidr,'Base Time[s]');
obj.baseTime = str2double(temp(find(temp==',')+1:end));
%waitbar(0.07,h);
%fprintf('\b\b7%%');
temp=findField(fidr,'Fitting Degree');
obj.fittingDegree = str2double(temp(find(temp==',')+1:end));
%waitbar(0.08,h);
%fprintf('\b\b8%%');
temp=findField(fidr,'HPF[Hz]');
obj.hpf = temp(find(temp==',')+1:end);
temp=findField(fidr,'LPF[Hz]');
obj.lpf = temp(find(temp==',')+1:end);
%waitbar(0.09,h);
%fprintf('\b\b9%%');
temp=findField(fidr,'Moving Average[s]');
obj.movingAvg = str2double(temp(find(temp==',')+1:end));

%waitbar(0.1,h);
%fprintf('\b\b10%%');

% Read Measurement information

% Get the probe mode and calculate the number of channels
temp=findField(fidr,'Date');
obj.date = temp(find(temp==',')+1:end); %Read Probe mode

if version_IsHigherOrEqual(tmpVersion,'1.21')
    temp=findField(fidr,'Probe Type');
    tmp_pInfo.type = lower(temp(find(temp==',')+1:end)); %Read Probe type
else
    %Previous versions. Set it to adult by default.
    tmp_pInfo.type = 'adult';
end

temp=findField(fidr,'Mode');
tmp_pInfo.mode = temp(find(temp==',')+1:end); %Read Probe mode
tmp_pInfo.read = 1;
%Estimate the channel capacity that will be needed
switch (tmp_pInfo.mode)
    case '3x3'
        tmp_nChannels = 24;
    case '4x4'
        tmp_nChannels = 24;
    case '3x5'
        tmp_nChannels = 22;
    otherwise
        error('ICNNA:rawData_ETG4000:import:UnexpectedProbeMode',...
             'Unexpected probe mode.');
end


%Get the wavelengths [nm] at which light is measured
temp = findField(fidr,'Wave[nm]'); %Read Nominal Wavelengths line
%%%The nominal wavelengths line has the following form:
%%%Wave[nm],w1,w2,...
%%%where wi are the different wavelengths at which light is measured
%%%So I need to split this line...
idx=find(temp==',');
wLengths=zeros(1,length(idx));
for wl=1:length(idx)-1
    wLengths(wl)=str2double(temp(idx(wl)+1:idx(wl+1))); %Read single wavelength
end
wLengths(end)=str2double(temp(idx(end)+1:end));%Read last wavelength
obj.wLengths = wLengths;
clear idx wLengths

%waitbar(0.12,h);
%fprintf('\b\b\b12%%');


temp = findField(fidr,'Wave Length'); %Read Effective Wavelengths line
%%%The effective wavelengths line has the following form:
%%%Wave Length,CH1(w1),CH1(w2),...,CH1(wl),CH2(w1),...,CHCC(wl)
%%%where wi are the different wavelengths at which light is measured
%%%and CHx are the different channels.
%%%So I need to split this line...
idx=find(temp==',');
effWLengths=zeros(tmp_nChannels,length(obj.wLengths));
for ch=1:tmp_nChannels
    for wl=1:length(obj.wLengths)
        pos=sub2ind([length(obj.wLengths) tmp_nChannels ],wl,ch);
        if(pos<length(idx))
            effWlengthString=temp(idx(pos):idx(pos+1));
        else
            effWlengthString=temp(idx(pos):end);
        end
        effWLengths(ch,wl)=getEffectiveWavelength(effWlengthString); %Read single wavelength
    end
end
clear idx

% Get the sampling period in [s] and the number of blocks
temp=findField(fidr,'Sampling Period[s]');
obj.samplingPeriod = str2double(temp(find(temp==',')+1:end));
temp=findField(fidr,'Repeat Count');
obj.repeatCount = str2double(temp(find(temp==',')+1:end));

%waitbar(0.14,h);
%fprintf('\b\b\b14%%');

%Ignore the rest of the header and finds the start of the Data section
while (~strcmp(temp,'Data'))
    temp = fgetl(fidr);
end

%x=0.15;
%waitbar(x,h,'Reading Data - 15%');
%fprintf('\b\b\b15%%');

%% Reading the Data ================================
%Probe number and channel headings
%Only interested in the probe number
temp=fgetl(fidr);
idx=find(temp==',');
tempProbeNumber=temp(1:idx(1)-1);
if strcmpi(tempProbeNumber(1:5),'Probe')
    tempProbeNumber=str2double(tempProbeNumber(6:end));
else
    error('ICNNA:rawData_ETG4000:import:MissingProbeSetNumber',...
          'Probe set number not found.');
end
%Update the probes set information. It may be necessary to
%initialize some intermediate probes sets information.
if tempProbeNumber > length(obj.probesetInfo)
    for pp=length(obj.probesetInfo)+1:tempProbeNumber
        obj.probesetInfo(pp).read=0;
        obj.probesetInfo(pp).type='adult';
        obj.probesetInfo(pp).mode='3x3';
        
    end
    
    %but also enlarge data structures
    
        %NOTE: In MATLAB, an assignment:
        %   + a=nan(0,0,0) leads to an empty array 0-by-0-by-0 with ndims 3
        %   + a=nan(0,n) leads to an empty array 0-by-n with ndims 2
        %   + a=nan(0,0,n) leads to an empty array 0-by-0-by-n with
        %           ndims 3, iff n~=1!!
        %but unfortunately
        %   + a=nan(0,0) leads to an empty array [] with ndims 2
        %   + a=nan(0,0,1) leads to an empty array [] with ndims 2
        
    
    if isempty(obj.lightRawData)
        %Do nothing; Wait until some data is available
        %Note that the solution analogous to the one used for the
        %other matrices below:
        %  obj.lightRawData(:,:,end+1:tempProbeNumber)=...
        %               nan(size(obj.lightRawData,1),...
        %                   size(obj.lightRawData,2),...
        %                   tempProbeNumber-size(obj.marks,3)));
        %...won't work here if tempProbeNumber happens to be 1 (i.e.
        %everytime the first probes set is imported!)

    else
        obj.lightRawData(:,:,end+1:tempProbeNumber)=nan;
    end
    %Note that the more obvious/simpler line:
    %
    %   obj.marks(:,end+1:tempProbeNumber)=nan;
    %
    %won't work properly if obj.marks is empty; as it will change
    %its size from 0-by-0 to 1-by-1 rather than 0-by-1
    obj.marks(:,end+1:tempProbeNumber)=...
        	nan(size(obj.marks,1),tempProbeNumber-size(obj.marks,2));
    obj.timestamps(:,end+1:tempProbeNumber)=...
        	nan(size(obj.timestamps,1),tempProbeNumber-size(obj.timestamps,2));
    obj.bodyMovement(:,end+1:tempProbeNumber)=...
        	nan(size(obj.bodyMovement,1),tempProbeNumber-size(obj.bodyMovement,2));
    obj.removalMarks(:,end+1:tempProbeNumber)=...
        	nan(size(obj.removalMarks,1),tempProbeNumber-size(obj.removalMarks,2));
    obj.preScan(:,end+1:tempProbeNumber)=...
        	nan(size(obj.preScan,1),tempProbeNumber-size(obj.preScan,2));
        
end

%fprintf('\b\b\b20%%');


%I can't call setProbeSetInfo as it might temporally violate the invariants.
%
%       obj=setProbeSetInfo(obj,tempProbeNumber,tmp_pInfo);
%
%Thus, I need to do this manually
tmp_pInfo = orderfields(tmp_pInfo, obj.probesetInfo(tempProbeNumber));
%Check fields
val=tmp_pInfo.read;
if (isscalar(val) && (val == 0 || val == 1))
    %Valid; do nothing
else
    error('ICNNA:rawData_ETG4000:import:InvalidFieldValue',...
        ['Field .read in probe set information record must be ' ...
        'either a 0 -not read-, or 1 -read.']);
end
val=tmp_pInfo.type;
if (ischar(val) && (strcmpi(val,'adult') ...
        || strcmpi(val,'neonates')))
    %This may temporarily introduced a bug
    %as I'm not sure what HITACHI uses for
    %other types of probes different from
    %the adult.
    %Valid; do nothing. Lower just for the sake of it
    tmp_pInfo.type=lower(tmp_pInfo.type);
else
    error('ICNNA:rawData_ETG4000:setProbesInfo:InvalidFieldValue',...
        ['Field .type in probe set information record must be ' ...
        'a recognized string (e.g. ''adult'').']);
end
val=tmp_pInfo.mode;
if isempty(val)
    tmp_pInfo.mode = '3x3'; %Switch for the default
elseif (ischar(val) && (strcmp(val,'3x3') ...
        || strcmp(val,'4x4') ...
        || strcmp(val,'3x5')))
    %Valid; do nothing
else
    error('ICNNA:rawData_ETG4000:setProbesInfo:InvalidFieldValue',...
        ['Field .mode in probe set information record must be ' ...
        'a recognized string (e.g. ''3x3'').']);
end

obj.probesetInfo(tempProbeNumber)=tmp_pInfo;

%fprintf('\b\b\b25%%');

%Now depending on the probe mode, it may be necessary to enlarge
%the channel capacity
nData=length(obj.wLengths)*tmp_nChannels;
if size(obj.lightRawData,2)<nData
    if isempty(obj.lightRawData)
        %Do nothing; Wait until some data is available
    else
        obj.lightRawData(:,end+1:nData,:)=nan;
    end
end

%fprintf('\b\b\b30%%');


%Read all the data at once
%Prepare the reading format string
tmpFormatStr='%f,'; %This first one goes for the frame number
for ii=1:nData
    tmpFormatStr=[tmpFormatStr '%f,'];
end
tmpFormatStr=[tmpFormatStr '%d,']; %For reading the stimulus mark
tmpFormatStr=[tmpFormatStr '%d:%d:%f,']; %For reading the timings
tmpFormatStr=[tmpFormatStr '%d,%d,%d\n']; %For reading the bodyMovement,
                                        %removalMarks and preScan

%Now tmpFormatStr should be able to read 1 line at once; so read
%the whole stuff
temp=fscanf(fidr, tmpFormatStr,inf);

%fprintf('\b\b\b60%%');


%Now reshape
nCols=1+nData+1+3+3;
temp=reshape(temp,nCols,length(temp)/nCols)';
%Now separate the data into each part
temp(:,1)=[]; %Ignore the frame number
obj.lightRawData(1:size(temp,1),1:nData,tempProbeNumber) = temp(:,1:nData);
temp(:,1:nData)=[];
obj.marks(1:size(temp,1),tempProbeNumber) = temp(:,1);
temp(:,1)=[];
tmpTimes = temp(:,1:3)'; %The timings still require
                         %some additional processing
                         %(see below)
temp(:,1:3)=[];
obj.bodyMovement(1:size(temp,1),tempProbeNumber) = temp(:,1);
temp(:,1)=[];
obj.removalMarks(1:size(temp,1),tempProbeNumber) = temp(:,1);
temp(:,1)=[];
obj.preScan(1:size(temp,1),tempProbeNumber) = temp(:,1);
temp(:,1)=[];

%fprintf('\b\b\b80%%');


%Convert times to relative to the date field.
startTime = datevec(obj.date)';
%assume same day
nSamples = size(tmpTimes,2);
tmpTimes= [repmat(startTime(1:3),1,nSamples); tmpTimes];
startTime = datenum(obj.date); %Express as a datenum now
tmpTimes= datevec(datenum(tmpTimes')' - startTime)';
%to seconds
tmpTimestamps = (tmpTimes(3,:)*(24*3600) ...
               + tmpTimes(4,:)*3600 + tmpTimes(5,:)*60 + tmpTimes(6,:));
           %Don't need to check years and months...
obj.timestamps(1:length(tmpTimestamps),tempProbeNumber) = tmpTimestamps';          

fclose(fidr);
%waitbar(1,h);
%close(h);
%fprintf('\b\b\b100%%\n');

assertInvariants(obj);



%%=============================================================
%%Auxiliar functions
%%=============================================================
function fieldName = getFieldName(lineString)
%Extract the field name
idx=find(lineString==',');
if (isempty(idx))
    fieldName='';
else
    fieldName=lineString(1:idx(1)-1);
end
end

function [lineString]=findField(fidr,fieldName)
%Finds the line containing the field specified
temp='';
lineString='';
while (ischar(lineString) && ~strcmpi(temp,fieldName))
        %Note: ischar(lineString) tests for end-of-file as indicated in
        %Matlab's help for the fgetl function and the help page on
        %"Testing for EOF with fgetl and fgets"
    lineString = fgetl(fidr);
    temp=getFieldName(lineString);
end
end

function [effWL]=getEffectiveWavelength(effWLstring)
%Extract the effective wavelength from a string 'CHXX(wl)'
idx1=find(effWLstring=='(');
idx2=find(effWLstring==')');
effWL=str2double(effWLstring(idx1(1)+1:idx2(1)-1));
end

end
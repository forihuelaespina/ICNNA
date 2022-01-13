function obj=import(obj,filename)
%RAWDATA_NIRScout/IMPORT Reads the raw light intensities 
%
% obj=import(obj,filename) Reads the light intensities recorded in
%   a .csv file produced by the NIRx NIRScout NIRS family systems.
%
%
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
%
%% Input file(s) structure
%
% The NIRScout capture all data using the software NIRStar and detailed
%information is available in the NIRStar User Manual. The following has
%been extractted from the user manual for the software version 14.1
%
%
% In any measurement performed with a NIRx imager system (NIRScout,
%NIRSport, or DYNOT), the following files are produced:
%
%    filename.hdr           [Information about the device, imaging
%                               parameters, (experimental?) paradigm,
%                               gain, experiment notes, events markers,
%                               source-detector couplings, and interoptode
%                               distances.]
%(-) filename.set           [gain-settings table]
%(-) filename.evt           [event records (triggers)]
%(-) filename.tpl           [topo layout]
%(-) filename_config.txt	[information regarding experimental configuration]
%    filename.wl1           [detector readings for wavelength 1 (760 nm)]
%    filename.wl2           [detector reading for wavelength 2 (830nm, or 850 nm)]
%    filename_probeInfo.mat	[anatomical locations of sources and
%                               detectors and channel locations (this information is only
%                               available starting from NIRStar version 14.1)]
%    filename.inf           [subject related information, as specified in
%                               NIRStar (this information is available
%                               starting from NIRStar 14.0)]
%
%
% (-) The files filename.set, filename.evt, filename_config.txt generated
%for each measurement contain mostly information that is redundant
%with entries in the .hdr file. These files are generated to maintain
%compatibility with other NIRx products.
%
% By default, the NIRStar software organizes and names files
%automatically, using to the date and time of acquisition to define
%the target directory name and the common root of the file names. For
%each experiment, the different files indicated above are generated,
%all of which have identical filenames consisting of a prefix, a date
%identifier, and the running number of experiments recorded on that
%day. For instance:
%
%   prefix-yyyy-mm-dd_xxx.wl1
%
% The prefix is 'NIRS' by default, but the user can specify a
%different prefix.
%
% Most of the files are saved in text (ASCII) format, apart *.nirs
%and *_probeInfo.mat, which are saved in Matlab format. 
%
%
%
%% The header file
%
% (From the NIRStar v14.1 User manual, pg 68-71)
%
%
% The file is structured into sections identified by a [section header]
%containing variables ('keywords'), to which parameter values are
%assigned according to a 'keyword=value' scheme.
% The following explains the header file sections using exemplary values.
%
% General: Contains general information about the time and date of
%   data recording, and the filename. The section looks like this:
%
%   [GeneralInfo]
%   FileName="NIRS-2012-02-16_004" Filename as defined above in Section 6.3
%   Date="Do, 16. Feb 2012" Date of recording
%   Time="15:54" Start time of measurement
%   Device="NIRScout 16x24" System type in use
%   Source=”LED” Type of source used (LED or Laser)
%   Mod=”Human Subject” Modulation amplitude according to study type
%   NIRStar=”14.1” NIRStar version used to record the dataset
%   Subject=1 Subject index
%
%
% Imaging Setup Parameters: Lists instrument setup parameters employed
%   for the measurement, such as the number of sources, number of
%   detectors, and trigger channels employed in the measurement. The
%   section looks like this:
%
%   [ImagingParameters]
%   Sources=16 No. of source steps in measurement
%   Detectors=16 No. of detector channels
%   Steps = 16 No. of steps (illumination pattern)
%   Wavelengths=”760 850” Wavelengths used for the measurement
%   TrigIns=4 No. of trigger inputs
%   TrigOuts=0 No. of trigger outputs (only available for NIRScoutX)
%   AnIns=0 No. of auxiliary analog inputs (future option)
%   SamplingRate=3.906250 Sampling rate in Hz
%   Mod Amp="0.40 0.40" Modulation amplitude used for illumination
%   Threshold=”0.00 0.00” Modulation threshold used (?0 only for Laser)
%
% Paradigm Information: Records details about the experimental paradigm. The
%   section looks like this:
%
%   [Paradigm]
%   StimulusType=None Specifies paradigm (future option)
%
% Experimental Notes: Notes entered into the notes editor of the user
%   interface are saved here. The section looks like this:
%
%   [ExperimentNotes]
%   Notes="[Type notes here]"
%
% Gain Settings: The gain settings used in the measurement are
%   recorded in a matrix. The gain for channel Si-Dj is found in the
%   ith row and jth column (counting from the upper left). Valid gains
%   for neighboring source-detector-pairs usually are in the range
%   of 4...7 for adults, depending on head size, hair density/color,
%   and measurement site. A gain value of ‘8’ indicates that too
%   little or no light was received for this particular pairing.
%   The gain values range from 0 (gain factor 100 = 1) through 8
%   (gain factor 108). The hash symbols '#' are used to identify
%   the beginning and end of the table.
%   The section looks like this:
%   
%   [GainSettings]
%   Gains=#
%   5 8 5 5 8 8 8 8 8 8 8 8 8 8 8 8
%   4 4 5 8 8 8 8 8 8 8 8 8 8 8 8 8
%   8 8 6 6 6 6 8 8 8 8 8 8 8 8 8 8
%   8 8 8 5 8 6 5 8 8 8 8 8 8 8 8 8
%   8 5 5 8 6 8 8 8 8 8 8 8 8 8 8 8
%   8 8 8 8 8 6 5 5 8 8 8 8 8 8 8 8
%   8 8 8 8 6 6 8 6 8 8 8 8 8 8 8 8
%   8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8
%   8 8 8 8 8 8 8 8 8 5 6 8 5 8 8 8
%   8 8 8 8 8 8 8 8 4 4 5 8 8 8 8 8
%   8 8 8 8 8 8 8 8 8 8 6 6 6 6 8 8
%   8 8 8 8 8 8 8 8 8 8 8 8 6 6 8 6
%   8 8 8 8 8 8 8 8 5 8 5 6 8 8 8 8
%   8 8 8 8 8 8 8 8 8 8 8 8 8 6 5 5
%   8 8 8 8 8 8 8 8 8 8 8 5 8 6 6 8
%   8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8
%   #
%
% 
% Event Trigger Markers: Records the event markers received by the
%   digital trigger inputs, with time stamp and frame number. Each event
%   contains 3 numbers;
%       Column 1: Time (in seconds) of trigger event after the scan
%           started.
%       Column 2: Trigger channel identifier, or condition marker.
%           Triggers received on each digital input DIx (where x denotes
%           the trigger channel) on the front panel are encoded as numbers
%           2DI(x-1), e.g. DI1, DI2, and DI3 are encoded as 1, 2, and 8,
%           respectively. The file stores the sum of simultaneously
%           triggered inputs in decimal representation. By using
%           combinations of trigger inputs, as many as 15 conditions
%           can be encoded by NIRScout and NIRSport systems, while
%           NIRScoutX receives up to 255 conditions (8 inputs).
%       Column 3: The number of the scan frame during which the
%           trigger event was received.
%   The hash symbols '#' are used to identify the beginning and end
%   of the table. The section looks like this:
%   
%   [Markers]
%   Events=#
%   86.40 1 300 e.g. Trigger of input 1 recorded after 1.80 s, during frame no. 12
%   116.40 2 404
%   146.40 1 508
%   ... ... ...
%   476.39 2 1654
%   #
%
% Data Structure: This section records the arrangement of detector
%   channels in the .wl1 and .wl2 files, and the channel masking pattern.
%       + 'S-D-Key' (source-detector key) denotes the order in which
%           the columns of the data files (*.wl1, *.wl2) are assigned
%           to source-detector combinations. Each channel is denoted by
%           the source number, a minus sign ('-') and the detector number.
%           The channel pair is followed by a colon (:) and the
%           corresponding column index in the optical data files. The
%           column index is followed by a comma (',') and the next
%           channel. This variable may be read to generate a table
%           header for the data files.
%       + 'S-D-Mask' stores the masking pattern in a table (for channel
%           masking, see Section 5.5). Channels that are set not to be
%           displayed are identified by '0's, while channels set to be
%           displayed are labeled with '1's. Counting from the upper left,
%           the column number corresponds to the detector channel, and
%           the row number corresponds to the source position. The example
%           below shows a 4-source/4-detector measurement, in which all
%           channels are displayed except for source 2 / detector 3.
%   The hash symbols '#' are used to identify the beginning and end
%   of the table. The section looks like this:
%
%   [DataStructure]
%   S-D-Key="1-1:1,1-2:2,1-3:3,1-4:4,1-5:5,1-6:6,1-7:7,1-8:8,1-9:9,1-10:10,
%   ...
%   S-D-Mask=#
%   1 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0
%   1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0
%   0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0
%   0 0 0 1 0 1 1 0 0 0 0 0 0 0 0 0
%   ...
%   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
%   #"
%     
% Channels Distance: The channel distance values entered in the
%   Hardware Configuration and used for the Beer-Lambert Law calculations
%   during a scan are recorded here. The order corresponds to the order
%   of the channel list in one of the software dialogs. This maybe an
%   issue as I do not have access to that info when reading the data.
%   The section looks like this:
%
%   [ChannelsDistance]
%   ChanDis="30.0 30.0 30.0 30.0 30.0 30.0 30.0 30.0 30.0 30.0
%               30.0 30.0 30.0 30.0 30.0 30.0 30.0 30.0 30.0 30.0”
%
%
%
%% The optical data files (.wl1/.wl2)
%
% (From the NIRStar v14.1 User manual, pg 67)
%
%   Si: ith source;
%   Dj: jth detector;
%   tk: kth scan, or time frame of measurement.
%   Si-Dj(tk): reading at the jth detector, of light emitted by
%       the ith source, during the kth scan.
%
% Structure of the optical data files *.wl1, *wl2.
%
%
% S1-D1(t1) S1-D2(t1) … S1-Dmax(t1) S2-D1(t1) … S2-Dmax(t1) S3-D1(t1) … Smax-Dmax(t1)
% S1-D1(t2) S1-D2(t2) … S1-Dmax(t2) S2-D1(t2) … S2-Dmax(t2) S3-D1(t2) … Smax-Dmax(t2)
% … … … … … … … … … …
% S1-D1(tmax) S1-D2(tmax) … S1-Dmax(tmax) S2-D1(tmax) … S2-Dmax(tmax) S3-D1(tmax) … Smax-Dmax(tmax)
%
% The number of columns in the file equals (number of sources x number of
%detectors): Smax x Dmax.
%
% To extract a desired data channel Si-Dj from the file, use the following
%formula to identify the appropriate column n:
%
%   n = (Si-1)x Dmax + Dj
%
%% Remarks
%
% Please note that the optode "effective" wavelengths at the different
% channels at which the optode is working might slightly differ from
% the "nominal" wavelengths. I have not found where does NIRStar save
% the effective wavelengths for each of channel. Anyway, 
% ICNNA is not taking that into account at the moment, and I
% consider the nominal waveleghts to be the effective wavelengths.
%
% Currently the file is read by "brute force", reading line by line and
% discarding those of no interest. This is not very flexible, and if
% Hitachi does ever change its format, this function will not work
% properly. A more correct approach is to construct a proper parser, and
% parser the input files. Unfortunately, I do not have the time to
% do this now...
%
% No effort is currently made in checking whether the file is
% an original NIRx NIRScout data file. This is simply assumed
% to be true.
%
%% Parameters
%
% filename - The NIRScout data file to import (.hdr or any of the valid
%       files *.wl* , *.evt, *.set, _config.txt or _probeInfo.mat).
%       Wherever the file is, it is assumed that at least the .hdr and
%       the .wl* files are also present in the same directory and with
%       the same filename (only changing the extension)!.
%
% 
% Copyright 2018
% @author: Felipe Orihuela-Espina
%
% See also rawData_NIRScout, convert
%



%% Log
%
% 4/25-Apr-2018: FOE. Method created
%
% 17-May-2018: FOE. Bug fixed. Subject gender may sometimes come empty.
%   Now it is assigned an ('U')ndefined value.
%
% 26-Apr-2019: FOE.
%   Bug fixed. Detected by Samuel Montero. Error while reading
%   dates and times in auxiliar functions @myTimeStr2DateTime and
%   @myDateStr2DateTime.
%   It was assumed that the date was entered in the langague set
%   in the OS, and that string do not have tildes.
%



%Check filename to decode the source directory and file extension
[srcDir,theFilename,~] = fileparts(filename);




%% Deal with the header .hdr file
hdr_filename = [srcDir '/' theFilename '.hdr'];

% Open the data file for conversion
fidr = fopen(hdr_filename, 'r');
if fidr == -1
    error('ICNNA:rawData_NIRScout:import:UnableToReadFile',...
          'Unable to read %s\n', hdr_filename);
end

h = waitbar(0,'Reading header...',...
    'Name','Importing raw data (NIRScout)');
fprintf('Importing header data (NIRScout) -> 0%%');

%% Reading the header ================================
% Read general information
temp=findField(fidr,'FileName');
tmpFilename=temp(find(temp=='=')+1:end); %Quoted
tmpFilename = tmpFilename(2:end-1); %Get rid of quotes
assert(strcmp(tmpFilename,theFilename),...
        'Unexpected filename');

temp=findField(fidr,'Date');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
tmpDate=myDateStr2DateTime(tmp);
%Set the time by now to 00:00h and wait for the field Time
obj=set(obj,'Date',tmpDate);

temp=findField(fidr,'Time');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
%Update the time
tmpDate = get(obj,'Date');
tmpTime=myTimeStr2DateTime(tmp);
%[h,m,s] = hms(tmpDate); %Ignore the date
obj=set(obj,'Date',tmpDate+timeofday(tmpTime)); 

temp=findField(fidr,'Device');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
obj=set(obj,'Device',tmp);

temp=findField(fidr,'Source');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
obj=set(obj,'Source',tmp);

temp=findField(fidr,'Mod');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
obj=set(obj,'StudyTypeModulation',tmp);

temp=findField(fidr,'NIRStar'); %Kind of equivalent to Fileversion
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
obj=set(obj,'FileVersion',tmp);

temp=findField(fidr,'Subject');
tmp=temp(find(temp=='=')+1:end);
obj=set(obj,'SubjectIndex',str2double(tmp));



% Read Measurement information
temp=findField(fidr,'Sources');
tmp=temp(find(temp=='=')+1:end);
obj=set(obj,'nSources',str2double(tmp));

temp=findField(fidr,'Detectors');
tmp=temp(find(temp=='=')+1:end);
obj=set(obj,'nDetectors',str2double(tmp));

temp=findField(fidr,'Steps');
tmp=temp(find(temp=='=')+1:end);
obj=set(obj,'nSteps',str2double(tmp));


%Get the wavelengths [nm] at which light is measured
temp = findField(fidr,'Wavelengths'); %Quoted. Read Nominal Wavelengths line
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
%%%The nominal wavelengths line has the following form:
%%%Wavelengths="w1\t w2"...
%%%where wi are the different wavelengths at which light is measured
%%%and \t is a tab. So I need to split this line...
tokens = strsplit(tmp);
wLengths=zeros(1,length(tokens));
for tt=1:length(tokens)
    wLengths(tt)=str2double(tokens(tt)); %Read single wavelength
end
obj=set(obj,'NominalWavelenghtSet',wLengths);
clear wLengths

temp=findField(fidr,'TrigIns');
tmp=temp(find(temp=='=')+1:end);
obj=set(obj,'nTriggerInputs',str2double(tmp));

temp=findField(fidr,'TrigOuts');
tmp=temp(find(temp=='=')+1:end);
obj=set(obj,'nTriggerOutputs',str2double(tmp));

temp=findField(fidr,'AnIns');
tmp=temp(find(temp=='=')+1:end);
obj=set(obj,'nAnalogInputs',str2double(tmp));


waitbar(0.12,h);
fprintf('\b\b\b12%%');


% 
% Get the sampling rate in [Hz] and the number of blocks
temp=findField(fidr,'SamplingRate');
obj=set(obj,'SamplingRate',str2double(temp(find(temp=='=')+1:end)));
% temp=findField(fidr,'Repeat Count');
% obj=set(obj,'RepeatCount',str2double(temp(find(temp=='=')+1:end)));
%

%Get the modulation amplitudes
temp = findField(fidr,'Mod Amp'); %Quoted. Read modulation amplitudes line
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
%%%The modulation amplitudes line has the following form:
%%%Mod Amp="Amp1\t Amp2"...
%%%where Ampi are the different modulation amplitudes
%%%and \t is a tab. So I need to split this line...
tokens = strsplit(tmp);
Amps=zeros(1,length(tokens));
for tt=1:length(tokens)
    Amps(tt)=str2double(tokens(tt)); %Read single wavelength
end
obj=set(obj,'modulationAmplitudes',Amps);
clear Amps

%Get the modulation thresholds
temp = findField(fidr,'Threshold'); %Quoted. Read modulation amplitudes line
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
%%%The modulation thresholds line has the following form:
%%%Threshold="thresh1\t thresh2"...
%%%where threshi are the different wavelengths at which light is measured
%%%and \t is a tab. So I need to split this line...
tokens = strsplit(tmp);
thresholds=zeros(1,length(tokens));
for tt=1:length(tokens)
    thresholds(tt)=str2double(tokens(tt)); %Read single wavelength
end
obj=set(obj,'modulationThresholds',thresholds);
clear thresholds



% Paradigm Information
temp=findField(fidr,'StimulusType');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
obj=set(obj,'paradigmStimulusType',tmp);

% Experimental Notes
temp=findField(fidr,'Notes');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
obj=set(obj,'Notes',tmp);

% Gain Settings
temp=findField(fidr,'Gains');
%Find field retrieves a single line, but gains are indicated across
%several lines.
if temp~=-1
    lineString=fgetl(fidr);
    tmp=nan(get(obj,'nSources'),get(obj,'nDetectors'));
    ss = 0;
    while (ischar(lineString) && ~strcmpi(lineString,'#"'))
        %Note: ischar(lineString) tests for end-of-file as indicated in
        %Matlab's help for the fgetl function and the help page on
        %"Testing for EOF with fgetl and fgets"
        tokens = strsplit(lineString);
        vals=zeros(1,length(tokens));
        for tt=1:length(tokens)
            vals(tt)=str2double(tokens(tt)); %Read single wavelength
        end
        assert(length(tokens) == get(obj,'nDetectors'),...
            'Unexpected number of gains columns. It should match number of detectors.');
        ss = ss+1;
        tmp(ss,:)=vals;
        lineString = fgetl(fidr);
    end
    assert(ss == get(obj,'nSources'),...
            'Unexpected number of gains rows. It should match number of sources.');
end
obj=set(obj,'Gains',tmp);




% Markers Information
temp=findField(fidr,'Events');
%Find field retrieves a single line, but gains are indicated across
%several lines.
if temp~=-1
    lineString=fgetl(fidr);
    tmp=nan(0,3);
    ss = 0;
    while (ischar(lineString) && ~strcmpi(lineString,'#"'))
        %Note: ischar(lineString) tests for end-of-file as indicated in
        %Matlab's help for the fgetl function and the help page on
        %"Testing for EOF with fgetl and fgets"
        tokens = strsplit(lineString);
        vals=zeros(1,length(tokens));
        for tt=1:length(tokens)
            vals(tt)=str2double(tokens(tt)); %Read single wavelength
        end
        assert(length(tokens) == 3,...
            'Unexpected number of event markers column information.')
        ss = ss+1;
        tmp(ss,:)=vals;
        lineString = fgetl(fidr);
    end
end
obj=set(obj,'EventTriggerMarkers',tmp);




% Data Structure
temp=findField(fidr,'S-D-Key');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
%The S-D-Key is a list of triplets (source-detector:ColumnKey) that has to
%be parsed
tmpSDKey = nan(get(obj,'nSources'),get(obj,'nDetectors'));
comma_idx = [0 find(tmp==',')];
for kk=1:length(comma_idx)-1
    triplet = tmp(comma_idx(kk)+1:comma_idx(kk+1)-1);
    dash_idx = find(triplet=='-');
    colon_idx = find(triplet==':');
    theSource = str2double(triplet(1:dash_idx-1));
    theDetector = str2double(triplet(dash_idx+1:colon_idx-1));
    theKey = str2double(triplet(colon_idx+1:end));
    tmpSDKey(theSource,theDetector)=theKey;
end
obj=set(obj,'SDKey',tmpSDKey);
clear comma_idx dash_idx colon_idx theSource theDetector theKey





temp=findField(fidr,'S-D-Mask');
%Find field retrieves a single line, but gains are indicated across
%several lines.
if temp~=-1
    lineString=fgetl(fidr);
    tmp=nan(get(obj,'nSources'),get(obj,'nDetectors'));
    ss = 0;
    while (ischar(lineString) && ~strcmpi(lineString,'#"'))
        %Note: ischar(lineString) tests for end-of-file as indicated in
        %Matlab's help for the fgetl function and the help page on
        %"Testing for EOF with fgetl and fgets"
        tokens = strsplit(lineString);
        vals=zeros(1,length(tokens));
        for tt=1:length(tokens)
            vals(tt)=str2double(tokens(tt)); %Read mask location
        end
        assert(length(tokens) == get(obj,'nDetectors'),...
            'Unexpected number of mask columns. It should match number of detectors.')
        ss = ss+1;
        tmp(ss,:)=vals;
        lineString = fgetl(fidr);
    end
    assert(ss == get(obj,'nSources'),...
            'Unexpected number of mask rows. It should match number of sources.')
end
obj=set(obj,'SDMask',tmp);
%sum(sum(tmp))
disp(' ')

% Channels Distance
%With the SDMask set, I finally know the number of channels
temp=findField(fidr,'ChanDis');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
tokens = strsplit(tmp);
vals=zeros(1,length(tokens));
for tt=1:length(tokens)
    vals(tt)=str2double(tokens(tt)); %Read channel distance
end
obj.nChannels = length(tokens);
obj=set(obj,'ChannelDistances',vals);
%Note that at this points, the *_probeInfo.mat file might not have been read.


      

fclose(fidr);
fprintf('\b\b\b100%%\n');





%% Deal with the raw intensities data .wl* files
nWavelengths = 2;
for kk = 1:nWavelengths
    wl_filename = [srcDir '/' theFilename '.wl' num2str(kk)];
    
    waitbar(0.01,h);
    fprintf('Importing raw wavelength %d [nm] data (NIRScout) -> 0%%',obj.wLengths(kk));

    
    
    %This is a classical csv files. I can read it all in one shot.
    M = dlmread(wl_filename,' ');
    
    obj.lightRawData(:,:,kk) = M;
    
    waitbar(1,h);
    fprintf('\b\b\b100%%\n');

end




%% Deal with the subject demographics information .inf files

inf_filename = [srcDir '/' theFilename '.inf'];

% Open the data file for conversion
fidr = fopen(inf_filename, 'r');
if fidr == -1
    error('ICNNA:rawData_NIRScout:import:UnableToReadFile',...
          'Unable to read %s\n', inf_filename);
end

waitbar(0.01,h);
fprintf('Importing information .inf file (NIRScout) -> 0%%');

% Subject demographics
temp=findField(fidr,'Name');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
obj=set(obj,'SubjectName',tmp);

temp=findField(fidr,'Age');
tmp=temp(find(temp=='=')+1:end);
obj=set(obj,'SubjectAge',str2double(tmp));

temp=findField(fidr,'Gender');
tmp=temp(find(temp=='=')+1:end); %Quoted
tmp = tmp(2:end-1); %Get rid of quotes
if isempty(tmp), tmp='U'; end;
obj=set(obj,'SubjectGender',tmp);


fclose(fidr);



%% Deal with the probe information _probeInfo.mat files

waitbar(0.01,h);
fprintf('Importing probeset information (NIRScout) -> 0%%');
tmp=load([srcDir '/' theFilename '_probeInfo.mat']);
obj=set(obj,'Probeset',tmp.probeInfo);

%Try to recover some information
pInfo= tmp.probeInfo.probes;
assert(pInfo.nSource0 == get(obj,'nSources'),...
    ['Unexpected number of sources in ' theFilename '_probeInfo.mat. ' ...
    'Please ensure it matches that in ' theFilename '.hdr file.']);
assert(pInfo.nDetector0 == get(obj,'nDetectors'),...
    ['Unexpected number of detectors in ' theFilename '_probeInfo.mat. ' ...
    'Please ensure it matches that in ' theFilename '.hdr file.']);
% assert(pInfo.nChannel0 == get(obj,'nChannels'),...
%     ['Unexpected number of channels in ' theFilename '_probeInfo.mat. ' ...
%     'Please ensure it matches that in ' theFilename '.hdr file.']);

if pInfo.nChannel0 ~= get(obj,'nChannels')
    warning(['Unexpected number of channels in ' theFilename '_probeInfo.mat. ' ...
            'It was expected to match that in ' theFilename '.hdr file. '])
end



waitbar(1,h);
close(h);
fprintf('\b\b\b100%%\n');


assertInvariants(obj);








%=============================================================
%Auxiliar functions
%=============================================================
function fieldName = getFieldName(lineString)
%Extract the field name
idx=find(lineString=='=');
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
% 
% function [effWL]=getEffectiveWavelength(effWLstring)
% %Extract the effective wavelength from a string 'CHXX(wl)'
% idx1=find(effWLstring=='(');
% idx2=find(effWLstring==')');
% effWL=str2double(effWLstring(idx1(1)+1:idx2(1)-1));
% end

function [tmpDate]=myDateStr2DateTime(tmp)
%Convert the tmp date string to a matlab's datetime object
try
    tmpDate=datetime(tmp,'Locale',get(0, 'Language'));
        %Local formatting might prevent this to work correctly
catch
%     warning(['Unable to decode date format. ' ...
%             'Attempting to use some specific known local formats.']);
    if strcmp(get(0, 'Language'),'es_MX')
    	%There might be some "de"s inserted
        try
            tmp=strrep(tmp, 'é', 'e'); %For "miércoles/mié"
            tmp = strrep(tmp, 'de ', '');
            tmpDate=datetime(tmp,...
                'InputFormat','eee., d MMM. yyyy',...
                'Locale',get(0,'Language'));
        catch
            warning(['Specific known local formats failed. ' ...
                'Setting date to today''s date.']);
            tmpDate=datetime('today');
        end
    else
        warning(['Unable to decode date format. ' ...
                 'Setting date to today''s date.']);
        tmpDate=datetime('today');
    end

end

end




function [tmpDate]=myTimeStr2DateTime(tmp)
%Convert the tmp date string to a matlab's datetime object
try
    tmpDate=datetime(tmp,'Locale',get(0, 'Language'));
        %Local formatting might prevent this to work correctly
catch
%     warning(['Unable to decode time format. ' ...
%             'Attempting to use some specific known local formats.']);
    if strcmp(get(0, 'Language'),'es_MX'),
    	%There might be some "de"s inserted
        try
            tmp=strrep(tmp, 'é', 'e'); %For "miércoles/mié"
            tmp=strrep(tmp, 'a. m.', 'AM');
            tmp=strrep(tmp, 'p. m.', 'PM');
            tmpDate=datetime(tmp,'InputFormat','hh:mm a');            
        catch
            warning(['Specific known local formats failed. ' ...
                'Setting time to today''s now.']);
            tmpDate=datetime('now');
        end
    else
        warning(['Unable to decode time format. ' ...
                 'Setting time to now.']);
        tmpDate=datetime('now');
    end

end

end



end
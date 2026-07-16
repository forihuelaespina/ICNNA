function sd=import(obj,varargin)
%Reads data files recorded by NIRx NIRStar software in a session.
%
% sd=import(obj,path) Reads the data files recorded produced by
%       the NIRx NIRStar software located in |path|. The properties
%       |path| and |dataFiles| will be updated.
%
% sd=import(obj) Reads the data files pointed in |dataFiles|
%
%
% obj=import(obj) Reads the data files pointed in |dataFiles|
%   DEPRECATED use. Maintain to keep backwards compatibility
%   with version 1.3.1 or earlier.
%
%% Input file(s) structure
%
% The NIRStar capture all data from NIRx fNIRS systems. Detailed
%information is available in the NIRStar User Manual. The following has
%been extracted from the user manual for the software version 14.1 which
%may no longer be the most up-to-date NIRStar format.
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
%                               *I believe this has now been deprecated
%(-) filename.evt           [event records (triggers)]
%                               *I believe this has now been deprecated
%(-) filename.tpl           [topo layout]
%                               *I believe this has now been deprecated
%(-) filename_config.txt	[information regarding experimental configuration]
%                               *I believe this has now been superseded
%                               by a *_config.json file.
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
%  == Files added posterior to NIRStar 14.0
%
%   digpoints.txt - 3D position of fiducial locations (e.g. Nz, Iz, etc
%       inc. sources and detectors)
%   filename_config.json	[information regarding experimental configuration]
%   filename_description.json	[some demographics]
%   filename_lsl.tri	    [lsl markers]
%   
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
% The following explains the header file sections using exemplary
% values, but importantly note that the sections and the key-value
% pairs do change from one file version to the next e.g. Sampling rate
% used to be in [ImagingParameters]->"SamplingRate" whereas now
% is more likely found as [GeneralInfo]->"Sampling rate".
%
% General: Contains general information about the time and date of
%   data recording, and the filename. The section looks like this:
%
%   [GeneralInfo]
%   Version=2021.9.0-6-g14ef4a71 %Not in the original files!
%   FileName="NIRS-2012-02-16_004" Filename as defined above in Section 6.3
%   Date="Do, 16. Feb 2012" Date of recording
%   Time="15:54" Start time of measurement
%   Device="NIRScout 16x24" System type in use
%   Source=”LED” Type of source used (LED or Laser)
%   Mod=”Human Subject” Modulation amplitude according to study type
%   NIRStar=”14.1” NIRStar version used to record the dataset
%   Subject=1 Subject index
%   %Since (at least) Version=2021.9.0-6-g14ef4a71
%   Amplitude details= 20.9%, 100.0%, 100.0%, 100.0%, 100.0%, 100.0%,
%   100.0%, 100.0%,  25.5%, 100.0%, 100.0%, 100.0%, 100.0%, 100.0%, 100.0%,
%   76.7% %Per source amplification
%   triggers=[]
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
%   %Since (at least) Version=2021.9.0-6-g14ef4a71
%   experiment_name=
%   experiment_subject=
%   experiment_subject_age=
%   experiment_subject_gender=
%   experiment_subject_contact_info=
%   experiment_remarks=
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
%   From (at least) file version "2021.9.0-6-g14ef4a71"
%   the S-D-Key may also take the form of "Channel indices"
%   e.g.
%
%   Channel indices=
%  0-0, 0-1, 0-8, 0-22, 1-0, 1-2, 1-23, 2-0, ..., 15-12, 15-21
%
%   Note that in the modern form the channel key is not explicit.
%
%
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
%% The event triggers files (.evt)
%
% The .evt files is just a matrix with one row per trigger and
% 1+n columns with the leading column being the frame number,
% and the n=8 (bits) subsequent columns represent the binary
% representation of the trigger being set. The binary representation
% is from the least significant bit e.g. 11000000 -> 3.
% 
% So for instance:
%
%   581	1	1	0	0	0	0	0	0
%
% indicate trigger 3 being fired on sample 581.
%
%
% Now in principle, this should "match" the information in the
% header file (.hdr) on the section for Markers, but in practice
% there may be substantial differences. However, the NIRStar manual
% does not explain this discrepancy.
%
% See also
% 
%   .hdr->Event Trigger Markers->Col 2.
%   The NIRStar user manual Section on "Other Files"
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
% No effort is currently made in checking whether the file is
% an original NIRx NIRScout data file. This is simply assumed
% to be true.
%
%% Parameters
%
% path - The folder to the data files to import.
%
% 
% Copyright 2025-26
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.misc.rawData_NIRx
%



%% Log
%
% 2-Feb-2025: FOE
%   + Method created.
%   Although this class supersedes class @rawData_NIRScout, the internal
%   rationale is completely different (see Remarks above). Hence, the
%   whole code for this method is completely different from its analagous
%   method import in old class @rawData_NIRScout.
%
%
% -- ICNNA v1.4.0
%
% 20-Dec-2025: FOE
%   + Adaptation to the new behaviour of superclass
%  @icnna.data.core.rawData whereby:
%       * the raw data is no longer stored but read on-the-fly
%           upon invoking method |import|,
%       * the property .dataFiles is no longer a dictionary
%           but a struct.
%       * the output is no longer obj but a structuredData.
%   UNFINISHED
%   + Improved some comments.
%   
%
% -- ICNNA v1.4.1
%
% 7/20-23-May-2026: FOE
%   + Continue working on the adaptation to the new behaviour
%   of superclass
%
%

%% Deal with options
%Check if path has been provided
if nargin > 1
    obj.path = varargin{1};
    varargin{1} = [];
end

opt.verbose = 0; %0 - silent



%% Preparations

%Function to check ICNNA running's version only became
%available in v1.4.1 so if function does not exist
%assume older version.

try
    tmpVersion = icnna.util.version();
catch ME
    tmpVersion = '1.3.1';
end


%Get the list of available files
fileList= dir(obj.path);
nFiles = length(fileList);


%% Main loop

%% 1) Read and store files OR store files location
% (v1.3.1 or below)
%Each file and its content is stored as a key(string)->value(cell) entry
%in the .dataFiles dictionary property.
% (v1.4.1 or above) 
% Only references to the files are store.
% These are read on demand.
for iFile = 1:nFiles

    %Retrieve the key
    %Note that there may be subfolders, so to get the key for property
    % .dataFiles I need to put together the whole path and then "substract"
    %the path.
    tmpFullPath = [fileList(iFile).folder filesep fileList(iFile).name];
    theKey = strrep(tmpFullPath,obj.path,'');
    if theKey(1) == filesep
        theKey(1) = [];
    end
    theKey = string(theKey);

    if opt.verbose >= 1
        fprintf(1,'Reading file: %s\n', theKey);
    end

    [~,theFilename,theFileExtension] = fileparts(theKey);


    if icnna.util.compareVersions(tmpVersion,'1.3.1','<=')

        %Read and store files
        switch (theFileExtension)
            case {'.','..','.zip'} %Ignore these files
                %Do nothing
            case '.hdr'
                obj.dataFiles(theKey) = {importFileHdr(tmpFullPath)};
                        %See auxiliar function below.
            case '.evt'
                obj.dataFiles(theKey) = {importFileEvt(tmpFullPath)};
                        %See auxiliar function below.
            case {'.wl1','.wl2'}
                obj.dataFiles(theKey) = {importFileWl(tmpFullPath)};
                        %See auxiliar function below.
            case '.set'
                obj.dataFiles(theKey) = {importFileSet(tmpFullPath)};
                        %See auxiliar function below.
            case '.tpl'
                obj.dataFiles(theKey) = {importFileTpl(tmpFullPath)};
                        %See auxiliar function below.
            case '.tri'
                obj.dataFiles(theKey) = {importFileTri(tmpFullPath)};
                        %See auxiliar function below.
            case '.inf'
                obj.dataFiles(theKey) = {importFileInf(tmpFullPath)};
                        %See auxiliar function below.
            case '.txt'
                obj.dataFiles(theKey) = {importFileTxt(tmpFullPath)};
                        %See auxiliar function below.
            case '.mat'
                obj.dataFiles(theKey) = {importFileMat(tmpFullPath)};
                        %See auxiliar function below.
            case '.json'
                obj.dataFiles(theKey) = {importFileJson(tmpFullPath)};
                        %See auxiliar function below.
            case '.snirf'
                tmp = icnna.data.snirf.snirf();
                obj.dataFiles(theKey) = {tmp.load(tmpFullPath)};
                        %See auxiliar function below.
            otherwise
                warning('icnna:data:misc:rawDataNIRx:import:UnexpectedFile',...
                     ['Unexpected file type ' char(theFileExtension) '. Skipping file.']);
        end

    elseif icnna.util.compareVersions(tmpVersion,'1.3.1','>')

        %Add the files (if they do not exist yet)
        %No need to read the files or store the files here.
        switch (theFileExtension)
            case {'.','..','.zip'} %Ignore these files
                %Do nothing
            case '.hdr'
                description = [theFileExtension ' - Session header.\n' ...
                               'Information about the device, imaging' ...
                               'parameters, (experimental?) paradigm,' ...
                               'gain, experiment notes, events markers,' ...
                               'source-detector couplings, and interoptode' ...
                               'distances.'];
                obj = addFile(obj,tmpFullPath,description);
            case '.evt'
                description = [theFileExtension ' - Event records (triggers).'];
                obj = addFile(obj,tmpFullPath,description);
            case {'.wl1','.wl2'}
                description = [theFileExtension ' - Detector readings by wavelength.'];
                obj = addFile(obj,tmpFullPath,description);
            case '.set'
                description = [theFileExtension ' - Gain-settings table.'];
                obj = addFile(obj,tmpFullPath,description);
            case '.tpl'
                description = [theFileExtension ' - Topographical layout.'];
                obj = addFile(obj,tmpFullPath,description);
            case '.tri'
                description = [theFileExtension ' - LSL markers.'];
                obj = addFile(obj,tmpFullPath,description);
            case '.inf'
                description = [theFileExtension ' - Subject related information' ...
                               ', as specified in NIRStar (this information ' ...
                               'is available starting from NIRStar 14.0).'];
                obj = addFile(obj,tmpFullPath,description);
            case '.txt'
                description = [theFileExtension ' - Configuration file.'];
                if strcmpi(theFilename,'digpoints')
                    description = [theFileExtension ' - 3D position ' ...
                               'of fiducial locations (e.g. Nz, Iz, ' ...
                               'etc inc. sources and detectors)'];
                end
                obj = addFile(obj,tmpFullPath,description);
            case '.mat'
                description = [theFileExtension ' - Anatomical locations of ' ...
                               'sources and detectors and channel locations ' ...
                               '(this information is only ' ...
                               'available starting from NIRStar version 14.1).'];
                obj = addFile(obj,tmpFullPath,description);
            case '.json'
                description = [theFileExtension ' - Configuration file.'];
                obj = addFile(obj,tmpFullPath,description);
            case '.snirf'
                description = [theFileExtension ' - fNIRS standardized file.'];
                obj = addFile(obj,tmpFullPath,description);
            otherwise
                warning('icnna:data:misc:rawDataNIRx:import:UnexpectedFile',...
                     ['Unexpected file type ' char(theFileExtension) '. Skipping file.']);
        end

        

    else
        error('icnna:data:misc:rawData_NIRx:VersionControl',...
                'Unexpected ICNNA version found.');
    end


end



%% Build the output
% (v1.3.1 or below) obj
% (v1.4.1 or above) structuredData
if icnna.util.compareVersions(tmpVersion,'1.3.1','<=')
    %Return the obj
    sd = obj;
elseif icnna.util.compareVersions(tmpVersion,'1.3.1','>')
    %Build the structuredData/nirs_neuroimage from the available files.

    % Locate and read the .hdr file
    hdrContent = [];
    hdrFiles = findFile(obj, '.*\.hdr$', 'regexp');
    if ~isempty(hdrFiles)
        hdrContent = importFileHdr(hdrFiles{1});
    end

    sd = nirs_neuroimage();
    %sd.id = 1;
    sd.description    = aux_getDescription(obj,hdrContent);
    sd.timeline       = aux_getTimeline(obj,hdrContent);
    sd.data           = aux_getData(obj,hdrContent);
    sd.integrity      = aux_getIntegrity(obj,hdrContent);
    sd.signalTags     = aux_getSignalTags(obj,hdrContent);
    sd.chLocationMap  = aux_getCLM(obj,hdrContent);

else
    error('icnna:data:misc:rawData_NIRx:VersionControl',...
        'Unexpected ICNNA version found.');
end


end


%% Auxiliar functions
function [filename] = findFile(obj,pattern,patternType)
% Retrieve the list of files that comply with a pattern in the rawData object.
%
%
%% Example of use
%
% [filename] = findFile(obj,'*.hdr'); %Look for the header file using glob pattern type.
% [filename] = findFile(obj,'.*\.hdr$','regexp'); %Look for the header file using regexp.
%
%% Input parameters
%
% obj - rawData_NIRx
%   The rawData_NIRx object where to import the file
% pattern - char[] | string
%   The pattern to be looked for in the filename. This pattern
%   can be expressed in "glob" or "regexp"
% patternType - Optional. char[] | string. Default is 'glob'
%   The tyupe of pattern in parameter |pattern|. Available
%   options are:
%       - 'glob' - Default
%       - 'regexp' - Regular expression
%
%
%% Output
% filename - char*{} 
%   The list of filename(s) including the full path associated
%   with obj that comply with the pattern.
%
%


%% Log
%
% -- ICNNA v1.4.1
%
% 20-May-2026: FOE
%   + Function added.
%

% Deal with options
if nargin < 3
    patternType = 'glob';
end

% Convert glob to regexp if needed
if strcmpi(patternType, 'glob')
    regexpPattern = regexptranslate('wildcard', pattern);
elseif strcmpi(patternType, 'regexp')
    regexpPattern = pattern;
else
    error('icnna:data:misc:rawData_NIRx:findFile:InvalidPatternType', ...
          'patternType must be ''glob'' or ''regexp''.');
end

% Search
filename = {};
for iFile = 1:length(obj.dataFiles)
    tmpFilename = obj.dataFiles(iFile).filename;
    if ~isempty(regexp(tmpFilename, regexpPattern, 'once'))
        fullPath = fullfile(obj.path, tmpFilename);
        filename{end+1} = fullPath; %#ok<AGROW>
    end
end


end

function obj = addFile(obj,filename,description)
%Add a file to the rawData file repository.
%
% obj = addFile(obj,filename,description)
%
%% Remarks
%
% Files are only added if not already declared.
%
% Filenames are internally stored relative to the object's |path|
% property. Any folder separators are automatically adapted to the
% current operating system.
%
%% Example of use
%
% obj = obj.addFile('nirx/header.hdr','NIRx header file');
%
%% Input parameters
%
% obj - rawData_NIRx
%   The rawData_NIRx object where to import the file
% filename - char* | string
%   The filename of the file to be added. This should be relative to the
%   rawData_NIRx object's |path|.
% description - char* | string
%   A description of the file to be added.
% 
%% Output
%
% obj - rawData_NIRx
%   The updated object.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx
%


%% Log
%
% -- ICNNA v1.4.1
%
% 21-May-2026: FOE
%   + Log added. For some reason I forgot to add the log when I
%   first created the function.
%




    %% Input validation
    
    if nargin < 3
        error('rawData_NIRx:addFile:InvalidNumberOfParameters',...
              'Expected obj, filename and description.');
    end

    if isstring(filename)
        filename = char(filename);
    end

    if isstring(description)
        description = char(description);
    end

    if ~ischar(filename)
        error('rawData_NIRx:addFile:InvalidFilename',...
              'filename must be a char array or string.');
    end

    if ~ischar(description)
        error('rawData_NIRx:addFile:InvalidDescription',...
              'description must be a char array or string.');
    end


    %% Normalize filename
    
    % Convert separators to current OS convention
    filename = strrep(filename,'/',filesep);
    filename = strrep(filename,'\',filesep);

    % Remove obj.path if redundantly included
    %
    % Example:
    %   obj.path = '/data/session1/'
    %   filename = '/data/session1/file1.wl1'
    %
    % becomes:
    %   file1.wl1
    %
    if startsWith(filename,obj.path)
        filename = filename(length(obj.path)+1:end);
            %Note that this may still leave some leading filesep
            % e.g. if obj.path = 'C:\data\session' and
            % filename = 'C:\data\session\file.hdr', then the
            % stripped result is '\file.hdr'
        filename = regexprep(filename ,'^[/\\]', '');
            %Remove the leading filesep if any
    end


    %% Check whether file already exists
    
    isDeclared = false;

    for iFile = 1:length(obj.dataFiles)

        tmpFilename = obj.dataFiles(iFile).filename;

        % Normalize separators for comparison
        tmpFilename = strrep(tmpFilename,'/',filesep);
        tmpFilename = strrep(tmpFilename,'\',filesep);

        if strcmp(tmpFilename,filename)
            isDeclared = true;
            break;
        end

    end


    %% Add file if not already declared
    
    if ~isDeclared

        newEntry.filename    = filename;
        newEntry.description = description;

        if isempty(obj.dataFiles)
            obj.dataFiles = newEntry;
        else
            obj.dataFiles(end+1) = newEntry;
        end

    end
end

function content = importFileHdr(filename)
%Reads a NIRStar .hdr file.
%
%% Input parameters
%
% filename - char[]. Full path to the .hdr file.
%
%% Output
%
% content - dictionary(string -> dictionary(string -> string))
%   The outer dictionary is at section level. The inner dictionary
%   are the key-value pairs in that section.
%   Outer dictionary keyed by section name; inner by field name.
%   Multiline values (quote- or hash-delimited) are stored with
%   literal '\n' separators between continuation lines.
% content - Dictionary (String -> Dictionary). The file content
%
%
% Copyright 2025-26
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx


%% Log
%
% 2-Feb-2025: FOE
%   + Function created.
%
% 22-May-2026: FOE
%   + Rewritten to fix:
%       (a) Crash when hash-delimited rows (no '=') arrived while
%           tmpValue was non-empty: the flagValueOpen detection
%           accessed idx outside the branch where idx was valid.
%       (b) Single-line quoted values (e.g. FileName="...") opened a
%           multiline read; the closing '"' on the same line was not
%           checked.
%       (c) Hash-delimited tables (Gains, Events, S-D-Mask) were not
%           handled as multiline; their rows hit the no-'=' fallback,
%           which then triggered crash (a).
%   + Added endDelimiter to distinguish quote- vs hash-delimited
%     multiline blocks using the single flagValueOpen flag.
%   + Blank lines no longer reset the section name (more robust).
%   + content(secName) flushed on every update, including multiline
%     continuation lines.
%
%

content = configureDictionary("string","dictionary");

[fid,errmsg] = fopen(filename,'r');
if fid < 0
    fprintf(1,errmsg);
    fprintf(1,'Unable to open .hdr file. Skipping file.');
    return;
end


secName       = "";
secContent    = configureDictionary("string","string");
tmpKey        = "";
tmpValue      = '';     % char[]; accumulated (possibly multiline) value
flagValueOpen = false;
endDelimiter  = '"';    % '"' = quote-delimited | '#' = hash-delimited



while ~feof(fid)
    tline = fgetl(fid); %This yields a char array.
    if ~ischar(tline)
        break;
    end
    trimmed = strtrim(tline);

    %There are 3 types of lines;
    %   - Section headers starting with '[' e.g. [GeneralInfo] 
    %   - empty lines (preceding a new section)
    %   - regular lines including a key-value pair.
    %   Exception: Some regular key-value pairs may extend beyond 1 line
    %   as for instance "Channel Mask" or "Channel indices". In these
    %   cases I will need to keep reading lines until the end of the
    %   value is found.

    if flagValueOpen
        % Continuation of a multiline value.
        tmpValue           = [tmpValue '\n' tline];
        secContent(tmpKey) = tmpValue;
        content(secName)   = secContent;
        if (endDelimiter == '"' && ~isempty(trimmed) && trimmed(end) == '"') || ...
           (endDelimiter == '#' && ~isempty(trimmed) && trimmed(1)   == '#')
            flagValueOpen = false;
        end

    elseif isempty(trimmed)
        % Blank line - skip, preserve section context.

    elseif trimmed(1) == '['
        % Section header  e.g.  [GeneralInfo]
        secName    = string(trimmed(2:end-1));
        secContent = configureDictionary("string","string");

    else
        % Key=value pair.
        idx = find(tline == '=', 1, 'first');
        if isempty(idx)
            % No '=': attach to previous key (graceful fallback).
            if strlength(tmpKey) > 0
                tmpValue           = [char(tmpValue) '\n' tline];
                secContent(tmpKey) = tmpValue;
                content(secName)   = secContent;
            end
        else
            tmpKey             = string(strtrim(tline(1:idx-1)));
            tmpValue           = tline(idx+1:end);
            secContent(tmpKey) = tmpValue;
            content(secName)   = secContent;
            % Detect multiline start — placed here where idx is valid.
            if ~isempty(tmpValue)
                if     tmpValue(1) == '"' && (length(tmpValue) < 2 || tmpValue(end) ~= '"')
                    flagValueOpen = true;  endDelimiter = '"';
                elseif strcmp(strtrim(tmpValue), '#')
                    flagValueOpen = true;  endDelimiter = '#';
                end
            end
        end
    end

end

fclose(fid);

end




function content = importFileEvt(filename)
%Reads a NIRStar .evt file
%
%% Input parameters
%
% filename - Char array. The filename (inc. path)
%
%% Output
%
% content - int[kx9]
%   The event marker file content. This is a simple matrix
%   where each row of the tab-separated table corresponds
%   to a recorded trigger event.
%   The first column is the frame number and the other 8 columns
%   correspond to the inary (least significant bit first) representation
%   of the condition.
%   Content may yield an empty matrix [0x9] if file is empty.
%   
%



%% Log
%
%
% -- ICNNA v???
%
% ??-???-????: FOE
%   + Function created. Only dummy body.
%
%
% -- ICNNA v1.4.1
%
% 20-May-2026: FOE
%   + Added actual body of the function.
%


[fid, errmsg] = fopen(filename, 'r');
if fid < 0
    warning('ICNNA:icnna:data:misc:rawDataNIRx:import:FileOpenError', ...
            ['Unable to open .evt file: ' errmsg '. Skipping file.']);
    content = zeros(0, 9);
    return;
end

content = fscanf(fid, '%d', [9, inf])';

fclose(fid);


end







function content = importFileWl(filename)
%Reads a NIRStar .wl* file
%
% filename - Char array. The filename (inc. path)
%
% content - Matrix of double sized (nSamples x nChannels)
%

T = readtable(filename,'FileType','text', 'ReadVariableNames', false);
content = table2array(T);

end







function content = importFileSet(filename)
%Reads a NIRStar .set file
%
% filename - Char array. The filename (inc. path)
%
% content - Dictionary (String -> Dictionary). The file content
%       The outer dictionary is at section level. The inner dictionary
%       are the key-value pairs in that section.

warning('ICNNA:icnna:data:misc:rawDataNIRx:import:FileReaderUnavailable',...
         'File reader for type .set not yet available. Skipping file.');
content = [];
return

% [fid,errmsg] = fopen(filename,'r');
% if fid < 0
%     fprintf(1,errmsg);
%     fprintf(1,'Unable to open .set file. Skipping file.');
%     return;
% end
% 
% fclose(fid);

end







function content = importFileTpl(filename)
%Reads a NIRStar .tpl file
%
% filename - Char array. The filename (inc. path)
%
% content - Dictionary (String -> Dictionary). The file content
%       The outer dictionary is at section level. The inner dictionary
%       are the key-value pairs in that section.

warning('ICNNA:icnna:data:misc:rawDataNIRx:import:FileReaderUnavailable',...
         'File reader for type .tpl not yet available. Skipping file.');
content = [];
return

% [fid,errmsg] = fopen(filename,'r');
% if fid < 0
%     fprintf(1,errmsg);
%     fprintf(1,'Unable to open .tpl file. Skipping file.');
%     return;
% end
% 
% fclose(fid);

end



function content = importFileTri(filename)
%Reads a NIRStar LSL trigger (.tri) file into a table.
%
% content = importFileTri(filename)
%
% Parses a NIRStar .tri file (typically named *_lsl.tri in modern
% NIRStar / Aurora datasets). Each line records one LSL-triggered
% event with three semicolon-delimited fields:
%
%   <ISO8601_datetime>;<frame>;<marker>
%
% For example:
%   2024-01-02T14:13:13.762634;38;1
%   2024-01-02T14:13:43.758906;191;2
%
% Column 1 (timestamp) is parsed as a MATLAB datetime when the
% ISO 8601 format is recognised by readtable. If parsing fails
% (non-standard format or MATLAB version limitation), the column
% is returned as a string array. Callers must handle both types
% (see aux_getTimeline).
%
%% Example of use
%
%   content = importFileTri('/path/to/session_lsl.tri');
%   frames  = content.sample;
%   markers = content.marker;
%
%% Assumptions and remarks
%
% - Delimiter is semicolon (';'). The file has no header row.
% - Exactly 3 columns are expected. If the file contains a
%   different number, an empty 0x3 table is returned with a warning.
% - This function is a thin reader: no timestamp conversion,
%   sorting check, or repair is performed here. All such logic
%   belongs in aux_getTimeline.
%
%% Error handling
%
% File read failures are caught; an empty table is returned and a
% warning issued rather than propagating an error to the caller.
%
%% Input parameters
%
% filename - char[] | string
%   Full path to the .tri file, including extension.
%
%% Output
%
% content - table [nEvents x 3]
%   Variable names: timestamp | sample | marker
%       .timestamp - datetime(:,1) or string(:,1)
%           Absolute acquisition datetime of each event (column 1).
%           Type depends on whether readtable parsed it as datetime.
%       .sample    - double(:,1)
%           Scan frame number at which the event occurred (column 2).
%       .marker    - double(:,1) or string(:,1)
%           Trigger/marker value for each event (column 3).
%   Returns an empty 0x3 table on any failure.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, aux_getTimeline, importFileEvt, importFileHdr
%


%% Log
%
% -- ICNNA v1.4.1
%
% 20-May-2026: FOE
%   + Function added.
%
% 23-May-2026: FOE
%   + Expanded to full ICNNA documentation style.
%   + Added column validation with graceful empty-table return.
%   + Added try/catch around readtable for file-open failures.
%


% Default: empty table with canonical variable names and types
emptyOut = table('Size',         [0, 3], ...
                 'VariableTypes', {'datetime','double','double'}, ...
                 'VariableNames', {'timestamp','sample','marker'});

% Read the file
try
    content = readtable(filename, ...
                        'Delimiter',        ';', ...
                        'DatetimeType',     'datetime', ...
                        'ReadVariableNames', false, ...
                        'FileType',         'text');
catch ME
    warning('icnna:data:misc:rawData_NIRx:import:importFileTri:ReadFailed', ...
            'Failed to read .tri file ''%s'': %s', filename, ME.message);
    content = emptyOut;
    return;
end

% Validate column count
if width(content) ~= 3
    warning('icnna:data:misc:rawData_NIRx:import:importFileTri:UnexpectedFormat', ...
            ['.tri file ''%s'' has %d column(s); 3 expected ' ...
             '(timestamp;sample;marker). Returning empty table.'], ...
            filename, width(content));
    content = emptyOut;
    return;
end

content.Properties.VariableNames = {'timestamp', 'sample', 'marker'};

end






function content = importFileTxt(filename)
%Reads a NIRStar .txt file
%
% filename - Char array. The filename (inc. path)
%
% content - A char array
content = [];
[fid,errmsg] = fopen(filename,'r');
if fid < 0
    fprintf(1,errmsg);
    fprintf(1,'Unable to open .txt file. Skipping file.');
    return;
end

raw = fread(fid,inf); 
fclose(fid); 
content = char(raw');

end







function content = importFileMat(filename)
%Reads a NIRStar .mat file
%
% filename - Char array. The filename (inc. path)
%
% content - A struct
%This is a .mat file so it can be read directly.
[content] = load(filename);
end





function content = importFileJson(filename)
%Reads a NIRStar .json file
%
% filename - Char array. The filename (inc. path)
%
% content - A (JSON) struct.

content = [];
[fid,errmsg] = fopen(filename,'r');
if fid < 0
    fprintf(1,errmsg);
    fprintf(1,'Unable to open .evt file. Skipping file.');
    return;
end
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
content = jsondecode(str);
end









function [description] = aux_getDescription(obj,hdrContent)
% Build a description string for the structuredData from the .hdr file.
%
% Attempts to construct a description from the [GeneralInfo] section
% of the .hdr file using the fields 'Subject' and 'FileName', in that
% order. Only fields that are actually present are included. If neither
% field is found, or if the .hdr file is absent, an empty string is
% returned.
%
%% Assumptions and remarks
%
% - Not all NIRStar .hdr files include the same fields. Missing fields
%   are silently skipped; no warning is raised as this is expected.
% - The format of the description is: Subject:FileName
%   If only one field is available, no colon separator is added.
%
%% Input parameters
%
% obj - @rawData_NIRx
%   A rawData_NIRx object with file references already populated.
%
% hdrContent - Dictionary
%   The parsed content of the header file.
%
%% Output
%
% description - char[]
%   A short description string. May be empty if no relevant fields
%   are found.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, importFileHdr, findFile
%

%% Log
%
% -- ICNNA v1.4.1
%
% 20-May-2026: FOE
%   + Function added.
%


description = '';

if isempty(hdrContent)
    return;
end

if ~isKey(hdrContent, "GeneralInfo")
    return;
end

generalInfo = hdrContent("GeneralInfo");

% Build description incrementally from available fields
parts = {};

if isKey(generalInfo, "Subject")
    parts{end+1} = strtrim(char(generalInfo("Subject")));
end

if isKey(generalInfo, "FileName")
    parts{end+1} = strtrim(char(generalInfo("FileName")));
end

description = strjoin(parts, ':');

end



function [t] = aux_getTimeline(obj,hdrContent)
% Build an icnna.data.core.timeline from the available NIRx session files.
%
% Reads event/trigger information from up to three file types and
% assembles them into a single icnna.data.core.timeline object:
%
%   .hdr (Markers section) - hardware triggers recorded by NIRStar
%   .evt                   - hardware trigger binary log
%   .tri                   - LSL markers (may include external triggers
%                            e.g. from PsychoPy)
%
%% Naming convention for conditions
%
% Events from .hdr and .evt originate from the NIRx hardware and are
% labelled with the prefix "NIRx:" (e.g. "NIRx:3"). Events from .tri
% originate from the Lab Streaming Layer (LSL) and are labelled with
% the prefix "LSL:" (e.g. "LSL:3"). This convention ensures
% unambiguous identification of the trigger source, especially since
% LSL triggers may exceed the 8-bit (0-255) range of NIRx hardware.
%
%% Conflict resolution
%
% If the same frame/condition pair appears consistently in more
% than one NIRx file (.hdr and .evt), it is added once (deduplicated).
% If different files report different conditions for the same frame,
% all are treated as separate events - no judgement is made at this
% stage; corrections, if needed, are deferred to downstream processing.
%
% Events present in only one file are always included.
%
%% Determining nSamples
%
% The number of samples for constructing the timeline timestamps is
% determined by the following fallback chain:
%   1. Row count of .wl1 file (default; raw intensity data)
%   2. Row count of .wl2 file (if .wl1 is absent)
%   3. Row count of nirs(1).data(1).dataTimeSeries from a .snirf file
%   4. *_hboxy.NAV / *_hbred.NAV files (not yet implemented; warning)
%   5. Last event frame number across all sources (last resort; warning)
%
%% Assumptions and remarks
%
% - The sampling rate is read from the .hdr [ImagingParameters] section.
% - Event durations are set to 0 and amplitudes to 1, as these are
%   not encoded in the NIRx/LSL trigger formats.
% - Condition IDs are auto-incrementing integers starting from 1.
%   The condition name (e.g. "NIRx:3") does NOT necessarily match
%   its assigned ID.
% - Conditions are added in alphabetical order by name, so all
%   "LSL:*" conditions if present, precede all "NIRx:*" conditions.
%
%% Input parameters
%
% obj - @rawData_NIRx
%   A rawData_NIRx object with file references already populated
%   (i.e. after the file registration loop in import.m).
%
% hdrContent - Dictionary
%   The parsed content of the header file.
%
%% Output
%
% t - icnna.data.core.timeline
%   A timeline object with conditions and events populated from the
%   available trigger files.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, icnna.data.core.timeline,
%   icnna.data.core.condition, importFileHdr, importFileEvt,
%   importFileTri, findFile
%

%% Log
%
% -- ICNNA v1.4.1
%
% 20-May-2026: FOE
%   + Function added.
%
% 23-May-2026: FOE
%   + Section 5 (.tri reading) expanded with timestamp consistency
%     check and repair for the known NIRx clock drift/reset bug
%     (discovered in file '002 MG/NIRX/2024-01-03_001').
%     Repair follows the convention of rawdata_nirx2snirf.m.
%   + importFileTri expanded with column-count validation and
%     try/catch for file-open failures.
%




% 1) Extract sampling rate from .hdr
if isempty(hdrContent)
    warning('icnna:data:misc:rawDataNIRx:import:aux_getTimeline:MissingHdrFile', ...
            ['No .hdr file found. Cannot determine sampling rate. ' ...
             'Returning empty timeline.']);
    timeline = icnna.data.core.timeline();
    return;
end

samplingRate = 1; %Default [Hz]
imgParams = [];
if isKey(hdrContent, "GeneralInfo")
    imgParams = hdrContent("GeneralInfo");
elseif isKey(hdrContent, "ImagingParameters")
    imgParams = hdrContent("ImagingParameters");
else
    warning('icnna:data:misc:rawDataNIRx:import:aux_getTimeline:MissingSamplingRate', ...
        ['Neither [GeneralInfo] section or [ImagingParameters] section found in .hdr. ' ...
        'Using default sampling rate 1 Hz.']);
end

if ~isempty(imgParams) && isKey(imgParams, "SamplingRate")
    samplingRate = str2double(imgParams("SamplingRate"));
elseif ~isempty(imgParams) && isKey(imgParams, "Sampling rate")
    samplingRate = str2double(imgParams("Sampling rate"));
else
    warning('icnna:data:misc:rawDataNIRx:import:aux_getTimeline:MissingSamplingRate', ...
         'SamplingRate not found. Using default 1 Hz.');
end

if isnan(samplingRate) || samplingRate <= 0
    warning('icnna:data:misc:rawDataNIRx:import:aux_getTimeline:InvalidSamplingRate', ...
        'SamplingRate parsed as %g; reverting to default 1 Hz.', samplingRate);
    samplingRate = 1;
end


% 2) Determine nSamples via fallback chain

nSamples = 0;
nSamplesSource = 'none'; %#ok<NASGU> Kept for traceability

% 2a) Try .wl1
wl1Files = findFile(obj, '.*\.wl1$', 'regexp');
if ~isempty(wl1Files)
    wl1Data = importFileWl(wl1Files{1});
    nSamples = size(wl1Data, 1);
    nSamplesSource = '.wl1'; %#ok<NASGU>
end

% 2b) Try .wl2 if .wl1 not available
if nSamples == 0
    wl2Files = findFile(obj, '.*\.wl2$', 'regexp');
    if ~isempty(wl2Files)
        wl2Data = importFileWl(wl2Files{1});
        nSamples = size(wl2Data, 1);
        nSamplesSource = '.wl2'; %#ok<NASGU>
    end
end

% 2c) Try .snirf
if nSamples == 0
    snirfFiles = findFile(obj, '.*\.snirf$', 'regexp');
    if ~isempty(snirfFiles)
        tmpSnirf  = icnna.data.snirf.snirf();
        snirfData = tmpSnirf.load(snirfFiles{1});
        nSamples  = size(snirfData.nirs(1).data(1).dataTimeSeries, 1);
        nSamplesSource = '.snirf'; %#ok<NASGU>
    end
end

% 2d) Try *_hboxy.NAV / *_hbred.NAV (not yet implemented)
if nSamples == 0
    navFiles = findFile(obj, '.*_hboxy\.NAV$', 'regexp');
    if ~isempty(navFiles)
        warning('icnna:data:misc:rawDataNIRx:import:aux_getTimeline:NAVReaderUnavailable', ...
                ['NAV file reader not yet implemented. ' ...
                 'Cannot determine nSamples from NAV files.']);
    end
end

% 2e) Last resort: estimated after reading events (see Section 6 below)


% 3) Read events from .hdr Markers section

hdrEvents = zeros(0, 2); % [frameNumber, conditionInt]

if isKey(hdrContent, "Markers")
    markersSection = hdrContent("Markers");
    if isKey(markersSection, "Events")
        eventsStr = char(markersSection("Events"));
        % The value is a hash-delimited table stored as a single
        % string with literal '\n' separators by importFileHdr.
        % Format per line: time_s conditionInt frameNumber
        eventsLines = strsplit(eventsStr, '\n');
        for iLine = 1:length(eventsLines)
            tmpLine = strtrim(eventsLines{iLine});
            if isempty(tmpLine) || strcmp(tmpLine, '#')
                continue;
            end
            vals = sscanf(tmpLine, '%f');
            if length(vals) >= 3
                % vals(1) = time in seconds (not used here)
                % vals(2) = condition integer (decimal)
                % vals(3) = frame number
                hdrEvents(end+1, :) = [vals(3), vals(2)]; %#ok<AGROW>
            end
        end
    end
end


% 4) Read events from .evt file

evtEvents = zeros(0, 2); % [frameNumber, conditionInt]

evtFiles = findFile(obj, '.*\.evt$', 'regexp');
if ~isempty(evtFiles)
    evtContent = importFileEvt(evtFiles{1});
    if ~isempty(evtContent) && size(evtContent, 2) == 9
        % Convert binary (LSB first) to decimal condition integer
        bitWeights = 2.^(0:7); % [1 2 4 8 16 32 64 128]
            %Vectorised .evt conversion: instead of looping per row,
            % the binary-to-decimal conversion uses a single
            % matrix multiplication evtContent(:, 2:9) * bitWeights'.
        condInts   = evtContent(:, 2:9) * bitWeights';
        evtEvents  = [evtContent(:, 1), condInts];
    end
end


% 5) Read events from .tri file (LSL markers), with timestamp repair
%
% The .tri format (modern NIRStar / Aurora) stores three columns:
%   timestamp (absolute ISO8601 datetime) | sample (frame number) | marker
%
% A NIRx hardware bug can occasionally cause the internal clock to jump
% backwards at a random sample, making timestamps unsorted while
% frame numbers remain correct (or vice versa). See
% icnna.io.rawData_nirx2snirf for further information.
% 
% In the face of such potential error, four cases arise:
%
%  * Both (frames and timestamps) are sorted - proceed normally.
%  * Frames sorted only - timestamps have clock errors; use frames as-is.
%  * Timestamps sorted only - frames have errors; recompute from timestamps.
%  * Neither sorted - unrecoverable; raise an error.
%
% Timestamp repair follows the same convention of
% icnna.io.rawdata_nirx2snirf, that is:
%
%   absTime_s = seconds(timestamps - timestamps(1)) + firstFrame/samplingRate
%   correctedFrame = round(absTime_s * samplingRate)
%
% where firstFrame is the (assumed correct) frame of the first event.
%

triEvents = zeros(0, 2); % [frameNumber, markerInt]

triFiles = findFile(obj, '.*\.tri$', 'regexp');
if ~isempty(triFiles)
    triContent = importFileTri(triFiles{1});
    if ~isempty(triContent) && height(triContent) > 0

        % 5a) Extract sample (frame) column
        tmpSamples = triContent.sample;
        if iscell(tmpSamples)
            tmpSamples = cellfun(@str2double, tmpSamples);
        end
        tmpSamples = tmpSamples(:); % ensure column vector

        % 5b) Extract marker column
        tmpMarkers = triContent.marker;
        if iscell(tmpMarkers)
            tmpMarkers = cellfun(@str2double, tmpMarkers);
        elseif isstring(tmpMarkers)
            tmpMarkers = double(tmpMarkers);
        end
        tmpMarkers = tmpMarkers(:); % ensure column vector

        % 5c) Timestamp consistency check and repair
        %
        % The check is only meaningful when readtable in importFileTri
        % successfully parsed column 1 as datetime (not as
        % string/cell). The isdatetime + ~all(isnat) guards
        % cover both failure modes.
        timestampsUsable = isdatetime(triContent.timestamp) && ...
                           ~all(isnat(triContent.timestamp));

        if timestampsUsable
            tmpTimes = triContent.timestamp; % datetime(:,1)

            isSamplesSorted    = isequal(tmpSamples, ...
                                         sort(tmpSamples, 'ascend'));
            isTimestampsSorted = isequal(tmpTimes, ...
                                         sort(tmpTimes,   'ascend'));

            if ~isSamplesSorted && ~isTimestampsSorted
                error(['icnna:data:misc:rawData_NIRx:import:' ...
                       'aux_getTimeline:triUnsortable'], ...
                      ['.tri file ''%s'' has neither sorted timestamps ' ...
                       'nor sorted frame numbers. Cannot recover the ' ...
                       'event timeline.'], triFiles{1});

            elseif isSamplesSorted && ~isTimestampsSorted
                % Frame numbers are reliable; timestamps have clock errors.
                % tmpSamples are already correct — no action needed.
                warning(['icnna:data:misc:rawData_NIRx:import:' ...
                         'aux_getTimeline:triTimestampUnsorted'], ...
                        ['Timestamps in .tri file ''%s'' are not in ' ...
                         'ascending order (possible NIRx clock drift ' ...
                         'or reset). Frame numbers are sorted and will ' ...
                         'be used for event timing.'], triFiles{1});

            elseif ~isSamplesSorted && isTimestampsSorted
                % Timestamps are reliable; frame numbers have errors.
                % Recompute frame numbers from relative timestamps,
                % anchored by the first event''s original frame number.
                warning(['icnna:data:misc:rawData_NIRx:import:' ...
                         'aux_getTimeline:triFramesUnsorted'], ...
                        ['Frame numbers in .tri file ''%s'' are not in ' ...
                         'ascending order. Timestamps are sorted; ' ...
                         'recomputing frame numbers from timestamps.'], ...
                        triFiles{1});

                % Convention (see icnna.io.rawdata_nirx2snirf.m):
                %   relToFirst_s  = time relative to first event [s]
                %   timeOffset_s  = scan time at first event = firstFrame/fs
                %   absFromScan_s = time from scan start [s]
                %   correctedFrame = round(absFromScan_s * samplingRate)
                timeOffset_s  = tmpSamples(1) / samplingRate;
                relToFirst_s  = seconds(tmpTimes - tmpTimes(1));
                absFromScan_s = relToFirst_s + timeOffset_s;
                tmpSamples    = round(absFromScan_s * samplingRate);

            % else: both sorted — no action needed
            end

        else
            % Timestamps not available as datetime (parsing failed or
            % column contains NaT). Use frame numbers as-is.
            % No warning: this is expected for some MATLAB versions or
            % non-standard timestamp formats.
        end

        triEvents = [tmpSamples, tmpMarkers];

    end % if triContent non-empty
end % if triFiles found


% 6) Last resort nSamples estimation from event frame numbers

if nSamples == 0
    allFrames = [hdrEvents(:,1); evtEvents(:,1); triEvents(:,1)];
    if ~isempty(allFrames)
        nSamples = max(allFrames);
        nSamplesSource = 'lastEventFrame'; %#ok<NASGU>
            %nSamplesSource variable: kept for traceability/debugging
            % even though it's not returned. The %#ok<NASGU> suppresses
            % the "unused variable" warning in MATLAB's code analyser.
        warning('icnna:data:misc:rawDataNIRx:import:aux_getTimeline:nSamplesEstimated', ...
                ['No data files (.wl1/.wl2/.snirf) found to determine ' ...
                 'nSamples. Estimated from last event frame number (%d). ' ...
                 'Timeline length may be shorter than actual recording.'], ...
                nSamples);
    else
        warning('icnna:data:misc:rawDataNIRx:import:aux_getTimeline:nSamplesUnknown', ...
                'No data files or events found. Timeline will be empty.');
    end
end


% 7) Create the timeline object

t = icnna.data.core.timeline();
t.unit               = 'seconds'; %Explicit: permeates to all conditions
                                         %via addCondition (see addCondition.m l.54-55)
t.timeUnitMultiplier = 0;         %Explicit: timestamps and events in seconds
                                         %(10^0 = 1 s). Default, but stated clearly
                                         %for readability.
t.nominalSamplingRate = samplingRate;
if nSamples > 0
    tmpTimestamps = (0:(nSamples - 1)) / samplingRate;
    t.timestamps = tmpTimestamps(:); %Ensure column vector [s]
end


% 8) Collect events and build conditions

% 8a) Merge NIRx events (.hdr + .evt) and deduplicate exact matches.
%     Rows with the same frame but different condition are preserved
%     (not a conflict; see Conflict Resolution in header).
nirxEvents = [hdrEvents; evtEvents];
nirxEvents = unique(nirxEvents, 'rows');

% 8b) Determine the full set of unique condition names across all sources.
%     Sorted alphabetically for deterministic ID assignment.
%     Note: "LSL:*" conditions will precede "NIRx:*" conditions.
uniqueNirxConds = unique(nirxEvents(:, 2)); %Unique NIRx condition integers
uniqueLslConds  = unique(triEvents(:, 2));  %Unique LSL condition integers




allCondNames = sort([ ...
    arrayfun(@(iC) ['NIRx:' num2str(iC)], uniqueNirxConds, 'UniformOutput', false); ...
    arrayfun(@(iC) ['LSL:'  num2str(iC)], uniqueLslConds,  'UniformOutput', false)  ...
]);

% 8c) Add each condition to the timeline.
%     The source event matrix is selected via a switch on the condition
%     prefix, avoiding any intermediate data structure.
for iCond = 1:length(allCondNames)
    condName = allCondNames{iCond};
    prefix   = extractBefore(condName, ':');
    condInt  = str2double(extractAfter(condName, ':'));

    switch prefix
        case 'NIRx'
            srcEvents = nirxEvents;
        case 'LSL'
            srcEvents = triEvents;
        otherwise
            warning('icnna:data:misc:rawDataNIRx:import:aux_getTimeline:UnknownConditionPrefix', ...
                    ['Unknown condition prefix ''%s''. ' ...
                     'Skipping condition ''%s''.'], prefix, condName);
            continue;
    end

    % Filter events for this condition
    mask          = srcEvents(:, 2) == condInt;
    evtOnsets     = srcEvents(mask, 1) / samplingRate; %Frame numbers -> seconds [s]
    nEvts         = sum(mask);
    evtDurations  = zeros(nEvts, 1);  % NIRx triggers carry no duration info
    evtAmplitudes = ones(nEvts, 1);

    % Crop events that extend beyond the end of the timeline.
    %
    % Two cases are handled independently:
    %
    %   (a) onset > timestamps(end)
    %       The event started after the recording ended. The onset is
    %       clamped to the last timestamp so the event is attributed to
    %       the final recorded sample; duration is forced to 0.
    %       Typical cause: LSL/PsychoPy trigger sent after the NIRx
    %       acquisition stopped, or a frame number that marginally
    %       overshoots nSamples after timestamp-based repair.
    %
    %   (b) onset <= timestamps(end), onset + duration > timestamps(end)
    %       The event started within the recording but its declared
    %       duration would carry it past the end. The duration is
    %       clipped so the event ends exactly at timestamps(end).
    %       Not currently reachable from NIRx sources (all durations
    %       are 0) but included for correctness and future use.
    %
    % A warning is issued for each case. Events are never silently
    % removed; the condition entry is always preserved.

    if nSamples > 0 && ~isempty(evtOnsets)
        tEnd = t.timestamps(end);

        % Case (a): onset beyond timeline — clamp to tEnd
        beyondMask = evtOnsets > tEnd;
        if any(beyondMask)
            warning(['icnna:data:misc:rawData_NIRx:import:' ...
                     'aux_getTimeline:eventOnsetClamped'], ...
                    ['%d event onset(s) in condition ''%s'' lie ' ...
                     'beyond the recording end (%.4f s) and have ' ...
                     'been clamped to the last timestamp. Duration ' ...
                     'set to 0 for those events.'], ...
                    sum(beyondMask), condName, tEnd);
            evtOnsets(beyondMask)    = tEnd;
            evtDurations(beyondMask) = 0;
        end

        % Case (b): duration overruns timeline — clip to tEnd
        overrunMask = (~beyondMask) & ...
                      (evtOnsets + evtDurations > tEnd);
        if any(overrunMask)
            warning(['icnna:data:misc:rawData_NIRx:import:' ...
                     'aux_getTimeline:eventDurationClipped'], ...
                    ['%d event duration(s) in condition ''%s'' extend ' ...
                     'beyond the recording end (%.4f s) and have ' ...
                     'been clipped to end exactly at that timestamp.'], ...
                    sum(overrunMask), condName, tEnd);
            evtDurations(overrunMask) = tEnd - evtOnsets(overrunMask);
        end

    end

    evtMatrix      = [evtOnsets, evtDurations, evtAmplitudes];
    exclusoryState = 0; %0 - Allow overlap; 1 - Exclusory

    t = addCondition(t, iCond, condName, evtMatrix, exclusoryState);
end


end

function [data] = aux_getData(obj,hdrContent)
% Retrieve the raw measurement data from the available NIRx session files.
%
% Attempts to retrieve data following this fallback chain:
%   1. .wl1 + .wl2 files (default; raw intensities/voltages per wavelength)
%   2. .snirf file (partially supported; see Remarks)
%   3. *_hboxy.NAV / *_hbred.NAV files (not yet implemented)
%
% Data is always returned as a 3D tensor [nSamples x nChannels x nSignals]
% to conform with the icnna.data.core.structuredData convention.
%
%% Channel ordering
%
% When reading from .wl1/.wl2 the channel ordering follows the
% [DataStructure]->S-D-Key field in the .hdr file. All channels
% declared in S-D-Key are imported. If S-D-Key is unavailable,
% columns from the .wl files are imported in natural order with
% a warning.
%
%% Assumptions and remarks
%
% - For the .wl1/.wl2 path: nSignals = 2 (one per wavelength).
%   The third dimension of the tensor is [wl1, wl2]. Signal labels
%   (wavelength values) are set separately in aux_getSignalTags.
%
% - For the .snirf path: only nirs(1).data(1).dataTimeSeries is
%   currently extracted. Multiple nirs groups or data groups are
%   noted with a warning but not yet fully supported. The
%   dataTimeSeries is wrapped as [nSamples x nColumns x 1] since
%   mapping measurementList columns to the [channel x signal]
%   dimensions requires full measurementList parsing, which is
%   deferred to a future implementation.
%
% - IMPORTANT: The structuredData.set.data setter will silently
%   extend or crop the timeline if nSamples does not match
%   timeline.length. This function and aux_getTimeline must
%   therefore read nSamples from the same source to guarantee
%   consistency.
%
% - If a wavelength file is missing (e.g. only .wl1 is present),
%   the missing wavelength slice is filled with NaN and a warning
%   is emitted.
%
%% Input parameters
%
% obj - @rawData_NIRx
%   A rawData_NIRx object with file references already populated.
%
% hdrContent - Dictionary
%   The parsed content of the header file.
%
%% Output
%
% data - double [nSamples x nChannels x nSignals]
%   A 3D tensor of measurement data. Returns zeros(0,0,0) if no
%   data source is found.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, importFileWl, importFileHdr, findFile,
%   aux_getTimeline, aux_getSignalTags
%

%% Log
%
% -- ICNNA v1.4.1
%
% 20-May-2026: FOE
%   + Function added.
%


data = zeros(0,0,0);

% 1) Try .wl1 / .wl2 (primary - raw intensity data)

wl1Files = findFile(obj, '.*\.wl1$', 'regexp');
wl2Files = findFile(obj, '.*\.wl2$', 'regexp');

if ~isempty(wl1Files) || ~isempty(wl2Files)

    % 1a) Read wavelength matrices
    wl1Data = [];
    if ~isempty(wl1Files)
        wl1Data = importFileWl(wl1Files{1});
    end
    wl2Data = [];
    if ~isempty(wl2Files)
        wl2Data = importFileWl(wl2Files{1});
    end

    % 1b) Handle missing wavelength: fill with NaN
    if isempty(wl1Data) && ~isempty(wl2Data)
        warning('icnna:data:misc:rawDataNIRx:import:aux_getData:MissingWl1', ...
                '.wl1 file not found. Wavelength 1 data filled with NaN.');
        wl1Data = NaN(size(wl2Data));
    elseif isempty(wl2Data) && ~isempty(wl1Data)
        warning('icnna:data:misc:rawDataNIRx:import:aux_getData:MissingWl2', ...
                '.wl2 file not found. Wavelength 2 data filled with NaN.');
        wl2Data = NaN(size(wl1Data));
    end

    nSamples = size(wl1Data, 1);
    nAllCols = size(wl1Data, 2); %nSources x nDetectors (all combinations)


    % 1c) Parse channel keys from .hdr to determine channel ordering
    %   Whether:
    %     S-D-Key format: "Si-Dj:colIdx,Si-Dj:colIdx,..."
    %     colIdx is the 1-based column index in the .wl files.
    %
    %   Or:
    %     Channel indices format: "Si-Dj, Si-Dj,..."
    sdKey = resolveChannelKey(hdrContent); %Will hold [nChannels x 3] = [source, detector, colIdx]


    % Fallback: if S-D-Key unavailable, use all columns in natural order
    if isempty(sdKey)
        warning('icnna:data:misc:rawDataNIRx:import:aux_getData:MissingSDKey', ...
                ['Channel indices not found in .hdr [DataStructure]. ' ...
                 'Importing all .wl columns in natural order.']);
        sdKey = [(1:nAllCols)', zeros(nAllCols, 1), (1:nAllCols)'];
            %[dummySource, dummyDetector, colIdx]
    end


    % 1d) Assemble 3D tensor [nSamples x nChannels x 2]
    colIndices = sdKey(:, 3); %1-based column indices in .wl files
    if max(colIndices) > size(wl1Data, 2)
        warning('icnna:data:misc:rawDataNIRx:import:aux_getData:ColIndexOutOfRange', ...
            'Channel indices references column %d but .wl file has only %d columns. Clipping.', ...
            max(colIndices), size(wl1Data,2));
        colIndices = min(colIndices, size(wl1Data, 2));
    end
    nChannels  = length(colIndices);
    data       = zeros(nSamples, nChannels, 2);
    data(:, :, 1) = wl1Data(:, colIndices);
    data(:, :, 2) = wl2Data(:, colIndices);
    return;

end


% 2) Try .snirf

snirfFiles = findFile(obj, '.*\.snirf$', 'regexp');
if ~isempty(snirfFiles)

    tmpSnirf  = icnna.data.snirf.snirf();
    snirfData = tmpSnirf.load(snirfFiles{1});

    % Handle multiple nirs groups (warn, use first only)
    nNirs = length(snirfData.nirs);
    if nNirs > 1
        warning('icnna:data:misc:rawDataNIRx:import:aux_getData:MultipleNirsGroups', ...
                ['SNIRF file contains %d nirs groups. ' ...
                 'Only nirs(1) will be used. ' ...
                 'Full multi-group support is not yet implemented.'], nNirs);
    end

    % Handle multiple data groups (warn, use first only)
    nDataGroups = length(snirfData.nirs(1).data);
    if nDataGroups > 1
        warning('icnna:data:misc:rawDataNIRx:import:aux_getData:MultipleDataGroups', ...
                ['SNIRF nirs(1) contains %d data groups. ' ...
                 'Only data(1) will be used. ' ...
                 'Full multi-group support is not yet implemented.'], nDataGroups);
    end

    % Parse measurementList to understand column structure
    probe                       = snirfData.nirs(1).probe;
    [mlInfo, uniqueSignalKeys]  = parseMeasurementList( ...
                                    snirfData.nirs(1).data(1).measurementList, ...
                                    probe);
    rawData  = snirfData.nirs(1).data(1).dataTimeSeries;
    nSamples = size(rawData, 1);
    nSignals = length(uniqueSignalKeys);

    % Determine channel ordering.
    % NOTE: No ordering assumption is made about the SNIRF converter.
    % The tensor is assembled by explicit (source,detector,signal) lookup
    % against measurementList regardless of the column order in
    % dataTimeSeries. sdKey provides the OUTPUT channel order only.
    sdKey = resolveChannelKey(hdrContent);
    if isempty(sdKey)
        % Fallback: derive channel order from first-appearance of unique
        % (source,detector) pairs in measurementList.
        warning('icnna:data:misc:rawDataNIRx:import:aux_getData:MissingSDKey', ...
                ['Channel indices not found in .hdr. Channel ordering derived ' ...
                 'from first-appearance of (source,detector) pairs ' ...
                 'in SNIRF measurementList.']);
        seenPairs = zeros(0, 2);
        for iCol = 1:height(mlInfo)
            pair = [mlInfo.sourceIndex(iCol), mlInfo.detectorIndex(iCol)];
            if ~any(seenPairs(:,1)==pair(1) & seenPairs(:,2)==pair(2))
                seenPairs(end+1, :) = pair; %#ok<AGROW>
            end
        end
        %Build sdKey-compatible matrix (col 3 set to 0; not used here)
        sdKey = [seenPairs, zeros(size(seenPairs,1), 1)];
    end

    nChannels = size(sdKey, 1);

    % Assemble 3D tensor [nSamples x nChannels x nSignals]
    % Initialise with NaN: unmatched combinations remain NaN.
    data         = NaN(nSamples, nChannels, nSignals);
    mlSources    = mlInfo.sourceIndex;
    mlDetectors  = mlInfo.detectorIndex;
    mlSignalKeys = mlInfo.signalKey;


    for iSig = 1:nSignals
        sigKey   = uniqueSignalKeys{iSig};
        sigMask  = strcmp(mlSignalKeys, sigKey);
        for iCh = 1:nChannels
            srcIdx  = sdKey(iCh, 1);
            detIdx  = sdKey(iCh, 2);
            colMask = sigMask & ...
                      (mlSources   == srcIdx) & ...
                      (mlDetectors == detIdx);
            if any(colMask)
                colIdx              = find(colMask, 1, 'first');
                data(:, iCh, iSig)  = rawData(:, colIdx);
            end
            %If no match: data(:,iCh,iSig) remains NaN (no warning
            %here; covered by verification step below).
        end
    end

    % Verification: warn on unmatched S-D-Key channels and
    % unused measurementList columns.
    usedCols = false(1, height(mlInfo));
    for iCh = 1:nChannels
        srcIdx  = sdKey(iCh, 1);
        detIdx  = sdKey(iCh, 2);
        chMask  = (mlSources == srcIdx) & (mlDetectors == detIdx);
        if ~any(chMask)
            warning('icnna:data:misc:rawDataNIRx:import:aux_getData:UnmatchedSDKeyChannel',...
                    ['S-D-Key channel S%d-D%d not found in SNIRF ' ...
                     'measurementList. Corresponding tensor slice ' ...
                     'will be NaN.'], srcIdx, detIdx);
        else
            usedCols(chMask) = true;
        end
    end

    unusedIdx = find(~usedCols);
    if ~isempty(unusedIdx)
        warning('icnna:data:misc:rawDataNIRx:import:aux_getData:UnusedSNIRFColumns', ...
                ['%d SNIRF measurementList column(s) were not matched ' ...
                 'by any S-D-Key channel and are excluded from the ' ...
                 'tensor. Column indices: %s.'], ...
                length(unusedIdx), num2str(unusedIdx));
    end

    return;

end


% 3) Try *_hboxy.NAV / *_hbred.NAV (not yet implemented)
navFiles = findFile(obj, '.*_hboxy\.NAV$', 'regexp');
if ~isempty(navFiles)
    warning('icnna:data:misc:rawDataNIRx:import:aux_getData:NAVReaderUnavailable', ...
            'NAV file reader not yet implemented. Cannot retrieve data from NAV files.');
    return;
end


% No data source found
warning('icnna:data:misc:rawDataNIRx:import:aux_getData:NoDataFound', ...
        ['No data files found (.wl1/.wl2, .snirf, or .nav). ' ...
         'Returning empty data tensor.']);

end



function [signalTags] = aux_getSignalTags(obj,hdrContent)
% Build the signal-tag label list for the nirs_neuroimage object.
%
% Signal tags identify the physical meaning of each slice in the third
% dimension of the data tensor [nSamples x nChannels x nSignals].
%
%% Label conventions
%
%   Raw intensity data (all non-processed SNIRF dataTypes):
%       'I(lambda=<wl>nm)'  where <wl> is the nominal wavelength in nm.
%       Fallback if wavelength unresolvable: 'I(wl<n>)' (no nm suffix).
%
%       Note: For non-CW modalities (FD-Phase, DCS-g2, etc.) this label
%       is physically inaccurate. Type-specific prefixes (e.g. phi(...),
%       g2(...)) are deferred to a future implementation. The inaccuracy
%       is documented here to facilitate that later work.
%
%   Processed/reconstructed data (SNIRF dataType == 99999):
%       dataTypeLabel verbatim (e.g. 'HbO', 'HbR', 'HbT', 'mua', 'StO2').
%       Fallback if dataTypeLabel is empty: 'proc<dataTypeIndex>'.
%
%% Output format and classVersion
%
% The output type depends on the classVersion of nirs_neuroimage:
%   classVersion '1.0': cell array of char strings.
%   Future versions: icnna.data.core.signalDescriptor array (stub; falls
%   back to cell strings with a warning).
%
%% Alignment with aux_getData
%
% This function mirrors the fallback chain of aux_getData. Labels are
% produced in the same order as the tensor signal slices:
%   .wl path  -- order matches .hdr Wavelengths field (wl1 first).
%   .snirf path -- order follows uniqueSignalKeys from parseMeasurementList,
%                  which preserves first-appearance order in measurementList.
%
%% Input parameters
%
% obj - @rawData_NIRx
%   A rawData_NIRx object with file references already populated.
%
% hdrContent - Dictionary
%   The parsed content of the header file.
%
%% Output
%
% signalTags - cell{1 x nSignals} of char[] (classVersion 1.0)
%   Physical signal labels, one per tensor signal slice.
%   Returns {} if no data source is found.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, aux_getData, parseMeasurementList,
%   nirs_neuroimage, icnna.data.core.signalDescriptor
%

%% Log
%
% -- ICNNA v1.4.1
%
% 21/22-May-2026: FOE
%   + Function added.
%
% 22-May-2026: FOE
%   + Wavelength resolution refactored into resolveWavelengths.
%     Now covers all .hdr sections (not just GeneralInfo/ImagingParameters),
%     with companion .snirf and hardcoded-default fallback steps.
%

signalTags = {};


% Determine classVersion of nirs_neuroimage to select output format
tmpNI            = nirs_neuroimage();
nirsClassVersion = classVersion(tmpNI);
clear tmpNI;


% 1) .wl1 / .wl2 path (CW raw intensity; always exactly 2 wavelengths)
wl1Files = findFile(obj, '.*\.wl1$', 'regexp');
wl2Files = findFile(obj, '.*\.wl2$', 'regexp');

if ~isempty(wl1Files) || ~isempty(wl2Files)

    wavelengths  = resolveWavelengths(obj, hdrContent);
    uniqueLabels = arrayfun(@(iWl) ['I(lambda=' num2str(iWl) 'nm)'], ...
                            wavelengths, 'UniformOutput', false);


else % 2) .snirf path

    snirfFiles = findFile(obj, '.*\.snirf$', 'regexp');
    if ~isempty(snirfFiles)

        tmpSnirf  = icnna.data.snirf.snirf();
        snirfData = tmpSnirf.load(snirfFiles{1});
        probe     = snirfData.nirs(1).probe;
        [mlTable, uniqueSignalKeys] = parseMeasurementList( ...
                                        snirfData.nirs(1).data(1).measurementList, ...
                                        probe);

        nSignals     = length(uniqueSignalKeys);
        uniqueLabels = cell(1, nSignals);
        for iSig = 1:nSignals
            % Find first mlTable row that carries this signal key
            rowIdx = find(strcmp(mlTable.signalKey, uniqueSignalKeys{iSig}), 1, 'first');
            uniqueLabels{iSig} = buildSignalLabel( ...
                mlTable.dataType(rowIdx), ...
                mlTable.dataTypeLabel{rowIdx}, ...
                mlTable.wavelengthValue(rowIdx), ...
                mlTable.wavelengthIndex(rowIdx), ...
                mlTable.dataTypeIndex(rowIdx));
        end

    else
        return; % No data source found
    end

end


% Format output according to classVersion

%NOTE: The >1.0 branch below is forward-facing (future signalDescriptor
%representation), not a dead legacy branch. Retain! do not assert away.
if icnna.util.compareVersions(nirsClassVersion, '1.0', '<=')
    signalTags = uniqueLabels;
else
    warning('icnna:data:misc:rawDataNIRx:import:aux_getSignalTags:SignalDescriptorNotImplemented', ...
            ['nirs_neuroimage classVersion %s expects signalDescriptor ' ...
             'objects; not yet implemented. Returning cell string labels.'], ...
            nirsClassVersion);
    signalTags = uniqueLabels;
end

end




function [integrity] = aux_getIntegrity(obj,hdrContent)
% Initialise an integrityStatus object sized to the channel count for
% this NIRx session.
%
% All elements are set to UNCHECK (-1). Actual integrity assessment is
% performed downstream by runIntegrity / runIntegrityOnRaw, which may
% draw on the NIRx gain settings ([GainSettings]->Gains) and channel
% mask ([DataStructure]->S-D-Mask) stored in the .hdr file.
%
%% Input parameters
%
% obj - @rawData_NIRx
%   A rawData_NIRx object with file references already populated.
%
% hdrContent - Dictionary
%   The parsed content of the header file.
%
%% Output
%
% integrity - integrityStatus (scalar)
%   Unchecked integrity record sized to nChannels (from S-D-Key).
%   If the .hdr or S-D-Key is absent, an empty integrityStatus() is
%   returned; structuredData will resize it when data is assigned.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, integrityStatus, resolveChannelKey
%

%% Log
%
% -- ICNNA v1.4.1
%
% 21-May-2026: FOE
%   + Function added.
%


integrity = integrityStatus(); % Default: empty; resized below if possible

sdKey     = resolveChannelKey(hdrContent);
nChannels = size(sdKey, 1);

if nChannels > 0
    integrity = integrityStatus(nChannels); % All UNCHECK (-1)
end

end


function [clm] = aux_getCLM(obj, hdrContent)
%Build a channelLocationMap from NIRx probe information.
%
% [clm] = aux_getCLM(obj, hdrContent)
%
% Constructs an ICNNA @channelLocationMap from the NIRx probe definition.
%
% Channel pairings are sourced from the S-D-Key in the .hdr file (parsed
% via resolveChannelKey).  The number of sources and detectors is derived from
% the highest indices that actually appear in the S-D-Key, not from the
% [GeneralInfo] fields, which may reflect hardware capability rather
% than actual probe geometry.  A warning is emitted when the two counts
% differ.
%
% Optode 3D positions are populated, in order of preference, from:
%   (1) A _probeInfo.mat file (NIRStar 14.1+ format).
%   (2) A digpoints.txt or digpts.txt digitisation file.
%   (3) Not populated (optodesLocations left as NaN) if neither is found.
%
% Channel 3D positions are always estimated as the midpoint of the
% corresponding source and detector positions (when positions are available).
%
% Optode index convention (ICNNA standard):
%   1 : nSources           -- OPTODE_TYPE_EMISOR
%   nSources+1 : nOptodes  -- OPTODE_TYPE_DETECTOR
%
%% Assumptions
%
% * hdrContent is the struct returned by importFileHdr (may be []).
% * resolveChannelKey, findFile, parseDigpoints are local functions in
%   import.m.
% * probeInfo.mat follows NIRStar 14.1+ layout:
%     probeInfo.probes.{coords_s3, coords_d3, nSource0, nDetector0}
% * parseDigpoints returns [sources, detectors, fiducials] where sources
%   and detectors are indexed by label number (sources(k,:) = source k).
%
%% Input parameters
%
% obj        - @rawData_NIRx.  The object being imported.
% hdrContent - dictionary | [].
%   Parsed .hdr content (see importFileHdr).
%
%% Output parameters
%
% clm - @channelLocationMap.  An empty channelLocationMap is returned when
%       the channel indices is absent or cannot be parsed.
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also channelLocationMap, snirfProbe2channelLocationMap

%% Log
%
% -- ICNNA v1.4.1
%
% 21-May-2026: FOE/Claude
%   + Function created (transient research session, rawData_NIRx adaptation).
%


%% Initialise output

clm = channelLocationMap();


% 1)Parse channel keys (source-detector pairings)
%
% resolveChannelKey returns an nChannels x 3 matrix:
%   col 1: source index (1-based)
%   col 2: detector index (1-based)
%   col 3: column index in .wl files (1-based)

sdKey = resolveChannelKey(hdrContent);

if isempty(sdKey)
    warning('icnna:rawData_NIRx:import:aux_getCLM:MissingChannelKey', ...
        ['Channel key absent or empty in .hdr. ' ...
         'Returning an empty channelLocationMap.']);
    return;
end

nChannels  = size(sdKey,1);


% 2) Derive nSources / nDetectors from S-D-Key
%
% Use the maximum indices that appear in the pairings as authoritative
% counts.  Cross-check against [GeneralInfo] and warn on mismatch.

nSources   = max(sdKey(:,1));
nDetectors = max(sdKey(:,2));
nOptodes   = nSources + nDetectors;

if ~isempty(hdrContent) && isKey(hdrContent, "GeneralInfo")
    ip = hdrContent("GeneralInfo");
    if isKey(ip, "Sources")
        hdrNSrc = str2double(char(ip("Sources")));
        if ~isnan(hdrNSrc) && hdrNSrc ~= nSources
            warning('icnna:rawData_NIRx:import:aux_getCLM:sourceCountMismatch', ...
                ['S-D-Key implies %d source(s); ' ...
                 '[GeneralInfo] Sources = %d. ' ...
                 'Using S-D-Key count.'], nSources, hdrNSrc);
        end
    end
    if isKey(ip, "Detectors")
        hdrNDet = str2double(char(ip("Detectors")));
        if ~isnan(hdrNDet) && hdrNDet ~= nDetectors
            warning('icnna:rawData_NIRx:import:aux_getCLM:detectorCountMismatch', ...
                ['S-D-Key implies %d detector(s); ' ...
                 '[GeneralInfo] Detectors = %d. ' ...
                 'Using S-D-Key count.'], nDetectors, hdrNDet);
        end
    end
end


% 3) Collect 3D positions (before building CLM)
%
% Try to gather optode and channel positions now so that the CLM can
% be fully populated in a single, ordered pass (Step 4 below).
%
% srcPos      : nSources   x 3  optode 3D positions for sources
% detPos      : nDetectors x 3  optode 3D positions for detectors
% channelPos  : nChannels  x 3  channel midpoints
% fiducials   : struct array(.name, .location) — reference points
% positionsOk : logical flag

srcPos     = [];
detPos     = [];
channelPos = [];
fiducials  = struct('name',{},'location',{});
positionsOk = false;

% --- Attempt 1: *_probeInfo.mat (NIRStar 14.1+) ---
probeInfoFiles = findFile(obj,'.*_probeInfo\.mat$','regexp');
if ~isempty(probeInfoFiles)
    try
        tmp = load(probeInfoFiles{1},'probeInfo');
        p   = tmp.probeInfo.probes;

        if isfield(p,'coords_s3') && isfield(p,'coords_d3') ...
                && size(p.coords_s3,1) >= nSources   ...
                && size(p.coords_d3,1) >= nDetectors

            srcPos = p.coords_s3(1:nSources,   :);
            detPos = p.coords_d3(1:nDetectors,  :);

            % Channel positions: midpoint between source and detector
            channelPos = zeros(nChannels,3);
            for iCh = 1:nChannels
                iSrc = sdKey(iCh,1);
                iDet = sdKey(iCh,2);
                channelPos(iCh,:) = ...
                    (srcPos(iSrc,:) + detPos(iDet,:)) / 2;
            end

            positionsOk = true;
        else
            warning('icnna:rawData_NIRx:import:aux_getCLM:probeInfoDimMismatch', ...
                ['probeInfo.mat coords_s3/coords_d3 are smaller than ' ...
                 'the channel map requires (%d sources, %d detectors). ' ...
                 'Falling back to digitisation file.'], ...
                nSources, nDetectors);
        end

    catch ME
        warning('icnna:rawData_NIRx:import:aux_getCLM:probeInfoLoadFailed', ...
            'Failed to load probeInfo.mat: %s', ME.message);
    end
end

% --- Attempt 2: digpoints.txt / digpts.txt ---
if ~positionsOk
    digFiles = [findFile(obj,'.*digpoints\.txt$','regexp'), ...
                findFile(obj,'.*digpts\.txt$',    'regexp')];

    if ~isempty(digFiles)
        try
            rawStr = fileread(digFiles{1});
            [srcDig, detDig, fidDig] = parseDigpoints(rawStr);

            if ~isempty(srcDig) && size(srcDig,1) >= nSources   ...
                    && ~isempty(detDig) && size(detDig,1) >= nDetectors

                srcPos = srcDig(1:nSources,   :);
                detPos = detDig(1:nDetectors,  :);

                channelPos = zeros(nChannels,3);
                for iCh = 1:nChannels
                    iSrc = sdKey(iCh,1);
                    iDet = sdKey(iCh,2);
                    channelPos(iCh,:) = ...
                        (srcPos(iSrc,:) + detPos(iDet,:)) / 2;
                end

                fiducials   = fidDig;
                positionsOk = true;
            else
                warning('icnna:rawData_NIRx:import:aux_getCLM:digpointsDimMismatch', ...
                    ['Digitisation file has fewer entries than required ' ...
                     '(%d sources, %d detectors). ' ...
                     '3D positions will be left as NaN.'], ...
                    nSources, nDetectors);
            end

        catch ME
            warning('icnna:rawData_NIRx:import:aux_getCLM:digpointsReadFailed', ...
                'Failed to read digitisation file: %s', ME.message);
        end
    end
end

if ~positionsOk
    warning('icnna:rawData_NIRx:import:aux_getCLM:noPositionData', ...
        ['No probeInfo.mat or digitisation file found. ' ...
         'Optode and channel 3D positions will be left as NaN.']);
end


% 4) Build CLM
%
% Setter order follows snirfProbe2channelLocationMap:
%   nOptodes -> optodesLocations -> setOptodeTypes -> setOptodeProbeSets
%   -> nChannels -> setPairings -> setChannel3DLocations -> setChannelProbeSets
%   -> referencePoints

% --- 4a: Optodes ---

clm.nOptodes = nOptodes;

if positionsOk
    clm.optodesLocations = [srcPos; detPos];
end

clm = clm.setOptodeTypes( ...
        1:nSources, ...
        clm.OPTODE_TYPE_EMISOR * ones(nSources,1));

clm = clm.setOptodeTypes( ...
        nSources + (1:nDetectors), ...
        clm.OPTODE_TYPE_DETECTOR * ones(nDetectors,1));

clm = clm.setOptodeProbeSets( ...
        1:nOptodes, ...
        ones(nOptodes,1));

% --- 4b: Channels ---

clm.nChannels = nChannels;

% Pairings: [sourceOptodeIdx, detectorOptodeIdx]
% Detectors occupy slots nSources+1 : nOptodes.
pairings = [sdKey(:,1),  nSources + sdKey(:,2)];
clm = clm.setPairings(1:nChannels, pairings);

if positionsOk
    clm = clm.setChannel3DLocations(1:nChannels, channelPos);
end

clm = clm.setChannelProbeSets(1:nChannels, ones(nChannels,1));

% --- 4c: Reference points (fiducials) ---

if ~isempty(fiducials)
    clm.referencePoints = fiducials;
end

end







function [sdKey] = resolveChannelKey(hdrContent)
% Resolve the channel ordering from the .hdr content dictionary.
%
% Two formats are supported, tried in this order:
%
%   1. Old format — [DataStructure] -> S-D-Key (NIRStar ≤ 14.x)
%         "Si-Dj:colIdx, ..."
%      Indices are 1-based. colIdx is the explicit column index in
%      the .wl files.
%
%   2. New format — "Channel indices" in any section (NIRStar 15+)
%         "Si-Dj, ..."  (value on the line following the key)
%      Indices are 0-based. colIdx is assigned as the list position
%      (1-based), which matches the column order in the .wl files.
%
% In both cases the output triplet [source, detector, colIdx] uses
% 1-based indices and is suitable for direct use by aux_getData,
% aux_getCLM, and aux_getIntegrity without any further conversion.
%
%% Assumptions
%
% - When both S-D-Key and Channel indices are present, S-D-Key wins.
% - Channel indices is assumed to list channels in the same order as
%   the columns of the .wl files (i.e. colIdx = list position).
%
%% Input parameters
%
% hdrContent - dictionary | []
%   The parsed .hdr content as returned by importFileHdr.
%
%% Output
%
% sdKey - double [nChannels x 3]
%       col 1: sourceIndex   (1-based)
%       col 2: detectorIndex (1-based)
%       col 3: colIdx        (1-based column index in .wl files)
%   Returns zeros(0,3) if neither key is found.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, aux_getData, aux_getCLM, importFileHdr


%% Log
%
% -- ICNNA v1.4.1
%
% 21-May-2026: FOE
%   + Function added. Refactored out of aux_getData.
%
% 22-May-2026: FOE
%   + Extended to support the modern NIRStar "Channel indices" format.
%     Old S-D-Key format is tried first to preserve backward compatibility.
%     Parsing delegated to private helpers parseKey_SDKey and
%     parseKey_ChannelIndices.
%   + Renamed resolveChannelKey from parseSDKey as it now can resolve
%     NIRx key-value pairs either "S-D-Key" or "Channel indices".
%


sdKey = zeros(0, 3);

if isempty(hdrContent)
    return;
end

% --- Attempt 1: old format ---
if isKey(hdrContent, "DataStructure")
    dsSection = hdrContent("DataStructure");
    if isKey(dsSection, "S-D-Key")
        sdKey = parseKey_SDKey(char(dsSection("S-D-Key")));
        if ~isempty(sdKey), return; end
    end
end

% --- Attempt 2: new format (search every section) ---
sectionNames = keys(hdrContent);
for iSec = 1:length(sectionNames)
    sec = hdrContent(sectionNames(iSec));
    if isKey(sec, "Channel indices")
        sdKey = parseKey_ChannelIndices(char(sec("Channel indices")));
        if ~isempty(sdKey), return; end
    end
end

warning('icnna:data:misc:rawData_NIRx:import:resolveChannelKey:NoChannelKey', ...
        ['Neither S-D-Key nor "Channel indices" found in .hdr. ' ...
         'Channel ordering unavailable.']);

end




function sdKey = parseKey_SDKey(sdKeyStr)
%Parses a NIRStar S-D-Key string into a channel table.
%
% sdKey = parseKey_SDKey(sdKeyStr)
%
% Converts the raw string value of the [DataStructure]->S-D-Key field
% (as stored by importFileHdr) into the standard ICNNA channel ordering
% table used throughout import.m.
%
%% Example of use
%
%   sdKeyStr = '"1-1:1,1-2:2,2-1:3,2-2:4"';
%   sdKey = parseKey_SDKey(sdKeyStr);
%   % sdKey = [1 1 1; 1 2 2; 2 1 3; 2 2 4]
%
%% Assumptions and remarks
%
% - Input format (post importFileHdr parsing):
%       '"Si-Dj:colIdx, Si-Dj:colIdx, ...\n..."'
%   where Si and Dj are 1-based source and detector indices, and
%   colIdx is the explicit 1-based column index in the .wl files.
%   Surrounding quotes and literal '\n' separators are stripped
%   internally before parsing.
%
% - Entries that do not match the expected pattern Si-Dj:colIdx are
%   silently skipped (no warning). This tolerates minor formatting
%   artefacts without aborting the parse.
%
% - Returns zeros(0,3) if the input string is empty or contains no
%   valid entries. Callers are responsible for handling this case.
%
%% Error handling
%
% No errors are raised. Malformed entries are skipped silently.
% The caller (resolveChannelKey) emits a warning if the returned table is
% empty and no alternative channel key was found.
%
%% Input parameters
%
% sdKeyStr - char[]
%   Raw value of the S-D-Key field as returned by importFileHdr.
%   May include surrounding double quotes and literal '\n' separators
%   from multiline parsing. Must not be empty (checked by caller).
%
%% Output
%
% sdKey - double [nChannels x 3]
%   Ordered channel table. Columns are:
%       1: sourceIndex   (integer, 1-based)
%       2: detectorIndex (integer, 1-based)
%       3: colIdx        (integer, 1-based column index in .wl files)
%   Returns zeros(0,3) if no valid entries are found.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also resolveChannelKey, parseKey_ChannelIndices, importFileHdr


%% Log
%
% -- ICNNA v1.4.1
%
% 22-May-2026: FOE
%   + Function added. Extracted from the original monolithic parseSDKey
%   (now renamed resolveChannelKey) to allow independent handling
%   of old and new NIRStar .hdr formats.
%

sdKey    = zeros(0, 3);
sdKeyStr = strtrim(sdKeyStr);

% Strip surrounding quotes and literal '\n' separators inserted by
% importFileHdr during multiline value accumulation.
if ~isempty(sdKeyStr) && sdKeyStr(1)   == '"', sdKeyStr(1)   = []; end
if ~isempty(sdKeyStr) && sdKeyStr(end) == '"', sdKeyStr(end) = []; end
sdKeyStr = strrep(sdKeyStr, '\n', '');

% Parse comma-separated 'Si-Dj:colIdx' entries.
entries  = strsplit(strtrim(sdKeyStr), ',');
nChRaw   = length(entries);
sdKey    = zeros(nChRaw, 3);   % Pre-allocate; trimmed at end.
iChValid = 0;

for iCh = 1:nChRaw
    entry = strtrim(entries{iCh});
    if isempty(entry), continue; end
    tokens = regexp(entry, '(\d+)-(\d+):(\d+)', 'tokens');
    if ~isempty(tokens)
        iChValid           = iChValid + 1;
        sdKey(iChValid, :) = str2double(tokens{1});
    end
end

sdKey = sdKey(1:iChValid, :);   % Trim unused pre-allocated rows.

end




function sdKey = parseKey_ChannelIndices(indicesStr)
%Parses a modern NIRStar "Channel indices" string into a channel table.
%
% sdKey = parseKey_ChannelIndices(indicesStr)
%
% Converts the raw string value of the "Channel indices" field (as
% stored by importFileHdr) into the standard ICNNA channel ordering
% table used throughout import.m.
%
%% Example of use
%
%   indicesStr = char(10) + '0-0, 0-1, 1-0, 1-2';
%       % (leading newline is typical when value follows key on next line)
%   sdKey = parseKey_ChannelIndices(indicesStr);
%   % sdKey = [1 1 1; 1 2 2; 2 1 3; 2 3 4]
%
%% Assumptions and remarks
%
% - Input format (post importFileHdr parsing):
%       '\nSi-Dj, Si-Dj, ...'
%   where Si and Dj are 0-based source and detector indices.
%   The leading '\n' arises because the value in the .hdr file starts
%   on the line following the key (i.e. the value after '=' is empty
%   and importFileHdr attaches the next line via the no-'=' fallback).
%   Leading and trailing whitespace and literal '\n' separators are
%   stripped internally before parsing.
%
% - Source and detector indices are 0-based in this format and are
%   converted to 1-based on output, consistent with the output of
%   parseKey_SDKey and with ICNNA's internal optode indexing convention.
%
% - The column index (col 3 of the output) is assigned as the 1-based
%   position of the entry in the list. This assumes that NIRStar writes
%   the "Channel indices" list in the same order as the columns of the
%   .wl files. This assumption holds for all versions of NIRStar known
%   at the time of writing but is not formally guaranteed by any public
%   specification. Flag any observed mismatch for investigation.
%
% - Entries that do not match the expected pattern Si-Dj are silently
%   skipped (no warning). This tolerates minor formatting artefacts
%   such as trailing commas without aborting the parse.
%
% - Returns zeros(0,3) if the input string is empty or contains no
%   valid entries. Callers are responsible for handling this case.
%
%% Error handling
%
% No errors are raised. Malformed entries are skipped silently.
% The caller (resolveChannelKey) emits a warning if the returned
% table is empty and no alternative channel key was found.
%
%% Input parameters
%
% indicesStr - char[]
%   Raw value of the "Channel indices" field as returned by
%   importFileHdr. Typically begins with a literal '\n' followed by
%   a comma-separated list of Si-Dj pairs. Must not be empty
%   (checked by caller).
%
%% Output
%
% sdKey - double [nChannels x 3]
%   Ordered channel table. Columns are:
%       1: sourceIndex   (integer, 1-based)
%       2: detectorIndex (integer, 1-based)
%       3: colIdx        (integer, 1-based list position; assumed to
%                         match column order in the .wl files)
%   Returns zeros(0,3) if no valid entries are found.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also resolveChannelKey, parseKey_SDKey, importFileHdr


%% Log
%
% -- ICNNA v1.4.1
%
% 22-May-2026: FOE
%   + Function added to support the modern NIRStar "Channel indices"
%     .hdr field, introduced alongside parseKey_SDKey as part of the
%     refactoring of the former monolithic parseSDKey into the
%     resolveChannelKey dispatcher pattern.
%


sdKey      = zeros(0, 3);
indicesStr = strtrim(strrep(indicesStr, '\n', ''));

if isempty(indicesStr)
    return;
end

% Parse comma-separated 'Si-Dj' entries.
entries  = strsplit(indicesStr, ',');
nChRaw   = length(entries);
sdKey    = zeros(nChRaw, 3);   % Pre-allocate; trimmed at end.
iChValid = 0;

for iCh = 1:nChRaw
    entry = strtrim(entries{iCh});
    if isempty(entry), continue; end
    tokens = regexp(entry, '(\d+)-(\d+)', 'tokens');
    if ~isempty(tokens)
        iChValid           = iChValid + 1;
        src = str2double(tokens{1}{1}) + 1;   % 0-based → 1-based
        det = str2double(tokens{1}{2}) + 1;   % 0-based → 1-based
        sdKey(iChValid, :) = [src, det, iChValid];
    end
end

sdKey = sdKey(1:iChValid, :);   % Trim unused pre-allocated rows.

end







function wl = resolveWavelengths(obj, hdrContent)
%Resolve the measurement wavelengths for a NIRx dataset.
%
% wl = resolveWavelengths(obj, hdrContent)
%
%
%% About the resolution of the wavelengths
%
% In old NIRx's file formats, the wavelengths were to be expected
% in .hdr section [ImagingParameters]. However, in more recent file
% formats, the wavelengths may be completely absent. It may be the
% case that NIRx hard-codes them somehow, but for us it means that
% we need to fallback to some other ways to find out the
% values for the wavelengths. Note that the wavelengths may differ
% across NIRx devices. Now in the modern file version, the
% [GeneralInfo] section has a key value pair for key "Device ID"
% e.g. "Device ID=1911_0039_A" but unfortunately this is not the
% device model so that is insufficient information. So here is
% the strategy;
%
% Attempts to determine the wavelengths (in nm) used during the fNIRS
% measurement. Three steps are sequentially tried in order:
%
%   Step 1 - Broad .hdr search
%       Every section and every key in hdrContent is searched
%       case-insensitively for a key named 'Wavelengths'. This covers
%       both the old NIRStar format ([ImagingParameters]) and any future
%       section renames. The value is expected to be a space-separated
%       list of numeric values (e.g. "760 850").
%
%   Step 2 - Companion .snirf file
%       If a .snirf file is present in obj.path, it is loaded via
%       icnna.data.snirf.snirf.load and probe.wavelengths is read from
%       the first nirsDataset. This is reliable for modern NIRx systems
%       (NIRStar 15+ / Aurora) that generate both .wl and .snirf files
%       simultaneously, because the SNIRF specification mandates
%       probe.wavelengths as a required field.
%
%   Step 3 - Hardcoded default [760, 850] nm
%       Applied when neither Tier 1 nor Tier 2 yields a result. A warning
%       is issued. The default is justified by device prevalence: The
%       large majority of NIRx fNIRS systems - NIRScout 816/1616, 
%       NIRSport 1/2, and NIRSport2/16 - all operate at 760 and 850 nm.
%       Other NIRx devices (e.g. DYNOT at 760/830 nm) will receive
%       incorrect labels and the warning will flag this.
%
%% Assumptions and remarks
%
% - This function is intended for the .wl data path only. On the .snirf
%   path, wavelengths are resolved directly from probe.wavelengths via
%   parseMeasurementList and this function is not called.
%
% - Tier 2 loads the full .snirf file; it is only triggered when Tier 1
%   fails. For modern NIRx datasets that include a companion .snirf, this
%   imposes a one-time loading cost on an edge-case fallback path.
%
% - If multiple .snirf files are found, only the first is used.
%
% - probe.wavelengths in icnna.data.snirf.probe is a required SNIRF field
%   and is always present. However, the default value is nan(0,1) when
%   the field was not populated by the loader. The check ~isempty and
%   all(isfinite(...)) guards against this case.
%
%% Error handling
%
% No errors are raised. Each tier falls through gracefully on failure.
% A warning is emitted only at Step 3 (hardcoded default) and when the
% Step 2 .snirf load itself fails.
%
%% Input parameters
%
% obj - @rawData_NIRx
%   The object being imported. Used by findFile (Step 2) to locate
%   companion .snirf files relative to obj.path.
%
% hdrContent - dictionary | []
%   Parsed .hdr content as returned by importFileHdr. May be empty
%   if .hdr was not found or could not be parsed; Step 1 is then
%   skipped gracefully.
%
%% Output
%
% wl - double [1 x nWavelengths]
%   Wavelength values in nm, as a row vector. Always non-empty:
%   if all tiers fail, returns the Step 3 default [760, 850].
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also rawData_NIRx, aux_getSignalTags, resolveChannelKey,
%   icnna.data.snirf.snirf, icnna.data.snirf.probe


%% Log
%
% -- ICNNA v1.4.1
%
% 22-May-2026: FOE
%   + Function added. Refactored wavelength lookup out of
%     aux_getSignalTags into this dedicated three-step resolver,
%     extending coverage to a broad .hdr scan (all sections) and
%     companion .snirf fallback.
%


% 1) Search .hdr (all sections, case-insensitive)

if ~isempty(hdrContent)
    sectionNames = keys(hdrContent);
    for iSec = 1:length(sectionNames)
        sec     = hdrContent(sectionNames(iSec));
        secKeys = keys(sec);
        for iKey = 1:length(secKeys)
            if strcmpi(char(secKeys(iKey)), 'Wavelengths')
                wlStr = strtrim(char(sec(secKeys(iKey))));
                % Strip surrounding quotes if present
                if ~isempty(wlStr) && wlStr(1)   == '"', wlStr(1)   = []; end
                if ~isempty(wlStr) && wlStr(end) == '"', wlStr(end) = []; end
                wl = str2num(wlStr); %#ok<ST2NM> space-separated list
                    %Do not use str2double here.
                    %The wavelengths value is a space-separated list of
                    %multiple numbers e.g. "760 850". str2num handles this
                    %naturally whereas str2double returns NaN on such input.
                if ~isempty(wl)
                    wl = wl(:)'; % ensure row vector
                    return;
                end
            end
        end
    end
end


% 2) Search in the companion .snirf file if present
snirfFiles = findFile(obj, '.*\.snirf$', 'regexp');
if ~isempty(snirfFiles)
    try
        snirfObj = icnna.data.snirf.snirf.load(snirfFiles{1});
        if snirfObj.nNirsDatasets > 0
            wlTmp = snirfObj.nirs(1).probe.wavelengths; % (:,1) double
            if ~isempty(wlTmp) && all(isfinite(wlTmp))
                wl = wlTmp(:)'; % column → row vector
                return;
            end
        end
    catch ME
        warning('icnna:data:misc:rawData_NIRx:import:resolveWavelengths:SNIRFLoadFailed', ...
            ['Failed to load companion .snirf file for wavelength ' ...
             'resolution: %s'], ME.message);
    end
end


% 3) Hardcoded default 
wl = [760, 850];
warning('icnna:data:misc:rawData_NIRx:import:resolveWavelengths:UsingDefaultWavelengths', ...
    ['No wavelength information found in .hdr or companion .snirf. ' ...
     'Defaulting to [760, 850] nm - the most common NIRx fNIRS ' ...
     'configuration (NIRScout 816/1616, NIRSport 1/2, NIRSport2/16). ' ...
     'If your device uses different wavelengths (e.g. DYNOT: ' ...
     '[760, 830] nm), verify the signal labels in the output ' ...
     'nirs_neuroimage.']);

end






function [mlTable, uniqueSignalKeys] = parseMeasurementList(measurementList, probe)
% Parse a SNIRF measurementList into per-column structured metadata,
% augmented with a resolved wavelength value and a signal key.
%
% Delegates the core measurement list extraction to
% icnna.op.snirf.unfoldMeasurementList, then augments the resulting
% table with two additional columns:
%
%   wavelengthValue - Resolved wavelength in nm.
%   signalKey       - Compact string identifying the signal type.
%
% The signalKey is used both for assembling the ICNNA 3D tensor
% (aux_getData) and for generating signal tags (aux_getSignalTags).
%
%% Signal key convention
%
% The signalKey format depends on the SNIRF dataType field
% (SNIRF specification v1.1):
%
%   Raw data (dataType 1-500): '<typeStr>:<wavelengthValue>'
%       where typeStr is a short mnemonic:
%
%       dataType  typeStr       Description
%       --------  ----------    --------------------------------
%       001       CW            CW amplitude
%       051       Fluo-CW       CW fluorescence amplitude
%       101       FD-AC         FD AC amplitude
%       102       FD-Phase      FD phase
%       151       Fluo-FD-AC    FD fluorescence amplitude
%       152       Fluo-FD-Ph    FD fluorescence phase
%       201       TDG           TD gated amplitude
%       251       Fluo-TDG      TD gated fluorescence amplitude
%       301       TDM           TD moments amplitude
%       351       Fluo-TDM      TD moments fluorescence amplitude
%       401       DCS-g2        DCS g2
%       410       DCS-BFi       DCS blood flow index
%       other     type<N>       Unknown/future code (+ warning)
%
%       <wavelengthValue> is resolved in this priority order:
%         1. wavelengthActual from measurementList (if not NaN)
%         2. probe.wavelengths(wavelengthIndex) (if probe available)
%         3. Fallback: 'wl<wavelengthIndex>'
%
%   Processed data (dataType == 99999): '<dataTypeLabel>'
%       e.g. 'HbO', 'HbR', 'HbT', 'dOD', 'mua', 'StO2', 'BFi'.
%       Fallback: 'proc<dataTypeIndex>' if dataTypeLabel is empty.
%
%% Assumptions and remarks
%
% - The core extraction delegates to icnna.op.snirf.unfoldMeasurementList
%   which handles optional SNIRF properties safely via isproperty().
% - For TD and DCS types, dataTypeIndex is a 2-element vector indexing
%   probe time-delay or correlation arrays. It is preserved in the table
%   but NOT encoded in the signalKey. If multiple TD/DCS columns at the
%   same (source,detector,dataType,wavelength) differ only in
%   dataTypeIndex, they will share the same signalKey and only the first
%   match will be used in tensor assembly. This is a known limitation.
% - uniqueSignalKeys preserves first-appearance order across the full
%   measurementList.
%
%% Input parameters
%
% measurementList - icnna.data.snirf.measurement[] | icnna.data.snirf.dataBlock
%   As accessed via snirfData.nirs(i).data(j).measurementList or
%   snirfData.nirs(i).data(j). Both forms accepted by
%   icnna.op.snirf.unfoldMeasurementList.
%
% probe - SNIRF probe object | []
%   As accessed via snirfData.nirs(i).probe. Used to resolve
%   wavelength values when wavelengthActual is absent. Pass [] if
%   unavailable; the 'wl<n>' fallback will be used instead.
%
%% Output
%
% mlTable - table [nColumns x 16]
%   Augmented measurement list table. Contains all 14 columns
%   produced by icnna.op.snirf.unfoldMeasurementList, plus:
%       .wavelengthValue - double. Resolved wavelength in nm.
%                          NaN if unresolvable.
%       .signalKey       - cell of char[]. Signal type identifier
%                          (see Signal key convention above).
%
% uniqueSignalKeys - cell {1 x nSignals} of char[]
%   Unique signal keys in first-appearance order. Defines the
%   signal dimension of the ICNNA 3D tensor.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, aux_getData, aux_getSignalTags,
%   icnna.op.snirf.unfoldMeasurementList,
%   https://github.com/fNIRS/snirf/blob/master/snirf_specification.md
%

%% Log
%
% -- ICNNA v1.4.1
%
% 21-May-2026: FOE
%   + Function added. Core extraction delegated to
%     icnna.op.snirf.unfoldMeasurementList; signalKey derivation
%     and wavelength resolution added on top.


% Preliminaries
% SNIRF dataType code -> typeStr map (SNIRF spec v1.1)
SNIRF_DATATYPE_PROCESSED = 99999;

dataTypeMap = containers.Map( ...
    int32([1, 51, 101, 102, 151, 152, ...
           201, 251, 301, 351, 401, 410]),  ...
    {'CW', 'Fluo-CW', 'FD-AC', 'FD-Phase', 'Fluo-FD-AC', 'Fluo-FD-Ph', ...
     'TDG', 'Fluo-TDG', 'TDM', 'Fluo-TDM', 'DCS-g2', 'DCS-BFi'}, ...
     'KeyType','int32','ValueType','char');


% 1) Extract the measurementList

mlTable = icnna.op.snirf.unfoldMeasurementList(measurementList);
nCols   = height(mlTable);


% 2) Resolve wavelengthValue for each column
%
% Priority: wavelengthActual (from table) > probe.wavelengths > fallback NaN.
% Note: wavelengthActual is already in the table if the SNIRF loader
% populated it; otherwise it is NaN (unfoldMeasurementList initialises
% optional properties to NaN).

wavelengthValue = NaN(nCols, 1);
for iCol = 1:nCols
    if ~isnan(mlTable.wavelengthActual(iCol))
        %Already resolved in the SNIRF file
        wavelengthValue(iCol) = mlTable.wavelengthActual(iCol);
    elseif ~isempty(probe)
        wlIdx = mlTable.wavelengthIndex(iCol);
        if wlIdx > 0 && wlIdx <= length(probe.wavelengths)
            wavelengthValue(iCol) = probe.wavelengths(wlIdx);
        end
    end
    %Otherwise remains NaN; fallback key 'wl<n>' used in Step 3
end
mlTable.wavelengthValue = wavelengthValue;


% 3) Derive signalKey for each column

signalKeys = repmat({''}, nCols, 1);
for iCol = 1:nCols
    dt = mlTable.dataType(iCol);

    if dt == SNIRF_DATATYPE_PROCESSED
        %Processed: use dataTypeLabel
        lbl = strtrim(mlTable.dataTypeLabel{iCol});
        if ~isempty(lbl)
            signalKeys{iCol} = lbl;
        else
            signalKeys{iCol} = ['proc:' num2str(mlTable.dataTypeIndex(iCol))];
        end

    else
        %Raw (dataType 1-500): '<typeStr>:<wavelengthValue>'
        dtKey = int32(dt);
        if isKey(dataTypeMap, dtKey)
            typeStr = dataTypeMap(dtKey);
        else
            typeStr = ['type' num2str(dt)];
            warning('icnna:data:misc:rawDataNIRx:import:parseMeasurementList:UnknownSNIRFDataType', ...
                    ['Unknown SNIRF dataType code %d in measurementList ' ...
                     'column %d. Using fallback signalKey ''%s:<wl>''.'], ...
                    dt, iCol, typeStr);
        end

        wlVal = wavelengthValue(iCol);
        if ~isnan(wlVal)
            wlStr = num2str(wlVal);
        else
            %Probe unavailable or wavelengthIndex out of range
            wlStr = ['wl' num2str(mlTable.wavelengthIndex(iCol))];
        end

        signalKeys{iCol} = [typeStr ':' wlStr];
    end
end
mlTable.signalKey = signalKeys;


% 4) Collect unique signal keys in first-appearance order

uniqueSignalKeys = {};
for iCol = 1:nCols
    sk = signalKeys{iCol};
    if ~any(strcmp(uniqueSignalKeys, sk))
        uniqueSignalKeys{end+1} = sk; %#ok<AGROW>
    end
end

end







function label = buildSignalLabel(dataType, dataTypeLabel, wavelengthValue, ...
                                  wavelengthIndex, dataTypeIndex)
% Map a single SNIRF measurement column's metadata to a human-readable label.
%
% Convention status (v1.4.1):
%   This function defines the canonical signal label format for
%   nirs_neuroimage objects produced by rawData_NIRx/import.m.
%   If the format is revised in a future version, update this
%   function, the nirs_neuroimage.signalTags property documentation,
%   and doc/ICNNA-Version.log (see also: § Signal label convention).
%
%% Input parameters
%
% dataType         - double scalar. SNIRF dataType code.
% dataTypeLabel    - char[]. SNIRF dataTypeLabel string (may be empty).
% wavelengthValue  - double scalar. Resolved wavelength in nm (may be NaN).
% wavelengthIndex  - double scalar. SNIRF wavelengthIndex (1-based).
% dataTypeIndex    - double scalar. SNIRF dataTypeIndex
%
%% Output
%
% label - char[]
%   The signal label
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also aux_getSignalTags,
%

%% Log
%
% -- ICNNA v1.4.1
%
% 21-May-2026: FOE
%   + Function added.
%


SNIRF_DATATYPE_PROCESSED = 99999;

if dataType == SNIRF_DATATYPE_PROCESSED
    lbl = strtrim(dataTypeLabel);
    if ~isempty(lbl)
        label = lbl;                               % e.g. 'HbO', 'HbR', 'mua'
    else
        label = ['proc:' num2str(dataTypeIndex)]; % generic fallback
    end
else
    % Raw data: I(lambda=<wl>nm).
    % Note: physically accurate for CW (dataType 1). For FD-Phase,
    % DCS-g2 etc. this label is an approximation; type-specific prefixes
    % are deferred (see function header).
    if ~isnan(wavelengthValue)
        label = ['I(lambda=' num2str(wavelengthValue) 'nm)'];
    else
        label = ['I(wl' num2str(wavelengthIndex) ')'];
    end
end

end



function [sources, detectors, fiducials] = parseDigpoints(rawStr)
% Parse a NIRStar digpoints / digpts text file into structured outputs.
%
% Format: one entry per line — '<label>: <x> <y> <z>'
%
% Classification is based on label pattern:
%   Source label:   s<n>  where <n> is a positive integer (case-insensitive)
%   Detector label: d<n>  where <n> is a positive integer (case-insensitive)
%   Any other label (standard 10/20 landmarks, photogrammetry points, etc.)
%   is treated as a fiducial reference point.
%
%% Input parameters
%
% rawStr - char[]
%   Raw text content as returned by importFileTxt.
%
%% Output
%
% sources   - double [nSources x 3].
%   Rows indexed by source number (s<n> -> row n). NaN row if index absent.
%
% detectors - double [nDetectors x 3].
%   Rows indexed by detector number (d<n> -> row n). NaN row if index absent.
%
% fiducials - struct array with fields .name (char) and .location (1x3 double).
%   One entry per non-source, non-detector point, in file order.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRx, aux_getCLM, importFileTxt
%

%% Log
%
% -- ICNNA v1.4.1
%
% 21-May-2026: FOE
%   + Function added.
%


sources   = zeros(0,3);
detectors = zeros(0,3);
fiducials = struct('name',{},'location',{});

if isempty(strtrim(rawStr))
    return;
end


% 1) Tabulate all valid entries
% textscan reads each line as '<label>: <x> <y> <z>'.
% %s captures the label including its trailing colon; %f captures each
% coordinate. Empty lines and trailing whitespace are handled automatically.
C = textscan(rawStr, '%s %f %f %f');
if isempty(C{1})
    return;
end

% Strip trailing colon from labels; normalise to lower case.
allLabels = lower(cellfun(@(l) strrep(l,':',''), C{1}, 'UniformOutput', false));
allCoords = [C{2}, C{3}, C{4}];


% 2) Classify by label pattern i.e. source, detector or fiducial
srcMask = cellfun(@(l) ~isempty(regexp(l, '^s\d+$', 'once')), allLabels);
detMask = cellfun(@(l) ~isempty(regexp(l, '^d\d+$', 'once')), allLabels);
fidMask = ~srcMask & ~detMask;


% 3) Assemble sources [nSrc x 3], indexed by label number
srcLabels  = allLabels(srcMask);
srcCoords  = allCoords(srcMask, :);
srcIndices = cellfun(@(l) str2double(l(2:end)), srcLabels);

if ~isempty(srcIndices)
    sources = NaN(max(srcIndices), 3);
    sources(srcIndices, :) = srcCoords;
end


% 4) Assemble detectors [nDet x 3], indexed by label number
detLabels  = allLabels(detMask);
detCoords  = allCoords(detMask, :);
detIndices = cellfun(@(l) str2double(l(2:end)), detLabels);

if ~isempty(detIndices)
    detectors = NaN(max(detIndices), 3);
    detectors(detIndices, :) = detCoords;
end


% 5) Assemble fiducials struct array
fidLabels = allLabels(fidMask);
fidCoords = allCoords(fidMask, :);

for iFid = 1:length(fidLabels)
    fiducials(iFid).name     = fidLabels{iFid};
    fiducials(iFid).location = fidCoords(iFid,:);
end

end
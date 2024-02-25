classdef rawData_NIRScout < rawData
%Class rawData_NIRScout
%
%A rawData_NIRScout represents the experimentally recorded data
%with a NIRx NIRScout device during a fNIRS session.
%This data is not yet converted to a proper neuroimage.
%
%
% The NIRx NIRScout is a family of fNIRS devices that comes in three
%major presentations (see NIRScout User manual, Sections 6 and 8 pgs. 21-25):
%   + NIRScout: The basic system. This model has been chosen to set the
%       default parameters for the class.
%   + NIRScoutX: The extended system. NIRScoutX is functionally identical
%       to the basic system e.g. LED based, but offers the following extended
%       capabilities; (i) Up to 32 fiber-based detection channels,
%       (ii) up to 48 LED illumination sources, (iii) up to 8 digital
%       input channels and (iv) up to 8 digitaloutput channels.
%   + NIRScoutXP: The extended system. NIRScoutXP is functionally identical
%       to the NIRScoutX system, but further offers (i) fiber based laser
%       illuminationat up to 64 source channels at 2 wavelengths, or 32
%       source channels at 4 wavelengths. It can be configured to use LED
%       based or laser based illumination.
%
%
% The NIRx NIRScout family operates at two or 4 wavelengths (see NIRScout
%User manual, Section 9 pg. 31):
%   + LED based: 760 nm and 850 nm with and optical intensity of 25mW
%        per wavelength (Default configuration of this class)
%   + Laser based: 780 nm and 830 nm with and optical intensity of 20mW
%        per wavelength 
%
%       NOTE: I can't find the deviation from the nominal wavelength
%           in the user manual. Not sure if it is reported somewhere
%           in the data files.
%
%
%
%This class also contains some experimental parameters such as
%the sampling rate, etc...
%
% The interoptode distance is configurable, but by default is set to 3cm.
%
%The number of channels is also configurable by setting the appropriate
%sensing geometry (it can go up to 128 channels). 
%
% The main attribute is lightRawData holding the raw light intensity
%data. It is a matrix sized nSamples x nChannels x nWLengths.
%
%
%
%
%% Remarks
%
% Private function
%
%       coe=table_abscoeff;
%
% is actually copyrighted by fOSA and licenced under the GNU end user
% licence agreement.
%
%
%% Superclass
%
% rawData - An abstract class for holding raw data.
%
%
%% Properties
%
%  == General information
%   .filename - The filename (without extension). The NIRStar 
%       software organizes and names files automatically. A number of
%       files are generated in each measurement bu they are all stored
%       in the same directory and shared a common filename (with different
%       extensions). Default value is: NIRS-2018-01-01_001.
%   .device - The NIRS system type. By default is set to 'NIRScout 16x24'.
%   .source - Type of source used (LED or Laser). By default is set to 'LED'.
%   .studyTypeModulation - Study type to set modulation amplitude. This
%       corresponds to field "Mod" in the .hdr input file (but note
%       that the real modulation amplitudes are set later in the Imaging
%       Parameters section. By default is set to 'Human Subject'.
%   .fileVersion - The NIRStar software version. By default is set to 14.2.
%       Latest known version is 15.2
%   .subjectIndex - Subject index. By default is set to 1.
%  == Measurement information
%   .probesetInfo - An struct holding information about the probe
%       sets and their configuration. The struct has the following fields;
%       .geom - Some standard information about the head and the
%           international 10-20 system
%           |
%           |- NIRxHead - 
%           .   |
%           .   |- ext1020sys 
%           .   .   |
%           .   .   |- coords3d (nPoints x 3)
%           .   .   |
%           .   .   |- labels (1 x 137) with 1|37 being the number of
%           .   .   |       labels of the 10/20 system
%           .   .   |
%           .   .   |- normals (137 x 3)
%           .   .   |
%           .   .   |- center (1 x 3)
%           .   .   |
%           .   .   |- sphere (137 x 3)
%           .   .   |
%           .   .   |- coords2d (137 x 2) - Note that these are NOT a
%           .   .           reduction of the 3D coordinates above. These
%           .   .           seem to be normalized.
%           .   |
%           .   |- mesh - Not all of the following may be defined;
%           .   .   |
%           .   .   |- nodes (nPoints x 4) - Point ID and 3D coordinates
%           .   .   |
%           .   .   |- elems (???? x 5)
%           .   .   |
%           .   .   |- belems (???? x 4)
%           .   .   |
%           .   .   |- fiducials (13 x 4) - Used to generate the affine
%           .   .           transformation matrix for source/detector
%           .   .           registrationsSee NIRSLab User's Manual
%           .   .           v2016.01 (pg.183)
%           .   |
%           .   |- mesh1 - See fields for mesh.
%           .   |
%           .   |- mesh2 - See fields for mesh.
%           .   |
%           .   |- mesh3 - See fields for mesh.
%           |
%           |- xy2dcircle - 
%           .   |
%           .   |- xycircles (??? x 2) -  
%           .   |
%           .   |- xynose (3 x 2) -  
%           .   |
%           .   |- xycross1 (2 x 2) -  
%           .   |
%           .   |- xycross2 (2 x 2) -  
%           .   |
%           .   |- xysquare (5 x 2) -  
%           .   |
%           .   |- xyearL (9 x 2) - Left ear <X,Y> 
%           .   |
%           .   |- xyearR (9 x 2) - Right ear <X,Y> 
%           .
%       .probes - A struct containing channel coordinate values for
%           sources and detectors, both in 2D and 3D spaces.
%           |
%           |- setupType - Scalar
%           |
%           |- nSource0 - Number of sources
%           |
%           |- nDetector0 - Number of detectors
%           |
%           |- nspecify_s - Scalar.
%           |
%           |- normals_s (nSource0 x 3) - Normals of the sources ???
%           |
%           |- coords_s2 (nSource0 x 2) - 2D coordinates of the sources?
%           |
%           |- coords_s3 (nSource0 x 3) - 3D coordinates of the sources?
%           |
%           |- index_s  (nSource0 x 2) - Link to .geom.NIRxHead.nodes? For
%           .               sources
%           |
%           |- nspecify_d - Scalar.
%           |
%           |- normals_d (nSource0 x 3) - Normals of the detectors ???
%           |
%           |- coords_d2 (nSource0 x 2) - 2D coordinates of the detectors?
%           |
%           |- coords_d3 (nSource0 x 3) - 3D coordinates of the detectors?
%           |
%           |- index_d  (nSource0 x 2) - Link to .geom.NIRxHead.nodes? For
%           .               detectors
%           |
%           |- nearDetectors -
%           |
%           |- nearDetectors0 -
%           |
%           |- nChannel0 - Number of configured channels?
%           |
%           |- coords_s2 (nChannel0 x 2) - 2D coordinates of the channels
%           |
%           |- coords_s3 (nChannel0 x 3) - 3D coordinates of the channels
%           |
%           |- index_c  (nChannel0 x 2) - Link to .geom.NIRxHead.nodes? For
%           .               channels
%           |
%           |- normals_c (nChannel0 x 3) - Normals of the channels
%           |
%           |- sourcei0 - Scalar
%           |
%           |- viewType - Scalar. 2 for 2D top? view, or 3 for 3D view.
%           |
%           |- viewangle3 - Azimuth and elevation for the 3D view?
%           .
%       .temphandles - A struct. Not understood.
%       .probeInforFileName - A string with the montage filename
%       .probeInforFilePath - A string with the path to the montage file
%
%
%   .nSources - Number of source steps in measurement. By default is set to 16.
%   .nDetectors - Number of detector channels. By default is set to 8.
%   .nSteps - Number of steps (illumination pattern). By default is set to 16.
%   .wLengths - The nominal wavelengths at which the light
%       intensities were acquired in [nm]. This corresponds to a
%       default LED based system. NIRScout based on lasers will use
%       780 and 830 nm instead.
%   .nTriggerInputs - Number of trigger inputs. By default is set to 0.
%   .nTriggerOutputs - Number of trigger outputs (only available for
%       NIRScoutX). By default is set to 0.
%   .nAnalogInputs - Number of auxiliary analog inputs. Reserve for future
%       usage. By default is set to 0.
%   .samplingRate - Sampling rate in Hz. By default is set to 1 Hz.
%   .modulationAmplitudes - An array with the modulation amplitudes used
%       for illumination. By default is set to [0 0].
%   .modalutionThresholds - An array with the modulation threshold used (?0 only
%       for Laser). By default is set to [0.0 0.0].
%
%  == Paradigm Information
%   .paradigmStimulusType=None Specifies paradigm (future option)
%
%  == Experimental Notes
%   .notes - A string of experimental notes. By default is set to empty.
%
%  == Gain Settings
%   .gains - The gain settings used in the measurement are
%       recorded in a matrix. The gain for channel Si-Dj is found in the
%       ith row and jth column (counting from the upper left). Valid gains
%       for neighboring source-detector-pairs usually are in the range
%       of 4...7 for adults, depending on head size, hair density/color,
%       and measurement site. A gain value of ‘8’ indicates that too
%       little or no light was received for this particular pairing.
%       The gain values range from 0 (gain factor 100 = 1) through 8
%       (gain factor 108). The hash symbols '#' are used to identify
%       the beginning and end of the table. By default is set to
%       6*ones(defaultNumOfSources,defaultNumOfDetectors).
%
%  == Markers Information
%   .eventTriggerMarkers: A matrix for recording the event markers
%       received by the digital trigger inputs, with time stamp and
%       frame numbers. Each event is a row that
%       contains 3 numbers;
%         Column 1: Time (in seconds) of trigger event after the scan
%           started.
%         Column 2: Trigger channel identifier, or condition marker.
%           Triggers received on each digital input DIx (where x denotes
%           the trigger channel) on the front panel are encoded as numbers
%           2DI(x-1), e.g. DI1, DI2, and DI3 are encoded as 1, 2, and 8,
%           respectively. The file stores the sum of simultaneously
%           triggered inputs in decimal representation. By using
%           combinations of trigger inputs, as many as 15 conditions
%           can be encoded by NIRScout and NIRSport systems, while
%           NIRScoutX receives up to 255 conditions (8 inputs).
%         Column 3: The number of the scan frame during which the
%           trigger event was received.
%       By default is empty, set to nan(0,3).
%
%  == Data Structure:
%   This section records the arrangement of detector channels, and
%   the channel masking pattern in two fields;
%   .sdKey (source-detector key) - A matrix mapping
%       a column in the data files (*.wl1, *.wl2) to a source-detector
%       pair. The column in the data files for potential pair Si-Dj is
%       found in the ith row and jth column (counting from the upper
%       left). This attribute makes a header for the data files. For
%       source detector pairs without an associated column in the data
%       files (*.wl1, *.wl2), a nan value is stored. By default is set to
%       nan(defaultNumOfSources,defaultNumOfDetectors).
%
%   .sdMask (source-detector mask) stores the masking pattern in a matrix
%       Channels that are set not to be
%       displayed are identified by '0's, while channels set to be
%       displayed are labeled with '1's. Counting from the upper left,
%       the column number corresponds to the detector channel, and
%       the row number corresponds to the source position. The example
%       below shows a 4-source/4-detector measurement, in which all
%       channels are displayed except for source 2 / detector 3.
%
%
%  == Channel Distance:
%   .channelsDistances - The channel distance in [mm] declared in the
%       hardware configuration and used for the Beer-Lambert Law calculations
%       during a scan are recorded here. The order corresponds to the order
%       of the channel list in one of the software dialogs. This maybe an
%       issue as I do not have access to that info when reading the data.
%       By default is set to nan(1,0).
%
%  == Patient information
%   .userName - The user name. By default set to empty.
%   .userAge - The user age in years. By default set to 1. 
%   .userGender - The user gender. (U)nset -default, (M)ale or (F)emale. 
%
%  == The data
%   .lightRawData - The raw light intensity data. The third dimension
%       of the matrix holds the information for the different wavelengths
%       across all source detector pairs (whether visible or note- see
%       SDKey and SDMask).
%  
%% Methods
%
% Type methods('rawData_NIRScout') for a list of methods
%
%
% Copyright 2018-23
% @author: Felipe Orihuela-Espina
%
% See also rawData, rawData_NIRScout
%

%% Log
%
% File created: 4-Apr-2018
% File last modified (before creation of this log): 25-Apr-2018
%
% 4/25-Apr-2018 (FOE): Class created.
%
% 30-Oct-2018 (FOE): Class should now recognize files for version 15.2
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Improved some comments.
%   + Remove some old inheritance code no longer used.
%
% 20-Feb-2024 (FOE):
%   + NIRx have changed their file version again. Here are some of the
%       changes (this class cannot still read this file version!)
%       * Version naming convention e.g. 15.2, is no longer followed.
%       Instead they are now using a date.building format
%       * FileName field may not be present
%       * Device filed may not be present
%       * A new alphanumerical field Device ID has been added.
%       * A whole new "ExperimentNotes" section has been added with the
%       following fields;
%        [ExperimentNotes]
%        experiment_name=
%        experiment_subject=
%        experiment_subject_age=
%        experiment_subject_gender=
%        experiment_subject_contact_info=
%        experiment_remarks=
%       * Section "MeasurementInformation", "GainSettings" or
%       "MarkersInformation" may no longer be present in the header.
%       * Name of the hdr file may NOT coincide with the other file names
%       in the folder e.g. 2024-01-03_001_config.hdr and 2024-01-03_001.wl1
%       * A few of the old files have disappear. Namely;
%           - .tpl
%           - .avg
%           - .set
%           - .evt
%           - .inf
%           - .dat
%       ...and in contrast a few new ones have appeared;
%           - _calibration.json - Contains some quality control information
%                   such as the dark noise, saturation, cross-talk, etc
%           - _description.json -  Information about the subject
%               demographics
%           - _config.json - A large file with a lot of info which is not
%               clear to me right now what it is...
%
%           
%
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties %(SetAccess=private, GetAccess=private)
        %General information
        filename(1,:) char ='NIRS-2018-01-01_001'; %The filename (without extension).
        device(1,:) char='NIRScout 16x24'; %Name of the acquisition device
        source(1,:) char {mustBeMember(source,{'LED','LASER'})}='LED'; % Type of source used (LED or Laser).
        studyTypeModulation(1,:) char='Human Subject';
        fileVersion(1,:) char='14.2';
        subjectIndex(1,1) double {mustBeInteger, mustBeNonnegative}=1;

        % Measurement information
        probesetInfo=struct('geom',[],'probes',[],'temphandles',[],...
                            'probeInforFileName',[],...
                            'probeInforFilePath',[])
        
        nSources(1,1) double {mustBeInteger, mustBeNonnegative}=16; %Number of source steps in measurement.
        nDetectors(1,1) double {mustBeInteger, mustBeNonnegative}=8; %Number of detector channels.
        nChannels(1,1) double {mustBeInteger, mustBeNonnegative}=0; %Number of channels.
        nSteps(1,1) double {mustBeInteger, mustBeNonnegative}=16; %Number of steps (illumination pattern).
        wLengths(1,2) double {mustBeInteger, mustBeNonnegative}=[780 830];%The nominal wavelengths at which the light
            %intensities were acquired in [nm] for a laser based
            %equipment.
        nTriggerInputs(1,1) double {mustBeInteger, mustBeNonnegative}=0; %Number of trigger inputs.
        nTriggerOutputs(1,1) double {mustBeInteger, mustBeNonnegative}=0; %Number of trigger outputs (only available for
                          %NIRScoutX).
        nAnalogInputs(1,1) double {mustBeInteger, mustBeNonnegative} =0; %Number of auxiliary analog inputs.
        samplingRate(1,1) double {mustBeNonnegative} = 1; % Sampling rate in Hz.
        modulationAmplitudes(1,:) double =[0 0]; %Modulation amplitudes for illumination.
        modulationThresholds(1,:) double =[0.0 0.0]; %Modulation thresholds used (?0 only for Laser).
%         probesetInfo = struct('read',{},'type',{},'mode',{});
%         repeatCount=0; %Repeat Count (e.g. Number of blocks)


        
        paradigmStimulusType(1,:) char=''; % Paradigm Information
        
        notes(1,:) char=''; % Experimental Notes

        % Gain Settings
        %gains=6*ones(obj.nSources,obj.nDetectors); %I can't do this here...obj has not yet been created
        gains=nan(0,0); %See the constructor below
        
        % Markers Information
        eventTriggerMarkers=nan(0,3);       

        
        % Data Structure:
%         sdKey= nan(obj.nSources,obj.nDetectors); %Source-detector data
%                                     %keys (columns in the .wl* data files)
%                                     %I can't do this here...obj has not yet been created
         sdKey=nan(0,0); %See the constructor below
        %sdMask=nan(obj.nSources,obj.nDetectors); %I can't do this here...obj has not yet been created
        sdMask=nan(0,0); %See the constructor below
        

        
        
        channelDistances=nan(1,0); % Channel Distances
        
        
        
        %Subject Demographics
        userName(1,:) char=''; %Subject's name
        userGender(1,1) char {mustBeMember(userGender,{'M','MALE','F','FEMALE','U','UNSET'})}='U'; %Subject's sex
            %Deprecate the short formats.
        userAge(1,1) double {mustBeInteger, mustBeNonnegative}=1;  %Subject's age in years
%         userBirthDate=[]; % A date vector

        %The data itself!!
        %NOTE: In MATLAB, an assignment:
        %   + a=nan(0,0,0) leads to an empty array 0-by-0-by-0 with ndims 3
        %   + a=nan(0,n) leads to an empty array 0-by-n with ndims 2
        %   + a=nan(0,0,n) leads to an empty array 0-by-0-by-n with
        %           ndims 3, iff n~=1!!
        %but unfortunately
        %   + a=nan(0,0) leads to an empty array [] with ndims 2
        %   + a=nan(0,0,1) leads to an empty array [] with ndims 2
        lightRawData=nan(0,0,0);%The raw light intensity data.
            %note that initializing to nan(0,0) is equal to
            %initializing to []. See above
%         marks=nan(0,0);%The stimulus marks.
%         timestamps=nan(0,0);%Timestamps.
%         bodyMovement=nan(0,0);%Body movement artifacts as determined by the ETG-4000
%         removalMarks=nan(0,0);%Removal marks
%         preScan=nan(0,0);%preScan stamps
    end


    properties (Dependent)
        samplingPeriod
        nominalWavelengthSet
        probeSet
        subjectName
        subjectGender
        subjectAge
    end
    


 
    methods    
        function obj=rawData_NIRScout(varargin)
            %RAWDATA_NIRScout RawData_NIRScout class constructor
            %
            % obj=rawData_NIRScout() creates a default rawData_NIRScout
            %   with ID equals 1.
            %
            % obj=rawData_NIRScout(obj2) acts as a copy constructor of
            %   rawData_NIRScout
            %
            % obj=rawData_NIRScout(id) creates a new rawData_NIRScout
            %   with the given identifier (id). The name of the
            %   rawData_NIRScout is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %
            
            obj.gains=6*ones(obj.nSources,obj.nDetectors);
            obj.sdKey= nan(obj.nSources,obj.nDetectors);
            obj.sdMask= nan(obj.nSources,obj.nDetectors);
            
            if (nargin==0)
                %Keep all other default values
            elseif isa(varargin{1},'rawData_NIRScout')
                obj=varargin{1};
                return;
            else
                obj.id=varargin{1};
                obj.description=['RawData' num2str(obj.id,'%04i')];
            end
            assertInvariants(obj);

        end
  
    end

    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Static)
        coe=table_abscoeff;
    end




    methods

      %Getters/Setters

          %General information


      function res = get.filename(obj)
         %Gets the object's |filename|
         res = obj.filename;
      end
      function obj = set.filename(obj,val)
         %Sets the object's |filename|
        obj.filename = val;
      end


      function res = get.device(obj)
         %Gets the object's |device|
         res = obj.device;
      end
      function obj = set.device(obj,val)
         %Sets the object's |device|
        obj.device = val;
      end


      function res = get.source(obj)
         %Gets the object's |source|
         res = obj.source;
      end
      function obj = set.source(obj,val)
         %Sets the object's |source|
        obj.source = val;
      end


      function res = get.studyTypeModulation(obj)
         %Gets the object's |studyTypeModulation|
         res = obj.studyTypeModulation;
      end
      function obj = set.studyTypeModulation(obj,val)
         %Sets the object's |studyTypeModulation|
        obj.studyTypeModulation = val;
      end


      function res = get.fileVersion(obj)
         %Gets the object's |fileVersion|
         res = obj.fileVersion;
      end
      function obj = set.fileVersion(obj,val)
         %Sets the object's |fileVersion|
        obj.fileVersion = val;
      end


      function res = get.subjectIndex(obj)
         %Gets the object's |subjectIndex|
         res = obj.subjectIndex;
      end
      function obj = set.subjectIndex(obj,val)
         %Sets the object's |subjectIndex|
        obj.subjectIndex = val;
      end


        % Measurement information


      function res = get.nSources(obj)
         %Gets the object's |nSources|
         res = obj.nSources;
      end
      function obj = set.nSources(obj,val)
         %Sets the object's |nSources|
        obj.nSources = val;
      end


      function res = get.nDetectors(obj)
         %Gets the object's |nDetectors|
         res = obj.nDetectors;
      end
      function obj = set.nDetectors(obj,val)
         %Sets the object's |nDetectors|
        obj.nDetectors = val;
      end


      function res = get.nSteps(obj)
         %Gets the object's |nSteps|
         res = obj.nSteps;
      end
      function obj = set.nSteps(obj,val)
         %Sets the object's |nSteps|
        obj.nSteps = val;
      end



      function res = get.wLengths(obj)
         %Gets the object's |wLengths|
         res = obj.wLengths;
      end
      function obj = set.wLengths(obj,val)
         %Sets the object's |wLengths|
        obj.wLengths = val;
      end
      function res = get.nominalWavelengthSet(obj)
         %(DEPENDENT) Gets the object's |nominalWavelengthSet|
         res = obj.wLengths;
      end
      function obj = set.nominalWavelengthSet(obj,val)
         %(DEPENDENT) Sets the object's |nominalWavelengthSet|
        obj.wLengths = val;
      end


      function res = get.nTriggerInputs(obj)
         %Gets the object's |nTriggerInputs|
         res = obj.nTriggerInputs;
      end
      function obj = set.nTriggerInputs(obj,val)
         %Sets the object's |nTriggerInputs|
        obj.nTriggerInputs = val;
      end


      function res = get.nTriggerOutputs(obj)
         %Gets the object's |nTriggerOutputs|
         res = obj.nTriggerOutputs;
      end
      function obj = set.nTriggerOutputs(obj,val)
         %Sets the object's |nTriggerOutputs|
        obj.nTriggerOutputs = val;
      end


      function res = get.nAnalogInputs(obj)
         %Gets the object's |nAnalogInputs|
         res = obj.nAnalogInputs;
      end
      function obj = set.nAnalogInputs(obj,val)
         %Sets the object's |nAnalogInputs|
        obj.nAnalogInputs = val;
      end


      function res = get.samplingPeriod(obj)
         %(DEPENDENT) Gets or sets the object's |samplingPeriod|
         res = 1/obj.samplingRate;
      end
      function obj = set.samplingPeriod(obj,val)
         %(DEPENDENT) Sets the object's |samplingPeriod|
        obj.samplingRate = 1/val;
      end


      function res = get.samplingRate(obj)
         %Gets or sets the object's |samplingRate|
         res = obj.samplingRate;
      end
      function obj = set.samplingRate(obj,val)
         %Sets the object's |samplingRate|
        obj.samplingRate = val;
      end


      function res = get.modulationAmplitudes(obj)
         %Gets or sets the object's |modulationAmplitudes|
         res = obj.modulationAmplitudes;
      end
      function obj = set.modulationAmplitudes(obj,val)
         %Sets the object's |modulationAmplitudes|
        obj.modulationAmplitudes = val;
      end


      function res = get.modulationThresholds(obj)
         %Gets or sets the object's |modulationThresholds|
         res = obj.modulationThresholds;
      end
      function obj = set.modulationThresholds(obj,val)
         %Sets the object's |modulationThresholds|
        obj.modulationThresholds = val;
      end



         %Measure information


      function res = get.probesetInfo(obj)
         %Gets or sets the object's |probesetInfo|
         res = obj.probesetInfo;
      end
      function obj = set.probesetInfo(obj,val)
          %Sets the object's |probesetInfo|
          if (isstruct(val))
              %The fields in this probeset struct are NOT always the
              %same. So these have to be check everytime.
              obj.probesetInfo = struct('probes',[],'geom',[],...
                  'temphandles',[],'headmodel','',...
                  'probeInforFileName','','probeInforFilePath','');
              fields = fieldnames(val);
              nFields = length(fields);
              for ff=1:nFields
                  fieldname = fields{ff};
                  if isfield(obj.probesetInfo,fieldname)
                      obj.probesetInfo.(fieldname) = val.(fieldname);
                  else
                      warning('ICNNA:rawData_NIRScout:set.probeSetInfo:UnexpectedParameterValue',...
                          ['Unexpected field name ''' fieldname '''in probe set descriptor. Ignoring field.'])
                  end
              end

              %Field setupType is not present in all file versions.
              % I have found it in version 14.2 but not in 15.2
              %but it was used for several things during conversion
              %to structuredData.
              if ~isfield(obj.probesetInfo.probes,'setupType')
                  obj.probesetInfo.probes.setupType = 1;
              end

          else
              error('ICNNA:rawData_NIRScout:set.probeSetInfo:InvalidParameterValue',...
                  'Value must be a struct.');
          end
      end
      function res = get.probeSet(obj)
         %(DEPENDENT) Gets or sets the object's |probesetInfo|
         res = obj.probesetInfo;
      end
      function obj = set.probeSet(obj,val)
          %(DEPENDENT) Sets the object's |probesetInfo|
          obj.probesetInfo = val;
      end




      function res = get.nChannels(obj)
         %Gets or sets the object's |nChannels|
         res = obj.nChannels;
      end
      function obj = set.nChannels(obj,val)
         %Sets the object's |nChannels|
        obj.nChannels = val;

        %Ensure number of channelDistances matches the number of channels (visible
        %in the mask)
        sillyNChannels = get(obj,'nChannels');
        if (numel(obj.channelDistances) < sillyNChannels)
            %Add new distances and send warning
            obj.channelDistances(end+1:end+sillyNChannels)=nan;
            warning('Adding default channel distances to new channels.')
        elseif (numel(obj.channelDistances) > sillyNChannels)
            %Discard latter distances and send warning
            obj.channelDistances(sillyNChannels+1:end)=[];
            warning('Removing extra channel distances.')
            %else %(obj.channelsDistances == sum(sum(obj.sdMask)))
            %Do nothing
        end


      end



         %Paradigm information

      function res = get.paradigmStimulusType(obj)
         %Gets or sets the object's |paradigmStimulusType|
         res = obj.paradigmStimulusType;
      end
      function obj = set.paradigmStimulusType(obj,val)
         %Sets the object's |paradigmStimulusType|
        obj.paradigmStimulusType = val;
      end



         %Experimental notes

      function res = get.notes(obj)
         %Gets or sets the object's |notes|
         res = obj.notes;
      end
      function obj = set.notes(obj,val)
         %Sets the object's |notes|
        obj.notes = val;
      end



         %Gain settings

      function res = get.gains(obj)
         %Gets or sets the object's |gains|
         res = obj.gains;
      end
      function obj = set.gains(obj,val)
         %Sets the object's |gains|
        if any(any(val<0))
            warning('ICNNA:rawData_NIRScout:set.gains:InvalidParameterValue',...
                  'Nagative gain found.');
        end
        obj.gains = val;
      end


         %Markers Information

      function res = get.eventTriggerMarkers(obj)
         %Gets or sets the object's |eventTriggerMarkers|
         res = obj.eventTriggerMarkers;
      end
      function obj = set.eventTriggerMarkers(obj,val)
         %Sets the object's |eventTriggerMarkers|
        if (size(val,2)==3 && all(all(floor(val(:,2:3))==val(:,2:3))) && all(all(val>=0)))
            obj.eventTriggerMarkers = val;
        else
            error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a 3 columns matrix with the second and third columns being integer numbers.');
        end
      end


         %Data Structure

      function res = get.sdKey(obj)
         %Gets or sets the object's |sdKey|
         res = obj.sdKey;
      end
      function obj = set.sdKey(obj,val)
         %Sets the object's |sdKey|
        if (all(all(isnan(val))) || (all(all(floor(val)==val)) && all(all(val>=0))))
            obj.sdKey = val;
        else
            error('ICNNA:rawData_NIRScout:set.sdKey:InvalidParameterValue',...
                  'Value must be a matrix positive integers.');
        end
      end


      function res = get.sdMask(obj)
         %Gets or sets the object's |sdMask|
         res = obj.sdMask;
      end
      function obj = set.sdMask(obj,val)
         %Sets the object's |sdMask|
        if (all(all(isnan(val))) || (all(all(ismember(val,[0,1])))))
            obj.sdMask = val;
        else
            error('ICNNA:rawData_NIRScout:set.sdMask:InvalidParameterValue',...
                  'Value must be a binary matrix (of 0s and 1s).');
        end
      end


         %Channel Distances

      function res = get.channelDistances(obj)
         %Gets or sets the object's |channelDistances|
         res = obj.channelDistances;
      end
      function obj = set.channelDistances(obj,val)
         %Sets the object's |channelDistances|
        if (all(all(val>=0)) && length(val)==obj.nChannels)
            obj.channelDistances = val;
        else
            if (length(val)==obj.nChannels)
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a vector positive numbers.');
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Number of channel distances is different from the number of channels.');
            end
        end

        %Ensure number of channelDistances matches the number of channels (visible
        %in the mask)
        sillyNChannels = get(obj,'nChannels');
        if (numel(obj.channelDistances) < sillyNChannels)
            %Add new distances and send warning
            obj.channelDistances(end+1:end+sillyNChannels)=nan;
            warning('Adding default channel distances to new channels.')
        elseif (numel(obj.channelDistances) > sillyNChannels)
            %Discard latter distances and send warning
            obj.channelDistances(sillyNChannels+1:end)=[];
            warning('Removing extra channel distances.')
            %else %(obj.channelsDistances == sum(sum(obj.sdMask)))
            %Do nothing
        end


      end





         %Patient Information

      function res = get.userName(obj)
         %Gets or sets the object's |userName|
         res = obj.userName;
      end
      function obj = set.userName(obj,val)
         %Sets the object's |userName|
        obj.userName = val;
      end
      function res = get.subjectName(obj)
         %Gets or sets the object's |userName|
         res = obj.userName;
      end
      function obj = set.subjectName(obj,val)
         %Sets the object's |userName|
        obj.userName = val;
      end


      function res = get.userGender(obj)
         %Gets or sets the object's |userGender|
         res = obj.userGender;
      end
      function obj = set.userGender(obj,val)
         %Sets the object's |userGender|
        if isempty(val)
            obj.userGender = 'UNSET';
        elseif ischar(val)
            %Try to decode the gender; if not possible, set to 'U'
            %and issue a warning.
            if ismember(upper(val),{'F','FEMALE','WOMAN'})
                obj.userGender = 'FEMALE';
            elseif ismember(upper(val),{'M','MALE','MAN'})
                obj.userGender = 'MALE';
            elseif ismember(upper(val),{'U','UNSET'})
                obj.userGender = 'UNSET';
            else
                obj.userGender = 'UNSET';
                warning('ICNNA:rawData_NIRScout:set.userGender:UnexpectedParameterValue',...
                        ['Value for subject gender is not recognised. ' ...
                        'It will be set to (U)nset. ' ...
                        'Try common gender identifiers e.g. (M)ale or (F)emale.']);
            end
        else
            error('ICNNA:rawData_NIRScout:set.userGender:InvalidParameterValue',...
                  'Value must be a string.');
        end
      end
      function res = get.subjectGender(obj)
         %Gets or sets the object's |userGender|
         res = obj.userGender;
      end
      function obj = set.subjectGender(obj,val)
         %Sets the object's |userGender|
        obj.userGender = val;
      end


      function res = get.userAge(obj)
         %Gets the object's |subjectAge|
         res = obj.userAge;
      end
      function obj = set.userAge(obj,val)
         %Sets the object's |subjectAge|
        obj.userAge = val;
      end
      function res = get.subjectAge(obj)
         %(DEPENDENT) Gets the object's |subjectAge|
         res = obj.userAge;
      end
      function obj = set.subjectAge(obj,val)
         %(DEPENDENT) Sets the object's |subjectAge|
        obj.userAge = val;
      end







         %The data itself

      function res = get.lightRawData(obj)
         %Gets or sets the object's |lightRawData|
         res = obj.lightRawData;
      end
      function obj = set.lightRawData(obj,val)
         %Sets the object's |lightRawData|
        if (isreal(val) && size(val,3)==length(obj.probesetInfo))
            obj.lightRawData = val;
                %Note that the size along the 3rd dimension is expected to
                %match the number of probes sets declared.
                %See assertInvariants
        else
            error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Size of data is expected to match the number of probes sets declared.');
        end
      end

















    end



end

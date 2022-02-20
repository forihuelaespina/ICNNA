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
% Copyright 2018
% @date: 4-Apr-2018
% @author: Felipe Orihuela-Espina
% @modified: 25-Apr-2018
%
% See also rawData, rawData_NIRScout
%

%% Log
%
% 4/25-Apr-2018 (FOE): Class created.
%
% 30-Oct-2018 (FOE): Class should now recognize files for version 15.2
%
% 13-February-2022 (ESR): Get/Set Methods created in rawData_NIRScout
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside the rawData_NIRScout class.
%   +The samplingPeriod dependent property depends on samplingRate. 
%

classdef rawData_NIRScout < rawData
    properties (SetAccess=private, GetAccess=private)
        %General information
        filename='NIRS-2018-01-01_001';
        device='NIRScout 16x24';
        source='LED';
        studyTypeModulation='Human Subject';
        fileVersion='14.2';
        subjectIndex=1;

        % Measurement information
        probesetInfo=struct('geom',[],'probes',[],'temphandles',[],...
                            'probeInforFileName',[],...
                            'probeInforFilePath',[])
        
        nSources=16; %Number of source steps in measurement.
        nDetectors=8; %Number of detector channels.
        nChannels=0; %Number of channels.
        nSteps=16; %Number of steps (illumination pattern).
        wLengths=[780 830];%The nominal wavelengths at which the light
            %intensities were acquired in [nm] for a laser based
            %equipment.
        nTriggerInputs=0; %Number of trigger inputs.
        nTriggerOutputs=0; %Number of trigger outputs (only available for
                          %NIRScoutX).
        nAnalogInputs =0; %Number of auxiliary analog inputs.
        samplingRate = 1; % Sampling rate in Hz.
        modulationAmplitudes =[0 0]; %Modulation amplitudes for illumination.
        modulationThresholds =[0.0 0.0]; %Modulation thresholds used (?0 only
                                    %for Laser).
%         probesetInfo = struct('read',{},'type',{},'mode',{});
%         repeatCount=0; %Repeat Count (e.g. Number of blocks)


        % Paradigm Information
        paradigmStimulusType='';

        % Experimental Notes
        notes='';

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
        

        
        % Channel Distances
        %channelDistance=nan(nChannels); %I can't do this here...obj has
        %not yet been created and number of channels has not yet been
        %"decoded"
        channelDistances=nan(1,0);       
        
        
        
        %Subject Demographics
        userName='';
        userGender='U';
        userAge=1;
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
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        % Channel Distances:
        %channelDistances
        function val = get.channelDistances(obj)
           val = obj.channelDistances; 
        end
        function obj = set.channelDistances(obj,val)
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
        end
        
        %General information
        %device
        function val = get.device(obj)
            val = obj.device;
        end
        function obj = set.device(obj,val)
            if (ischar(val))
                obj.device = val;
            else
            error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        %Markers Information
        %eventTriggerMarkers
        function val = get.eventTriggerMarkers(obj)
           val = obj.eventTriggerMarkers; 
        end
        function obj = set.eventTriggerMarkers(obj,val)
            if (size(val,2)==3 && all(all(floor(val(:,2:3))==val(:,2:3))) && all(all(val>=0)))
                obj.eventTriggerMarkers = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a 3 columns matrix with the second and third columns being integer numbers.');
            end  
        end
        
        %General Information
        %filename
        function val = get.filename(obj)
            val = obj.filename;
        end
        function obj = set.filename(obj,val)
            if (ischar(val))
                obj.filename = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        %General Information
        %fileVersion
        function val = get.fileVersion(obj)
            val = obj.fileVersion;
        end
        function obj = set.fileVersion(obj,val)
            if (ischar(val))
                obj.fileVersion = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        %Gain settings
        %gains
        function val = get.gains(obj)
            val = obj.gains;
        end
        function obj = set.gains(obj,val)
            if any(any(val<0))
            warning('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Nagative gain found.');
            end
            obj.gains = val;
        end
        
        
        
        %wLengths
        function val = get.wLengths(obj)
            val = obj.wLengths;
        end
        function obj = set.wLengths(obj,val)
            if (isvector(val) && isreal(val))
                obj.wLengths = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a vector of wavelengths in nm.');
            end
        end
        
        %The data itself!!
        %lightRawData
        function val = get.lightRawData(obj)
           val = obj.lightRawData; %The raw light intensity data.
        end
        function obj = set.lightRawData(obj,val)
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
        
        % Measurement information
        %modulationAmplitudes
        function val = get.modulationAmplitudes(obj)
            val = obj.modulationAmplitudes;
        end
        function obj = set.modulationAmplitudes(obj,val)
            if (isvector(val) && isreal(val))
                obj.modulationAmplitudes = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a vector of amplitudes.');
            end
        end
        
        % Measurement information
        %modulationThresholds
        function val = get.modulationThresholds(obj)
            val = obj.modulationThresholds;
        end
        function obj = set.modulationThresholds(obj,val)
            if (isvector(val) && isreal(val))
                obj.modulationThresholds = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a vector of thresholds.');
            end
        end
        
        % Experimental Notes
        %notes
        function val = get.notes(obj)
            val = obj.notes;
        end
        function obj = set.notes(obj,val)
            if (ischar(val))
                obj.notes = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        % Measurement information: -------------------------------------->
        
        %nAnalogInputs
        function val = get.nAnalogInputs(obj)
            val = obj.nAnalogInputs;
        end
        function obj = set.nAnalogInputs(obj,val)
            if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
                obj.nAnalogInputs = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be an integer number.');
            end
        end
       
        %nChannels
        function val = get.nChannels(obj)
            %Total number of channels across all probes.
            val = obj.nChannels;
        end
        function obj = set.nChannels(obj,val)
            if (isscalar(val) && isnumeric(val) && mod(val,val)==0 && val>=0)
                obj.nChannels = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be an integer number.');
            end
        end
        
        %nDetectors
        function val = get.nDetectors(obj)
            val = obj.nDetectors;
        end
        function obj = set.nDetectors(obj,val)
            if (isscalar(val) && isnumeric(val) && mod(val,val)==0 && val>=0)
                obj.nDetectors = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be an integer number.');
            end
        end

        %nSources
        function val = get.nSources(obj)
            val = obj.nSources;
        end
        function obj =setnSources(obj,val)
            if (isscalar(val) && isnumeric(val) && mod(val,val)==0 && val>=0)
                obj.nSources = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be an integer number.');
            end
        end

        %nSteps
        function val = get.nSteps(obj)
            val = obj.nSteps;
        end
        function obj = set.nSteps(obj,val)
            if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
                obj.nSteps = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be an integer number.');
            end
        end

        %nTriggerInputs
        function val = get.nTriggerInputs(obj)
            val = obj.nTriggerInputs;
        end
        function obj = set.nTriggerInputs(obj,val)
            if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
                obj.nTriggerInputs = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be an integer number.');
            end
        end

        %nTriggerOutputs
        function val = get.nTriggerOutputs(obj)
            val = obj.nTriggerOutputs;
        end
        function obj = set.nTriggerOutputs(obj,val)
            if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
                obj.nTriggerOutputs = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be an integer number.');
            end
        end
        %---------------------------------------------------------------->
        
        %Measure information
        %probesetInfo
        function val = get.probesetInfo(obj)
            val = obj.probesetInfo;
        end
        function obj = set.probesetInfo(obj,val)
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
                        warning('ICNNA:rawData_NIRScout:set:UnexpectedParameterValue',...
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
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a struct.');
            end
        end
        
        %Paradigm Information
        %paradigmStimulusType
        function val = get.paradigmStimulusType(obj)
            val = obj.paradigmStimulusType;
        end
        function obj = set.paradigmStimulusType(obj,val)
            if (ischar(val))
                obj.paradigmStimulusType = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
                
        %General Information
        %Source
        function val = get.source(obj)
            val = obj.source;
        end
        function obj = set.source(obj,val)
            if (ischar(val) && ismember(upper(val),{'LED','LASER'}))
                obj.source = upper(val);
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be either "LED" or "LASER".');
            end
        end
        
        %General Information
        %studyTypeModulation
        function val = get.studyTypeModulation(obj)
            val = obj.studyTypeModulation;
        end
        function obj = set.studyTypeModulation(obj,val)
            if (ischar(val))
                obj.studyTypeModulation = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        %General Information
        %subjectIndex
        function val = get.subjectIndex(obj)
            val = obj.subjectIndex;
        end
        function obj = set.subjectIndex(obj,val)
            if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
                obj.subjectIndex = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be an integer number.');
            end
        end
        
        % Measurement information
        %samplingRate
        function val = get.samplingRate(obj)
            val = obj.samplingRate;
        end
        function obj = set.samplingRate(obj,val)
            if (isscalar(val) && isreal(val) && val>0)
                obj.samplingRate = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a positive real');
            end
        end
        
        % Measurement information
        %samplingPeriod
        function val = get.samplingPeriod(obj)
           val = 1/obj.samplingRate; 
        end
        
        % Data Structure: ----------------------------------------------->
        %sdKey
        function val = get.sdKey(obj)
           val = obj.sdKey; 
        end
        function obj = set.sdKey(obj,val)
            if (all(all(floor(val)==val)) && all(all(val>=0)))
                obj.sdKey = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a matrix positive integers.');
            end 
        end
        
        %sdMask
        function val = get.sdMask(obj)
           val = obj.sdMask; 
        end
        function obj = set.sdMask(obj,val)
           if (all(all(ismember(val,[0,1]))))
                obj.sdMask = val;
           else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a binary matrix (of 0s and 1s).');
           end 
        end
        %--------------------------------------------------------------->
        
        
        %Patient information: ------------------------------------------>
        %userAge
        function val = get.userAge(obj)
           val = obj.userAge; 
        end
        function obj = set.userAge(obj,val)
           if (isscalar(val) && isreal(val))
                obj.userAge = val;
           else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be numeric');
           
           
           end 
        end

        %userGender
        function val = get.userGender(obj)
           val = obj.userGender; 
        end
        function obj = set.userGender(obj,val)
           if isempty(val)
                obj.userGender = 'U';
            elseif ischar(val)
                %Try to decode the gender; if not possible, set to 'U'
                %and issue a warning.
                if ismember(upper(val),{'F','FEMALE','WOMAN'})
                        obj.userGender = 'F';
                    elseif ismember(upper(val),{'M','MALE','MAN'})
                        obj.userGender = 'M';
                    elseif ismember(upper(val),{'U'})
                        obj.userGender = 'U';
                else
                    obj.userGender = 'U';
                    warning('ICNNA:rawData_NIRScout:set:UnexpectedParameterValue',...
                        ['Value for subject gender is not recognised. ' ...
                        'It will be set to (U)nset. ' ...
                        'Try common gender identifiers e.g. (M)ale or (F)emale.']);
                end
           else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a string.');
           end 
        end
        
        %userName
        function val = get.userName(obj)
           val = obj.userName; 
        end
        function obj = set.userName(obj,val)
            if ischar(val)
                obj.userName = val;
            else
                error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end

    end

    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Static)
        coe=table_abscoeff;
    end

end

classdef rawData_NIRx < icnna.data.core.rawData
%Class rawData_NIRx
%
% This class supersedes class |rawData_NIRScout|.
% 
%
%A rawData_NIRx represents data experimentally recorded with a NIRx device
%e.g. NIRScout or NIRSport, during a fNIRS session, and stored in NIRx
%propietary format defined with NIRStar software.
%
%% About NIRx propietary format
%
% NIRx offers (or has offered) a family of CW-fNIRS devices that comes in
%several presentations (see NIRScout User manual, Sections 6 and 8 pgs. 21-25):
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
%   + NIRSport: A portable system.
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
% The NIRx propietary format (NIRStar software) has changed substantially
% over the years. The information is stored not in a file, but spread
% in several files within a folder.
%
%   Depending on the version of the files, the following information
%   may (or may be not) be present.
%
% +++++ .hdr: Header file ++++++++++
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
% +++++ .wl1/.wl2: Light data at different wavelength ++++++++++
%  == The data
%   .wl* - The raw light intensity data as a 2D matrix (time x channel)
%       + NOTE: There will be one field per wavelength, e.g. wl1, wl2, etc.
%  
%
%
%% Remarks
%
% The NIRx propietary format (NIRStar software) has changed substantially
% over the years. Although this class aims to keep some backward
% compatibility, this is not guaranteed. If you find some issues when
% importing your data, please do get in touch with ICNNA developers. 
%
% Moreover, rather than attempting to have hard-coded properties
% as in the old class |rawData_NIRScout|, this new class aims to store
% the information in a dynamic soft-format that should be able to adapt to
% NIRx changes easier. This should simplify the implementation of the
% import method. The price to pay is a more complicated conversion
% later (but note that there is no convert method anymore).
%
%% Superclass
%
% icnna.data.core.rawData - An abstract class for holding raw data.
%
%
%% Properties
% 
%   == Inherited
%       See class icnna.data.core.rawData
%       
%
%
%% Methods
%
% Type methods('rawData_NIRx') for a list of methods
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.rawData, rawData_NIRScout
%


%% Log
%
%   + Class available since ICNNA v1.2.3
%
% 2-Feb-2025: FOE
%   + File and class created.
%   Although the class supersedes class |rawData_NIRScout|, the internal
%   rationale is completely different (see Remarks above). Hence, the
%   whole code is virtually brand new.
%
%



    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties %(SetAccess=private, GetAccess=private)
        %No new properties defined.
    end


 
    methods    
        function obj=rawData_NIRScout(varargin)
            %ICNNA.DATA.MISC.RAWDATA_NIRScout RawData_NIRScout class constructor
            %
            % obj=icnna.data.misc.rawData_NIRx() creates a default rawData_NIRx
            %   with ID equals 1.
            %
            % obj=icnna.data.misc.rawData_NIRx(obj2) acts as a copy constructor of
            %   rawData_NIRx
            %
            % obj=icnna.data.misc.rawData_NIRx(id) creates a new rawData_NIRx
            %   with the given identifier (id). The name of the
            %   rawData_NIRx is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %
                        
            if (nargin==0)
                %Keep all other default values
            elseif isa(varargin{1},'rawData_NIRx')
                obj=varargin{1};
                return;
            else
                obj.id=varargin{1};
                obj.description=['RawData' num2str(obj.id,'%04i')];
            end
            assertInvariants(obj);

        end
  
    end


end

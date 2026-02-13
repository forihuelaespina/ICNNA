classdef nirsMontage < icnna.data.core.montage
% icnna.data.core.nirsMontage - A montage for an fNIRS neuroimaging.
%
% This class provides a specific implementation of @icnna.data.core.montage
% for fNIRS neuroimaging. The fundamental sampling location in fNIRS
% neuroimages is the channel which arises from the pairing of
% a @icnna.data.core.lightSource and an @icnna.data.core.lightDetector.
% Each channel can be responsible to yield a number of measurements.
%
% This class is somewhat the ICNNA native alternative to .snirf's
% @icnna.data.snirf.probe. While there is a substantial overlap between
% these two classes, the separation allows ICNNA to:
% 1) better provide backward compatibility with previous ICNNA versions, and
% 2) should it be needed, store additional information that .snirf's
%   @icnna.data.snirf.probe, by being linked to the snirf file format
%   standard, may not provide. For instance, the montage keeps track
%   of both nominal and actual locations for both channels and optodes.
%
% A @icnna.data.core.nirsMontage provides support to describe the
%the arrangement of optodes and channels on the head. 
% An @icnna.data.core.nirsMontage captures the spatial positioning
% of channels for a NIRS neuroimage in different ways:
%   * Real world coordinates location (e.g. <X,Y,[Z]>) - The real world
%       coordinates are cartesian coordinates.
%   * Channel surface position (e.g. standard 10/20, but also supports
%       more refined systems like the UI 10/10 or the 10/5).
%           Note that .snirf alternative landmarks is not "attached" to
%           channels, and yes, ICNNA also provides additional landmarks
%           in the form of @icnna.data.core.referencePoints.
%
%This class further keeps track of the @icnna.data.core.optodes (both
% @icnna.data.core.lightSource and @icnna.data.core.lightDetector)
% and their pairings (to conform the channels).
%
%The @icnna.data.core.montage also allows to allocate the different
% optodes and channels to a physical holder a.k.a. optode array, tile
% and/or a probe set.
%
%% Optode arrays, tiles and probesets
%
% Near Infrared Spectroscopy optodes in neuroimage are commonly
% disposed in optode arrays, tiles or sets of probes (here all
% gathered under the concept of probeset), e.g.
% old HITACHI arrays, or hyperscanning splitting.
%
% The class name may be a bit misleading to the NIRS community where
% the montage has been called probe or probeset; See the corresponding
% entry term in the standard fNIRS glossary:
%
% https://openfnirs.org/?swp_form%5Bform_id%5D=2&s=probeset
%
% However, here a probeset stands for an optode array, a tile or any other
% generic form of probeset. A montage can represent several probesets.
% See property |probesets|. In this sense, ICNNA adopts the term montage,
% which is perhaps more common in the EEG community, to refer to the
% whole arrangement of optodes.
%
% Although by default all optodes are assigned to a default
% probeset (i.e. probeset.id=1), this class can keep track of
% such allocation, by storing a probeset.id associated to each
% optode. Please refer to property |probesets|.
%
%
%% Remarks
%
% IMPORTANT: The @icnna.data.core.montage does NOT hold any image
%   data! It only stores information about the montage design
%  to acquire such neuroimage.
%
% In contrast to the channelLocationMap, here sources and detectors
%have separate |id|, so there can be one source and one detector
%sharing the same |id|. There is still the restriction that
%sources cannot have the same |id| among themselves, nor can detectors
%share |id| among themselves.
%
%% Properties
%
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties from icnna.data.core.identifiableObject
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. Default is 'montage0001'
%       The montage name.
%
%   -- Inherited properties from icnna.data.core.montage
%   .samplingLocationName - char[]. Default is 'channel'.
%       The common name to refer to the sampling location in the sensing
%       modality at hand, e.g. 'pixel', 'voxel', 'channel', etc
%
%   -- Public properties
%   .positioningSystem - Char array. Default is 'UI 10/10'
%       The surface positioning system used for reference.
%       All @icnna.data.core.optodes and free landmarks (e.g.
%       @icnna.data.core.referenceLocations) ought to share this
%       positioningSystem.
%   .baseDistance - char[]. (Enum) Default is 'euclidean'
%       Distance function used to estimate the interoptode distance or
%       source-detector separation  for channels. See icnna.util.pdist2
%       for accepted distance functions.
%   .shortChannelThreshold - double. Default is 12 [mm].
%       A threshold to decide whether a channel is considered 'short'
%       or 'long' in [mm].
%       The decision of whether channels are 'short' or 'long' give 
%       preference to the 3D locations of the optodes over the 2D. That
%       is, whether a channel is short or not is always determined over
%       the channel's |nominalIOD3D| first, and only if this yields NaN,
%       then it attempts to use the channel's |nominalIOD2D|.
%
%  -- Set access private properties
%   .sources - struct[] of @icnna.data.core.lightSource. Default is empty
%       List of light sources.
%       Light sources are sorted by |id|
%   .detectors - struct[] of @icnna.data.core.lightDetector. Default is empty
%       List of light detectors.
%       Light detectors are sorted by |id|
%   .probesets - struct[] Each struct is a probeset. Default is empty.
%       List of probesets. Probesets permits logically grouping
%       the optodes whether due to hardware/instrumentation separation
%       e.g. tiles, or due to experimental separation e.g. hyperscanning
%       settings. Optodes (whether sources or detectors) can
%       be associated to one or more probesets.
%       Each probeset is characterized by the following fields;
%          + id - uint32. The probeset id,
%          + name - char[] The probeset name.
%           The default probeset will be named 'probeset0001' but
%           the user can change this.
%          + sources_id - uint32[]. Default is empty
%           The list of |id| from the associated |sources|.
%          + detectors_id - uint32[]. Default is empty
%           The list of |id| from the associated |detectors|.
%          + channels_id - uint32[]. Default is empty
%           The list of |id| from the associated |channels|.
%       Probesets are sorted by |id| and all probeset |id| and |name|
%       ough to be unique. 
%   .channels - struct[]. Default is empty.
%         Light sources and detector pairings forming a channel.
%         Each struct is an channel.
%         The list has AT LEAST the following columns;
%          + id - uint32. The channel id.
%          + name - char[]. The channel name e.g. 'ch001:src001:det002'
%          + nominalLocation - @icnna.data.core.referenceLocation
%               A nominal location for the channel, usually the
%               mid point between the source and the detector.
%          + actualLocation - @icnna.data.core.referenceLocation
%               A registered location for the channel, usually
%               observed by some registration effort.
%          + source_id - uint32. The associated source |id| (see property |sources|).
%          + detector_id - uint32. The associated detector |id| (see property |detectors|).
%       Channels are sorted by their own |id|.
%   .measurements - struct[]. Default is empty.
%         List of measurements acquired at each channel.
%         Each struct is an measurement (somewhat alike .snirf's
%           measurements).
%         Each struct has AT LEAST the following fields;
%          + id - uint32. The measurement id.
%          + name - char[]. The measurement name e.g. 'measurement0001'.
%          + channel_id - uint32. The |id| of the channel where this
%           measurement was acquired.
%          + label - char[]. The measurement label e.g. 'HbO'. While
%           not enforced, as ICNNA considers the recording of non-nirs
%           measurements e.g. multi-modal imaging, but it is recommended
%           that for fNIRS related measurements, .snirf standard
%           labels are used;
%
%           https://github.com/fNIRS/snirf/blob/master/snirf_specification.md#supported-measurementlistkdatatypelabel-values-in-datatimeseries
%
%          + type - int.
%           A measurement type (mostly) as per .snirf measurement data type;
%           See type codes here:
%
%            https://github.com/fNIRS/snirf/blob/master/snirf_specification.md#supported-measurementlistkdatatype-values-in-datatimeseries
%
%           In addition, ICNNA reserves types identified by
%           negative values e.g. -1 for measurements not associated with
%           .snirf recognised measurements.
%          + metadata - struct[]- Default is empty.
%       Note that there are different types of measurements for instance
%       depending on whether the data is reconstructed or not (e.g.
%       intensities, optical densities, reconstructed concentrations, etc).
%       Each type of measurement requires different concomitant
%       information or metadata. In principle, .snirf collects
%       the same information for all types measurements, but this
%       is somewhat rigid. For instance, in .snirf each measurement
%       stores information about an associated wavelength, but this
%       information makes no sense for measurements of chromophore
%       concentrations. ICNNA addresses this in a slightly different
%       manner, by allowing each measurement to include different
%       metadata. Note also that some .snirf measurement information
%       such as the the detector gain or the source power, ICNNA does
%       store it directly in the @icnna.data.core.lightSource and
%       @icnna.data.core.lightDetector respectively, so the correspondence
%       is NOT one-to-one. The following table summarizes the expected
%       metadata for .snirf standard types, but in addition to these
%       the user can define its own metadata;
%
%     Measurement      |    Parameter    | 
%   type | Description |       name      | Meaning
%  ------+-------------+-----------------+-----------------------
%    1   | Raw CW      | wavelength      | double. Nominal acquisition
%        | Amplitude   |                 |   wavelength [nm].
%        |             |                 |   In contrast to .snirf, this
%        |             |                 |   field holds the wavelength
%        |             |                 |   itself rather than some index.
%        |             | wavelengthActual| double. Actual acquisition
%        |             |                 |   wavelength [nm].
%        |             | unit            | char[]. Units in which the
%        |             |                 |   measurement is acquired.
%        |             | unitMultiplier  | int. Units multiplier in
%        |             |                 |   power of 10.
%  ------+-------------+-----------------+-----------------------
%
%       Measurements are sorted by their own |id|
%   .landmarks - icnna.data.core.referenceLocation[]
%         List of additional landmarks (i.e. reference locations)
%       Landmarks are sorted by |id| which ought to be unique within
%       a montage.
%
%
%% Dependent properties
%
%   -- Inherited properties from icnna.data.core.montage
%   .nSamplingLocations - Int. Read-only.
%       The total number of sampling locations in the montage.
%       Here this matches |nChannels|.
%
%   -- New dependent properties
%   .optodes - struct[] of @icnna.data.core.optodes. Read-only
%       The collection of both |sources| and |detectors|.
%       Although this is sorted by optode's |id| but note that
%       a source and a detector may have the same |id|.
%   .nOptodes - Int. Read-only
%       Number of optodes (sum of emitters and detectors)
%   .nSources - Int. Read-only
%       Number of sources
%   .nDetectors - Int. Read-only
%       Number of detectors
%   .nChannels - Int. Read-only
%       Number of total channels. This includes both short and long
%       channels.
%       Here this matches |nSamplingLocations|
%   .nMeasurements - Int. Read-only
%       Number of total measurements. Since there may be (likely are)
%       more than one measurement per channel e.g. one per wavelength,
%       this figure is likely higher than the number of channels.
%   .nProbesets - Int. Read-only
%       Number of probesets.
%
%   .channelsNominalLocations2D - Array of double sized <nChannels,2>. Read-only
%       Nominal 2D locations of the channels calculated on the fly.
%       See properties |channels|.|nominalLocation|.|location2D| and |baseDistance|
%   .measurementsNominalLocations2D - Array of double sized <nMeasurements,2>. Read-only
%       Nominal 2D locations of the channels to which the measurements are
%       associated. See |channelsNominalLocations2D|
%
%   .channelsNominalLocations3D - Array of double sized <nChannels,3>. Read-only
%       Nominal 3D locations of the channels calculated on the fly.
%       See properties |channels|.|nominalLocation|.|location3D| and |baseDistance|
%   .measurementsNominalLocations3D - Array of double sized <nMeasurements,3>. Read-only
%       Nominal 3D locations of the channels to which the measurements are
%       associated. See |channelsNominalLocations3D|
%
%   .channelsActualLocations2D - Array of double sized <nChannels,2>. Read-only
%       Actual 2D locations of the channels calculated on the fly.
%       See properties |channels|.|actualLocation|.|location2D| and |baseDistance|
%   .measurementsActualLocations2D - Array of double sized <nMeasurements,2>. Read-only
%       Actual 2D locations of the channels to which the measurements are
%       associated. See |channelsActualLocations2D|
%
%   .channelsActualLocations3D - Array of double sized <nChannels,3>. Read-only
%       Actual 3D locations of the channels calculated on the fly.
%       See properties |channels|.|actualLocation|.|location3D| and |baseDistance|
%   .measurementsActualLocations3D - Array of double sized <nMeasurements,3>. Read-only
%       Actual 3D locations of the channels to which the measurements are
%       associated. See |channelsActualLocations3D|
%
%   .channelsNominalIOD2D - double[] sized <nChannels,1>. Read-only
%       Channels nominal 2D interoptode distances calculated on the fly.
%       See properties |channels|.|nominalIOD2D| and |baseDistance|
%
%   .channelsNominalIOD3D - double[] sized <nChannels,1>. Read-only
%       Channels nominal 3D interoptode distances calculated on the fly.
%       See properties |channels|.|nominalIOD3D| and |baseDistance|
%
%   .channelsActualIOD2D - double[] sized <nChannels,1>. Read-only
%       Channels actual 2D interoptode distances calculated on the fly.
%       See properties |channels|.|actualIOD2D| and |baseDistance|
%
%   .channelsActualIOD3D - double[] sized <nChannels,1>. Read-only
%       Channels actual 3D interoptode distances calculated on the fly.
%       See properties |channels|.|actualIOD3D| and |baseDistance|
%
%   .shortChannels - bool[] sized <nChannels,1>. Read-only
%       Channels flags indicating whether the channels is considered
%       'short' (1/true) or 'long' (0/false) calculated on the fly.
%       See properties |channels|.|isShort| and |short|
%       Note that this is calculated over the nominal iod of
%       the channel (not the actual iod).
%           Note 1: See property |shortChannelThreshold| for the threshold
%           to decide whether channels are considered 'short' or 'long'.
%           Note 2: isShort is always calculated over |nominalIOD3D| first, and
%           only if this yields NaN, then it attempts to use |nominalIOD2D|.
%
%% Superclass
%
% icnna.data.core.montage - An abstract class for holding montages.
%
%
%% Methods
%
% Type methods('icnna.data.core.montage') for a list of methods
%
%
% Copyright 2025
% Author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.probe, channelLocationMap
%



%% Log
%
%   + Class available since ICNNA v1.4.0
%
% 29-Jun-2025: FOE
%   + File and class created. Class is still unfinished (and not
%   documented).
%
% 1-Jul-2025: FOE
%   + Worked on adding the private and dependent properties.
%   Class structure is now complete but the class remains unfinished
%   in the sense that all the methods to interact with the private
%   properties are still missing.
%
%
% 21/23-Dec-2025: FOE
%   + Class is now subclass of icnna.data.core.montage
%   + Change the class name from icnna.data.core.nirsProbeset to
%   icnna.data.core.nirsMontage (no harm done as the class has 
%   not yet been published).
%   + Refined the implementation (UNFINISHED).
%   + Improved comments.
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        positioningSystem(1,:) char = 'UI 10/10';
        baseDistance(1,:) char = 'euclidean';
        shortChannelThreshold double {mustBeNonNan,mustBeNonnegative} = 12;
    end

    properties (SetAccess=private)
        exclusory(:,:) logical = false(0,0); %Pairwise exclusory states
        conditions(:,1) icnna.data.core.condition = ...
                    icnna.data.core.condition.empty; % List of conditions 
    end


    properties (SetAccess=private)
        sources(:,1) icnna.data.core.lightSource = ...
                    icnna.data.core.lightSource.empty; % List of sources
        detectors(:,1) icnna.data.core.lightDetector = ...
                    icnna.data.core.lightDetector.empty; % List of detectors

        probesets struct = struct( ...
            'id', [], ...
            'name', {}, ...
            'sources_id', [], ...
            'detectors_id', [], ...
            'channels_id', []); % List of probesets
        
        channels struct = struct( ...
            'id', [], ...
            'name', {}, ...
            'nominalLocation', {}, ...
            'actualLocation', {}, ...
            'source_id', [], ...
            'detector_id', []); % List of channels

        measurements struct = struct( ...
            'id', [], ...
            'name', {}, ...
            'channel_id', [], ...
            'label', {}, ...
            'type', [], ...
            'metadata', {}); % List of measurements

        landmarks(:,1) icnna.data.core.referenceLocation = ...
                    icnna.data.core.referenceLocation.empty; % List of additional landmarks
    end

    properties (Dependent)
        % Redefine the abstract dependent property here.
        % Note that this is a MATLAB requirement.
        nSamplingLocations
    end


    properties (Dependent)
        optodes  %Read-only
        nOptodes  %Read-only
        nSources  %Read-only
        nDetectors %Read-only

        nChannels %Read-only. This includes both short and long channels
        nMeasurements %Read-only. Number of measurements.
        nProbesets %Read-only. Number of measurements.

        channelsNominalLocations2D  %Read-only. Nominal 2D locations of the channels.
        measurementsNominalLocations2D  %Read-only. Nominal 2D locations of the channels to which the measurements are associated. 
                            %See |channelsNominalLocations2D|
        channelsNominalLocations3D  %Read-only. Nominal 3D locations of the channels.
        measurementsNominalLocations3D  %Read-only. Nominal 3D locations of the channels to which the measurements are associated. 
                            %See |channelsNominalLocations3D|
        channelsActualLocations2D  %Read-only. Actual 2D locations of the channels.
        measurementsActualLocations2D  %Read-only. Actual 2D locations of the channels to which the measurements are associated. 
                            %See |channelsActualLocations2D|
        channelsActualLocations3D  %Read-only. Actual 3D locations of the channels.
        measurementsActualLocations3D  %Read-only. Actual 3D locations of the channels to which the measurements are associated. 
                            %See |channelsActualLocations3D|

        channelsNominalIOD2D %Read-only. Nominal 2D interoptode distances
        channelsNominalIOD3D %Read-only. Nominal 3D interoptode distances
        channelsActualIOD2D  %Read-only. Actual 2D interoptode distances
        channelsActualIOD3D  %Read-only. Actual 3D interoptode distances


        shortChannels %Read-only. Channels flags indicating whether the channels are considered 'short' (1/true) or 'long' (0/false)

    end


    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=nirsMontage(varargin)
            %Constructor for class @icnna.data.core.nirsMontage
            %
            % obj=icnna.data.core.nirsMontage() creates a default nirsMontage
            % obj=icnna.data.core.nirsMontage(obj2) acts as a copy constructor
            %
            % @Copyright 2025
            % Author: Felipe Orihuela-Espina
            %
            
            obj@icnna.data.core.montage();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            obj.samplingLocationName = 'channel';
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.nirsMontage')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.nirsMontage:nirsMontage:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
        end
    end




    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods

         %Retrieves the object |positioningSystem|
        function res = get.positioningSystem(obj)
            % Getter for |positioningSystem|:
            %   Returns the |positioningSystem| of the montage.
            %
            % Usage:
            %   res = obj.positioningSystem;  % Retrieves the positioning system of the montage
            %
            %% Output
            % res - char[].
            %   The positioning system of the montage or 'none'
            %   if the location refers to a free coordinate system.
            %
            res = obj.positioningSystem;
        end
            %Sets the object |positioningSystem|
        function obj = set.positioningSystem(obj,val)
            % Setter for |positioningSystem|:
            %   Sets the |positioningSystem| of the montage.
            %
            %
            % Usage:
            %   obj.positioningSystem = '10/20';  % Set the positioning system to '10/20'
            %
            %% Input parameters
            %
            %  val - char[]
            %   The new positioning system e.g. '10/20'. Use 'none'
            % if the locations refer to a free coordinate system.
            %
            %% Output
            %
            % obj - @icnna.data.core.referenceLocation
            %   The updated object
            %
            %
            obj.positioningSystem = val;
        end

         %Retrieves the object |baseDistance|
        function res = get.baseDistance(obj)
            % Getter for |baseDistance|:
            %   Returns the |baseDistance| to calculate inter-optode
            %   distances
            %
            % Usage:
            %   res = obj.baseDistance;  % Retrieves the base distance
            %
            %% Output
            % res - char[].
            %   The base distance to calculate inter-optode
            %   distances.
            %
            res = obj.baseDistance;
        end
            %Sets the object |baseDistance|
        function obj = set.baseDistance(obj,val)
            % Setter for |baseDistance|:
            %   Sets the |baseDistance| to calculate inter-optode
            %   distances
            %
            %
            % Usage:
            %   obj.baseDistance = 'euclidean';  % Set the base distance to 'euclidean'
            %
            %% Error handling
            %
            %  + val has to be an accepted distance function. Acceptable 
            %   values are:
            %       'euclidean'
            %       'geodesic'
            % 
            %% Input parameters
            %
            %  val - char[] (Enum)
            %   The new base didstance to calculate inter-optode
            %   distances. 
            %
            %% Output
            %
            % obj - @icnna.data.core.referenceLocation
            %   The updated object
            %
            val = lower(val);
            assert(any(strcmp(val,{'euclidean','geodesic'})),...
                ['icnna:data:core:montage:set_baseDistance:InvalidParameterValue',...
                '|baseDistance| ought to be one of the following: ' ...
                '{''euclidean'',''geodesic''}.'])
            obj.baseDistance = val;
        end

         %Retrieves the object |shortChannelThreshold|
        function res = get.shortChannelThreshold(obj)
            % Getter for |shortChannelThreshold|:
            %   Returns the |shortChannelThreshold| of the montage.
            %
            % Usage:
            %   res = obj.shortChannelThreshold;  % Retrieves the |shortChannelThreshold|
            %
            %% Output
            % res - char[].
            %   The threshold distance to decide whether channels are to be
            %   considered 'short' or 'long' in [mm].
            %
            res = obj.shortChannelThreshold;
        end
            %Sets the object |shortChannelThreshold|
        function obj = set.shortChannelThreshold(obj,val)
            % Setter for |shortChannelThreshold|:
            %   Sets the |shortChannelThreshold| of the montage.
            %
            %
            % Usage:
            %   obj.shortChannelThreshold = 12;  % Set the |shortChannelThreshold| to 12 [mm]
            %
            %% Input parameters
            %
            %  val - char[]
            %   The threshold distance to decide whether channels are to be
            %   considered 'short' or 'long' in [mm].
            %
            %% Output
            %
            % obj - @icnna.data.core.referenceLocation
            %   The updated object
            %
            %
            obj.shortChannelThreshold = val;
        end



         %Retrieves the object |sources|
      function res = get.sources(obj)
            % Getter for |sources|:
            %   Returns the list of |sources|.
            %
            % Usage:
            %   res = obj.sources;  % Retrieve the list of light sources.
            %
            %% Output
            % res - icnna.data.core.lightSource[]
            %   The list of |sources|.
            %
         res = obj.sources;
      end
        %NOTE that |sources| set permission is private.
        %See method setSources

         %Retrieves the object |detectors|
      function res = get.detectors(obj)
            % Getter for |detectors|:
            %   Returns the list of |detectors|.
            %
            % Usage:
            %   res = obj.detectors;  % Retrieve the list of light detectors.
            %
            %% Output
            % res - icnna.data.core.lightDetector[]
            %   The list of |detectors|.
            %
         res = obj.detectors;
      end
        %NOTE that |detectors| set permission is private.
        %See method setDetectors

      function res = get.probesets(obj)
            % Getter for |probesets|:
            %   Returns the list of |probesets|.
            %
            % Usage:
            %   res = obj.probesets;  % Retrieve the list of probesets.
            %
            %% Output
            % res - struct[]
            %   The list of |probesets|. Refer to the class documentation
            %   for the fields in the struct.
            %
         res = obj.probesets;
      end
        %NOTE that |probesets| set permission is private.
        %See method setProbesets

      function res = get.channels(obj)
            % Getter for |channels|:
            %   Returns the list of |channels|.
            %
            % Usage:
            %   res = obj.channels;  % Retrieve the list of channels.
            %
            %% Output
            % res - struct[]
            %   The list of |channels|. Refer to the class documentation
            %   for the fields in the struct.
            %
         res = obj.channels;
      end
        %NOTE that |channels| set permission is private.
        %See method setChannels

      function res = get.measurements(obj)
            % Getter for |measurements|:
            %   Returns the list of |measurements|.
            %
            % Usage:
            %   res = obj.measurements;  % Retrieve the list of measurements.
            %
            %% Output
            % res - struct[]
            %   The list of |measurements|. Refer to the class documentation
            %   for the fields in the struct.
            %
         res = obj.measurements;
      end
        %NOTE that |measurements| set permission is private.
        %See method setMeasurements

        function res = get.landmarks(obj)
            % Getter for |landmarks|:
            %   Returns the list of |landmarks|.
            %
            % Usage:
            %   res = obj.landmarks;  % Retrieve the list of landmarks.
            %
            %% Output
            % res - struct[]
            %   The list of |landmarks|. Refer to the class documentation
            %   for the fields in the struct.
            %
         res = obj.landmarks;
      end
        %NOTE that |landmarks| set permission is private.
        %See method setLandmarks





        %-- Dependent properties
         %(DEPENDENT) Retrieves the object |nSamplingLocations|
      function res = get.nSamplingLocations(obj)
            %(DEPENDENT) Retrieves the object |nSamplingLocations|
            %
            % Returns the number of sampling locations (channels) in the
            % montage.
            %
            % Usage:
            %   res = obj.nSamplingLocations;  % Retrieves the list of
            %                       %number of sampling locations (channels)
            %                       %in the montage.
            %
            %% Output
            % res - int
            %   The list of |landmarks|. Refer to the class documentation
            %   for the fields in the struct.
            %
         res = obj.nChannels;
      end

         %(DEPENDENT) Retrieves the object |optodes|
       function res = get.optodes(obj)
            %(DEPENDENT) Retrieves the object |optodes|
            %
            % Returns the list of optodes (sources and detectors).
            %
            % Usage:
            %   res = obj.optodes;  % Retrieves the list of optodes.
            %
            %% Output
            % res - icnna.data.core.optodes[]
            %   The list of |optodes|. Refer to the class documentation
            %   for the fields in the struct.
            %
         res = [obj.sources; obj.detectors];
         [~, idx] = sort([res.id]);
         res = res(idx);
      end

         %(DEPENDENT) Retrieves the object |nOptodes|
       function res = get.nOptodes(obj)
            %(DEPENDENT) Retrieves the object |nOptodes|
            %
            % Returns the number of optodes (sources + detectors).
            %
            % Usage:
            %   res = obj.nOptodes;  % Retrieves the number of optodes.
            %
            %% Output
            % res - int
            %   The number of optodes (sources + detectors).
            %
         res = obj.nSources + obj.nDetector;
      end

         %(DEPENDENT) Retrieves the object |nSources|
      function res = get.nSources(obj)
            %(DEPENDENT) Retrieves the object |nSources|
            %
            % Returns the number of light sources.
            %
            % Usage:
            %   res = obj.nSources;  % Retrieves the number of sources.
            %
            %% Output
            % res - int
            %   The number of light sources.
            %
         res = size(obj.sources,1);
      end

         %(DEPENDENT) Retrieves the object |nDetectors|
      function res = get.nDetectors(obj)
            %(DEPENDENT) Retrieves the object |nDetectors|
            %
            % Returns the number of light detectors.
            %
            % Usage:
            %   res = obj.nDetectors;  % Retrieves the number of detectors.
            %
            %% Output
            % res - int
            %   The number of light detectors.
            %
         res = size(obj.detectors,1);
      end

         %(DEPENDENT) Retrieves the object |nMeasurements|
      function res = get.nMeasurements(obj)
            %(DEPENDENT) Retrieves the object |nMeasurements|
            %
            % Returns the number of measurements.
            %
            % Usage:
            %   res = obj.nMeasurements;  % Retrieves the number of measurements.
            %
            %% Output
            % res - int
            %   The number of measurments.
            %
         res = size(obj.measurements,1);
      end

         %(DEPENDENT) Retrieves the object |nChannels|
      function res = get.nChannels(obj)
            %(DEPENDENT) Retrieves the object |nChannels|
            %
            % Returns the number of channels.
            %
            % Usage:
            %   res = obj.nChannels;  % Retrieves the number of channels.
            %
            %% Output
            % res - int
            %   The number of channels.
            %
         res = size(obj.channels,1);
      end

         %(DEPENDENT) Retrieves the object |nProbesets|
      function res = get.nProbesets(obj)
            %(DEPENDENT) Retrieves the object |nProbesets|
            %
            % Returns the number of probesets.
            %
            % Usage:
            %   res = obj.nProbesets;  % Retrieves the number of probesets.
            %
            %% Output
            % res - int
            %   The number of probesets.
            %
         res = size(obj.probesets,1);
      end

         %(DEPENDENT) Retrieves the object |channelsNominalLocations3D|
      function res = get.channelsNominalLocations3D(obj)
            %(DEPENDENT) Retrieves the object |channelsNominalLocations3D|
            %
            % Nominal 3D locations of the channels
            %
            % Usage:
            %   res = obj.channelsNominalLocations3D;  % Retrieves the nominal 3D locations of the channels
            %
            %% Output
            % res - double[nChannelsx3]
            %   The nominal 3D locations of the channels.
            %
         res = [obj.channels.nominalLocation.location3D];
      end

         %(DEPENDENT) Retrieves the object |measurementsNominalLocations3D|
      function res = get.measurementsNominalLocations3D(obj)
            %(DEPENDENT) Retrieves the object |measurementsNominalLocations3D|
            %
            % Nominal 3D locations of the measurements
            %
            % Usage:
            %   res = obj.measurementsNominalLocations3D;  % Retrieves the nominal 3D locations of the measurements
            %
            %% Output
            % res - double[nMeasurementsx3]
            %   The nominal 3D locations of the measurements.
            %
         tmpLocations = zeros(obj.nMeasurements,3);
         for iMeas = 1:obj.nMeasurements
             chId = obj.measurements(iMeas).channel_id;
             idx = findChannel(obj,chId);
             tmpLocations(iMeas,:) = obj.channels(idx).nominalLocation.location3D;
         end
         res = tmpLocations;
      end

         %(DEPENDENT) Retrieves the object |channelsNominalLocations2D|
      function res = get.channelsNominalLocations2D(obj)
            %(DEPENDENT) Retrieves the object |channelsNominalLocations2D|
            %
            % Nominal 2D locations of the channels
            %
            % Usage:
            %   res = obj.channelsNominalLocations2D;  % Retrieves the nominal 2D locations of the channels
            %
            %% Output
            % res - double[nChannelsx2]
            %   The nominal 2D locations of the channels.
            %
         res = [obj.channels.nominalLocation.location2D];
      end

         %(DEPENDENT) Retrieves the object |measurementsNominalLocations2D|
      function res = get.measurementsNominalLocations2D(obj)
            %(DEPENDENT) Retrieves the object |measurementsNominalLocations2D|
            %
            % Nominal 2D locations of the measurements
            %
            % Usage:
            %   res = obj.measurementsNominalLocations2D;  % Retrieves the nominal 2D locations of the measurements
            %
            %% Output
            % res - double[nMeasurementsx2]
            %   The nominal 2D locations of the measurements.
            %
         tmpLocations = zeros(obj.nMeasurements,2);
         for iMeas = 1:obj.nMeasurements
             chId = obj.measurements(iMeas).channel_id;
             idx = findChannel(obj,chId);
             tmpLocations(iMeas,:) = obj.channels(idx).nominalLocation.location2D;
         end
         res = tmpLocations;
      end



         %(DEPENDENT) Retrieves the object |channelsActualLocations3D|
      function res = get.channelsActualLocations3D(obj)
            %(DEPENDENT) Retrieves the object |channelsActualLocations3D|
            %
            % Actual 3D locations of the channels
            %
            % Usage:
            %   res = obj.channelsActualLocations3D;  % Retrieves the actual 3D locations of the channels
            %
            %% Output
            % res - double[nChannelsx3]
            %   The actual 3D locations of the channels.
            %
         res = [obj.channels.actualLocation.location3D];
      end

         %(DEPENDENT) Retrieves the object |measurementsActualLocations3D|
      function res = get.measurementsActualLocations3D(obj)
            %(DEPENDENT) Retrieves the object |measurementsActualLocations3D|
            %
            % Actual 3D locations of the measurements
            %
            % Usage:
            %   res = obj.measurementsActualLocations3D;  % Retrieves the actual 3D locations of the measurements
            %
            %% Output
            % res - double[nMeasurementsx3]
            %   The actual 3D locations of the measurements.
            %
         tmpLocations = zeros(obj.nMeasurements,3);
         for iMeas = 1:obj.nMeasurements
             chId = obj.measurements(iMeas).channel_id;
             idx = find(obj.channels.id == chId);
             tmpLocations(iMeas,:) = obj.channels(idx).actualLocation.location3D;
         end
         res = tmpLocations;
      end

         %(DEPENDENT) Retrieves the object |channelsActualLocations2D|
      function res = get.channelsActualLocations2D(obj)
            %(DEPENDENT) Retrieves the object |channelsActualLocations2D|
            %
            % Actual 2D locations of the channels
            %
            % Usage:
            %   res = obj.channelsActualLocations2D;  % Retrieves the actual 2D locations of the channels
            %
            %% Output
            % res - double[nChannelsx2]
            %   The actual 2D locations of the channels.
            %
         res = [obj.channels.actualLocation.location2D];
      end

         %(DEPENDENT) Retrieves the object |measurementsActualLocations2D|
      function res = get.measurementsActualLocations2D(obj)
            %(DEPENDENT) Retrieves the object |measurementsActualLocations2D|
            %
            % Actual 2D locations of the measurements
            %
            % Usage:
            %   res = obj.measurementsActualLocations2D;  % Retrieves the actual 2D locations of the measurements
            %
            %% Output
            % res - double[nMeasurementsx2]
            %   The actual 2D locations of the measurements.
            %
         tmpLocations = zeros(obj.nMeasurements,2);
         for iMeas = 1:obj.nMeasurements
             chId = obj.measurements(iMeas).channel_id;
             idx = find(obj.channels.id == chId);
             tmpLocations(iMeas,:) = obj.channels(idx).actualLocation.location2D;
         end
         res = tmpLocations;
      end



         %(DEPENDENT) Retrieves the object |channelsNominalIOD2D|
      function res = get.channelsNominalIOD2D(obj)
            %(DEPENDENT) Retrieves the object |channelsNominalIOD2D|
            %
            % Channels nominal inter-optode distances in 2D
            %
            % Usage:
            %   res = obj.channelsNominalIOD2D;  % Retrieves the channels nominal inter-optode distances in 2D
            %
            %% Output
            % res - double[nChannels]
            %   The channels nominal inter-optode distances in 2D.
            %
         tmpSrcLocations = zeros(obj.nChannels,2);
         tmpDetLocations = zeros(obj.nChannels,2);
         for iCh = 1:obj.nChannels
             idxSrc = find(obj.sources.id   == obj.channels(iCh).source_id);
             idxDet = find(obj.detectors.id == obj.channels(iCh).detector_id);
             tmpSrcLocations(iCh,:) = obj.sources(idxSrc).nominalLocation2D;
             tmpDetLocations(iCh,:) = obj.detectors(idxDet).nominalLocation2D;
         end
         res = diag(icnna.util.pdist2(tmpSrcLocations,tmpSrcLocations,...
                                      obj.baseDistance));
      end


         %(DEPENDENT) Retrieves the object |channelsNominalIOD3D|
      function res = get.channelsNominalIOD3D(obj)
            %(DEPENDENT) Retrieves the object |channelsNominalIOD3D|
            %
            % Channels nominal inter-optode distances in 3D
            %
            % Usage:
            %   res = obj.channelsNominalIOD3D;  % Retrieves the channels nominal inter-optode distances in 3D
            %
            %% Output
            % res - double[nChannels]
            %   The channels nominal inter-optode distances in 3D.
            %
         tmpSrcLocations = zeros(obj.nChannels,3);
         tmpDetLocations = zeros(obj.nChannels,3);
         for iCh = 1:obj.nChannels
             idxSrc = find(obj.sources.id   == obj.channels(iCh).source_id);
             idxDet = find(obj.detectors.id == obj.channels(iCh).detector_id);
             tmpSrcLocations(iCh,:) = obj.sources(idxSrc).nominalLocation3D;
             tmpDetLocations(iCh,:) = obj.detectors(idxDet).nominalLocation3D;
         end
         res = diag(icnna.util.pdist2(tmpSrcLocations,tmpSrcLocations,...
                                      obj.baseDistance));
      end


         %(DEPENDENT) Retrieves the object |channelsActualIOD2D|
      function res = get.channelsActualIOD2D(obj)
            %(DEPENDENT) Retrieves the object |channelsActualIOD2D|
            %
            % Channels actual inter-optode distances in 2D
            %
            % Usage:
            %   res = obj.channelsActualIOD2D;  % Retrieves the channels actual inter-optode distances in 2D
            %
            %% Output
            % res - double[nChannels]
            %   The channels actual inter-optode distances in 2D.
            %
         tmpSrcLocations = zeros(obj.nChannels,2);
         tmpDetLocations = zeros(obj.nChannels,2);
         for iCh = 1:obj.nChannels
             idxSrc = find(obj.sources.id   == obj.channels(iCh).source_id);
             idxDet = find(obj.detectors.id == obj.channels(iCh).detector_id);
             tmpSrcLocations(iCh,:) = obj.sources(idxSrc).actualLocation2D;
             tmpDetLocations(iCh,:) = obj.detectors(idxDet).actualLocation2D;
         end
         res = diag(icnna.util.pdist2(tmpSrcLocations,tmpSrcLocations,...
                                      obj.baseDistance));
      end


         %(DEPENDENT) Retrieves the object |channelsActualIOD3D|
      function res = get.channelsActualIOD3D(obj)
            %(DEPENDENT) Retrieves the object |channelsActualIOD3D|
            %
            % Channels actual inter-optode distances in 3D
            %
            % Usage:
            %   res = obj.channelsActualIOD3D;  % Retrieves the channels actual inter-optode distances in 3D
            %
            %% Output
            % res - double[nChannels]
            %   The channels actual inter-optode distances in 3D.
            %
         tmpSrcLocations = zeros(obj.nChannels,3);
         tmpDetLocations = zeros(obj.nChannels,3);
         for iCh = 1:obj.nChannels
             idxSrc = find(obj.sources.id   == obj.channels(iCh).source_id);
             idxDet = find(obj.detectors.id == obj.channels(iCh).detector_id);
             tmpSrcLocations(iCh,:) = obj.sources(idxSrc).actualLocation3D;
             tmpDetLocations(iCh,:) = obj.detectors(idxDet).actualLocation3D;
         end
         res = diag(icnna.util.pdist2(tmpSrcLocations,tmpSrcLocations,...
                                      obj.baseDistance));
      end



         %(DEPENDENT) Retrieves the object |shortChannels|
      function res = get.shortChannels(obj)
            %(DEPENDENT) Retrieves the object |shortChannels|
            %
            % A boolean mask of short channels.
            %
            % Usage:
            %   res = obj.shortChannels;  % Retrieves the channels actual inter-optode distances in 3D
            %
            %% Output
            % res - bool[nChannels]
            %       Channels flags indicating whether the channels is considered
            %       'short' (1/true) or 'long' (0/false) calculated on the fly.
            %       See properties |channels|.|isShort| and |short|
            %       Note that this is calculated over the nominal iod of
            %       the channel (not the actual iod).
            %           Note 1: See property |shortChannelThreshold| for the threshold
            %           to decide whether channels are considered 'short' or 'long'.
            %           Note 2: isShort is always calculated over |nominalIOD3D| first, and
            %           only if this yields NaN, then it attempts to use |nominalIOD2D|.
        tmp = obj.channelsNominalIOD3D;
        if any(isnan(tmp))
            tmp = obj.channelsNominalIOD2D;
        end
        res = tmp < obj.shortChannelThreshold;
      end


    end

end


classdef channelLocationMap
%Class channelLocationMap
%
%
%   +==================================================+
%   | NOTE: ChannelLocationMaps are associated to a    |
%   |neuroimage object. However, although current      |
%   |implementation can support fMRI and EEG, the fact |
%   |that this class provides support for optodes is   |
%   |clearly oriented towards nirs_neuroimage images.  |
%   |In the future, support for optodes, probe sets,   |
%   |and optode arrays should be detached to a subclass|
%   |specific for nirs_neuroimage.                     |
%   +==================================================+
%
%
%A channelLocationMap captures the spatial positioning of channels
%for a neuroimage in different ways:
%   * Real world coordinates (e.g. <X,Y,Z>)
%   * Channel surface location (e.g. standard 10/20).
%           Note this may be intended, rather than real
%   * Stereotactic coordinates (e.g. MNI coordinates)
%
%It further keeps track of the optode arrangement by storing:
%   * Optodes real world coordinates (e.g. <X,Y,Z>)
%   * Optodes surface location (e.g. standard 10/20)
%           Note this may be intended, rather than real
%   * Optodes types; whether emissor or receptor. See class constants.
%   * Optodes pairings (to conform the channels)
%
%
%The real world coordinates are cartesian coordinates.
%
% In addition to the above representations of the channel locations,
%the map allows to allocate the different optodes and channels to
%a physical holder a.k.a. optode array, and/or a probe set.
%
%
% IMPORTANT: The channelLocationMap class does NOT hold any image data!
%   It only keeps track of the channel locations!
%
%
%% Optode Arrays
%
% Near Infrared Spectroscopy optodes in neuroimage are commonly
%disposed in optode arrays coupling light emitters and detectors
%to form channels at specific places.
%   The size and type of the optode array and hence the number
%of channels that the optode array can accommodate and their spatial
%disposition (topological arrangement) vary with every device. This
%information is encoded in this class, which hold
%the information about the topological arrangement of the channels
%for the optode array.
%
% Following, a few examples of the topological disposition of channels
%for some known optode arrays are illustrated. All the information
%regarding the optode array configuration is part of the attribute
%oaInfo.
%
%   Example: HITACHI ETG-4000 3x3 optode array
%
%   S - Light Source           S---1---D---2---S
%   D - Light Detector         |       |       |
%   1,..,12 - Channel          3       4       5
%                              |       |       |
%                              D---6---S---7---D
%                              |       |       |
%                              8       9      10
%                              |       |       |
%                              S--11---D--12---S
%
%
%   Example: HITACHI ETG-4000 4x4 optode array
%
%   S - Light Source           S---1---D---2---S---3---D
%   D - Light Detector         |       |       |       |
%   1,..,24 - Channel          4       5       6       7
%                              |       |       |       |
%                              D---8---S---9---D--10---S
%                              |       |       |       |
%                             11      12      13      14
%                              |       |       |       |
%                              S--15---D--16---S--17---D
%                              |       |       |       |
%                             18      19      20      21
%                              |       |       |       |
%                              D--22---S--23---D--24---S
%
%
%           3 -  HITACHI ETG-4000 3x5 optode array
%
%   S - Light Source        S---1---D---2---S---3---D---4---S
%   D - Light Detector      |       |       |       |       |
%   1,..,24 - Channel       5       6       7       8       9
%                           |       |       |       |       |
%                           D--10---S--11---D--12---S--13---D
%                           |       |       |       |       |
%                           14      15      16      17      18
%                           |       |       |       |       |
%                           S--19---D--20---S--21---D--22---S
%
%
%% Optode arrays vs probe sets
%
% An optode array is NOT a probe. A probe set is a collection of sensors,
%but which can be configured in more than one optode array. For instance,
%in the HITACHI ETG-4000 NIRS device with 48 channels, you may have
%2 probes (one for each set of 24 channels), but have 1 (e.g. 4x4 or 3x5)
%or 2 (e.g. 3x3) optode arrays per probe.
%
%
%
%% Properties
%
%   .id - A numerical identifier.
%   .description - A short description
%   .nChannels - Number of channels supported by the channelLocationMap
%   .nOptodes - Number of optodes supported by the channelLocationMap
%   .chLocations - The "real-world" 3D locations of the channels
%       (nChannelsx3 array). Perhaps measured with a Polhemus.
%         This will become critical later when 
%       support for tomographic images is added. These may not
%       be standardised to a stereotactic reference system (see
%       property .stereotacticPositions for more information).
%   .optodesLocations - The "real-world" 3D locations of the optodes
%       (nOptodesx3 array). Perhaps measured with a Polhemus.
%   .optodesTypes - The type of optodes (nOptodesx3 array). Optodes
%       can be of one of the following types:
%           * 0: Unknown
%           * 1: Emission or source
%           * 2: Detector
%       See constants below
%
%   .referencePoints - The "real-world" 3D locations of the reference
%       points; e.g. left ear, right ear, inion, nasion, top (Cz).
%       An array of struct with the following fields
%           .name - A string with the reference location name. In
%               particular the following locations are expected to
%               have standard names:
%                   + 'nasion' or 'Nz': dent at the upper root of the
%                       nose bridge;
%                   + 'inion' or 'Iz': external occipital protuberance;
%                   + 'leftear' or 'LPA': left preauricular point, an
%                       anterior root of the center of the peak
%                       region of the tragus;
%                   + 'rightear' or 'RPA': right preauricular point
%                   + 'top' or 'Cz': Midpoint between Nz and Iz
%           .location - The "real-world" 3D locations of the reference
%               point
%
%   .surfacePositioningSystem - A string indicating the surface positioning
%       system used for reference. Both, channels and optodes
%       must be expressed in the same positioning system.
%           Currently, only the 10/20 and
%       UI 10/10 (default) systems [JurcakV2007] are supported.
%   .chSurfacePositions - A standard surface position for each channel
%       (a nChannelsx1 cell array with a position per channel as a string
%       e.g. 'C3'). Unset positions are indicated with an empty string ''.
%       Refer to property .surfacePositioningSystem for
%       currently supported positioning systems.
%   .optodesSurfacePositions - A standard surface position for each optode
%       (a nOptodesx1 cell array with a position per optode as a string
%       e.g. 'C3'). Unset positions are indicated with an empty string ''.
%       Refer to property .surfacePositioningSystem for
%       currently supported positioning systems.
%
%   .stereotacticPositioningSystem - A string indicating the stereotactic
%       positioning system used for reference. Currently, only the MNI
%       (default) and Talairach systems are supported.
%           SUPPORT FOR STEREOTACTIC INFORMATION IS LIMITED.
%   .chStereotacticPositions - A standard stereotactic position for each
%       channel (a nChannelsx3 array with a position per channel).
%       Refer to property .stereotacticPositioningSystem for
%       currently supported positioning systems.
%           SUPPORT FOR STEREOTACTIC INFORMATION IS LIMITED.
%
%   .chProbeSets - A nChannelsx1 column vector indicating the associated
%       probes set for each channel.
%   .chOptodeArrays - A nChannelsx1 column vector indicating the
%       associated optode array for each channel. Each optode array
%       has an associated information (see property .optodeArrays)
%   .optodesProbeSets - A nOptodesx1 column vector indicating the
%       associated probes set for each optode.
%
%   +==================================================+
%   | NOTE: HITACHI customarily enumerates optodes     |
%   |"locally" to each probe set. Here, optodes        |
%   |numbers, like channels, are unique.               |
%   +==================================================+
%
%
%   .optodesOptodeArrays - A nOptodesx1 column vector indicating the
%       associated optode array for optode. Each optode array
%       has an associated information (see property .optodeArrays)
%   .pairings - A nChannelsx2 matrix indicating the
%       associated optodes conforming each channel. Each pairing
%       must hold a light source and a light detector (or nan if
%       unknown). The source is always stored on the first column
%       and the detector on the second column.
%
%           NOTE: The constant OPTODE_TYPE_UNKNOWN applies to
%               property .optodesTypes
%
%
%   .optodeArrays - An array of struct holding the information for the
%       m different optode arrays. The number of optode arrays (m)
%       is at least the maximum in the property chOptodeArrays.
%       The struct has the following fields:
%           .mode - A string describing the optode array.
%               Valid modes depend on the neuroimage type. Each neuroimage
%               subclass should check the validity of the modes.
%           .type - A string describing whether the optode array is for
%               adults, infants or neonates.
%           .chTopoArrangement - Topographical arrangement of the channels
%               within the optode array. 
%           .optodesTopoArrangement - Topographical arrangement of the
%               optodes within the optode array.
%
%                       The above two subfields are 3D coordinates which
%               locate the channels and optodes respectively internally
%               to the optode array. The
%               XY plane is the surface plane (i.e. over the scalp)
%               with arbitrary rotation and axis origin, and the Z
%               coordinate indicates the depth (with Z=0 being the scalp
%               plane and positive values indicating deeper layers into
%               the head. Note how these coordinates differ from those
%               of the real world in the class attributes .chLocations
%               and optodesLocations.
%                   The coordinates in this property are assigned to the
%               channels and optodes associated to this optode array in 
%               order from the lowest channel or optode number (i.e. 1)
%               to the highest. A default arrangement positions
%               the channels and optodes along a straight line
%               over the X axis.
%               The number of locations in this topographical arrangement
%               may not match the number of associated channels or optodes
%               respectively. When associating new channels or optodes,
%               if the number of associated channels or optodes
%               surpasses the number of defined topographical
%               locations, these latter will be automatically be
%               generated by default (set along a line over the X axis).
%               When the number of associated channels or optodes
%               drop below the
%               number of defined topographical locations, the remaining
%               topographical locations will simply be ignored. However,
%               beware that they will not be removed, and will remain
%               latent and will be used again if ever new channels or
%               optodes are associated to the optode array.
%
%
% ==Constants
%   .OPTODE_TYPE_UNKNOWN - Unknown optode type.
%   .OPTODE_TYPE_EMISOR - Light sources.
%   .OPTODE_TYPE_DETECTOR - Light detector.
%
%     NOTE: These constants apply for property .optodesTypes
%
%
%% Methods
%
% Type methods('channelLocationMap') for a list of methods
%
%
%% References
%
%   [JurcakV2007] Jurcak, V.; Tsuzuki, D.; Dan, I. "10/20, 10/10,
%   and 10/5 systems revisited: Their validity as relative
%   head-surface-based positioning systems" NeuroImage 34 (2007) 1600–1611
%  
%
%
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also rawData, rawData_ETG4000, nirs_neuroimage, icnnna.data.snirf.probe
%


%% Log
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 10-Sep-2013
%
% 10-Sep-2013: Fixed erroneous comment on Source-Detector distribution
%       for probes of mode 4x4.
%       * Bug fixed. Initialization of pairings was made with only 1 column
%
% 8-Sep-2013: Enhanced support for optodes. Now it can track the
%       optodes 3D locations, their surface positions, the arrays
%       and probe sets to which they are associated and the pairings
%       conforming the channels.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Improved some comments.
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
        description(1,:) char = 'ChannelLocationMap0001'; %A short description of the probe.
        nChannels(1,1) double {mustBeInteger, mustBeNonnegative}=0; %Number of channels supported by the channelLocationMap
        nOptodes(1,1) double {mustBeInteger, mustBeNonnegative}=0; %Number of optodes supported by the channelLocationMap
        chLocations = nan(0,3); %3D "real world" location of the channels.
        optodesLocations = nan(0,3); %3D "real world" location of the channels.
        %optodesTypes = nan(0,3); %Optodes types; (0) Unknown, (1) Emission, (2) Detector
        optodesTypes(:,1) double {mustBeInteger, mustBeNonnegative} = nan(0,1); %Optodes types; (0) Unknown, (1) Emission, (2) Detector
        
        referencePoints = struct('name',{},'location',{}); %Landmarks

        surfacePositioningSystem(1,:) char = 'UI 10/10';
        chSurfacePositions = cell(0,1); %Channels surface positions
        optodesSurfacePositions = cell(0,1); %Optodes surface positions

        stereotacticPositioningSystem(1,:) char {mustBeMember(stereotacticPositioningSystem,{'MNI','Talairach'})}= 'MNI';
        chStereotacticPositions = nan(0,3); %3D MNI location of the channels.

        chProbeSets = nan(0,1); %column vector indicating the associated
                                %probe set for each channel.
        chOptodeArrays = nan(0,1); %column vector indicating the
                                %associated optode array for each channel.
        optodesProbeSets = nan(0,1); %column vector indicating the associated
                                %probe set for each optode.
        optodesOptodeArrays = nan(0,1); %column vector indicating the
                                %associated optode array for each optode.
        pairings = nan(0,2); %Pairings of optodes conforming the channels

        optodeArrays = struct('mode',{},'type',{},...
                                'chTopoArrangement',{},...
                                'optodesTopoArrangement',{});
    end
    properties (Constant=true, GetAccess=public)
        OPTODE_TYPE_UNKNOWN=0;
        OPTODE_TYPE_EMISOR=1;
        OPTODE_TYPE_DETECTOR=2;
    end
    
    methods
        function obj=channelLocationMap(varargin)
            %CHANNELLOCATIONMAP channelLocationMap class constructor
            %
            % obj=channelLocationMap() creates a default channelLocationMap
            %   with no channels.
            %
            % obj=channelLocationMap(obj2) acts as a copy constructor of
            %   channelLocationMap
            %
            % obj=channelLocationMap(id) creates a new channelLocationMap
            %   with the given identifier (id). The name of the
            %   channelLocationMap is initialised to
            %   'ChannelLocationMapXXXX' where is the id preceded with 0.
            %
            % Most times, you should initialize the number of channels
            %of your location map following object constrution, e.g.:
            %
            %       obj=channelLocationMap();
            %       obj.nChannels = 24;
            %
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'channelLocationMap')
                obj=varargin{1};
                return;
            else
                obj.id = varargin{1};
                obj.description = ['ChannelLocationMap' ...
                                        num2str(obj.id,'%04i')];
            end
            assertInvariants(obj);

        end
  
    end

    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Static)
        [valid]=isValidSurfacePosition(positions,positioningSystem);
    end


    methods

      %Getters/Setters

      function res = get.id(obj)
         %Gets the object |id|
         res = obj.id;
      end
      function obj = set.id(obj,val)
         %Sets the object |id|
         obj.id = val;
      end

      function res = get.description(obj)
         %Gets the object |description|
         res = obj.description;
      end
      function obj = set.description(obj,val)
         %Sets the object |description|
         obj.description = val;
      end


      function res = get.nChannels(obj)
         %Gets the object |nChannels|
         res = obj.nChannels;
      end
      function obj = set.nChannels(obj,val)
         %Sets the object |nChannels|
        if (isscalar(val) && (floor(val)==val) ...
                && val>=0)
            if val > obj.nChannels
                %Add new channels
                obj.chLocations(end+1:val,:) = nan(val-obj.nChannels,3);
                obj.pairings(end+1:val,:) = nan(val-obj.nChannels,2);
                obj.chSurfacePositions(end+1:val) = {''};
                obj.chStereotacticPositions(end+1:val,:) = ...
                                             nan(val-obj.nChannels,3);
                obj.chOptodeArrays(end+1:val) = nan(val-obj.nChannels,1);
                obj.chProbeSets(end+1:val) = nan(val-obj.nChannels,1);
            elseif val < obj.nChannels
                %Discard the latter channels
                obj.chLocations = obj.chLocations(1:val,:);
                obj.pairings = obj.pairings(1:val,:);
                obj.chSurfacePositions = obj.chSurfacePositions(1:val);
                obj.chStereotacticPositions = ...
                                obj.chStereotacticPositions(1:val,:);
                obj.chOptodeArrays = obj.chOptodeArrays(1:val);
                obj.chProbeSets = obj.chProbeSets(1:val);
            end
            obj.nChannels = val;
        else
            error('ICNNA:channelLocationMap:set:InvalidParameterValue',...
                    'Value must be a positive integer or 0.');
        end
        assertInvariants(obj);
      end


      function res = get.nOptodes(obj)
         %Gets the object |nOptodes|
         res = obj.nOptodes;
      end
      function obj = set.nOptodes(obj,val)
         %Sets the object |nOptodes|
        if (isscalar(val) && (floor(val)==val) ...
                && val>=0)
            if val > obj.nOptodes
                %Add new optodes
                obj.optodesLocations(end+1:val,:) = nan(val-obj.nOptodes,3);
                obj.optodesSurfacePositions(end+1:val) = {''};
                obj.optodesOptodeArrays(end+1:val) = nan(val-obj.nOptodes,1);
                obj.optodesProbeSets(end+1:val) = nan(val-obj.nOptodes,1);
            elseif val < obj.nOptodes
                %Discard the latter optodes
                obj.optodesLocations = obj.optodesLocations(1:val,:);
                obj.optodesSurfacePositions = obj.optodesSurfacePositions(1:val);
                obj.optodesOptodeArrays = obj.optodesOptodeArrays(1:val);
                obj.optodesProbeSets = obj.optodesProbeSets(1:val);
            end
            obj.nOptodes = val;
        else
            error('ICNNA:channelLocationMap:set:InvalidParameterValue',...
                    'Value must be a positive integer or 0.');
        end
        assertInvariants(obj);
      end


      function res = get.surfacePositioningSystem(obj)
         %Gets the object |surfacePositioningSystem|
         res = obj.surfacePositioningSystem;
      end
      function obj = set.surfacePositioningSystem(obj,val)
         %Sets the object |surfacePositioningSystem|
         if (strcmpi(val,'10/20') ...
                 || strcmpi(val,'UI 10/10'))
             obj.surfacePositioningSystem=val;
             %Unset those positions which are not part of the
             %positioning system
             [valid]=channelLocationMap.isValidSurfacePosition(...
                 obj.surfacePositions,...
                 obj.surfacePositioningSystem);
             obj.surfacePositions(~valid)={''};
         else
             error('ICNA:channelLocationMap:set:InvalidParameterValue',...
                 ['Currently valid surface positioning systems are: ' ...
                 '''10/20'' and ''UI 10/10''.']);
         end
         assertInvariants(obj);
      end



      function res = get.stereotacticPositioningSystem(obj)
         %Gets the object |stereotacticPositioningSystem|
         res = obj.stereotacticPositioningSystem;
      end
      function obj = set.stereotacticPositioningSystem(obj,val)
         %Sets the object |surfacePositioningSystem|
         if (strcmpi(val,'MNI') ...
                 || strcmpi(val,'Talairach'))
             obj.stereotacticPositioningSystem=val;
         else
             error('ICNA:channelLocationMap:set:InvalidParameterValue',...
                 ['Currently valid stereotactic positioning systems are: ' ...
                 '''MNI'' and ''Talairach''.']);
         end
        assertInvariants(obj);

      end



    end


end

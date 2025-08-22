classdef nirsProbeset
% icnna.data.core.nirsProbeset - A probeset describes the spatial arrangement of measurements collected during an observation
%
% This class provides a ligther alternative to class @channelLocationMap
%   and it is only intended to support NIRS neuroimaging data (in contrast
%   to @channelLocationMap which can in principle also support other
%   neuroimaging modalities.
%
% This class is the ICNNA native alternative to .snirf's
% @icnna.data.snirf.probe. While there is a substantial overlap between
% these two classes, the separation allows ICNNA to:
% 1) better provide backward compatibility with previous ICNNA versions, and
% 2) should it be needed, store additional information that .snirf's
%   @icnna.data.snirf.probe, by being linked to the snirf file format
%   standard, does not provides.
%
% A @icnna.data.core.nirsProbeset provides support to describe the
%the arrangement of optodes and channels on the head. Analogously to
%@channelLocationMap, an @icnna.data.core.nirsProbeset captures the
%spatial positioning of channels for a NIRS neuroimage in different ways:
%   * Real world coordinates (e.g. <X,Y,Z>) - The real world coordinates
%       are cartesian coordinates.
%   * Channel surface location (e.g. standard 10/20, but also supports
%       more refined systems like the UI 10/10 or the 10/5).
%           Note that snirf alternative landmarks is not "attached" to
%           channels, and yes, ICNNA also provides additional landmarks
%           in the form of referencePoints.
%
%It further keeps track of the optodes (sources and detectors) arrangement
% by storing:
%   * Optodes real world coordinates (e.g. <X,Y,Z>)
%   * Optodes surface location (e.g. standard 10/20)
%           Note this may be intended, rather than real
%   * Optodes types; whether emissor or receptor. See class constants.
%   * Optodes pairings (to conform the channels)
%
%The @icnna.data.core.nirsProbeset also allows to allocate the different
% optodes and channels to a physical holder a.k.a. optode array, and/or
% a probe set.
%
%% Optode arrays and probesets
%
% The class name may be slightly misleading in the sense that a single
%instance can actually represent several probesets at once. See property
%.probesets
%
% Near Infrared Spectroscopy optodes in neuroimage are commonly
%disposed in optode arrays or sets of probes (probesets), e.g.
%old HITACHI arrays, or hyperscanning splitting.
%
% Although by default all optodes are assigned to a default
% probeset (i.e. probeset.id=1), this class can keep track of
% such allocation, by storing a probeset.id associated to each
% optode. Please refer to probeset.id fields in the .sources and
% .detectors properties.
%
%
%% Remarks
%
% IMPORTANT: The @icnna.data.core.nirsProbeset does NOT hold any image
%   data! It only store information about the channel locations.
%
% See corresponding term in the standard fNIRS glossary:
%
% https://openfnirs.org/?swp_form%5Bform_id%5D=2&s=probeset
%
% In contrast to the channelLocationMap, here sources and detectors
%have separate |id|, so there can be one source and one detector
%sharing the same |id|. There is still the restriction that
%sources cannot have the same |id| among themselves, nor can detectors
%share |id| among themselves.
%
%% Properties
%
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. Default is 'NirsProbeset0001'
%       The nirsProbeset name
%   .positioningSystem - Char array. Default is 'UI 10/10'
%       The surface positioning system used for reference.
%
% -- Private properties
%   .sources - Table. List of emitters.
%         Each row is an emitter.
%         The list has AT LEAST the following columns;
%          + id - uint32. The source id,
%          + name - String. A name.
%          + nominalWavelenth - cell. A vector of the nominal wavelengths
%            at which this source operation
%          + probeset.id - The associated probe set for each source
%          + position2D - cell. A 1x2 row vector of 2D location of the
%               source
%          + position3D - cell. A 1x3 row vector of 3D location of the
%               source
%       Sources are sorted by |id|
%   .detectors - Table. List of detectors.
%         Each row is an emitter.
%         The list has AT LEAST the following columns;
%          + id - uint32. The source id,
%          + name - String. A name.
%          + QE (quantum efficiency) - cell. The QE function of the
%          detector
%          + probeset_id - The associated probe set for each detector
%          + location2D - cell. A 1x2 row vector of 2D location of the
%               detector
%          + location3D - cell. A 1x3 row vector of 3D location of the
%               detector
%       Detectors are sorted by |id|
%   .probesets - Table. List of probeset.
%         Each row is an probeset. A default probeset with |id|=1
%         will always exist.
%         The list has AT LEAST the following columns;
%          + id - uint32. The probeset id,
%          + name - String. The probeset name.
%           The default probeset will be named 'default' but
%           the user can change this.
%       Probesets are sorted by |id|
%   .channels - Table. List of channels.
%         Each row is an channel.
%         The list has AT LEAST the following columns;
%          + id - uint32. The channel id.
%          + name - String. The channel name.
%          + landmark - String. A targeted standard position e.g. 'Cz'
%               Watch out! In contrast to @channelLocationMap, this
%               class makes no attempt to verify the landmark name is
%               defined in the |positioningSystem|.
%               NOTE: The same landmark ought to be shared for all
%               measurements in the same channel.
%          + source_id - uint32. The source id (see property |sources|).
%          + detector_id - uint32. The detector id (see property |detectors|).
%          + probeset_id - uint32. The probeset id (see property |probesets|).
%       Channels are sorted by |id|
%   .measurements - Table. List of measurements.
%         Each row is an measurement (alike snirf's measurements).
%         The list has AT LEAST the following columns;
%          + measurement_id - uint32. The measurement id.
%          + measurement_name - String. The measurement name.
%          + channel_id - uint32. The channel id (although channels
%               |id| ought to be unique in the |channels|, but here
%               they can be repeated since several measurements can
%               be acquired at the same
%               combination of source-detector but they will differ
%               in the nominal wavelength; i.e. here it acts as a foreign
%               key in the database lingo).
%          + nominalWavelength- double. The nominal wavelength at which
%               this measurement is operating.
%          + gain - double. Calibration gain.
%       Measurements are sorted by |id|
%   .referencePoints - Table. List of additional reference points and
%           landmarks
%         Each row is a different reference points (somewhat alike
%         to snirf's landmarks).
%         The list has AT LEAST the following columns;
%          + id - uint32. The reference point id (ought to be
%               unique within a @icnna.data.core.nirsProbeset).
%          + name - String. The reference point name.
%          + landmark - String. A targeted standard position e.g. 'Cz'
%               Watch out! In contrast to @channelLocationMap, this
%               class makes no attempt to verify the landmark name is
%               defined in the |positioningSystem|.
%          + location2D - cell. A 1x2 row vector of 2D location of the
%               eference point
%          + location3D - cell. A 1x3 row vector of 3D location of the
%               eference point
%       Reference points are sorted by |id|
%
%% Dependent properties
%
%   .nOptodes - Int. Read-only
%       Number of optodes (sum of emitters and detectors)
%   .nSources - Int. Read-only
%       Number of sources
%   .nDetectors - Int. Read-only
%       Number of detectors
%   .nChannels - Int. Read-only
%       Number of total channels. This includes both short and long
%       channels.
%   .nMeasurements - Int. Read-only
%       Number of total measurements. Since there may be (likely are)
%       more than one measurement per channel e.g. one per wavelength,
%       this figure is likely higher than the number of channels.
%   .nProbesets - Int. Read-only
%       Number of probesets
%
%   .channelsLocations3D - Array of double sized <nChannels,3>. Read-only
%       3D locations of the channels calculated on the fly as the
%       Euclidean mid point between the source and the detector.
%           NOTE 1: This entails a small error as the head
%           curvature is not considered.
%   .measurementLocations3D - Array of double sized <nMeasurements,3>. Read-only
%       3D locations of the channels to which the measurements are
%       associated. See |channelsLocations3D|
%
%   .channelsLocations2D - Array of double sized <nChannels,2>. Read-only
%       2D locations of the channels calculated on the fly as the
%       Euclidean mid point between the source and the detector.
%           NOTE 1: This entails a small error as the head
%           curvature is not considered.
%   .measurementLocations2D - Array of double sized <nMeasurements,2>. Read-only
%       2D locations of the channels to which the measurements are
%       associated. See |channelsLocations2D|
%
%   .channelsIOD - Array of double sized <nChannels,1>. Read-only
%       Channels interoptode distances. Calculated on the fly as the
%       Euclidean distance between the source and the detector.
%           NOTE 1: This entails a small error as the head
%           curvature is not considered.
%
%
%% Methods
%
% Type methods('nirsProbeset') for a list of methods
%
%
% Copyright 2025
% Author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.probe, channelLocationMap
%



%% Log
%
%   + Class available since ICNNA v1.3.1
%
% 29-Jun-2025: FOE
%   + File and class created. Class is still unfinished (and not
%   documented).
%
% 1-Jul-2025: FOE
%   + Worked on adding the private and dependent properties.
%   Class structure is now complere but the class remains unfinished
%   in the sense that all the methods to interact with the private
%   properties are still missing.
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        id(1,1) uint32 {mustBeInteger, mustBeNonnegative} = 1; %Numerical identifier to make the object identifiable.
        name(1,:) char = 'NirsProbeset0001'; %The nirsProbeset's name
        positioningSystem(1,:) char = 'UI 10/10';

    end

    properties (SetAccess=private)
        sources  table = table('Size',[0 6],...
                        'VariableTypes',{'uint32','string','cell',...
                                         'uint32','cell','cell'},...
                        'VariableNames',{'id','name','nominalWavelengths',...
                                    'probeset_id','location2D','location3D'});
                    %Information about sources
        detectors  table = table('Size',[0 6],...
                        'VariableTypes',{'uint32','string','cell',...
                                         'uint32','cell','cell'},...
                        'VariableNames',{'id','name','QE',...
                                    'probeset_id','location2D','location3D'});
                    %Information about detectors
        probesets  table = table('Size',[0 2],...
                        'VariableTypes',{'uint32','string'},...
                        'VariableNames',{'id','name'});
                    %Information about probesets

        channels  table = table('Size',[0 6],...
                        'VariableTypes',{'uint32','string','string',...
                                        'uint32','uint32',...
                                        'uint32'},...
                        'VariableNames',{'channel_id','name','landmark',...
                                        'source_id','detector_id',...
                                        'probeset_id'});
                    %The list of channels.
        measurements  table = table('Size',[0 5],...
                        'VariableTypes',{'uint32','string',...
                                        'uint32',...
                                        'double','double'},...
                        'VariableNames',{'measurement_id','measurement_name',...
                                        'channel_id',...
                                        'nominalWavelength','gain'});
                    %The list of measurements.
       referencePoints table = table('Size',[0 5],...
                        'VariableTypes',{'uint32','string','string',...
                                         'cell','cell'},...
                        'VariableNames',{'id','name','landmark',...
                                         'location2D','location3D'});
                    %Information of additional reference points and
                    %landmarks
    end

    properties (Dependent)
        nOptodes  %Read-only
        nSources  %Read-only
        nDetectors %Read-only

        nChannels %Read-only. This includes both short and long channels
        nMeasurements %Read-only. Number of measurements.
        nProbesets %Read-only. Number of measurements.

        channelsLocations3D  %Read-only. 3D locations of the channels
        measurementsLocations3D  %Read-only. 3D locations of the channels to which the measurements are associated.

        channelsLocations2D  %Read-only. 2D locations of the channels.
        measurementsLocations2D  %Read-only. 2D locations of the channels to which the measurements are associated. 
                            %See |channelsLocations2D|
        channelsIOD %Read-only. Interoptode distances
        
    end


    methods
        function obj=nirsProbeset(varargin)
            %ICNNA.DATA.CORE.NIRSPROBESET nirsProbeset class constructor
            %
            % obj=icnna.data.core.nirsProbeset() creates a default
            %   nirsProbeset with ID equals 1.
            %
            % obj=icnna.data.core.nirsProbeset(obj2) acts as a copy
            %   constructor of icnna.data.core.nirsProbeset
            %
            % @Copyright 2025
            % Author: Felipe Orihuela-Espina
            %
            % See also
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.nirsProbeset')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.nirsProbeset:nirsProbeset:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
        end
    end
    

    methods

      %Getters/Setters

      function res = get.id(obj)
         %Gets the object |id|
         res = obj.id;
      end
      function obj = set.id(obj,val)
         %Sets the object |id|
         obj.id =  val;
      end


    function res = get.name(obj)
         %Gets the object |name|
         res = obj.name;
      end
      function obj = set.name(obj,val)
         %Sets the object |name|
         obj.name =  val;
      end

    function res = get.positioningSystem(obj)
         %Gets the object |positioningSystem|
         res = obj.positioningSystem;
      end
      function obj = set.positioningSystem(obj,val)
         %Sets the object |positioningSystem|
         obj.positioningSystem =  val;
      end



    function res = get.sources(obj)
         %Gets the object |sources|
         res = obj.sources;
      end
      function obj = set.sources(obj,val)
         %Sets the object |sources|
         obj.sources =  val;
      end









        %-- Dependent properties
       function res = get.nOptodes(obj)
         %(DEPENDENT) Gets the object |nOptodes|
         %
         % The number of optodes (sources + detectors).
         res = obj.nSources + obj.nDetector;
      end

      function res = get.nSources(obj)
         %(DEPENDENT) Gets the object |nSources|
         %
         % The number of sources.
         res = size(obj.sources,1);
      end

      function res = get.nDetectors(obj)
         %(DEPENDENT) Gets the object |nDetectors|
         %
         % The number of detectors.
         res = size(obj.detectors,1);
      end

      function res = get.nMeasurements(obj)
         %(DEPENDENT) Gets the object |nMeasurements|
         %
         % The number of measurements.
         res = size(obj.measurements,1);
      end

      function res = get.nChannels(obj)
         %(DEPENDENT) Gets the object |nChannels|
         %
         % The number of channels.
         res = size(obj.channels,1);
      end

      function res = get.nProbesets(obj)
         %(DEPENDENT) Gets the object |nProbesets|
         %
         % The number of channels.
         res = size(obj.probesets,1);
      end

      function res = get.channelsLocations3D(obj)
         %(DEPENDENT) Gets the object |channelsLocations3D|
         %
         % 3D locations of the channels
         tmpSrcLocations = zeros(obj.nChannels,3);
         tmpDetLocations = zeros(obj.nChannels,3);
         for iCh = 1:obj.nChannels
             idxSrc = find(obj.sources.id   == obj.channels.source_id(iCh));
             idxDet = find(obj.detectors.id == obj.channels.detector_id(iCh));
             tmpSrcLocations(ich,:) = obj.sources.location3D(idxSrc);
             tmpDetLocations(ich,:) = obj.detectors.location3D(idxDet);
         end
         res = (tmpSrcLocations + tmpDetLocations)./2;
      end

      function res = get.measurementsLocations3D(obj)
         %(DEPENDENT) Gets the object |measurementsLocations3D|
         %
         % 3D locations of the measurements
         tmpSrcLocations = zeros(obj.nChannels,3);
         tmpDetLocations = zeros(obj.nChannels,3);
         for iMeas = 1:obj.nMeasurements
             tmpCh  = obj.measurements.channel_id(iMeas);
             idxCh  = find(obj.channels.id  == tmpCh);
             idxSrc = find(obj.sources.id   == obj.channels.source_id(idxCh));
             idxDet = find(obj.detectors.id == obj.channels.detector_id(idxCh));
             tmpSrcLocations(ich,:) = obj.sources.location3D(idxSrc);
             tmpDetLocations(ich,:) = obj.detectors.location3D(idxDet);
         end
         res = (tmpSrcLocations + tmpDetLocations)./2;
      end

      function res = get.channelsLocations2D(obj)
         %(DEPENDENT) Gets the object |channelsLocations2D|
         %
         % 2D locations of the channels
         tmpSrcLocations = zeros(obj.nChannels,2);
         tmpDetLocations = zeros(obj.nChannels,2);
         for iCh = 1:obj.nChannels
             idxSrc = find(obj.sources.id   == obj.channels.source_id(iCh));
             idxDet = find(obj.detectors.id == obj.channels.detector_id(iCh));
             tmpSrcLocations(ich,:) = obj.sources.location2D(idxSrc);
             tmpDetLocations(ich,:) = obj.detectors.location2D(idxDet);
         end
         res = (tmpSrcLocations + tmpDetLocations)./2;
      end

      function res = get.measurementsLocations2D(obj)
         %(DEPENDENT) Gets the object |measurementsLocations2D|
         %
         % 2D locations of the measurements
         tmpSrcLocations = zeros(obj.nChannels,2);
         tmpDetLocations = zeros(obj.nChannels,2);
         for iMeas = 1:obj.nMeasurements
             tmpCh  = obj.measurements.channel_id(iMeas);
             idxCh  = find(obj.channels.id  == tmpCh);
             idxSrc = find(obj.sources.id   == obj.channels.source_id(idxCh));
             idxDet = find(obj.detectors.id == obj.channels.detector_id(idxCh));
             tmpSrcLocations(ich,:) = obj.sources.location2D(idxSrc);
             tmpDetLocations(ich,:) = obj.detectors.location2D(idxDet);
         end
         res = (tmpSrcLocations + tmpDetLocations)./2;
      end


      function res = get.channelsIOD(obj)
         %(DEPENDENT) Gets the object |channelsIOD|
         %
         % Channels inter-optode distances
         tmpSrcLocations = zeros(obj.nChannels,3);
         tmpDetLocations = zeros(obj.nChannels,3);
         for iMeas = 1:obj.nMeasurements
             tmpCh  = obj.measurements.channel_id(iMeas);
             idxCh  = find(obj.channels.id  == tmpCh);
             idxSrc = find(obj.sources.id   == obj.channels.source_id(idxCh));
             idxDet = find(obj.detectors.id == obj.channels.detector_id(idxCh));
             tmpSrcLocations(ich,:) = obj.sources.location3D(idxSrc);
             tmpDetLocations(ich,:) = obj.detectors.location3D(idxDet);
         end
         res = sqrt(sum((tmpSrcLocations - tmpDetLocations).^2));
      end


    
    end

end


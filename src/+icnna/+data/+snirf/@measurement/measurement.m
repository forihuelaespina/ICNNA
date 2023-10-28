classdef measurement
% icnna.data.snirf.measurement A NIRS per-channel source-detector information as defined in the snirf file format.
%
%% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% https://github.com/fNIRS/snirf
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
%
%
%% Properties
%
% See snirf specifications
% 
%
%
%% Methods
%
% Type methods('icnna.data.snirf.probe') for a list of methods
% 
% Copyright 2022-23
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf, icnna.data.snirf.measurementGroup
%


%% Log
%
% 15-Jul-2022: FOE
%   File and class created.
%
% 14-May-2023: FOE
%   + Imported from my LaserLab sandbox code to ICNNA. Had to adjust the
%   the package from; data.snirf.* to icnna.data.snirf.*
%   + Added property classVersion. Set to '1.0' by default.
%
%
% 16-May-2023: FOE
%   + Added validation rules to properties and simplified the code
%   accordingly.
%   + Renamed from @NIRSchannelInformation to @measurement
%
% 19-May-2023: FOE
%   + Added constructor polymorphism for typecasting a struct.
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties
        sourceIndex(1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}; %Source index for the channel
        detectorIndex(1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}; %Detector index for the channel
        wavelengthIndex(1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}; %Wavelength index for the channel
        wavelengthActual(1,1) double {mustBeNonnegative, mustBeFinite}; %Actual wavelength for the channel
        wavelengthEmissionActual(1,1) double {mustBeNonnegative, mustBeFinite}; %Actual emission wavelength index for the channel
        dataType(1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}; %Data type for then channel
        dataUnit(1,:) char; %SI unit for the channel
        dataTypeLabel(1,:) char; %Data type name for the  channel
        dataTypeIndex(1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}; %Data type index for the channel
        sourcePower(1,1) double {mustBeNonnegative, mustBeFinite}; %Source power for the channel
        detectorGain(1,1) double {mustBeNonnegative, mustBeFinite}; %Detector for the channel
        moduleIndex(1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}; %Index of the parent module (if modular)
        sourceModuleIndex(1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}; %Index of the source's parent module
        detectorModuleIndex(1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}; %Index of the detector's parent module
        
    end
    
    methods
        function obj=measurement(varargin)
            %ICNNA.DATA.SNIRF.MEASUREMENT A icnna.data.snirf.measurement class constructor
            %
            % obj=icnna.data.snirf.measurement() creates a default object.
            %
            % obj=icnna.data.snirf.measurement(obj2) acts as a copy constructor
            %
            % obj=icnna.data.snirf.measurement(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2022-23
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.measurement')
                obj=varargin{1};
                return;
            elseif isstruct(varargin{1}) %Attempt to typecast
                tmp=varargin{1};
                tmpFields = fieldnames(tmp);
                for iField = 1:length(tmpFields)
                    tmpProp = tmpFields{iField};
                    if ismember(tmpProp,properties(obj))
                        obj.(tmpProp) = tmp.(tmpProp);
                    end
                end
                return;
            else
                error(['icnna.data.snirf.measurement:measurement:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

        function val = get.sourceIndex(obj)
        %Retrieves the channel source index
            val = obj.sourceIndex;
        end
        function obj = set.sourceIndex(obj,val)
        %Updates the channel source index
            obj.sourceIndex = val;
        end



        function val = get.detectorIndex(obj)
        %Retrieves the channel detector index
            val = obj.detectorIndex;
        end
        function obj = set.detectorIndex(obj,val)
        %Updates the channel detector index
            obj.detectorIndex = val;
        end



        function val = get.wavelengthIndex(obj)
        %Retrieves the channel wavelength index
            val = obj.wavelengthIndex;
        end
        function obj = set.wavelengthIndex(obj,val)
        %Updates the channel wavelength index
            obj.wavelengthIndex = val;
        end



        function val = get.wavelengthActual(obj)
        %Retrieves the channel actual wavelength
            val = obj.wavelengthActual;
        end
        function obj = set.wavelengthActual(obj,val)
        %Updates the channel actual wavelength
            obj.wavelengthActual = val;
        end



        function val = get.wavelengthEmissionActual(obj)
        %Retrieves the channel actual emission wavelength
            val = obj.wavelengthEmissionActual;
        end
        function obj = set.wavelengthEmissionActual(obj,val)
        %Updates the channel actual emission wavelength
            obj.wavelengthEmissionActual = val;
        end



        function val = get.dataType(obj)
        %Retrieves the channel data type
            val = obj.dataType;
        end
        function obj = set.dataType(obj,val)
        %Updates the channel data type
            obj.dataType = val;
        end



        function val = get.dataUnit(obj)
        %Retrieves the channel SI data unit
            val = obj.dataUnit;
        end
        function obj = set.dataUnit(obj,val)
        %Updates the channel SI data unit
            obj.dataUnit = val;
        end



        function val = get.dataTypeLabel(obj)
        %Retrieves the data type name for the channel
            val = obj.dataTypeLabel;
        end
        function obj = set.dataTypeLabel(obj,val)
        %Updates the data type name for the channel
            obj.dataTypeLabel = val;
        end



        function val = get.dataTypeIndex(obj)
        %Retrieves the channel data type index
            val = obj.dataTypeIndex;
        end
        function obj = set.dataTypeIndex(obj,val)
        %Updates the channel data type index
            obj.dataTypeIndex = val;
        end



        function val = get.sourcePower(obj)
        %Retrieves the source power for the channel
            val = obj.sourcePower;
        end
        function obj = set.sourcePower(obj,val)
        %Updates the source power for the channel
            obj.sourcePower = val;
        end



        function val = get.detectorGain(obj)
        %Retrieves the detector gain for the channel
            val = obj.detectorGain;
        end
        function obj = set.detectorGain(obj,val)
        %Updates the detector gain for the channel
            obj.detectorGain = val;
        end



        function val = get.moduleIndex(obj)
        %Retrieves the channel's module index (if modular)
            val = obj.moduleIndex;
        end
        function obj = set.moduleIndex(obj,val)
        %Updates the channel's module index (if modular)
            obj.moduleIndex = val;
        end



        function val = get.sourceModuleIndex(obj)
        %Retrieves the channel's source module index (if modular)
            val = obj.sourceModuleIndex;
        end
        function obj = set.sourceModuleIndex(obj,val)
        %Updates the channel's source module index (if modular)
            obj.sourceModuleIndex = val;
        end



        function val = get.detectorModuleIndex(obj)
        %Retrieves the channel's detector module index (if modular)
            val = obj.detectorModuleIndex;
        end
        function obj = set.detectorModuleIndex(obj,val)
        %Updates the channel's detector module index (if modular)
            obj.detectorModuleIndex = val;
        end



    end


end

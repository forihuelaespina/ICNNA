classdef measurement
% icnna.data.snirf.measurement A NIRS per-channel source-detector information as defined in the snirf file format.
%
% A measurement is each one of the measurements in the measurementList
%within /nirs/data in the snirf file format.
%
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
% 6-Apr-2024: FOE
%   + Added visibility flags for optional properties.
%       Some of the properties of the measurement are optional; they
%       may or may not be present. In its implementation thus far, ICNNA
%       had no way to distinguish the case when the attribute was simply
%       missing from the case it has some default value. Having visibility
%       or enabling flags solves the problem.
%       ICNNA also provides a couple of further methods; one to "remove" (hide)
%       existing optional attributes and one to check whether it has
%       been defined (e.g. to check its visibility status) which shall
%       prevent the need for try/catch in other functions using the class.
%       Regarding this latter, note that;
%       + Calling properties(measurement) will still list the "hidden"
%       properties, which ideally should not happen -but this relates back
%       to MATLAB's new way of the defining the get/set methods for struct
%       like access which requires the properties to be public.
%       + MATLAB has function isprop to determine whether a property is
%       defined by object, but again this will "see" the hidden properties.
%
%       NOTE: Making the class mutable so that it can grow organically 
%       on these optional attributes is not a good solution as this then
%       loses control on what other attributes could be defined beyond
%       those acceptable for snirf.
%

    properties (Constant, Access=private)
        classVersion = '1.0.1'; %Read-only. Object's class version.
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


    properties (Access = private)
        %Visibility/Availability flags:
        %The optional attributes are;
        % 1) wavelengthActual
        % 2) wavelengthEmissionActual
        % 3) dataUnit 
        % 4) dataTypeLabel
        % 5) sourcePower
        % 6) detectorGain
        % 7) moduleIndex
        % 8) sourceModuleIndex
        % 9) detectorModuleIndex


        flagVisible struct = struct('wavelengthActual',false, ...
            'wavelengthEmissionActual',false, ...
            'dataUnit',false, ...
            'dataTypeLabel',false, ...
            'sourcePower',false, ...
            'detectorGain',false, ...
            'moduleIndex',false, ...
            'sourceModuleIndex',false, ...
            'detectorModuleIndex',false); %Not visible by default
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
            if obj.flagVisible.wavelengthActual
                val = obj.wavelengthActual;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.wavelengthActual:Undefined', ...
                    'Undefined optional field wavelengthActual.');
            end
        end
        function obj = set.wavelengthActual(obj,val)
        %Updates the channel actual wavelength
            obj.wavelengthActual = val;
            obj.flagVisible.wavelengthActual = true;
        end



        function val = get.wavelengthEmissionActual(obj)
        %Retrieves the channel actual emission wavelength
            if obj.flagVisible.wavelengthEmissionActual
                val = obj.wavelengthEmissionActual;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.wavelengthEmissionActual:Undefined', ...
                    'Undefined optional field wavelengthEmissionActual.');
            end
        end
        function obj = set.wavelengthEmissionActual(obj,val)
        %Updates the channel actual emission wavelength
            obj.wavelengthEmissionActual = val;
            obj.flagVisible.wavelengthEmissionActual = true;
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
            if obj.flagVisible.dataUnit
                val = obj.dataUnit;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.dataUnit:Undefined', ...
                    'Undefined optional field dataUnit.');
            end
        end
        function obj = set.dataUnit(obj,val)
        %Updates the channel SI data unit
            obj.dataUnit = val;
            obj.flagVisible.dataUnit = true;
        end



        function val = get.dataTypeLabel(obj)
        %Retrieves the data type name for the channel
            if obj.flagVisible.dataTypeLabel
                val = obj.dataTypeLabel;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.dataTypeLabel:Undefined', ...
                    'Undefined optional field dataTypeLabel.');
            end
        end
        function obj = set.dataTypeLabel(obj,val)
        %Updates the data type name for the channel
            obj.dataTypeLabel = val;
            obj.flagVisible.dataTypeLabel = true;
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
            if obj.flagVisible.sourcePower
                val = obj.sourcePower;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.sourcePower:Undefined', ...
                    'Undefined optional field sourcePower.');
            end
        end
        function obj = set.sourcePower(obj,val)
        %Updates the source power for the channel
            obj.sourcePower = val;
            obj.flagVisible.sourcePower = true;
        end



        function val = get.detectorGain(obj)
        %Retrieves the detector gain for the channel
            if obj.flagVisible.detectorGain
                val = obj.detectorGain;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.detectorGain:Undefined', ...
                    'Undefined optional field detectorGain.');
            end
        end
        function obj = set.detectorGain(obj,val)
        %Updates the detector gain for the channel
            obj.detectorGain = val;
            obj.flagVisible.detectorGain = true;
        end



        function val = get.moduleIndex(obj)
        %Retrieves the channel's module index (if modular)
            if obj.flagVisible.moduleIndex
                val = obj.moduleIndex;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.moduleIndex:Undefined', ...
                    'Undefined optional field moduleIndex.');
            end
        end
        function obj = set.moduleIndex(obj,val)
        %Updates the channel's module index (if modular)
            obj.moduleIndex = val;
            obj.flagVisible.moduleIndex = true;
        end



        function val = get.sourceModuleIndex(obj)
        %Retrieves the channel's source module index (if modular)
            if obj.flagVisible.sourceModuleIndex
                val = obj.sourceModuleIndex;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.sourceModuleIndex:Undefined', ...
                    'Undefined optional field sourceModuleIndex.');
            end
        end
        function obj = set.sourceModuleIndex(obj,val)
        %Updates the channel's source module index (if modular)
            obj.sourceModuleIndex = val;
            obj.flagVisible.sourceModuleIndex = true;
        end



        function val = get.detectorModuleIndex(obj)
        %Retrieves the channel's detector module index (if modular)
            if obj.flagVisible.detectorModuleIndex
                val = obj.detectorModuleIndex;
            else
                error('ICNNA:icnna.data.snirf.measurement.get.detectorModuleIndex:Undefined', ...
                    'Undefined optional field detectorModuleIndex.');
            end
        end
        function obj = set.detectorModuleIndex(obj,val)
        %Updates the channel's detector module index (if modular)
            obj.detectorModuleIndex = val;
            obj.flagVisible.detectorModuleIndex = true;
        end





        %%Suport methods for visibility of optional attributes
        function res = isproperty(obj,propertyName)
        %Check whether existing optional attributes have been defined (i.e. checks visibility)
            propertyName = char(propertyName);
            res = isprop(obj,propertyName);
            switch(propertyName)
                case {'wavelengthActual','wavelengthEmissionActual',...
                        'dataUnit','dataTypeLabel','sourcePower', ...
                        'detectorGain','moduleIndex','sourceModuleIndex', ...
                        'detectorModuleIndex'}
                    res = obj.flagVisible.(propertyName);
                otherwise
                    %Do nothing
            end
        end


        function obj = rmproperty(obj,propertyName)
        %"Removes" (hides) existing optional attributes
            propertyName = char(propertyName);
            switch(propertyName)
                case {'wavelengthActual','wavelengthEmissionActual',...
                        'dataUnit','dataTypeLabel','sourcePower', ...
                        'detectorGain','moduleIndex','sourceModuleIndex', ...
                        'detectorModuleIndex'}
                    obj.flagVisible.(propertyName) = false;
                case {'sourceIndex','detectorIndex','wavelengthIndex',...
                        'dataType','dataTypeIndex'}
                    error('ICNNA:icnna.data.snirf.measurement.rmproperty:NonOptionalProperty', ...
                        ['Property ' propertyName ' cannot be removed. It is not optional for .snirf format.']);
                otherwise
                    error('ICNNA:icnna.data.snirf.measurement.rmproperty:UnknownProperty', ...
                        ['Unknown property ' propertyName '.']);
            end
        end




    end


end

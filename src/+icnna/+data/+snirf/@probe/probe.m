classdef probe
% icnna.data.snirf.probe A NIRS probe information as defined in the snirf file format.
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
% See also icnna.data.snirf.snirf, icnna.data.snirf.nirsDataset
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
%   + Added some pending properties; frequencies, timeDelays,
%   timeDelayWidths, momentOrders, correlationTimeDelays,
%   correlationTimeDelayWidths,sourceLabels,detectorLabels,
%   landmarkPos2D,landmarkPos3D,landmarkLabels,useLocalIndex
%
%
% 19-May-2023: FOE
%   + Added constructor polymorphism for typecasting a struct.
%
% 21-Feb-2024: FOE
%   + Bug fixed. Methods to set sourceLabels and detectorLabels were
%   checking for a size(val,3)==0. Now they cheks for ndims(val) == 2.
%
% 3-Mar-2024: FOE
%   + Class format update:
%       * Attributes sourceLabels, detectorLabels
%       and landmarkLabels are now string arrays instead of cell arrays
%       as specified by .snirf. Compatibility support is provided; if the user
%       passes a cell array for any of these attributes this is accepted, and
%       type casted to string array. However, when getting this property,
%       now only a string array is returned. Finally, cell array use for
%       these attributes is now DEPRECATED.
%       * Attributes sourcePos2D, detectorPos2D and landmarkPos2D have been
%       reformatted from free sized (:,:) to 2 columns 2D arrays (:,2).
%       * Attributes sourcePos3D, detectorPos3D and landmarkPos3D have been
%       reformatted from 3D arrays (:,:,:) to 3 columns 2D arrays (:,3).
%   + Added methods get/set for detectorPos2D and detectorPos3D (yes! I
%       forgot to add these originally!)
%   + classVersion increased to '1.0.1'
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
        %classVersion = '1.0'; %Read-only. Object's class version.
        classVersion = '1.0.1'; %Read-only. Object's class version.
    end




    properties
        wavelengths(:,1) double     = nan(0,1); %List of wavelengths in [nm]
        wavelengthsEmission(:,1) double = nan(0,1); %List of emission wavelengths in [nm]
        sourcePos2D(:,:) double     = nan(0,2); %Source 2-D positions in LengthUnit
                                  %1 row per source
        sourcePos3D(:,3) double   = nan(0,3); %Source 3-D positions in LengthUnit
                                  %1 row per source
        detectorPos2D(:,:) double   = nan(0,2); %Detector 2-D positions in LengthUnit
                                  %1 row per source
        detectorPos3D(:,3) double = nan(0,3); %Detector 3-D positions in LengthUnit
                                  %1 row per source

        frequencies(:,1) double = nan(0,1); %Modulation frequency list   
        timeDelays(:,1) double  = nan(0,1); %Time delays for gated time-domain data   
        timeDelayWidths(:,1) double = nan(0,1); %Time delay width for gated time-domain data   
        momentOrders(:,1) double    = nan(0,1); % Moment orders of the moment TD data   
        correlationTimeDelays(:,1) double = nan(0,1); % Time delays for DCS measurements  
        correlationTimeDelayWidths(:,1) double = nan(0,1); % Time delay width for DCS measurements 
        sourceLabels(:,1) string    = strings(0,1); % String arrays specifying source names   
        detectorLabels(:,1) string  = strings(0,1); % String arrays specifying detector names   
        landmarkPos2D(:,:) double = nan(0,1); % Anatomical landmark 2-D positions  
        landmarkPos3D(:,:,:) double = nan(0,1); % Anatomical landmark 3-D positions  
        landmarkLabels(:,1) string  = strings(0,1); % String arrays specifying landmark names 
        useLocalIndex(1,1) double = nan; % If source/detector index is within a module
    end
    
    properties (Access = private)
        %Visibility/Availability flags:
        %The optional attributes are;
        %  1) wavelengthsEmission
        %  2) frequencies
        %  3) timeDelays
        %  4) timeDelayWidths
        %  5) momentOrders
        %  6) correlationTimeDelays
        %  7) correlationTimeDelayWidths
        %  8) sourceLabels
        %  9) detectorLabels
        % 10) landmarkPos2D
        % 11) landmarkPos3D
        % 12) landmarkLabels
        % 13) coordinateSystem
        % 14) coordinateSystemDescription
        % 15) useLocalIndex


        flagVisible struct = struct('wavelengthsEmission',false, ...
            'frequencies',false, ...
            'timeDelays',false, ...
            'timeDelayWidths',false, ...
            'momentOrders',false, ...
            'correlationTimeDelays',false, ...
            'correlationTimeDelayWidths',false, ...
            'sourceLabels',false, ...
            'detectorLabels',false, ...
            'landmarkPos2D',false, ...
            'landmarkPos3D',false, ...
            'landmarkLabels',false, ...
            'coordinateSystem',false, ...
            'coordinateSystemDescription',false, ...
            'useLocalIndex',false); %Not visible by default
    end
   

    methods
        function obj=probe(varargin)
            %ICNNA.DATA.SNIRF.PROBE A icnna.data.snirf.probe class constructor
            %
            % obj=icnna.data.snirf.probe() creates a default object.
            %
            % obj=icnna.data.snirf.probe(obj2) acts as a copy constructor
            %
            % obj=icnna.data.snirf.probe(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2022-23
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.probe')
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
                error(['icnna.data.snirf.probe:probe:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

        function val = get.wavelengths(obj)
        %Retrieves the list of wavelengths
            val = obj.wavelengths;
        end
        function obj = set.wavelengths(obj,val)
        %Updates the list of wavelengths
            obj.wavelengths = val;
        end



        function val = get.wavelengthsEmission(obj)
        %Retrieves the list of emission wavelengths
            if obj.flagVisible.wavelengthEmission
                val = obj.wavelengths;
            else
                error('ICNNA:icnna.data.snirf.probe.get.wavelengthEmission:Undefined', ...
                    'Undefined optional field wavelengthEmission.');
            end
        end
        function obj = set.wavelengthsEmission(obj,val)
        %Updates the list of emission wavelengths
            obj.wavelengthsEmission = val;
            obj.flagVisible.wavelengthEmission = true;
        end



        function val = get.sourcePos2D(obj)
        %Retrieves the set of source positions in 2D.
        %
        %Uses 1 row per source and 2 Euclidean coordinates.
            val = obj.sourcePos2D;
        end
        function obj = set.sourcePos2D(obj,val)
        %Updates the set of source positions in 2D.
        %
        %Uses 1 row per source and 2 Euclidean coordinates.
           if (ismatrix(val) && size(val,2) == 2 && all(isnumeric(val)))
               obj.sourcePos2D = val;
           elseif (ismatrix(val) && size(val,2) == 3 && all(isnumeric(val)))
               warning(['icnna.data.snirf.probe:set.sourcePos2D:InvalidPropertyValue',...
                     'Value must be a Mx2 matrix of planar coordinates for M sources. Discarding any additional values provided.'])
               obj.sourcePos2D = val(:,1:2);
           else
               error(['icnna.data.snirf.probe:set.sourcePos2D:InvalidPropertyValue',...
                     'Value must be a Mx2 matrix of planar coordinates for M sources.']);
           end
           %assertInvariants(obj);
        end


        function val = get.sourcePos3D(obj)
        %Retrieves the set of source positions in 3D.
        %
        %Uses 1 row per source and 3 Euclidean coordinates.
            val = obj.sourcePos3D;
        end
        function obj = set.sourcePos3D(obj,val)
        %Updates the set of source positions in 3D.
        %
        %Uses 1 row per source and 3 Euclidean coordinates.
           if (ismatrix(val) && size(val,2) == 3 && all(isnumeric(val)))
               obj.sourcePos3D = val;
           else
               error(['icnna.data.snirf.probe:set.sourcePos3D:InvalidPropertyValue',...
                     'Value must be a Mx3 matrix of planar coordinates for M sources.']);
           end
           %assertInvariants(obj);
        end



        function val = get.detectorPos2D(obj)
        %Retrieves the set of detector positions in 2D.
        %
        %Uses 1 row per detector and 2 Euclidean coordinates.
            val = obj.detectorPos2D;
        end
        function obj = set.detectorPos2D(obj,val)
        %Updates the set of detector positions in 2D.
        %
        %Uses 1 row per detector and 2 Euclidean coordinates.
           if (ismatrix(val) && size(val,2) == 2 && all(isnumeric(val)))
               obj.detectorPos2D = val;
           elseif (ismatrix(val) && size(val,2) == 3 && all(isnumeric(val)))
               warning(['icnna.data.snirf.probe:set.detectorPos2D:InvalidPropertyValue',...
                     'Value must be a Mx2 matrix of planar coordinates for M detectors. Discarding any additional values provided.'])
               obj.detectorPos2D = val(:,1:2);
           else
               error(['icnna.data.snirf.probe:set.detectorPos2D:InvalidPropertyValue',...
                     'Value must be a Mx2 matrix of planar coordinates for M detectors.']);
           end
           %assertInvariants(obj);
        end


        function val = get.detectorPos3D(obj)
        %Retrieves the set of detector positions in 3D.
        %
        %Uses 1 row per detector and 3 Euclidean coordinates.
            val = obj.detectorPos3D;
        end
        function obj = set.detectorPos3D(obj,val)
        %Updates the set of detector positions in 3D.
        %
        %Uses 1 row per detector and 3 Euclidean coordinates.
           if (ismatrix(val) && size(val,2) == 3 && all(isnumeric(val)))
               obj.detectorPos3D = val;
           else
               error(['icnna.data.snirf.probe:set.detectorPos3D:InvalidPropertyValue',...
                     'Value must be a Mx3 matrix of planar coordinates for M detectors.']);
           end
           %assertInvariants(obj);
        end



        function val = get.frequencies(obj)
        %Retrieves the list of modulation frequencies
            if obj.flagVisible.frequencies
                val = obj.frequencies;
            else
                error('ICNNA:icnna.data.snirf.probe.get.frequencies:Undefined', ...
                    'Undefined optional field frequencies.');
            end
        end
        function obj = set.frequencies(obj,val)
        %Updates the list of modulation frequencies
            obj.frequencies = val;
            obj.flagVisible.frequencies = true;
        end


        function val = get.timeDelays(obj)
        %Retrieves the list of time delays for gated time-domain data 
            if obj.flagVisible.timeDelays
                val = obj.timeDelays;
            else
                error('ICNNA:icnna.data.snirf.probe.get.timeDelays:Undefined', ...
                    'Undefined optional field timeDelays.');
            end
        end
        function obj = set.timeDelays(obj,val)
        %Updates the list of time delays for gated time-domain data
            obj.timeDelays = val;
            obj.flagVisible.timeDelays = true;
        end



        function val = get.timeDelayWidths(obj)
        %Retrieves the list of time delay widths for gated time-domain data  
            if obj.flagVisible.timeDelayWidths
                val = obj.timeDelayWidths;
            else
                error('ICNNA:icnna.data.snirf.probe.get.timeDelayWidths:Undefined', ...
                    'Undefined optional field timeDelayWidths.');
            end
        end
        function obj = set.timeDelayWidths(obj,val)
        %Updates the list of time delay widths for gated time-domain data 
            obj.timeDelayWidths = val;
            obj.flagVisible.timeDelayWidths = true;
        end


        function val = get.momentOrders(obj)
        %Retrieves the list of moment orders of the moment TD data   
            if obj.flagVisible.momentOrders
                val = obj.momentOrders;
            else
                error('ICNNA:icnna.data.snirf.probe.get.momentOrders:Undefined', ...
                    'Undefined optional field momentOrders.');
            end
        end
        function obj = set.momentOrders(obj,val)
        %Updates the list of moment orders of the moment TD data 
            obj.momentOrders = val;
            obj.flagVisible.momentOrders = true;
        end


        function val = get.correlationTimeDelays(obj)
        %Retrieves the list of time delays for DCS measurements 
            if obj.flagVisible.correlationTimeDelays
                val = obj.correlationTimeDelays;
            else
                error('ICNNA:icnna.data.snirf.probe.get.correlationTimeDelays:Undefined', ...
                    'Undefined optional field correlationTimeDelays.');
            end
        end
        function obj = set.correlationTimeDelays(obj,val)
        %Updates the list of time delays for DCS measurements
            obj.correlationTimeDelays = val;
            obj.flagVisible.correlationTimeDelays = true;
        end


        function val = get.correlationTimeDelayWidths(obj)
        %Retrieves the list of time delay widths for DCS measurements 
            if obj.flagVisible.correlationTimeDelayWidths
                val = obj.correlationTimeDelayWidths;
            else
                error('ICNNA:icnna.data.snirf.probe.get.correlationTimeDelayWidths:Undefined', ...
                    'Undefined optional field correlationTimeDelayWidths.');
            end
        end
        function obj = set.correlationTimeDelayWidths(obj,val)
        %Updates the list of time delay widths for DCS measurements
            obj.correlationTimeDelayWidths = val;
            obj.flagVisible.orrelationTimeDelayWidths = true;
        end


        function val = get.sourceLabels(obj)
        %Retrieves the set of source names.
            if obj.flagVisible.sourceLabels
                val = obj.sourceLabels;
            else
                error('ICNNA:icnna.data.snirf.probe.get.sourceLabels:Undefined', ...
                    'Undefined optional field sourceLabels.');
            end
        end
        function obj = set.sourceLabels(obj,val)
        %Updates the set of source names.
           if (isstring(val) && size(val,2) == 1 && ndims(val)==2)
               obj.sourceLabels = val;
               obj.flagVisible.sourceLabels = true;
           elseif (iscell(val) && size(val,2) == 1 && ndims(val)==2) %DEPRECATED
               warning(['icnna.data.snirf.probe:set.sourceLabels:InvalidPropertyValue',...
                     'Use of cell array is now deprecated. Value must be a Mx1 string array of labels for M sources.']);
               for iElem = 1:numel(val) 
                    obj.sourceLabels(iElem) = val{iElem};
               end
               obj.flagVisible.sourceLabels = true;
           else
               error(['icnna.data.snirf.probe:set.sourceLabels:InvalidPropertyValue',...
                     'Value must be a Mx1 string array (or cell array -deprecated-) of labels for M sources.']);
           end
           %assertInvariants(obj);
        end


        function val = get.detectorLabels(obj)
        %Retrieves the set of detector names.
            if obj.flagVisible.detectorLabels
                val = obj.detectorLabels;
            else
                error('ICNNA:icnna.data.snirf.probe.get.detectorLabels:Undefined', ...
                    'Undefined optional field detectorLabels.');
            end
        end
        function obj = set.detectorLabels(obj,val)
        %Updates the set of detector names.
           if (isstring(val) && size(val,2) == 1 && ndims(val)==2)
               obj.detectorLabels = val;
               obj.flagVisible.detectorLabels = true;
           elseif (iscell(val) && size(val,2) == 1 && ndims(val)==2) %DEPRECATED
               warning(['icnna.data.snirf.probe:set.detectorLabels:InvalidPropertyValue',...
                     'Use of cell array is now deprecated. Value must be a Mx1 string array of labels for M detectors.']);
               for iElem = 1:numel(val) 
                    obj.detectorLabels = val;
               end
               obj.flagVisible.detectorLabels = true;
           else
               error(['icnna.data.snirf.probe:set.detectorLabels:InvalidPropertyValue',...
                     'Value must be a Mx1 string array (or cell array -deprecated-) of labels for M detectors.']);
           end
           %assertInvariants(obj);
        end



        function val = get.landmarkPos2D(obj)
        %Retrieves the set of anatomical landmark positions in 2D.
        %
        %Uses 1 row per source.
            if obj.flagVisible.landmarkPos2D
                val = obj.landmarkPos2D;
            else
                error('ICNNA:icnna.data.snirf.probe.get.landmarkPos2D:Undefined', ...
                    'Undefined optional field landmarkPos2D.');
            end
        end
        function obj = set.landmarkPos2D(obj,val)
        %Updates the set of anatomical landmark positions in 2D.
        %
        %Uses 1 row per source.
        %This array should contain a minimum of 2 columns, representing
        % the x and y coordinates (in LengthUnit units) of the 2-D
        % projected landmark positions. If a 3rd column presents, it
        % stores the index to the labels of the given landmark. Label
        % names are stored in the probe.landmarkLabels subfield. An
        % label index of 0 refers to an undefined landmark.

           if (ismatrix(val) && (size(val,2) == 2 || size(val,2) == 3) && all(isnumeric(val)))
               obj.landmarkPos2D = val;
               obj.flagVisible.landmarkPos2D = true;
           elseif (ismatrix(val) && size(val,2) == 3 && all(isnumeric(val)))
               warning(['icnna.data.snirf.probe:set.landmarkPos2D:InvalidPropertyValue',...
                     'Value must be a Mx2 matrix of planar coordinates for M anatomical landmark. Discarding any additional values provided.'])
               obj.landmarkPos2D = val(:,1:2);
               obj.flagVisible.landmarkPos2D = true;
           else
               error(['icnna.data.snirf.probe:set.landmarkPos2D:InvalidPropertyValue',...
                     'Value must be a Mx2 (or Mx3 with label indices) matrix of anatomical landmark coordinates for M labels (see property landmarkLabels).']);
           end
           %assertInvariants(obj);
        end


        function val = get.landmarkPos3D(obj)
        %Retrieves the set of anatomical landmark positions in 3D.
        %
        %Uses 1 row per source.
            if obj.flagVisible.landmarkPos3D
                val = obj.landmarkPos3D;
            else
                error('ICNNA:icnna.data.snirf.probe.get.landmarkPos3D:Undefined', ...
                    'Undefined optional field landmarkPos3D.');
            end
        end
        function obj = set.landmarkPos3D(obj,val)
        %Updates the set of landmark positions in 3D.
        %
        %Uses 1 row per source and 3 Euclidean coordinates.
        %This array should contain a minimum of 3 columns, representing
        % the x, y and z coordinates (in LengthUnit units) of the
        % digitized landmark positions. If a 4th column presents, it
        % stores the index to the labels of the given landmark. Label
        % names are stored in the probe.landmarkLabels subfield. An
        % label index of 0 refers to an undefined landmark.

           if (ismatrix(val) && (size(val,2) == 3 || size(val,2) == 4) && all(isnumeric(val)))
               obj.landmarkPos3D = val;
               obj.flagVisible.landmarkPos3D = true;
           else
               error(['icnna.data.snirf.probe:set.landmarkPos3D:InvalidPropertyValue',...
                     'Value must be a Mx3 (or Mx4 with label indices)  matrix of anatomical landmark coordinates for M labels (see property landmarkLabels).']);
           end
           %assertInvariants(obj);
        end

        function val = get.landmarkLabels(obj)
        %Retrieves the set of anatomical landmark names.
            if obj.flagVisible.landmarkLabels
                val = obj.landmarkLabels;
            else
                error('ICNNA:icnna.data.snirf.probe.get.landmarkLabels:Undefined', ...
                    'Undefined optional field landmarkLabels.');
            end
        end
        function obj = set.landmarkLabels(obj,val)
        %Updates the set of anatomical landmark names.
           if (isstring(val) && size(val,2) == 1 && ndims(val)==2)
               obj.landmarkLabels = val;
               obj.flagVisible.landmarkLabels = true;
           elseif (iscell(val) && size(val,2) == 1 && ndims(val)==2) %DEPRECATED
               warning(['icnna.data.snirf.probe:set.landmarkLabels:InvalidPropertyValue',...
                     'Use of cell array is now deprecated. Value must be a Mx1 string array of labels for M anatomical landmarks.']);
               for iElem = 1:numel(val) 
                    obj.landmarkLabels = val;
                    obj.flagVisible.landmarkLabels = true;
               end
           else
               error(['icnna.data.snirf.probe:set.landmarkLabels:InvalidPropertyValue',...
                     'Value must be a Mx1 string array (or cell array -deprecated-) of labels for M anatomical landmarks.']);
           end
           %assertInvariants(obj);
        end


        function val = get.useLocalIndex(obj)
        %For modular NIRS systems, setting this flag to a non-zero integer indicates that measurementList(k).sourceIndex and measurementList(k).detectorIndex are module-specific local-indices. 
            if obj.flagVisible.useLocalIndex
                val = obj.useLocalIndex;
            else
                error('ICNNA:icnna.data.snirf.probe.get.useLocalIndex:Undefined', ...
                    'Undefined optional field useLocalIndex.');
            end
        end
        function obj = set.useLocalIndex(obj,val)
        %Updates the flags indicating module-specific local-indices.
            obj.useLocalIndex = val;
            obj.flagVisible.useLocalIndex = true;
        end








        %%Suport methods for visibility of optional attributes
        function res = isproperty(obj,propertyName)
        %Check whether existing optional attributes have been defined (i.e. checks visibility)
            propertyName = char(propertyName);
            res = isprop(obj,propertyName);
            switch(propertyName)
                case {'wavelengthsEmission','frequencies', ...
                        'timeDelays','timeDelayWidths', 'momentOrders', ...
                        'correlationTimeDelays', 'correlationTimeDelayWidths', ...
                        'sourceLabels', 'detectorLabels', ...
                        'landmarkPos2D', 'landmarkPos3D', 'landmarkLabels', ...
                        'coordinateSystem', 'coordinateSystemDescription', ...
                        'useLocalIndex'}
                    res = obj.flagVisible.(propertyName);
                otherwise
                    %Do nothing
            end
        end


        function obj = rmproperty(obj,propertyName)
        %"Removes" (hides) existing optional attributes
            propertyName = char(propertyName);
            switch(propertyName)
                case {'wavelengthsEmission','frequencies', ...
                        'timeDelays','timeDelayWidths', 'momentOrders', ...
                        'correlationTimeDelays', 'correlationTimeDelayWidths', ...
                        'sourceLabels', 'detectorLabels', ...
                        'landmarkPos2D', 'landmarkPos3D', 'landmarkLabels', ...
                        'coordinateSystem', 'coordinateSystemDescription', ...
                        'useLocalIndex'}
                    obj.flagVisible.(propertyName) = false;
                case {'wavelengths','sourcePos2D','sourcePos3D',...
                        'detectorPos2D','detectorPos3D'}
                    error('ICNNA:icnna.data.snirf.probe.rmproperty:NonOptionalProperty', ...
                        ['Property ' propertyName ' cannot be removed. It is not optional for .snirf format.']);
                otherwise
                    error('ICNNA:icnna.data.snirf.probe.rmproperty:UnknownProperty', ...
                        ['Unknown property ' propertyName '.']);
            end
        end

        

    end


end

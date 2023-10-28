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
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end




    properties
        wavelengths(:,1) double     = nan(0,1); %List of wavelengths in [nm]
        wavelengthsEmission(:,1) double = nan(0,1); %List of emission wavelengths in [nm]
        sourcePos2D(:,:) double     = nan(0,2); %Source 2-D positions in LengthUnit
                                  %1 row per source
        sourcePos3D(:,:,:) double   = nan(0,3); %Source 3-D positions in LengthUnit
                                  %1 row per source
        detectorPos2D(:,:) double   = nan(0,2); %Detector 2-D positions in LengthUnit
                                  %1 row per source
        detectorPos3D(:,:,:) double = nan(0,3); %Detector 3-D positions in LengthUnit
                                  %1 row per source

        frequencies(:,1) double = nan(0,1); %Modulation frequency list   
        timeDelays(:,1) double  = nan(0,1); %Time delays for gated time-domain data   
        timeDelayWidths(:,1) double = nan(0,1); %Time delay width for gated time-domain data   
        momentOrders(:,1) double    = nan(0,1); % Moment orders of the moment TD data   
        correlationTimeDelays(:,1) double = nan(0,1); % Time delays for DCS measurements  
        correlationTimeDelayWidths(:,1) double = nan(0,1); % Time delay width for DCS measurements 
        sourceLabels(:,1) cell    = cell(0,1); % String arrays specifying source names   
        detectorLabels(:,1) cell  = cell(0,1); % String arrays specifying detector names   
        landmarkPos2D(:,:) double = nan(0,1); % Anatomical landmark 2-D positions  
        landmarkPos3D(:,:,:) double = nan(0,1); % Anatomical landmark 3-D positions  
        landmarkLabels(:,1) cell  = cell(0,1); % String arrays specifying landmark names 
        useLocalIndex(1,1) double = nan; % If source/detector index is within a module
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
            val = obj.wavelengths;
        end
        function obj = set.wavelengthsEmission(obj,val)
        %Updates the list of emission wavelengths
            obj.wavelengthsEmission = val;
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

        function val = get.frequencies(obj)
        %Retrieves the list of modulation frequencies
            val = obj.frequencies;
        end
        function obj = set.frequencies(obj,val)
        %Updates the list of modulation frequencies
            obj.frequencies = val;
        end


        function val = get.timeDelays(obj)
        %Retrieves the list of time delays for gated time-domain data 
            val = obj.timeDelays;
        end
        function obj = set.timeDelays(obj,val)
        %Updates the list of time delays for gated time-domain data
            obj.timeDelays = val;
        end



        function val = get.timeDelayWidths(obj)
        %Retrieves the list of time delay widths for gated time-domain data  
            val = obj.timeDelayWidths;
        end
        function obj = set.timeDelayWidths(obj,val)
        %Updates the list of time delay widths for gated time-domain data 
            obj.timeDelayWidths = val;
        end


        function val = get.momentOrders(obj)
        %Retrieves the list of moment orders of the moment TD data   
            val = obj.momentOrders;
        end
        function obj = set.momentOrders(obj,val)
        %Updates the list of moment orders of the moment TD data 
            obj.momentOrders = val;
        end


        function val = get.correlationTimeDelays(obj)
        %Retrieves the list of time delays for DCS measurements 
            val = obj.correlationTimeDelays;
        end
        function obj = set.correlationTimeDelays(obj,val)
        %Updates the list of time delays for DCS measurements
            obj.correlationTimeDelays = val;
        end


        function val = get.correlationTimeDelayWidths(obj)
        %Retrieves the list of time delay widths for DCS measurements 
            val = obj.correlationTimeDelayWidths;
        end
        function obj = set.correlationTimeDelayWidths(obj,val)
        %Updates the list of time delay widths for DCS measurements
            obj.correlationTimeDelayWidths = val;
        end


        function val = get.sourceLabels(obj)
        %Retrieves the set of source names.
            val = obj.sourceLabels;
        end
        function obj = set.sourceLabels(obj,val)
        %Updates the set of source names.
           if (iscell(val) && size(val,2) == 1 && size(val,3)==0)
               obj.sourceLabels = val;
           else
               error(['icnna.data.snirf.probe:set.sourceLabels:InvalidPropertyValue',...
                     'Value must be a Mx1 cell array of labels for M sources.']);
           end
           %assertInvariants(obj);
        end


        function val = get.detectorLabels(obj)
        %Retrieves the set of detector names.
            val = obj.detectorLabels;
        end
        function obj = set.detectorLabels(obj,val)
        %Updates the set of detector names.
           if (iscell(val) && size(val,2) == 1 && size(val,3)==0)
               obj.detectorLabels = val;
           else
               error(['icnna.data.snirf.probe:set.detectorLabels:InvalidPropertyValue',...
                     'Value must be a Mx1 cell array of labels for M detectors.']);
           end
           %assertInvariants(obj);
        end



        function val = get.landmarkPos2D(obj)
        %Retrieves the set of anatomical landmark positions in 2D.
        %
        %Uses 1 row per source.
            val = obj.landmarkPos2D;
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
            val = obj.landmarkPos3D;
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
           else
               error(['icnna.data.snirf.probe:set.landmarkPos3D:InvalidPropertyValue',...
                     'Value must be a Mx3 (or Mx4 with label indices)  matrix of anatomical landmark coordinates for M labels (see property landmarkLabels).']);
           end
           %assertInvariants(obj);
        end

        function val = get.landmarkLabels(obj)
        %Retrieves the set of anatomical landmark names.
            val = obj.landmarkLabels;
        end
        function obj = set.landmarkLabels(obj,val)
        %Updates the set of anatomical landmark names.
           if (iscell(val) && size(val,2) == 1 && ndims(val)==2)
               obj.landmarkLabels = val;
           else
               error(['icnna.data.snirf.probe:set.landmarkLabels:InvalidPropertyValue',...
                     'Value must be a Mx1 cell array of labels for M anatomical landmarks.']);
           end
           %assertInvariants(obj);
        end


        function val = get.useLocalIndex(obj)
        %For modular NIRS systems, setting this flag to a non-zero integer indicates that measurementList(k).sourceIndex and measurementList(k).detectorIndex are module-specific local-indices. 
            val = obj.useLocalIndex;
        end
        function obj = set.useLocalIndex(obj,val)
        %Updates the flags indicating module-specific local-indices.
            obj.useLocalIndex = val;
        end




    end


end

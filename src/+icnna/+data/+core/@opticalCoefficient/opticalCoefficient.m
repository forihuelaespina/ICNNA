classdef opticalCoefficient < icnna.data.core.identifiableObject
% icnna.data.core.opticalCoefficient - An optical coefficient
% 
% 
% 
% An optical coefficient such as absorption, scattering, extenction, etc,
% whether macroscopic, reduced or specific. In fact, this can represent
% any spectral function e.g. DPF wavelength dependence.
%
%
% A factory method .create is provided to generate optical coefficients
% from existing .json files. ICNNA provides a few coefficients (inherited
% from UCL's fOSA) directly out of the box available in package:
%
%   +icnna/+data/+coeffs
%
%   e.g.: obj = icnna.data.core.opticalCoefficient.create('+icnna/+data/+coeffs/HbO2_extinction_specific_fOSA_CopeM.json')
% 
% but a user can add other coefficients as they need following the same
% .json template.
%
%
%% Superclass
%
%   icnna.data.core.identifiableObject
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - (Since v1.3.1) Char array. By default is empty 'opticalCoefficient0001'.
%       A name for the object. 
%
%   -- Public properties
%   .description - char[]. Default is empty
%       Human readable notes.
%
%   .response - double[kx2]. Default is 0 at all UV-VIS-NIR e.g. [200 0; 1400 0]
%       Spectral response of the coefficient. The first column are
%       wavelengths in [nm] and the second column is the amplitude
%       of the coefficient in |unitMultiplier|*|unit| at each wavelength.
%       Missing wavelengths will be interpolated/extrapolated if
%       requested (see method getResponseAt).
%
%   .coefficientType - String. Enum. Default is "other"
%       Type of optical coefficient. Valid types are:
%           * absorption
%           * scattering
%           * reducedScattering
%           * extinction
%           * dpf - Differential pathlength factor
%                   Strictly not an optical coefficient but it also
%                   exhibits wavelength dependence.
%           * ppf - Partial pathlength factor
%                   Strictly not an optical coefficient but it also
%                   exhibits wavelength dependence.
%           * kdpf - Wavelength-dependent part of a DPF
%                   Strictly not an optical coefficient but it also
%                   exhibits wavelength dependence.
%           * other
%
%   .scaleType - String. Enum. Default is "macroscopic"
%       Scale of the optical coefficient. Valid types are:
%           * macroscopic
%           * specific
%
%   .unit - Char array. Default is 'm^{-1}'.
%       The unit of measure for the spectral response
%
%   .unitMultiplier - Scalar (int16). Default 0.
%       The time unit multiplier exponent in base 10. This represents
%       fractional units, e.g. if unit is 'm^{-1}', then -2 equals to
%       [cm^{-1}]. 
%
%   .interpolationMethod - String. Enum. Default is "linear"
%       Type of interpolation. Valid interpolation methods are:
%           * linear
%           * nearest - For nearest neighbour
%           * pchip
%           * spline - For cubic spline
%
%   .extrapolationMethod - String. Enum. Default is "extrap"
%       Type of extrapolation. Valid extrapolation methods are:
%           * extrap
%           * none
%
%% Dependent properties
%
%   N/A
%
%% Methods
%
% Type methods('icnna.data.core.opticalCoefficient') for a list of methods
% 
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also
%




%% Log
%
%   + Class available since ICNNA v1.4.0
%
% 10-Feb-2026: FOE
%   + File and class created.
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        description (1,:) char = ''   % Optional human-readable notes
        response(:,2) double {mustBeNumeric} = [200 0; 1400 0]; %Spectral response
        coefficientType (1,1) string {mustBeMember(coefficientType, ...
            ["absorption","scattering","reducedScattering","extinction",...
             "dpf","ppf","kdpf","other"])} = "other"
        scaleType (1,1) string {mustBeMember(scaleType, ...
            ["macroscopic","specific"])} = "macroscopic"
        unit(1,:) char = 'm^{-1}'; % Unit of measure
        unitMultiplier(1,1) int16 = 0; % Multiplier for unit

        interpolationMethod (1,1) string {mustBeMember(interpolationMethod, ...
            ["linear","nearest","pchip","spline"])} = "linear"
    
        extrapolationMethod (1,1) string {mustBeMember(extrapolationMethod, ...
            ["extrap","none"])} = "extrap"
    
    
    end


    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=opticalCoefficient(varargin)
            %Constructor for class @icnna.data.core.opticalCoefficient
            %
            % obj=icnna.data.core.opticalCoefficient() creates a default opticalCoefficient.
            % obj=icnna.data.core.opticalCoefficient(obj2) acts as a copy constructor
            %
            %

            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.opticalCoefficient')
                obj = varargin{1};
                return;
            else
                error(['icnna:data:core:opticalCoefficient:opticalCoefficient:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
        end
    end



    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods

          %Retrieves the object |response|
      function res = get.response(obj)
            % Getter for |response|:
            %   Returns the optical coefficient spectral response.
            %
            % Usage:
            %   res = obj.response;  % Retrieve spectral response of the coefficient
            %
            %% Output
            % res - double[kx2]
            %       Spectral response of the coefficient. The first column are
            %       wavelengths in [nm] and the second column is the amplitude at
            %       each wavelength.
            %
          res = obj.response;
      end
          %Sets the object |response|
      function obj = set.response(obj,val)
            % Setter for |response|:
            %   Sets the optical coefficient spectral response.
            %
            % Usage:
            %   obj.response = [200 1; 1400 1]; % Set the spectral response of the coefficient
            %
            %% Error handling
            %
            % Wavelengths must be in increasing order.
            %
            %% Input parameters
            %
            % val - double[kx2]
            %       Spectral response of the coefficient. The first column are
            %       wavelengths in [nm] and the second column is the amplitude at
            %       each wavelength.
            %
            %% Output
            %
            % obj - @icnna.data.core.opticalCoefficient
            %   The updated object
            %
            assert(size(val,2)==2, ...
                    'response must be kx2 [wavelength amplitude].');
            assert(all(diff(val(:,1))>0), ...
                    'Wavelengths must be strictly increasing.');
            obj.response =  val;
      end

        %Retrieves the coefficient's |unit|
        function res = get.unit(obj)
            % Getter for |unit|:
            %   Returns the current unit of measure for the coefficient.
            %
            % Usage:
            %   res = obj.unit;  % Get the current unit
            %
            %% Output
            % res - string
            %   The current unit of measure for the coefficient.
            %
            res = obj.unit;
        end
        %Sets the coefficient's |unit|
        function obj = set.unit(obj,val)
            % Setter for |unit|:
            %   Sets the |unit| property. 
            %
            % Usage:
            %   obj.unit = 'm^{-1}';  % Set unit to 'm^{-1}'
            %
            %% Input parameters
            %
            % val - char[]
            %   The new unit for the optical coefficient.
            %
            %% Output
            %
            % obj - @icnna.data.core.opticalCoefficient
            %   The updated object
            %

            obj.unit = val; % Assign the new unit value
        end


        %Retrieves the unit multiplier
        function res = get.unitMultiplier(obj)
            % Getter for |unitMultiplier|:
            %   Returns the current value of the unit multiplier,
            %   which determines the precision (e.g. centimeters= -2).
            %
            % Usage:
            %   res = obj.unitMultiplier;  % Get the current multiplier
            %
            %% Output
            % res - int16
            %   The time unit multiplier.
            %
            res = obj.unitMultiplier;
        end
        %Sets the unit multiplier
        function obj = set.unitMultiplier(obj,val)
            % Setter for |unitMultiplier|:
            %   Sets the |unitMultiplier| property.
            % 
            % Usage:
            %   obj.unitMultiplier = -3;  % Set the multiplier to -3 (e.g., mm)
            %
            %% Input parameters
            %
            % val - int16
            %   The new unit multiplier.
            %
            %% Output
            %
            % obj - @icnna.data.core.opticalCoefficient
            %   The updated object
            %

            obj.unitMultiplier = val; % Assign the new multiplier value
        end


    end




    % =====================================================================
    % General methods
    % =====================================================================
    methods
        function val = getResponseAt(obj, wavelengths)
            % Returns the spectral response at specified wavelengths (nm)
            %
            % Usage:
            %   v = obj.getResponseAt(750);
            %   v = obj.getResponseAt([650 750 850]);
            %
            %% Input parameters
            %
            % wavelengths - double[]
            %   Column of row vector.
            %   List of wavelengths at which to retrieve the response.
            %
            %% Output
            %
            % val - double[]
            %   List of response amplitude as column vector
            %   Note that this is returned as column vector even
            %   if input wavelengths are expressed as row vector.
            %
    
            arguments
                obj
                wavelengths (:,1) double {mustBePositive}
            end
    
            wl  = obj.response(:,1);
            amp = obj.response(:,2);

            if strcmp(obj.extrapolationMethod,"none")
                val = interp1(wl, amp, wavelengths, ...
                    obj.interpolationMethod);
                if any(isnan(val))
                    warning(['Some wavelengths are outside the defined ' ...
                            'range. See property |extrapolationMethod|.']);
                end
            else
                val = interp1(wl, amp, wavelengths, ...
                    obj.interpolationMethod, "extrap");
            end
        end

        function toJSON(obj, filename)
            % Writes the opticalCoefficient to a JSON file
            %
            % obj.toJSON(filename)
            %   Serializes the opticalCoefficient object into a JSON file
            %   that can later be reloaded using fromJSON().
            %
            %% Input parameters
            %
            % filename - char[]
            %   Name of the .json file (inc. path) to store the
            %   optical coefficient.
            %
    
            assert(exist('jsonencode','builtin')==5, ...
                'JSON support requires MATLAB R2016b or newer.');
            s = struct();
            s.icnna.data.core.opticalCoefficient.classVersion        = ...
                    obj.classVersion;
            s.icnna.data.core.opticalCoefficient.id                  = ...
                    obj.id;
            s.icnna.data.core.opticalCoefficient.name                = ...
                    obj.name;
            s.icnna.data.core.opticalCoefficient.coefficientType     = ...
                    char(obj.coefficientType);
            s.icnna.data.core.opticalCoefficient.scaleType           = ...
                    char(obj.scaleType);
            s.icnna.data.core.opticalCoefficient.unit                = ...
                    obj.unit;
            s.icnna.data.core.opticalCoefficient.unitMultiplier      = ...
                    obj.unitMultiplier;
            s.icnna.data.core.opticalCoefficient.response            = ...
                    obj.response;
            s.icnna.data.core.opticalCoefficient.description         = ...
                    obj.description;
            s.icnna.data.core.opticalCoefficient.interpolationMethod = ...
                    char(obj.interpolationMethod);
            s.icnna.data.core.opticalCoefficient.extrapolationMethod = ...
                    char(obj.extrapolationMethod);
    
            txt = jsonencode(s,'PrettyPrint',true);
    
            fid = fopen(filename,'w');
            assert(fid~=-1,'Could not open file for writing.');
            fwrite(fid,txt,'char');
            fclose(fid);
        end
        
    
    end    







    methods (Static)
        function obj = create(filename)
            % Factory method for common optical coefficients
            %
            % obj = icnna.data.core.opticalCoefficient.create(filename)
            %   Creates an opticalCoefficient object from a JSON file
            %   The file may describe a single optical coefficient
            %   and must include all mandatory fields (name, response,
            %   unit, etc.).
            %   If the file contains multiple coefficients, it returns
            %   an array of objects.
            %
            %% Input parameters
            %
            % filename - char[]
            %   Name of the .json file (inc. path) describing the
            %   optical coefficient.
            %
            %% Output
            %
            % obj - @icnna.data.core.opticalCoefficient
            %   The created optical coefficient object.
            %
            obj = icnna.data.core.opticalCoefficient.fromJSON(filename);
        end
    end
    
    
    methods (Static, Access=private)
        function obj = fromJSON(filename, varargin)
            %Reads an opticalCoefficient from a JSON file.
            %
            %
            % obj[] = icnna.data.core.opticalCoefficient.fromJSON(filename)
            %   Reads an optical coefficient description from a JSON file
            %   and returns the corresponding opticalCoefficient object.
            %   The file may describe one or multiple optical coefficients
            %   each one must include all mandatory fields (name, response,
            %   unit, etc.).
            %   If the file contains multiple coefficients, all are read
            %   and returned as an array of objects.
            %
            % NOTE: The file can be in any directory, and the function
            % accepts both single and multiple coefficients in the same
            % file.
            %
            % Usage:
            %   coeffObj = icnna.data.core.opticalCoefficient.fromJSON('path_to_single_coefficient.json');
            %   coeffObjs = icnna.data.core.opticalCoefficient.fromJSON('path_to_multiple_coefficients.json');
            %
            %% Minimal example JSON file describing a coefficient.
            %
            % {
            %  "icnna.data.core.opticalCoefficient": {
            %   "classVersion": "1.0",
            %   "id": 1,
            %   "name": "HbO",
            %   "coefficientType": "absorption",
            %   "scaleType": "specific",
            %   "unit": "m^{-1} M^{-1}",
            %   "unitMultiplier": 0,
            %   "interpolationMethod": "pchip",
            %   "response": [
            %     [650, 0.12],
            %     [700, 0.09],
            %     [750, 0.07],
            %     [800, 0.05],
            %     [850, 0.04]
            %   ]
            %  }
            % }
            %
            %% Minimal example JSON file describing several coefficients.
            %
            % {
            %   "icnna.data.core.opticalCoefficients": [
            %     {
            %       "classVersion": "1.0",
            %       "name": "Skull",
            %       "coefficientType": "scattering",
            %       "scaleType": "macroscopic",
            %       "unit": "m^{-1} M^{-1}",
            %       "unitMultiplier": 0,
            %       "description": "From OMLC coefficients",
            %       "values": [
            %          [650, 0.12],
            %          [700, 0.09],
            %          [850, 0.04]
            %       ]
            %     },
            %     {
            %       "name": "HbO",
            %       "coefficientType": "absorption",
            %       "scaleType": "specific",
            %       "unit": "m^{-1} M^{-1}",
            %       "unitMultiplier": 0,
            %       "description": "From fOSA original coefficients",
            %       "response": [
            %          [650, 0.12],
            %          [700, 0.09],
            %          [750, 0.07],
            %          [800, 0.05],
            %          [850, 0.04]
            %        ]
            %     }
            %   ]
            % }
            %
            %% Input parameters
            %
            % filename - char[]
            %   Name of the file (inc. path) containing the
            %   optical coefficient.
            %
            %% Output
            %
            % obj - @icnna.data.core.opticalCoefficient
            %   If the file describes one coefficient, a single object
            %   is returned.
            %   If the file describes multiple coefficients, an array
            %   of objects is returned.
            %

            assert(exist('jsondecode','builtin')==5, ...
                'JSON support requires MATLAB R2016b or newer.');

            % Check if the filename is a valid file
            if ~isfile(filename)
                error('The file %s does not exist.', filename);
            end

            % Read the JSON file
            txt = fileread(filename);
            s = jsondecode(txt);
                %Note that this will replace any '.' in the
                %object's class name with '_'

            % Initialize an empty array of objects
            obj = [];

            % Handle the case where the file contains a single coefficient
            if isfield(s, 'icnna_data_core_opticalCoefficient')
                coeffData = s.icnna_data_core_opticalCoefficient;
                obj = icnna.data.core.opticalCoefficient(); % Create a single object

                % Populate properties from the JSON data
                if isfield(coeffData, 'classVersion')
                    %Class version is READ-ONLY. No need to write.
                    % Future migration logic goes here
                 end

                if isfield(coeffData, 'id')
                    obj.id = coeffData.id;
                end

                obj.name             = coeffData.name;
                obj.response         = coeffData.response;
                obj.unit             = coeffData.unit;
                obj.unitMultiplier   = int16(coeffData.unitMultiplier);
                obj.coefficientType  = string(coeffData.coefficientType);
                obj.scaleType        = string(coeffData.scaleType);

                if isfield(coeffData, 'description')
                    obj.description = coeffData.description;
                end

                if isfield(coeffData, 'interpolationMethod')
                    obj.interpolationMethod = string(coeffData.interpolationMethod);
                end

                if isfield(coeffData, 'extrapolationMethod')
                    obj.extrapolationMethod = string(coeffData.extrapolationMethod);
                end

                % Handle the case where the file contains multiple coefficients
            elseif isfield(s, 'icnna_data_core_opticalCoefficients')
                % Multiple coefficients are stored in the "icnna.data.core.opticalCoefficients" array
                coeffDataArray = s.icnna_data_core_opticalCoefficients;

                % Initialize the object array to match the number of coefficients
                obj = icnna.data.core.opticalCoefficient.empty(0, length(coeffDataArray));

                % Iterate over each coefficient in the array
                for i = 1:length(coeffDataArray)
                    tmpObj = icnna.data.core.opticalCoefficient();
                    coeffData = coeffDataArray{i};

                    % Populate properties from each coefficient entry
                    if isfield(coeffData, 'classVersion')
                        %Class version is READ-ONLY. No need to write.
                        % Future migration logic goes here
                    end

                    if isfield(coeffData, 'id')
                        tmpObj.id = coeffData.id;
                    end

                    tmpObj.name            = coeffData.name;
                    tmpObj.response        = coeffData.response;
                    tmpObj.unit            = coeffData.unit;
                    tmpObj.unitMultiplier  = int16(coeffData.unitMultiplier);
                    tmpObj.coefficientType = string(coeffData.coefficientType);
                    tmpObj.scaleType       = string(coeffData.scaleType);

                    if isfield(coeffData, 'description')
                        tmpObj.description = coeffData.description;
                    end

                    if isfield(coeffData, 'interpolationMethod')
                        tmpObj.interpolationMethod = string(coeffData.interpolationMethod);
                    end

                    if isfield(coeffData, 'extrapolationMethod')
                        tmpObj.extrapolationMethod = string(coeffData.extrapolationMethod);
                    end

                    % Add the created object to the array
                    obj(i) = tmpObj;
                end

            else
                error('The JSON file does not contain valid optical coefficient data.');
            end
        end
    end

end
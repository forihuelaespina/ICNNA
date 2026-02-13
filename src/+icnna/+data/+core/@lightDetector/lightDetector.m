classdef lightDetector < icnna.data.core.optode
% icnna.data.core.lightDetector - A light detector
%
% A light detector e.g. photodiode.
%
% Together with icnna.data.core.lightSource they form the optode
% pairs forming a channel.
%
%
%% Superclass
%
%   icnna.data.core.optode
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
%   .name - (Since v1.3.1) Char array. By default is empty 'lightDetector0001'.
%       A name for the object. 
%
%   -- Inherited properties from @icnna.data.core.optode
%   .location - @icnna.data.core.referenceLocation
%       The position where the optode is located. This in turn
%       keeps track of the positioning system and associated landmark
%       if any.
%   .direction2D - 2x1 double. Vector. Default is [0; 1]
%       The 2D direction vector of photon emission. To be used with 
%       location2D.
%   .direction3D - 3x1 double. Vector. Default is [0; 0; 1]
%       The 3D direction vector of photon emission. To be used with 
%       location3D.
%
%   -- Public properties
%   .detType - char[] Enum. Default is 'disk'.
%       The following types are available at the moment.
%
%  srctype      | Description                  
%  -------------+------------------------------
%  "disk"       | circled area detector
%
%   Although currently only "disk" detectors are recognised, this is
%   reserved for future use.
%
%   .direction2D - 2x1 double. Vector. Default is [0; 1]
%       The 2D direction vector of photon detection. To be used with 
%       location2D.
%   .direction3D - 3x1 double. Vector. Default is [0; 0; 1]
%       The 3D direction vector of photon detection. To be used with 
%       location3D.
%   .param - Struct. Default is empty.
%       A list of parameters describing the light source. The list of
%       fields depends on the source type |detType|
%
%  srctype      | param fieldname | Meaning
%  -------------+-----------------+---------------------------------
%  "disk"       | radius          | radius of the disk
%  -------------+-----------------+---------------------------------
%
%
%      IMPORTANT: Changing the detType resets the param to default values.
%
%   .response - double[kx2]. Default is UV-VIS-NIR all at 1 (100% efficiency)
%                           e.g. [200 1; 1400 1]
%       Spectral response or quantum efficiency of the detector normalized
%       to 1 (100%). The first column are wavelengths in [nm] and the
%       second column is the detector efficiency at each wavelength.
%       Missing wavelengths will be interpolated/extrapolated if requested.
%
%   .powerGain - double. Default is 0 (i.e. no increase or decrease in
%                           signal strength or amplitude).
%       Relative amplification of the detector in [dB].
%       Strictly speaking, the gain may come not from the detector itself,
%       but from some amplifier/attenuator placed in front of the
%       detector.
%
%% Dependent properties
%
%   N/A
%
%% Methods
%
% Type methods('icnna.data.core.lightDetector') for a list of methods
% 
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also assertInvariant
%




%% Log
%
%   + Class available since ICNNA v1.4.0
%
% 28-Apr-2025: FOE
%   + File and class created.
%
% 10-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%   * No need to update classVersion as this classVersion
%     of ICNNA has not yet been released and this is the first
%     version including this class.params, ergo, no harm done.
%   + Improved comments
%   + |direction| is now inherited from @icnna.data.core.optode
%     and split into |direction2D| and |direction3D|.
%   + Improved verification of |params| setting.
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        detType(1,:) char {mustBeMember(detType,{'disk'})} = 'disk';
        params(1,1) struct = struct; %List of parameters for the detType. See list above.
        response(:,2) double {mustBeNumeric} = [200 1; 1400 1]; %QE
        powerGain(1,1) double {mustBeNumeric} = 0; %Power gain in [dB]
    end


    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=lightDetector(varargin)
            %Constructor for class @icnna.data.core.lightDetector
            %
            % obj=icnna.data.core.lightDetector() creates a default lightDetector.
            % obj=icnna.data.core.lightDetector(obj2) acts as a copy constructor
            %
            %

            obj@icnna.data.core.optode();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            obj.detType = 'disk'; %May seems redundant given the
                                  %initialization above, but this
                                  %ensures that also |params| is
                                  %initialized correctly.
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.lightDetector')
                obj = varargin{1};
                return;
            else
                error(['icnna:data:core:lightDetector:lightDetector:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
        end
    end



    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods
          %Retrieves the object |detType|
      function res = get.detType(obj)
            % Getter for |detType|:
            %   Returns the light detector type,
            %
            % Refer to the class documentation for the available
            % types.
            %
            % Usage:
            %   res = obj.detType;  % Retrieve light detector type, e.g. 'disk'
            %
            %% Output
            % res - char[]. Enum
            %   The light detector type
            %
          res = obj.detType;
      end
          %Sets the object |detType|
      function obj = set.detType(obj,val)
            % Setter for |detType|:
            %   Sets the light detector type,
            %
            % Refer to the class documentation for the available
            % types.
            %
            % Setting the light detector type reset the companion
            % parameters in |params|.
            %
            %   Throws an error if the detector type does not match
            % any of the recognised detector types.
            %
            % Usage:
            %   obj.detType = 'disk';  % Assign new detector type 'disk'
            %
            % Error handling:
            %   - Input must be a char[]
            %
            %% Input parameters
            %
            % val - char[] (enum)
            %   A recognized light source type.
            %
            %% Output
            %
            % obj - @icnna.data.core.lightDetector
            %   The updated object
            %
          obj.detType =  lower(val);
          %...and reset the parameters
          tmp = struct;
          switch lower(val)
              case 'disk'
                  tmp.radius = 1; %[radius] of the disk
              otherwise
                  error('icnna:data:core:lightDetector:set_detType:InvalidParameterValue',...
                      ['Unknown detector type ' val '.']);
          end
          obj.params = tmp;
      end



          %Retrieves the object |params|
      function res = get.params(obj)
            % Getter for |params|:
            %   Get the additional |params| of a light detector,
            %
            % Refer to the class documentation for a full list of
            % parameters for each |detType|
            %
            % Usage:
            %   res = obj.params;  % Retrieve light detector parameters
            %
            %% Output
            % res - Struct.
            %       A list of parameters describing the light detector.
            %       The list of fields depends on the detector type |detType| 
            %
          res = obj.params;
      end
          %Sets the object |params|
      function obj = set.params(obj,val)
            % Setter for |params|:
            %   Sets the additional |params| of a light detector,
            %
            %   Throws an error if the provided list of parameters
            % does not match the expected list of parameters for they
            % current light detector type in |detType|.
            %
            % Usage:
            %   obj.params = struct(...);  % Assign new list of |params|
            %
            % Error handling:
            %   - Input must be a struct
            %   - List of fields must match the required list of 
            % parameters for they current light detector type in |detType|.
            %   - Parameter values ought to be type castable to they
            % expected type for the paramter, e.g. width for detector type
            % 'rectangular' is double.
            %
            %
            %% Input parameters
            %
            % val - struct
            %    The additional |params| of a light detector.
            %   Each field is a different parameter. For the
            %   full list of parameters and their types, please
            %   refer to the class documention.
            %
            %% Output
            %
            % obj - @icnna.data.core.lightDetector
            %   The updated object
            %

            % ---- Validate input --------------------------------------
            % Ensure the input is a struct array with the correct fields.
            if ~isstruct(val)
                error('icnna:data:core:lightDetector:set_params:InvalidValue',...
                      'Val is expected to be a struct.');
            end
            % Ensure that each struct in the array has the necessary fields
            requiredFields = {};
            switch (obj.detType)
                case 'disk'
                    requiredFields = {'radius'};
                otherwise
                    error('icnna:data:core:lightDetector:set_params:InvalidParameterValue',...
                        ['Unknown detector type ' val '.']);
            end

            if ~isempty(requiredFields) && ~all(isfield(val, requiredFields))
                error('icnna:data:core:lightDetector:set_params:MissingFields', ...
                      ['The list of parameters (fields) does not ' ...
                      'match the expected list of parameters for ' ...
                      'the current detector type']);
            end

          %Copy only the relevant recognised fields and ignore the rest.
          switch (obj.detType)
              case 'disk'
                  obj.params.radius = double(val.radius); %[radius] of the disk
              otherwise
                  error('icnna:data:core:lightDetector:set_params:InvalidParameterValue',...
                      ['Unknown source type ' val '.']);
          end

      end

          %Retrieves the object |response|
      function res = get.response(obj)
            % Getter for |response|:
            %   Returns the light detector spectral response.
            %
            % Usage:
            %   res = obj.response;  % Retrieve spectral response of the detector
            %                        % e.g. UV-VIS-NIR all at 1 (100% efficiency)
            %                        % [200 1; 1400 1]
            %
            %% Output
            % res - double[kx2]
            %       Spectral response or quantum efficiency of the detector normalized
            %       to 1 (100%). The first column are wavelengths in [nm] and the
            %       second column is the detector efficiency at each wavelength.
            %       Missing wavelengths will be interpolated/extrapolated if requested.
            %
          res = obj.response;
      end
          %Sets the object |response|
      function obj = set.response(obj,val)
            % Setter for |response|:
            %   Sets the light detector spectral response
            %
            % Usage:
            %   obj.response = [200 1; 1400 1]; % Set the spectral
            %                                   %response to UV-VIS-NIR
            %                                   %all at 1 (100% efficiency)
            %
            %% Input parameters
            %
            % val - double[kx2]
            %       Spectral response or quantum efficiency of the detector normalized
            %       to 1 (100%). The first column are wavelengths in [nm] and the
            %       second column is the detector efficiency at each wavelength.
            %       Missing wavelengths will be interpolated/extrapolated if requested.
            %
            %% Output
            %
            % obj - @icnna.data.core.lightDetector
            %   The updated object
            %
          obj.response =  val;
      end

          %Retrieves the object |powerGain|
      function res = get.powerGain(obj)
            % Getter for |powerGain|:
            %   Returns the gain of the light detector.
            %
            %   A gain 0 indicates no increase or decrease in
            %   signal strength or amplitude.
            %
            %
            % Usage:
            %   res = obj.powerGain;  % Retrieve the detector gain in [dB]
            %
            %% Output
            % res - double.
            %       Relative amplification of the detector in [dB].
            %       Strictly speaking, the gain may come not from the detector itself,
            %       but from some amplifier/attenuator placed in front of the
            %       detector.
            %
          res = obj.powerGain;
      end
          %Sets the object |powerGain|
      function obj = set.powerGain(obj,val)
            % Setter for |powerGain|:
            %   Sets the relative amplification of the detector in [dB].
            %
            % Usage:
            %   obj.response = 0; % Set a neutral gain (no increase or
            %                     % decrease in power)
            %
            %% Input parameters
            %
            % val - double.
            %       Relative amplification of the detector in [dB].
            %       Strictly speaking, the gain may come not from the detector itself,
            %       but from some amplifier/attenuator placed in front of the
            %       detector.
            %
            %% Output
            %
            % obj - @icnna.data.core.lightDetector
            %   The updated object
            %
          obj.powerGain =  val;
      end



    end


end
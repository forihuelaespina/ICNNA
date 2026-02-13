classdef lightSource < icnna.data.core.optode
% icnna.data.core.lightSource - A light source or emitter
%
% A light source or emitter.
%
% Together with icnna.data.core.lightDetector they form the optode
% pairs forming a channel.
%
%
%% Remarks
%
% Somewhat loosely inspired by MCX "src" component, but there are
% differences. In MCX the source contains the information of its
% switching pattern (e.g. initTime 't0' and time step for time resolved
% 'dt') whereas in ICNNA that is tracked by the @icnna.data.core.dutyCycle.
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
%   -- Inherited properties from @icnna.data.core.identifiableObject
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - (Since v1.3.1) Char array. By default is empty 'lightSource0001'.
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
%   .srcType - Enum. Default is 'pencil'.
%       The following types are available at the moment.
%
%  srctype      | Description                  
%  -------------+------------------------------
%  "pencil"     | Single-directional beam      
%  "isotropic"  | Omnidirectional point source 
%  "cone"       | Directional cone beam        
%  "gaussian"   | Gaussian beam profile        
%  "planar"     | Planar source emitting in a direction.
%  "pattern"    | Custom spatial pattern
%  "disk"       | Circular disk source
%  "rectangle"  | Rectangular source
%  "line"       | Line source
%  "area"       | Area source
%  "slit"       | Slit-shaped source
%  "bessel"     | Bessel beam 
%  "lambertian" | Lambertian emitter
%  "custom"     | User-defined source
%
%   Each source type may have a different set of parameters. See |param|
%
%   .param - Struct. Default is empty.
%       A list of parameters describing the light source. The list of
%       fields depends on the source type |srcType|
%
%  srctype      | param fieldname | Meaning
%  -------------+-----------------+---------------------------------
%  "pencil"     | N/A             | Emits photons in |direction|
%  -------------+-----------------+---------------------------------
%  "isotropic"  | N/A             | Emits uniformly in all directions
%  -------------+-----------------+---------------------------------
%  "cone"       | angle           | Half-angle of the emission cone (in degrees)
%  -------------+-----------------+---------------------------------
%  "gaussian"   | beam_radius     | standard deviation of beam profile
%  -------------+-----------------+---------------------------------
%  "planar"     | width           | size of the beam
%               | height          | size of the beam
%               | focal_length    | convergence of the beam
%  -------------+-----------------+---------------------------------
%  "pattern"    | pattern_id      | predefined emission pattern
%  -------------+-----------------+---------------------------------
%  "disk"       | radius          | radius of the disk
%  -------------+-----------------+---------------------------------
%  "rectangle"  | width           | width of the rectangle
%               | height          | height of the rectangle
%  -------------+-----------------+---------------------------------
%  "line"       | length          | length of the line
%  -------------+-----------------+---------------------------------
%  "area"       | width           | similar to rectangle
%               | height          | similar to rectangle
%  -------------+-----------------+---------------------------------
%  "slit"       | width           | width of the slit
%  -------------+-----------------+---------------------------------
%  "bessel"     | order           | beam order
%               | radius          | beam radius
%  -------------+-----------------+---------------------------------
%  "lambertian" | angle           | angular spread
%  -------------+-----------------+---------------------------------
%  "custom"     | Variable        | Depends on implementation;
%               |                 | Requires external pattern or function
%  -------------+-----------------+---------------------------------
%
%
%      IMPORTANT: Changing the srcType resets the param to default values.
%
%% Dependent properties
%
%   N/A
%
%% Methods
%
% Type methods('icnna.data.core.lightSource') for a list of methods
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
% 11-Apr-2025: FOE
%   + File and class created. UNFINISHED
%
% 27-Oct-2025: FOE
%   + Finished the first draft of the class.
%
%
% 5-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%   * No need to update classVersion as this classVersion
%     of ICNNA has not yet been released and this is the first
%     version including this class.params, ergo, no harm done.
%   + Improved comments
%   + Improved verification of |params| setting.
%   + |direction| is now a column vector for consistency.
%   + |direction| split into |direction2D| and |direction3D|
%   for consistency.
%
% 10-Dec-2025: FOE
%   + Support for |directon2D| and |direction3D| is now inherited
%   from @icnna.data.core.optode.
%
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        srcType(1,:) char {mustBeMember(srcType,{'pencil','isotropic', ...
                            'cone','gaussian', 'planar', 'pattern', ...
                            'disk', 'rectangle', 'line', 'area', 'slit', ...
                            'bessel', 'lambertian', 'custom'})} = 'pencil';
        params(1,1) struct = struct; %List of parameters for the srcType. See list above.
    end


    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj = lightSource(varargin)
            %Constructor for class @icnna.data.core.lightSource
            %
            % obj=icnna.data.core.lightSource() creates a default lightSource.
            % obj=icnna.data.core.lightSource(obj2) acts as a copy constructor
            %
            %

            obj@icnna.data.core.optode();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            obj.srcType = 'pencil'; %May seems redundant given the
                                  %initialization above, but this
                                  %ensures that also |params| is
                                  %initialized correctly.
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.lightSource')
                obj = varargin{1};
                return;
            else
                error(['icnna:data:core:lightSource:lightSource:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
        end
    end




    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods

      %Retrieves the object |srcType|
      function res = get.srcType(obj)
            % Getter for |srcType|:
            %   Returns the light source type,
            %
            % Refer to the class documentation for the available
            % types.
            %
            % Usage:
            %   res = obj.srcType;  % Retrieve light source type, e.g. 'pencil'
            %
            %% Output
            % res - string
            %   The light source type
            %
          res = obj.srcType;
      end
      %Sets the object |srcType|
      function obj = set.srcType(obj,val)
            % Setter for |srcType|:
            %   Sets the light source type,
            %
            % Refer to the class documentation for the available
            % types.
            %
            % Setting the light source type reset the companion parameters
            % in |params|.
            %
            %   Throws an error if the source type does not match
            % any of the recognised source types.
            %
            % Usage:
            %   obj.srcType = 'pencil';  % Assign new source type 'pencil'
            %
            % Error handling:
            %   - Input must be a char[] (enum)
            %
            %% Input parameters
            %
            % val - char[] (enum)
            %   A recognized light source type.
            %
            %% Output
            %
            % obj - @icnna.data.core.lightSource
            %   The updated object
            %
          obj.srcType =  lower(val);
          %...and reset the parameters
          tmp = struct;
          switch lower(val)
              case {'pencil','isotropic'}
                  %Do nothing
              case 'cone'
                  tmp.angle = 15; %Half-angle of the emission cone (in degrees)
              case 'gaussian'
                  tmp.beam_radius = 1; %standard deviation of beam profile
              case 'planar'
                  tmp.width  = 1;
                  tmp.height = 1;
                  tmp.focal_length = 1;
              case 'pattern'
                  tmp.pattern_id = 0; %[pattern_id]
              case 'disk'
                  tmp.radius = 1; %[radius] of the disk
              case 'rectangle'
                  %dimensions of the rectangle
                  tmp.width  = 1;
                  tmp.height = 1;
              case 'line'
                  tmp.length = 1; %[length] of the line
              case 'area'
                  %dimensions of the area
                  tmp.width  = 1;
                  tmp.height = 1;
              case 'slit'
                  tmp.width  = 1; %[width] of the slit
              case 'bessel'
                  tmp.order  = 1; %Beam order
                  tmp.radius = 1; %Beam radius
              case 'lambertian'
                  tmp.angle = 180; %angular spread
              case 'custom'
                  %Do nothing. Depends on implementation; Requires external pattern or function
              otherwise
                  error('icnna:data:core:lightSource:set_srcType:InvalidParameterValue',...
                      ['Unknown source type ' val '.']);
          end
          obj.params = tmp;
      end





      %Retrieves the the additional parameters |params| of the light source
      function res = get.params(obj)
            % Getter for |params|:
            %   Get the additional |params| of a light source,
            %
            % Refer to the class documentation for a full list of
            % parameters for each |srcType|
            %
            % Usage:
            %   res = obj.params;  % Retrieve light source parameters
            %
            %% Output
            % res - Struct.
            %       A list of parameters describing the light source.
            %       The list of fields depends on the source type |srcType| 
            %
          res = obj.params;
      end
      %Sets the object |params|
      function obj = set.params(obj,val)
            % Setter for |params|:
            %   Sets the additional |params| of a light source,
            %
            %   Throws an error if the provided list of parameters
            % does not match the expected list of parameters for they
            % current light source type in |srcType|.
            %
            % Usage:
            %   obj.params = struct(...);  % Assign new list of |params|
            %
            % Error handling:
            %   - Input must be a struct
            %   - List of fields must match the required list of 
            % parameters for they current light source type in |srcType|.
            %   - Parameter values ought to be type castable to they
            % expected type for the paramter, e.g. width for source type
            % 'rectangular' is double.
            %
            %
            %% Input parameters
            %
            % val - struct
            %    The additional |params| of a light source.
            %   Each field is a different parameter. For the
            %   full list of parameters and their types, please
            %   refer to the class documention.
            %
            %% Output
            %
            % obj - @icnna.data.core.lightSource
            %   The updated object
            %

            % ---- Validate input --------------------------------------
            % Ensure the input is a struct array with the correct fields.
            if ~isstruct(val)
                error('icnna:data:core:lightSource:set_params:InvalidValue',...
                      'Val is expected to be a struct.');
            end
            % Ensure that each struct in the array has the necessary fields
            requiredFields = {};
            switch (obj.srcType)
                case {'pencil','isotropic'}
                    %Do nothing
                    requiredFields = {};
                case 'cone'
                    requiredFields = {'angle'};
                case 'gaussian'
                    requiredFields = {'beam_radius'};
                case 'planar'
                    requiredFields = {'width','height','focal_length'};
                case 'pattern'
                    requiredFields = {'pattern_id'};
                case 'disk'
                    requiredFields = {'radius'};
                case 'rectangle'
                    requiredFields = {'width','height'};
                case 'line'
                    requiredFields = {'length'};
                case 'area'
                    requiredFields = {'width','height'};
                case 'slit'
                    requiredFields = {'width'};
                case 'bessel'
                    requiredFields = {'order','radius'};
                case 'lambertian'
                    requiredFields = {'angle'};
                case 'custom'
                    requiredFields = {};
                otherwise
                    error('icnna:data:core:lightSource:set_params:InvalidParameterValue',...
                        ['Unknown source type ' val '.']);
            end

            if ~isempty(requiredFields) && ~all(isfield(val, requiredFields))
                error('icnna:data:core:lightSource:set_params:MissingFields', ...
                      ['The list of parameters (fields) does not ' ...
                      'match the expected list of parameters for ' ...
                      'the current source type']);
            end

          %Copy only the relevant recognised fields and ignore the rest.
          switch (obj.srcType)
              case {'pencil','isotropic'}
                  %Do nothing
              case 'cone'
                  obj.params.angle = double(val.angle); %Half-angle of the emission cone (in degrees)
              case 'gaussian'
                  obj.params.beam_radius = double(val.beam_radius); %standard deviation of beam profile
              case 'planar'
                  obj.params.width  = double(val.width);
                  obj.params.height = double(val.height);
                  obj.params.focal_length = double(val.focal_length);
              case 'pattern'
                  obj.params.pattern_id = double(val.pattern_id); %[pattern_id]
              case 'disk'
                  obj.params.radius = double(val.radius); %[radius] of the disk
              case 'rectangle'
                  %dimensions of the rectangle
                  obj.params.width  = double(val.width);
                  obj.params.height = double(val.height);
              case 'line'
                  obj.params.length = double(val.length); %[length] of the line
              case 'area'
                  %dimensions of the area
                  obj.params.width  = double(val.width);
                  obj.params.height = double(val.height);
              case 'slit'
                  obj.params.width  = double(val.width);
              case 'bessel'
                  obj.params.order  = double(val.order); %Beam order
                  obj.params.radius = double(val.radius); %Beam radius
              case 'lambertian'
                  obj.params.angle  = double(val.angle); %angular spread
              case 'custom'
                  obj.params = val; %Depends on implementation; Requires external pattern or function
              otherwise
                  error('icnna:data:core:lightSource:set_params:InvalidParameterValue',...
                      ['Unknown source type ' val '.']);
          end

      end


    end


end
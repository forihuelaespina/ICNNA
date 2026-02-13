classdef optode < icnna.data.core.identifiableObject
% icnna.data.core.optode - Either a light source or a detector
%
% Available since ICNNA v1.4.0
%
% According to the fNIRS glossary, an optode is the distal end of
% an fNIRS system which interfaces with the surface of the tissue
% being measured. Optodes can contain a single source (source optode),
% a single detector (detector optode), or a source accompanied by a
% short-separation detector.
%
%
%% Remarks
%
% Somewhat loosely inspired by MCX "src" component.
%
%
%% Known subclasses
%
%   icnna.data.core.lightSource
%   icnna.data.core.lightDetector
%
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. default is 1.
%       A numerical identifier.
%   .name - Char array. By default is 'Optode0001'.
%       A name for the optode. 
%
%   -- Public properties
%   .nominalLocation - @icnna.data.core.referenceLocation
%       The nominal (ideal/intended) 2D/3D location where
%       the optode is located. This in turn keeps track of
%       the positioning system and associated landmark
%       if any.
%   .actualLocation - @icnna.data.core.referenceLocation
%       The actual (reeal/observed) 2D/3D location where
%       the optode is located. This in turn keeps track of
%       the positioning system and associated landmark
%       if any.
%   .direction2D - 2x1 double. Vector. Default is [0; 1]
%       The 2D direction vector of photon emission/detection. To be
%       used with location2D.
%   .direction3D - 3x1 double. Vector. Default is [0; 0; 1]
%       The 3D direction vector of photon emission/detection. To be
%       used with loaction3D.
%
%
%% Methods
%
% Type methods('icnna.data.core.condition') for a list of methods
% 
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.lightSource, icnna.data.core.lightDetector
%


%% Log
%
%   + Class available since ICNNA v1.4.0
%
% 8-Jul-2025: FOE
%   + File and class created.
%
% 10-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%   * No need to update classVersion as this classVersion
%     of ICNNA has not yet been released and this is the first
%     version including this class.params, ergo, no harm done.
%   + Improved comments
%   + Added support for direction 2D and 3D.
%
% 13-Dec-2025: FOE
%   + Added property |positioningSystem|.
%
% 21-Dec-2025: FOE
%   + Properties |positioningSystem|, |location2D| and
%   |location3D| are now "absorbed" under an @icnna.data.core.referenceLocation
%   which further adds support for an associated |landmark|.
%   + Split support for nominal and actual locations.
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties
        nominalLocation(1,1) icnna.data.core.referenceLocation = icnna.data.core.referenceLocation();
        actualLocation(1,1)  icnna.data.core.referenceLocation = icnna.data.core.referenceLocation();
        direction2D(2,1) double {mustBeNumeric} = [0; 1]; % The 2D direction vector of photon emission/detection.
        direction3D(3,1) double {mustBeNumeric} = [0; 0; 1]; % The 3D direction vector of photon emission/detection.
    end
    

    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=optode(varargin)
            %Constructor for class @icnna.data.core.optode
            %
            % obj=icnna.data.core.optode() creates a default object.
            % obj=icnna.data.core.optode(obj2) acts as a copy constructor
            %
            % 
            % Copyright 2025
            % @author: Felipe Orihuela-Espina
            %
            
            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.optode')
                obj=varargin{1};
                return;
            else
                error(['icnna:data:core:optode:optode:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
        end
    end



    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods


        %Retrieves the |nominalLocation| of the optode
        function val = get.nominalLocation(obj)
            % Getter for |nominalLocation|:
            %   Returns the |nominalLocation| where the optode is ideally located.
            %
            % Usage:
            %   res = obj.nominalLocation;  % Retrieve the optode nominal location
            %
            %% Output
            % res - icnna.data.core.referenceLocation
            %   The nominal position where the optode is located. 
            %
            val = obj.nominalLocation;
        end
        %Sets the |nominalLocation| of the optode
        function obj = set.nominalLocation(obj,val)
            % Setter for |nominalLocation|:
            %   Sets the |nominalLocation| in which the optode is ideally located.
            %
            % The nominal location is an @icnna.data.core.referenceLocation
            %            
            %
            % Usage:
            %   obj.nominalLocation = icnna.data.core.referenceLocation()   % Assign a new |nominalLocation|
            %
            %
            %% Input parameters
            %
            % val - icnna.data.core.referenceLocation
            %   The position where the optode is ideally located.
            %
            %% Output
            %
            % obj - @icnna.data.core.optode
            %   The updated object
            %
            obj.nominalLocation = val;
        end


        %Retrieves the |actualLocation| of the optode
        function val = get.actualLocation(obj)
            % Getter for |actualLocation|:
            %   Returns the |actualLocation| where the optode is truly located.
            %
            % Usage:
            %   res = obj.actualLocation;  % Retrieve the optode real location
            %
            %% Output
            % res - icnna.data.core.referenceLocation
            %   The real position where the optode is located. 
            %
            val = obj.actualLocation;
        end
        %Sets the |actualLocation| of the optode
        function obj = set.actualLocation(obj,val)
            % Setter for |actualLocation|:
            %   Sets the |actualLocation| in which the optode is truly located.
            %
            % The real location is an @icnna.data.core.referenceLocation
            %            
            %
            % Usage:
            %   obj.actualLocation = icnna.data.core.referenceLocation()   % Assign a new |actualLocation|
            %
            %
            %% Input parameters
            %
            % val - icnna.data.core.referenceLocation
            %   The position where the optode is truly located.
            %
            %% Output
            %
            % obj - @icnna.data.core.optode
            %   The updated object
            %
            obj.actualLocation = val;
        end


      %Retrieves the |direction2D| of the optode
      function res = get.direction2D(obj)
            % Getter for |direction2D|:
            %   Returns the |direction2D| in which the optode is
            % pointing.
            %
            % Usage:
            %   res = obj.direction2D;  % Retrieve the 2D directional vector
            %
            %% Output
            % res - double[2x1] Column vector
            %   2D directional vector in which the optode is pointing, 
            %
          res = obj.direction2D;
      end
      %Sets the |direction2D| in which the optode is pointing.
      function obj = set.direction2D(obj,val)
            % Setter for |direction2D|:
            %   Sets the |direction2D| in which the optode is pointing.
            %
            % The direction is a 2D column vector.
            %            %
            % Usage:
            %   obj.direction2D = [0; -1];  % Assign new |direction2D|
            %
            % Error handling:
            %   - Input must be a 2D (column) vector
            %
            %% Input parameters
            %
            % val - double[2x1]
            %   The 2D directional vector of the optode.
            %
            %% Output
            %
            % obj - @icnna.data.core.optode
            %   The updated object
            %
          obj.direction2D =  val;
      end

      %Retrieves the |direction3D| of the optode
      function res = get.direction3D(obj)
            % Getter for |direction3D|:
            %   Returns the |direction3D| in which the optode is
            % pointing.
            %
            % Usage:
            %   res = obj.direction3D;  % Retrieve the optode 3D directional vector
            %
            %% Output
            % res - double[3x1] Column vector
            %   3D directional vector in which the optode is pointing, 
            %
          res = obj.direction3D;
      end
      %Sets the |direction3D| in which the optode is pointing.
      function obj = set.direction3D(obj,val)
            % Setter for |direction3D|:
            %   Sets the |direction3D| in which the optode is pointing.
            %
            % The direction is a 3D column vector.
            %
            % Usage:
            %   obj.direction3D = [0; 0; -1];  % Assign new |direction3D|
            %
            % Error handling:
            %   - Input must be a 3D (column) vector
            %
            %% Input parameters
            %
            % val - double[3x1]
            %   The 3D directional vector of the optode.
            %
            %% Output
            %
            % obj - @icnna.data.core.optode
            %   The updated object
            %
          obj.direction3D =  val;
      end






    end


end

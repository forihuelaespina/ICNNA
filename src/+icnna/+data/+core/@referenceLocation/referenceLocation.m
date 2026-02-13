classdef referenceLocation < icnna.data.core.identifiableObject
% icnna.data.core.referenceLocation - A spatial reference location or landmark
%
% A name holder to refer to some spatial 2D/3D location. This location
% can be with respect to some standard positioning system or free.
%
% This class also supports the definition of montages by providing
% support to model an individual sampling location. See class
% @icnna.data.core.montage.
%
%
%% Remarks
%
% This class is somewhat equivalent to .snirf probe landmarks but this
% is not attached to the evolution of the .snirf format
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
%   .name - Char array. Default is 'referenceLocation0001'
%       The referenceLocation name.
%
%   -- Public properties
%   .positioningSystem - Char array. Default is 'none'
%       The surface positioning system used for reference if any (value
%       'none' indicates a free reference location not associated
%       with any standard positioning system). Exemplary
%       systems are '10/20', 'UI 10/10', etc
%   .landmark - char[]. Default is empty.
%       The associated landmark in the positioning system if any, e.g.
%       'Cz'.
%   .location2D - double[2x1]. Default is [0 0].
%       A 2x1 column vector of 2D location of the reference location.
%   .location3D - double[3x1]. Default is [0 0 0].
%       A 3x1 column vector of 3D location of the reference location.
%
%   The class makes no effort to control whether the 2D/3D locations
%   are consistent e.g. the first two coordinates of the 3D locations
%   being coincident, or truly have any relation to a claimed
%   positioning system, nor to whether the location is expressed in
%   any specific spatial units or are normalized.
%
%% Methods
%
% Type methods('icnna.data.core.referenceLocation') for a list of methods
%
%
% Copyright 2025
% Author: Felipe Orihuela-Espina
%
% See also icnna.data.core.nirsProbeset, icnna.data.snirf.probe
%



%% Log
%
%   + Class available since ICNNA v1.4.0
%
% 4-Dec-2025: FOE
%   + File and class created.
%
%
% 13-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%   * No need to update classVersion as this classVersion
%     of ICNNA has not yet been released and this is the first
%     version including this class.params, ergo, no harm done.
%   + Improved comments
%
% 21-Dec-2025: FOE
%   + Added property landmark.
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        positioningSystem(1,:) char = 'none'; %The surface positioning system used for reference if any
        landmark(1,:) char = ''; %The associated landmark in the positioning system if any, e.g. % 'Cz'.
        location2D(2,1) double = zeros(2,1); %2D location of the reference location.
        location3D(3,1) double = zeros(3,1); %3D location of the reference location.
    end


    

    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=referenceLocation(varargin)
            %Constructor for class @icnna.data.core.referenceLocation
            %
            % obj=icnna.data.core.referenceLocation() creates a default object.
            % obj=icnna.data.core.referenceLocation(obj2) acts as a copy constructor
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
            elseif isa(varargin{1},'icnna.data.core.referenceLocation')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.referenceLocation:referenceLocation:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end
    end



    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods
            %Retrieves the object |positioningSystem|
        function val = get.positioningSystem(obj)
            % Getter for |positioningSystem|:
            %   Returns the |positioningSystem| of the reference location.
            %
            % Usage:
            %   res = obj.positioningSystem;  % Retrieve the positioning system of the reference location
            %
            %% Output
            % res - char[].
            %   The positioning system of the reference location or 'none'
            %   if the location refers to a free coordinate system.
            %
            val = obj.positioningSystem;
        end
            %Sets the object |positioningSystem|
        function obj = set.positioningSystem(obj,val)
            % Setter for |positioningSystem|:
            %   Sets the |positioningSystem| of the reference location.
            %
            %
            % Usage:
            %   obj.positioningSystem = '10/20';  % Set the positioning system to '10/20'
            %
            %% Input parameters
            %
            %  val - char[]
            %   The new positioning system e.g. '10/20'. Use 'none'
            % if the location refers to a free coordinate system.
            %
            %% Output
            %
            % obj - @icnna.data.core.referenceLocation
            %   The updated object
            %
            %
            obj.positioningSystem = val;
        end

            %Retrieves the object |landmark|
        function val = get.landmark(obj)
            % Getter for |landmark|:
            %   Returns the associated |landmark| within the positioning
            % system of the reference location.
            %
            % Usage:
            %   res = obj.landmark;  % Retrieve the landmark
            %
            %% Output
            % res - char[].
            %   The associated |landmark| within the positioning system
            %   of the reference location, if any.
            %
            val = obj.landmark;
        end
            %Sets the object |landmark|
        function obj = set.landmark(obj,val)
            % Setter for |landmark|:
            %   Sets the |landmark| of the reference location.
            %
            %
            % Usage:
            %   obj.landmark = 'Cz';  % Set the landmark to 'Cz'
            %
            %% Input parameters
            %
            %  val - char[]
            %   The new associated |landmark| e.g. 'Cz' within the
            % positioning system.
            %
            %% Output
            %
            % obj - @icnna.data.core.referenceLocation
            %   The updated object
            %
            %
            obj.landmark = val;
        end

        %Retrieves the |location2D| of the reference location
        function val = get.location2D(obj)
            % Getter for |location2D|:
            %   Returns the |location2D| of the reference location.
            %
            % Usage:
            %   res = obj.direction2D;  % Retrieve the reference location in 2D
            %
            %% Output
            % res - double[2x1] Column vector
            %   2D vector in which the reference location located. 
            %
           val = obj.location2D;
        end
        %Sets the |location2D| of the reference location
        function obj = set.location2D(obj,val)
            % Setter for |location2D|:
            %   Sets the |location2D| of the reference location.
            %
            % The location is a 2D column vector.
            %            
            %
            % Usage:
            %   obj.location2D = [0; -1];  % Assign new |location2D|
            %
            % Error handling:
            %   - Input must be a 2D (column) vector
            %
            %% Input parameters
            %
            % val - double[2x1]
            %   The 2D location of the reference location.
            %
            %% Output
            %
            % obj - @icnna.data.core.referenceLocation
            %   The updated object
            %
            obj.location2D = val;
        end


        %Retrieves the |location3D| of the reference location
        function val = get.location3D(obj)
            % Getter for |location3D|:
            %   Returns the |location3D| of the reference location.
            %
            % Usage:
            %   res = obj.direction3D;  % Retrieve the reference location in 3D
            %
            %% Output
            % res - double[3x1] Column vector
            %   3D vector in which the reference location is located. 
            %
            val = obj.location3D;
        end
        %Sets the |location3D| of the reference location
        function obj = set.location3D(obj,val)
            % Setter for |location3D|:
            %   Sets the |location3D| of the reference location.
            %
            % The location is a 3D column vector.
            %            
            %
            % Usage:
            %   obj.location3D = [0; -1; 1]   % Assign new |location3D|
            %
            %
            % Error handling:
            %   - Input must be a 3D (column) vector
            %
            %% Input parameters
            %
            % val - double[3x1]
            %   The 3D location of the reference location.
            %
            %% Output
            %
            % obj - @icnna.data.core.referenceLocation
            %   The updated object
            %
            obj.location3D = val;
        end




    end


end


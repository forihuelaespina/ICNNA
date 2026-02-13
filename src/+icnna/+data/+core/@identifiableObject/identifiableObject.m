classdef identifiableObject
% icnna.data.core.identifiableObject - An object with an id and a name
%
% Most object in ICNNA have an id and a name or tag. This class intends
%to provide a parent class to support this behaviour.
%
%% Remarks
%
% Class inspired by Java's Object class in the sense that in Java, all
%classes descend from the class Object.
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       It is strongly recommended that subclasses implement
%       their own classVersion and do not rely on the inherited
%       value of this attribute. This permits subclasses to
%       evolve their own class version separatedly from the
%       superclass.
%
%   -- Public properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. Default is 'object0001'.
%       A name for the object. 
%
%
%% Known subclasses
%
%   icnna.data.core.condition
%
%
%
%% Methods
%
% Type methods('icnna.data.core.identifiableObject') for a list of methods
% 
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also 
%


%% Log
%
%   + Class available since ICNNA v1.3.1
%
% 9-Jul-2025: FOE
%   + File and class created. Originally created as a handle class.
%
%
% -- ICNNA v1.4.0
%
% 5-Dec-2025: FOE
%   + Reengineered as regular value (non-handle) class.
%	+ Class version - Updated to 1.1
%	+ Method copy() removed.
%	+ Improved some comments
%

    properties (Constant, Access=private)
        classVersion(1,:) char = '1.1'; %Read-only. Object's class version.
    end

    properties
        id(1,1) uint32 = 1; %Numerical identifier to make the object identifiable.
        name(1,:) char = 'object0001'; %Name of the condition
    end
    

    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj = identifiableObject(varargin)
            %A icnna.data.core.identifiableObject class constructor
            %
            % obj = icnna.data.core.identifiableObject() creates a default object.
            %
            % obj = icnna.data.core.identifiableObject(obj2) acts as a copy constructor
            %
            % 
            % Copyright 2025
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.identifiableObject')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.identifiableObject:identifiableObject:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end
	end



    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods

        %Retrieves the object |id|
        function res = get.id(obj)
            % Getter for |id|:
            %   Returns the |id| property.
            %
            % The numerical identifier of the object.
            %
            % Usage:
            %   res = obj.id;  % Retrieves the numerical identifier of the object.
            %
            %% Output
            % res - uint32
            %   The numerical identifier of the object.
            %
            res = obj.id;
        end
        %Sets the object |id|
        function obj = set.id(obj,val)
            % Setter for |id|:
            %   Sets the |id| property.
            %
            % The numerical identifier of the object.
            %
            % Usage:
            %   obj.id = 3;  % Set the |id| to 3.
            %
            %% Input parameters
            %
            % val - uint32
            %   The new |id|.
            %
            %% Output
            %
            % obj - @icnna.data.core.identifiableObject
            %   The updated object
            %
            %
            obj.id =  val;
        end


        %Retrieves the |name| of the object
        function val = get.name(obj)
            % Getter for |name|:
            %   Returns the |name| property.
            %
            % The name of the object.
            %
            % Usage:
            %   res = obj.name;  % Retrieves the object's name.
            %
            %% Output
            % res - char[]
            %   The name of the object.
            %
            val = obj.name;
        end
        %Sets the |name| of the object
        function obj = set.name(obj,val)
            % Setter for |name|:
            %   Sets the |name| property.
            %
            % The name of the object.
            %
            % Usage:
            %   obj.name = 'Foo';  % Set the |name| to 'Foo'.
            %
            %% Input parameters
            %
            % val - char[]
            %   The new |name|.
            %
            %% Output
            %
            % obj - @icnna.data.core.identifiableObject
            %   The updated object
            %
            %
            obj.name = val;
        end



    end


end

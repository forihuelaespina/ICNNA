classdef identifiableObject < handle
% icnna.data.core.identifiableObject - An object with an id and a name
%
% Most object in ICNNA have an id and a name or tag. This class intends
%to provide a parent class to support this behaviour.
%
% +====================================================================+
% | Beware of *collateral effects*!                                    |
% | @icnna.data.core.identifiableObject are handles.                   |
% | This breaks ICNNA traditional approach of using ONLY pass-by-value |
% | parameters and has the increased risk of collateral effects, but   |
% | of course relying on pass-by-reference should speed up a lot       |
% | of operations substantially.                                       |
% +====================================================================+
%
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
%   .id - uint32. default is 1.
%       A numerical identifier.
%   .name - Char array. By default is empty 'object0001'.
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
%   + File and class created.
%
%

    properties (Constant, Access=private)
        classVersion(1,:) char = '1.0'; %Read-only. Object's class version.
    end

    properties
        id(1,1) uint32 = 1; %Numerical identifier to make the object identifiable.
        name(1,:) char = 'object0001'; %Name of the condition
    end
    
    methods
        function obj=identifiableObject(varargin)
            %A icnna.data.core.identifiableObject class constructor
            %
            % obj=icnna.data.core.identifiableObject() creates a default object.
            %
            % obj=icnna.data.core.identifiableObject(obj2) acts as a copy constructor
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





        %Gets/Sets
        function res = get.id(obj)
        %Gets the object |id|
            res = obj.id;
        end
        function set.id(obj,val)
        %Sets the object |id|
            obj.id =  val;
        end


        function val = get.name(obj)
        %Retrieves the |name| of the condition
            val = obj.name;
        end
        function set.name(obj,val)
        %Sets the |name| of the condition
            obj.name = val;
        end



    end


end

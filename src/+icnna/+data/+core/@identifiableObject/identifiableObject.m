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
%   .classVersion - Char array. (Read only. Immutable instance property)
%       The class version of the object
%       Taken from the property default and stamped per object at the
%       object's construction time, but carried out through serialization.
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
% Copyright 2025-26
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
%
% -- ICNNA v1.4.2
%
% 18-Jun-2026: FOE
%
% + Improvement: Silent typecasting now yields warning.
% MATLAB does some silent typecasting e.g.
%
%   obj.id = 'A'
%
% will work with no error or warning resulting
%in:
%
%   obj.id = 65
%
% ...and viceversa: obj.name = [65 67] => obj.name = 'AC'
%
% While there is no need for forbidding this behaviour, but
% silent typecasting is dangerous and can be difficult to
% debug. Hence, I'm now adding warnings for (known) silent
% typecasting.
%
% 23-Jun-2026: FOE
%
% + Improvement: Property |id| is now verified to be non NaN.
%       HOWEVER watch out!! The validator 'mustBeNonNan' is NOT
%       sufficient to do the job as the validator will be called
%       only after the implicit type cast, e.g. uint32(NaN), i.e.
%       the real question the validator is asking is whether
% 
%           "Is the stored value NaN?"
%
%       Since in the particular case of uint32, this can never
%       be the case, then the validator fails to do its job as
%       by then it is too late because the input has already
%       been converted to 0. This is not a problem for properties
%       of type double though; In case of double, the typecasting
%       double(NaN) still yields NaN. Moreover, even if one tries to check
%       for isnan "manually" in the set_id method, than will still
%       occur AFTER the implicit typecasting, so again too late.
%       So in order to verify that the input is not NaN (and hence
%       no side effects e.g. setting the id to 0 inadvertently),
%       I need to check for NaN in the intercepted subasgn method.
%       Nevertheless, it is good to keep the validator (even if
%       useless) for the sake of clarity.
% 
%
% -- ICNNA v1.4.2.1
%
% 9-Jul-2026: FOE
%   + Data integrity fix: |classVersion| changed from Constant
%   (non-serializable) to immutable (serializable, but still
%   read-only). The .classVersion() accessor method and all call
%   site remain unchanged. Class version also remains 1.1.
%
%   NOTE: MATLAB does NOT serialize Constant properties, so on reload
%     an old file, a loaded (not freshly created) object would
%     not recovered the value of such property when the object was saved
%     but instead, will load the current class default, e.g. the
%     current class version. This silently defeats runtime versions
%     guards and can potentially lead to inconsistencies and ultimately
%     errors. Instead, immutable properties ARE serialized yet they
%     remain read-only, hence they will recover properly upon loading
%     and still remain safe against tampering and forging attempts.
%
% 
%

    properties (SetAccess = immutable, GetAccess = private)
        classVersion(1,:) char = '1.1'; %Read-only. Object's class version.
    end

    properties
        id(1,1) uint32 {mustBeNonNan} = 1; %Numerical identifier to make the object identifiable.
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
            if isnan(val)
                error('icnna:data:core:identifiableObject:set_id:MustBeNonNaN',...
                    'Value must be non NaN.');
            end
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


    methods

        %Catch the silent typecastings by intercepting the assignment
        function obj = subsasgn(obj, s, val)
            % Intercept simple .property assignments to warn on implicit typecast
            if numel(s) == 1 && strcmp(s.type, '.')
                switch s.subs
                    case 'id'
                        if isnumeric(val) && isscalar(val)
                            % Safe to call numeric functions here
                            if isnan(val)
                                error('icnna:data:core:identifiableObject:set_id:mustBeNonNan', ...
                                    ['NaN is not a valid value for |' s.subs '|.']);
                            elseif val ~= floor(val)
                                warning('icnna:data:core:identifiableObject:set_id:ImplicitTypecast', ... 
                                    ['Value assigned to |' s.subs '| is not integer. ' ...
                                     'MATLAB will attempt implicit typecasting.']);
                            end
                        else
                            % Not numeric or not scalar
                            warning('icnna:data:core:identifiableObject:set_id:ImplicitTypecast', ... 
                                ['Value assigned to |' s.subs '| is not numeric or not scalar. ' ...
                                 'MATLAB will attempt implicit typecasting.']);
                        end

                    case 'name'
                        if ~ischar(val)
                            warning('icnna:data:core:identifiableObject:set_name:ImplicitTypecast', ...
                                ['Value assigned to |' s.subs '| is not a char array. ' ...
                                 'MATLAB will attempt implicit typecasting.']);
                        end
                end
            end
            obj = builtin('subsasgn', obj, s, val);
        end

    end


end

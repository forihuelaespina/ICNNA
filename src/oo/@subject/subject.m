classdef subject
%Class Subject
%
%A subject represent an person or animal that has taken part
%in a experiment.
%
%A subject can hold any number of experimental measurements
%or sessions.
%
%% Properties
%
%   .id - A numerical identifier.
%   .name - The subject's name
%   .age - The subject age.
%   .sex - The subject sex; 'M'ale/'F'emale/'U'nknown
%   .hand - Handedness 'L'eft/'R'ight/'A'mbidextrous/'U'nknown
%   .sessions - Set of measurement sessions.
%
%% Dependent properties
%
%   .nSessions - Number of sessions.
%
%% Methods
%
% Type methods('subject') for a list of methods
%
%
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
% See also experiment, session
%



%% Log
%
% File created: 17-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Improved some comments.
%   + Added dependent properties for;
%       nSessions
%   + Deprecated methods
%       getNSessions
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
        name(1,:) char='Subj0001'; %The subject's name
        age(1,1) double {mustBeInteger, mustBeNonnegative}; %The subject age
        sex(1,:) char {mustBeMember(sex,{'M','F','U'})}='U'; %The subject sex
        hand(1,:) char {mustBeMember(hand,{'L','R','A','U'})}='U'; %The subject's handedness
    end

    properties (SetAccess=private, GetAccess=private)
        sessions=cell(1,0); %Collection of sessions recorded for the subject
    end

    properties (Dependent)
      nSessions % Number of sessions.
    end

    methods
        function obj=subject(varargin)
            %SUBJECT Subject class constructor
            %
            % obj=subject() creates a default subject with ID equals 1.
            %
            % obj=subject(obj2) acts as a copy constructor of subject
            %
            % obj=subject(id) creates a new subject with the given
            %   identifier (id). The name of the subject is initialised
            %   to 'SubjXXXX' where is the id preceded with 0.
            %
            % obj=subject(id,name) creates a new subject with the given
            %   identifier (id) and name.
            %
            % @Copyright 2008
            % date: 17-Apr-2008
            % Author: Felipe Orihuela-Espina
            %
            % See also assertInvariants, experiment, session
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'subject')
                obj=varargin{1};
                return;
            else
                obj.id = varargin{1};
                obj.name = ['Subj' num2str(obj.id,'%04i')];
                if (nargin>1)
                    if (ischar(varargin{2}))
                        obj.name = varargin{2};
                    else
                        error('Name is not a string.');
                    end
                end
            end
            assertInvariants(obj);
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findSession(obj,id);
    end



    methods

      %Getters/Setters

      function res = get.id(obj)
         %Gets the object |id|
         res = obj.id;
      end
      function obj = set.id(obj,val)
         %Sets the object |id|
         obj.id =  val;
      end


    function res = get.name(obj)
         %Gets the object |name|
         res = obj.name;
      end
      function obj = set.name(obj,val)
         %Sets the object |name|
         obj.name =  val;
      end

    function res = get.age(obj)
         %Gets the object |age|
         res = obj.age;
      end
      function obj = set.age(obj,val)
         %Sets the object |age|
         obj.age =  val;
      end


    function res = get.sex(obj)
         %Gets the object |sex|
         res = obj.sex;
      end
      function obj = set.sex(obj,val)
         %Sets the object |sex|
         obj.sex =  val;
      end

    function res = get.hand(obj)
         %Gets the object |hand|
         res = obj.hand;
      end
      function obj = set.hand(obj,val)
         %Sets the object |hand|
         obj.hand =  val;
      end

    
      function res = get.nSessions(obj)
         %Gets the object |nSessions|
         res = length(obj.sessions);
      end
    
    
    end

end


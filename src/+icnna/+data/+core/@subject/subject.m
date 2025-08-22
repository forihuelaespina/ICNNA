classdef subject < icnna.data.core.experimentalUnit
%icnna.data.core.subject - A subject acting as a experimental unit in a experiment
%
%
%A subject represent an person or animal that has taken part
% in a experiment and that forms an @icnna.data.core.experimentalUnit on
% its own.
%
% Although this class is intended to supersede class @subject, but
%there are two major differences;
%
%   * @icnna.data.core.subject are now a subclass of
% @icnna.data.core.experimentalUnit.
%   * @icnna.data.core.subject no longer keeps track of the @sessions
% to which they are associated. Instead, that is now controlled from the
% @icnna.data.core.experiment.
%
%
%% Properties
%
%   -- Inherited 
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. Default is 'Subject0001'
%       The experimental unit name. Often this will be the
%       alphanumerical identifier given to the experimental unit in order
%       to blind its origin and not the person's name.
%   .metaData - Struct. Default is empty.
%       User defined metadata.
%
%
%   -- Local metadata (these can be directly accessed as if they were
%       first level properties)
%   .dob  - datetime. Default is today.
%       Date of birth.
%   .sex  - Char. Default is 'U'
%       The subject sex; 'M'ale/'F'emale/'U'nknown
%   .hand - Char. Default is 'U'
%       Handedness 'L'eft/'R'ight/'A'mbidextrous/'U'nknown
%
%% Dependent properties
%
%   .age - Int. Read only. The subject age in years.
%
%% Methods
%
% Type methods('subject') for a list of methods
%
%
% Copyright 2025
% Author: Felipe Orihuela-Espina
%
% See also icnna.data.core.experimentalUnit
%



%% Log
%
%   + Class available since ICNNA v1.3.1
%
% 29-Jun-2025: FOE
%   + File and class created. Reused some code from predecessor class
%   @subject
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    % properties %(SetAccess=private, GetAccess=private)
    %     dob(1,1) datetime = datetime("now"); %The subject date of birth
    %     sex(1,1) char {mustBeMember(sex,{'M','F','U'})} = 'U'; %The subject sex
    %     hand(1,1) char {mustBeMember(hand,{'L','R','A','U'})} = 'U'; %The subject's handedness
    % end

    properties (Dependent)
      dob
      sex
      hand
      age % Read only
    end

    methods
        function obj=subject(varargin)
            %ICNNA.DATA.CORE.SUBJECT icnna.data.core.subject class constructor
            %
            % obj=icnna.data.core.subject() creates a default subject
            %   with ID equals 1.
            %
            % obj=icnna.data.core.subject(obj2) acts as a copy constructor  
            %   of subject
            %
            % @Copyright 2025
            % Author: Felipe Orihuela-Espina
            %
            % See also
            %

            obj = obj@icnna.data.core.experimentalUnit(varargin{:});
            obj.name = 'Subject0001';
            obj.dob  = datetime('today');
            obj.sex  = 'U';
            obj.hand = 'U';

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'subject')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.subject:subject:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end
    end
    


    methods

      %Getters/Setters

      function res = get.dob(obj)
         %Gets the object |dob|
         %
         % The subject's date of birth
         res = obj.metadata.dob;
      end
      function obj = set.dob(obj,val)
         %Sets the object |dob|
         %
         %  The subject's date of birth.
         obj.metadata.dob = datetime(val);
      end


    function res = get.sex(obj)
         %Gets the object |sex|
         res = obj.metadata.sex;
      end
      function obj = set.sex(obj,val)
         %Sets the object |sex|
         assert(ismember(val,{'M','F','U'}),...
                'icnna:data:core:subject:set_sex:InvalidParameterValue',...
                'Invalid parameter value. Sex must be ''M'', ''F'' or ''U''.')
         obj.metadata.sex =  val;
      end

    function res = get.hand(obj)
         %Gets the object |hand|
         res = obj.metadata.hand;
      end
      function obj = set.hand(obj,val)
         %Sets the object |hand|
         assert(ismember(val,{'L','R','A','U'}),...
                'icnna:data:core:subject:set_sex:InvalidParameterValue',...
                'Invalid parameter value. Sex must be ''L'', ''R'', ''A'' or ''U''.')
         obj.metadata.hand =  val;
      end






        %-- Dependent properties



    function res = get.age(obj)
         %Gets the object |age|
         today = datetime('today'); % Current date
         tmpDelta = between(obj.dob, today,'years');
         res = floor(calyears(tmpDelta));
      end


    
    end

end


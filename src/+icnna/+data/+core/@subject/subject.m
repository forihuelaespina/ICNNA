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
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. Default is 'subject0001'
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
%   .sex  - Char. (Enum) Default is 'U'
%       The subject sex; 'M'ale/'F'emale/'U'nknown
%   .hand - Char. (Enum) Default is 'U'
%       Handedness 'L'eft/'R'ight/'A'mbidextrous/'U'nknown
%
%% Dependent properties
%
%   .age - Int. Read only.
%       The subject age in years.
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
%
% -- ICNNA v1.4.0
%
% 13-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Class version - Updated to 1.1
%   + Improved comments
%

    properties (Constant, Access=private)
        classVersion = '1.1'; %Read-only. Object's class version.
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
    
    
    

    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=subject(varargin)
            %Constructor for class @icnna.data.core.subject
            %
            % obj=icnna.data.core.subject() creates a default subject
            % obj=icnna.data.core.subject(obj2) acts as a copy constructor  
            %
            % @Copyright 2025
            % Author: Felipe Orihuela-Espina
            %
            % See also
            %

            obj = obj@icnna.data.core.experimentalUnit(varargin{:});
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];

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
    


    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods
         %Retrieves the object |dob|
      function res = get.dob(obj)
            % Getter for |dob|:
            %   Returns the metadata |dob|.
            %
            % The subject's date of birth (dob).
            %
            % Usage:
            %   res = obj.dob;  % Retrieve the subject's date of birth (dob)
            %
            %% Output
            % res - datetime.
            %   The subject's date of birth (dob).
            %
         res = obj.metadata.dob;
      end
         %Sets the object |dob|
      function obj = set.dob(obj,val)
            % Setter for |dob|:
            %   Sets the subject's date of birth |dob|.
            %
            %
            % Usage:
            %   obj.dob = datetime('11-Mar-1985');  % Set subject's date of birth
            %
            %% Input parameters
            %
            %  val - datetime
            %  The subject's date of birth.
            %
            %% Output
            %
            % obj - @icnna.data.core.subject
            %   The updated object
            %
         obj.metadata.dob = datetime(val);
      end


         %Retrieves the object |sex|
      function res = get.sex(obj)
            % Getter for |sex|:
            %   Returns the metadata |sex|.
            %
            % The subject's sex.
            %
            % Usage:
            %   res = obj.sex;  % Retrieve the subject's sex
            %
            %% Output
            % res - char.
            %   The subject's sex.
            %
         res = obj.metadata.sex;
      end
         %Sets the object |sex|
      function obj = set.sex(obj,val)
            % Setter for |sex|:
            %   Sets the subject's |sex|.
            %
            %
            % Usage:
            %   obj.sex = 'F';  % Set subject's sex to female.
            %
            %% Input parameters
            %
            %  val - char
            %  The subject's sex; 'M'ale/'F'emale/'U'nknown
            %
            %% Output
            %
            % obj - @icnna.data.core.subject
            %   The updated object
            %
         assert(ischar(val),...
                'icnna:data:core:subject:set_sex:InvalidParameterValue',...
                'Invalid parameter value. Sex must be of type char.')
         assert(ismember(val,{'M','F','U'}),...
                'icnna:data:core:subject:set_sex:InvalidParameterValue',...
                'Invalid parameter value. Sex must be ''M'', ''F'' or ''U''.')
         obj.metadata.sex =  val;
      end

         %Retrieves the object |hand|
      function res = get.hand(obj)
            % Getter for |hand|:
            %   Returns the metadata |hand|.
            %
            % The subject's handedness.
            %
            % Usage:
            %   res = obj.hand;  % Retrieve the subject's handedness
            %
            %% Output
            % res - char.
            %   The subject's handedness.
            %
         res = obj.metadata.hand;
      end
         %Sets the object |hand|
      function obj = set.hand(obj,val)
            % Setter for |hand|:
            %   Sets the subject's |hand|.
            %
            %
            % Usage:
            %   obj.hand = 'R';  % Set subject's handedness to right-handed.
            %
            %% Input parameters
            %
            %  val - char
            %  The subject's handedness; 'L'eft/'R'ight/'A'mbidextrous/'U'nknown
            %
            %% Output
            %
            % obj - @icnna.data.core.subject
            %   The updated object
            %
         assert(ischar(val),...
                'icnna:data:core:subject:set_hand:InvalidParameterValue',...
                'Invalid parameter value. Hand must be of type char.')
         assert(ismember(val,{'L','R','A','U'}),...
                'icnna:data:core:subject:set_hand:InvalidParameterValue',...
                'Invalid parameter value. Hand must be ''L'', ''R'', ''A'' or ''U''.')
         obj.metadata.hand =  val;
      end






        %-- Dependent properties



         %Retrieves the object |age|
      function res = get.age(obj)
            % Getter for |age|:
            %   Returns the metadata |age|.
            %
            % The subject's age in years.
            %
            % Usage:
            %   res = obj.age;  % Retrieve the subject's age in years.
            %
            %% Output
            % res - int
            %   The subject's age.
            %
         today = datetime('today'); % Current date
         tmpDelta = between(obj.dob, today,'years');
         res = floor(calyears(tmpDelta));
      end


    
    end

end


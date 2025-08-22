classdef experimentalUnit
% icnna.data.core.experimentalUnit - An experimental unit in an experiment
%
% Experimental units are the simplest discernible statistical units from
%which experimental observations are sampled. What constitutes an
%experimental unit depends on the experiment, but common examples
%will be a subject in a regular neuroimaging experiment or a dyad in a
%hypercscanning experiment.
%
% Experimental units are grouped in an experiment depending on the
%experimental treatments they receive (see @icnna.data.core.experimentalGroup).
%
%% Remarks
%
% Note that the @icnna.data.core.experimentalUnit has no knowledge
%of the @icnna.data.core.experimentalGroup(s) to which it has been
%allocated. This is traced in a @icnna.data.core.experiment.
%
%% Properties
%
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. Default is 'ExperimentalUnit0001'
%       The experimental unit name. Often this will be the
%       alphanumrical identifier given to the experimental unit to
%       blind its origin.
%   .metadata - Struct. Default is empty.
%       User defined metadata as a struct.
%
%% Known subclasses
%
% icnna.data.core.subject - A subject participating in an experiment
%       constituting an @icnna.data.core.experimentalUnit on its own.
%
%% Methods
%
% Type methods('experimentalUnit') for a list of methods
%
%
% Copyright 2025
% Author: Felipe Orihuela-Espina
%
% See also experiment, session
%



%% Log
%
%   + Class available since ICNNA v1.3.1
%
% 29-Jun-2025: FOE
%   + File and class created.
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        id(1,1) uint32 {mustBeInteger, mustBeNonnegative} = 1; %Numerical identifier to make the object identifiable.
        name(1,:) char = 'ExperimentalUnit0001'; %The unit's name
        metadata(1,1) struct = struct(); %User defined metadata
    end

    properties (SetAccess=private, GetAccess=private)
        sessions=cell(1,0); %Collection of sessions recorded for the subject
    end

    methods
        function obj=experimentalUnit(varargin)
            %EXPERIMENTALUNIT Experimental unit class constructor
            %
            % obj=icnna.data.core.experimentalUnit() creates a default
            %   experimentalUnit with ID equals 1.
            %
            % obj=icnna.data.core.experimentalUnit(obj2) acts as a copy
            %   constructor of icnna.data.core.experimentalUnit
            %
            % @Copyright 2025
            % Author: Felipe Orihuela-Espina
            %
            % See also
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.experimentalUnit')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.experimentalUnit:experimentalUnit:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
        end
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


     function res = get.metadata(obj)
         %Gets the object |metadata|
         res = obj.metadata;
      end
      function obj = set.metadata(obj,val)
         %Sets the object |metadata|
         obj.metadata =  val;
      end


    
    end

end


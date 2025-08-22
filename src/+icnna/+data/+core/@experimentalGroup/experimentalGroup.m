classdef experimentalGroup
% icnna.data.core.experimentalGroup - An group of experimental units in
%   an experiment.
%
% Experimental groups are sets of experimental units (see
%@icnna.data.core.experimentalUnit) that share the same experimental
%treatment being applied to them.
% 
% Together with class @icnna.data.core.session,
% @icnna.data.core.experimentalGroup class "unfolds" the class
% @session/@sessionDefinition in its two components;
%   * the treatment allocation i.e. the group, and
%   * the sampling time i.e. the session.
% 
%
%% Remarks
%
% Note that the @icnna.data.core.experimentalGroup has no knowledge
%of the @icnna.data.core.experimentalUnit(s) allocated to it. This is
%traced at the level of a @icnna.data.core.experiment.
%
%% Properties
%
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. Default is 'ExperimentalGroup0001'
%       The experimental group name e.g. 'Control'|'Intervention', etc
%   .metadata - Struct. Default is empty.
%       User defined metadata as a struct.
%
%% Methods
%
% Type methods('experimentalGroup') for a list of methods
%
%
% Copyright 2025
% Author: Felipe Orihuela-Espina
%
% See also icnna.data.core.experiment, icnna.data.core.experimentalUnit,
%   @icnna.data.core.session
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
        name(1,:) char = 'ExperimentalGroup0001'; %The unit's name
        metadata(1,1) struct = struct(); %User defined metadata
    end

    properties (SetAccess=private, GetAccess=private)
        sessions=cell(1,0); %Collection of sessions recorded for the subject
    end

    methods
        function obj=experimentalUnit(varargin)
            %ICNNA.DATA.CORE.EXPERIMENTALUNIT Experimental unit class constructor
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
                error(['icnna.data.core.experimentalGroup:experimentalGroup:InvalidNumberOfParameters' ...
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


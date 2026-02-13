classdef experimentalGroup < icnna.data.core.identifiableObject
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
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - (Since v1.3.1) Char array. By default is 'experimentalGroup0001'.
%       A name for the experimental group. 
%
%   -- Other private properties
%   .sessionDefinitions - double[]. Default is empty.
%       PLACEHOLDER - INCOMPLETE
%       List of sessions definitions |id| associated to this
%       experimentalGroup
%       
%
%   -- Public properties
%   .metadata - struct. Default is empty.
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
% -- ICNNA v1.3.1
%
% 25-Jun-2025: FOE 
%   + Class is now identifiable.
%   + Class version - Updated to 1.1
%   + Improved comments.
%   + Added (separate) method classVersion
%   + Reformulated placeholder for sessionDefinitions.
%

    properties (Constant, Access=private)
        classVersion = '1.1'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        metadata(1,1) struct = struct(); %User defined metadata
    end

    properties (SetAccess=private, GetAccess=private)
        sessionDefinitions(:,1) uint32 = []; %Ids of sessions definitions
                            %associated with this group recorded
                            %from the @icnna.data.core.experimentalUnit.
    end

    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=experimentalGroup(varargin)
            %Constructor for class @icnna.data.core.experimentalGroup.
            %
            % obj=icnna.data.core.experimentalUnit() creates a default
            %   experimentalUnit.
            % obj=icnna.data.core.experimentalUnit(obj2) acts as a copy
            %   constructor.
            %
            % @Copyright 2025
            % Author: Felipe Orihuela-Espina
            %
            % See also
            %

            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.experimentalGroup')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.experimentalGroup:experimentalGroup:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
        end
    end
    

    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods
         %Gets the object |metadata|
     function res = get.metadata(obj)
            % Getter for |metadata|:
            %   Returns the list of |metadata| property.
            %
            % Usage:
            %   res = obj.metadata;  % Retrieve the metadata
            %
            %% Output
            % res - struct
            %   User defined metadata as a struct.
            %
         res = obj.metadata;
      end
         %Sets the object |metadata|
      function obj = set.metadata(obj,val)
            % Setter for |metadata|:
            %   Sets the |metadata| property.
            %
            % Usage:
            %   tmp = struct(...)
            %   obj.metadata = tmp;  % Set the metadata tmp
            %
            %% Input parameters
            %
            % val - struct
            %   User defined metadata as a struct.
            %
            %% Output
            %
            % obj - @icnna.data.core.timeline
            %   The updated object
            %
            %
         obj.metadata =  val;
      end


    
    end

end


classdef experimentalUnit < icnna.data.core.identifiableObject
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
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - (Since v1.3.1) Char array. By default is 'experimentalUnit0001'.
%       A name for the experimental group. 
%
%   -- Other private properties
%   .sessions - double[]. Default is empty.
%       PLACEHOLDER - INCOMPLETE
%       List of sessions |id| recorded from this experimentalUnit
%
%   -- Public properties
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
% -- ICNNA v1.3.1
%
% 25-Jun-2025: FOE 
%   + Class is now identifiable.
%   + Class version - Updated to 1.1
%   + Improved comments.
%   + Added (separate) method classVersion
%   + Reformulated placeholder for sessions.
%

    properties (Constant, Access=private)
        classVersion = '1.1'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        metadata(1,1) struct = struct(); %User defined metadata
    end

    properties (SetAccess=private, GetAccess=private)
        sessions=cell(1,0); %Collection of sessions recorded for the subject
    end

    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=experimentalUnit(varargin)
            %Constructor for class @icnna.data.core.experimentalUnit
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
            elseif isa(varargin{1},'icnna.data.core.experimentalUnit')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.experimentalUnit:experimentalUnit:InvalidNumberOfParameters' ...
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


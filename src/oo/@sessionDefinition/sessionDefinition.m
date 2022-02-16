%Class sessionDefinition
%
%A session definition encapsulates information about the session
%structure, but holds no data.
%
%It helps to ensure that session structure is respected across
%subjects within a experiment. This is critical for the proper
%identification of the sessions during the analysis stage.
%
%By including a sessionDefinition, the session is forced to comply
%with the definition structure. Data may still be missing, but
%it will not be possible to add wrong data by mistake, plus also
%it will be possible to ensure that the dataSource IDs are homogenously
%defined across subjects in a experiment as long as they share the same
%sessionDefinition.
%
%
%% Properties
%
%   .id - A numerical identifier for the session.
%   .name - The session's logical name. By default it is
%       defined as 'SessionXXXX' where XXXX is the ID.
%   .description -  A short description of the session. Empty by default.
%   .sources - A list of the sources of data recorded
%       during the session. Basically an cell array of dataSources.
%       This attribute defines not only which sources of data will
%       be collected during the session, but also which
%       dataSource IDs will be assigned to them.
%       Empty by default, i.e. no dataSource allowed.
%
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('sessionDefinition') for a list of methods
% 
% Copyright 2008
% date: 10-Jul-2008
% Author: Felipe Orihuela-Espina
%
% See also experiment, dataSourceDefinition, session, subject
%

%% Log
%
% 13-February-2022 (ESR): Get/Set Methods created in sessionDefinition
%   + The methods are added with the new structure. All the properties have 
%   the new structure (id,name and description)
%   + The new structure enables new MATLAB functions
%   + The properties are arranged alphabetically on Get/Set methods.
%

classdef sessionDefinition
    properties (SetAccess=private, GetAccess=private)
        id=1;
	    name='Session0001';
        description='';
        sources=cell(1,0);
    end
    
    methods
        function obj=sessionDefinition(varargin)
        %SESSIONDEFINITION SessionDefinition class constructor
        %
        % obj=sessionDefinition() creates a default sessionDefinition
        %   with ID equals 1.
        %
        % obj=sessionDefinition(obj2) acts as a copy constructor 
        %   of sessionDefinition.
        %
        % obj=sessionDefinition(id) creates a new sessionDefinition
        %   with the given identifier (id). The name of the
        %   sessionDefinition is initialised
        %   to 'SessionXXXX' where is the id preceded with 0.
        %
        % obj=sessionDefinition(id,name) creates a new sessionDefinition
        %   with the given identifier (id) and name.
        %
        % 
        % Copyright 2008
        % date: 10-Jul-2008
        % Author: Felipe Orihuela-Espina
        %
        % See also sessionDefinition, experiment, dataSourceDefinition
        %
        if (nargin==0)
            %Keep default values
        elseif isa(varargin{1},'sessionDefinition')
            obj=varargin{1};
            return;
        else
            obj=set(obj,'ID',varargin{1});
            obj.name=['Session' num2str(obj.id,'%04i')];
            if (nargin>1)
                obj=set(obj,'Name',varargin{2});
            end
        end
        assertInvariants(obj);
        end
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %Description
        function val = get.description(obj)
            % The method is converted and encapsulated. 
            % obj is the sessionDefinition class
            % val is the value added in the object
            % get.description(obj) = Get the data from the sessionDefinition class
            % and look for the description object.
            val = obj.description;
        end
        function obj = set.description(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the sessionDefinition class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type
            if (ischar(val))
                obj.description = val;
            else
                error('Value must be a string');
            end
            
        end
        
        %ID
        function val = get.id(obj)
            val = obj.id;
        end
        function obj = set.id(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar
                obj.id = val;
            else
                error('Value must be a scalar natural/integer');
            end
        end
        
        %Name
        function val = get.name(obj)
            val = obj.name;
        end
        function obj = set.name(obj,val)
            if (ischar(val))
                obj.name = val;
            else
                error('Value must be a string');
            end
        end    
            
    end

    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findSource(obj,id);
    end
end


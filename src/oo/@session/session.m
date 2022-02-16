%Class session
%
%A session represent an experimental run. During this experimental
%run data might be collected from different sources or devices.
%
%
%A session must comply with its sessionDefinition at all times.
%See invariants for more details.
%
%
%% Properties
%
%   .definition - The sessionDefinition
%   .date - Data collection date
%   .sources - Set of source data for this session.
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('session') for a list of methods
% 
% Copyright 2008
% date: 17-Apr-2008
% Author: Felipe Orihuela-Espina
%
% See also subject, sessionDefinition, dataSource
%
%
%% Log
%
% 15-February-2022 (ESR): Get/Set Methods created in session
%   + The methods are added with the new structure. All the properties have 
%   the new structure (definition and date)
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside the session class on line 50.
%   + The Name, Description and ID properties are inside of
%   session class.
%   + All the properties are arranged alphabetically on Get/Set methods.
%
classdef session
    properties %(SetAccess=private, GetAccess=private)
        definition=sessionDefinition;
        date=date;
        sources=cell(1,0);
    end
    
    properties (Dependent)
        ID
        Name
        Description
    end
    
    methods
        function obj=session(varargin)
            %SESSION Session class constructor
            %
            % obj=session() creates a default session with ID equals 1.
            %
            % obj=session(obj2) acts as a copy constructor of session
            %
            % obj=session(definition) creates a new session with the
            %   indicated definition.
            %
            % obj=session(id) creates a new session with its
            %   definiton given the indicated
            %   identifier (id). The name of the session is initialised
            %   to 'SessionXXXX' where is the id preceded with 0.
            %   No sources of data are defined.
            %
            % obj=session(id,name) creates a new session with its
            %   definiton given the indicated
            %   identifier (id) and name. No sources of data are defined.
            %
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'session')
                obj=varargin{1};
                return;
            elseif isa(varargin{1},'sessionDefinition')
                obj.definition=varargin{1};
            else
                obj.definition=sessionDefinition(varargin{1});
                id=get(obj.definition,'ID');
                name=['Session' num2str(id,'%04i')];
                if (nargin>1)
                    if (ischar(varargin{2}))
                        name=varargin{2};
                    else
                        error('ICNA:session:session',...
                            'Name is not a string.');
                    end
                end
                obj.definition=set(obj.definition,'Name',name);
            end
            assertInvariants(obj);
        end
        
       %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %Definition
        function val = get.definition(obj)
            % The method is converted and encapsulated. 
            % obj is the session class
            % val is the value added in the object
            % get.definition(obj) = Get the data from the session class
            % and look for the definition object.
            val = obj.definition;
        end
        function obj = set.definition(obj, val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the session class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type.
            if (isa(val,'sessionDefinition'))
                obj.definition = val;
                IDList=getSourceList(obj.definition);
                warning('ICNA:session:set:sessionDefinition',...
                    ['Updating the definition may result in sources ' ...
                    'being removed.']);
                    nElements=length(obj.sources);
                for ii=nElements:-1:1
                    id=get(obj.sources{ii},'ID');

                    %Check that it complies with the definition
                    if ~(ismember(id,IDList))
                        %Remove this source
                        obj.sources(ii)=[];
                    elseif ~(strcmp(...
                            get(getSource(obj.definition,id),'Type'),...
                            get(obj.sources{ii},'Type')))
                        %Remove this source
                        obj.sources(ii)=[];
                    end
                end
    
            else
                error('Value must be a sessionDefinition');
            end
        end 
        
        %Date
        function val = get.date(obj)
            val = obj.date;
        end
        function obj = set.date(obj,val)
            obj.date=val;
        end
        
        %---------------------------------------------------------------->
        %Definition Dependent
        %Dependent properties do not store data. 
        %The value of a dependent property depends on some other value, 
        %such as the value of a nondependent property.
        
        %Dependent properties must define get-access methods () to 
        %determine a value for the property when the property is queried: 
        %get.id(obj)
        %For example: The id, name and description properties
        %dependent of definition property.
        
        %We create a dependent property on line 131
        %---------------------------------------------------------------->
        
        %Decription
        function val = get.Description (obj)
           val = get(obj.definition,'Description'); 
        end
        function obj = set.Description(obj,val)
            obj.definition = set(obj.definition,'Description',val);
        end
        
        %ID
        function val = get.ID(obj)
            val = get(obj.definition,'ID');
        end
        function obj = set.ID(obj,val)
            obj.definition = set(obj.definition,'ID',val);
        end
        
        %Name
        function val = get.Name(obj)
           val = get(obj.definition,'Name'); 
        end
        function obj = set.Name(obj,val)
            obj.definition = set(obj.definition,'Name',val);
        end
        
        
        
        
        
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Access=private)
        idx=findDataSource(obj,id);
    end
    
end

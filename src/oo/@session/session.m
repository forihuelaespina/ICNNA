classdef session
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
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also subject, sessionDefinition, dataSource
%



%% Log
%
% File created: 17-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Improved some comments.
%   + Added dependent properties for;
%       nDataSources
%   + Deprecated methods
%       getNDataSources
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        definition(1,1) sessionDefinition = sessionDefinition; %The sessionDefinition object
        date=date; % The session date
    end

    properties (SetAccess=private, GetAccess=private)
        sources=cell(1,0); %Collection of dataSources recorded during the session
    end

    properties (Dependent)
      nDataSources % Number of dataSources.
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
                tmpSessDef = obj.definition;
                name=['Session' num2str(tmpSessDef.id,'%04i')];
                if (nargin>1)
                    if (ischar(varargin{2}))
                        name=varargin{2};
                    else
                        error('ICNA:session:session',...
                            'Name is not a string.');
                    end
                end
                tmpSessDef.name =name;
                obj.definition = tmpSessDef;
            end
            assertInvariants(obj);
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Access=private)
        idx=findDataSource(obj,id);
    end
    
    methods

      %Getters/Setters

      function res = get.definition(obj)
         %Gets the object |definition|
         res = obj.definition;
      end
      function obj = set.definition(obj,val)
         %Sets the object |definition|
         obj.definition =  val;
      end


    function res = get.date(obj)
         %Gets the object |date|
         res = obj.date;
      end
      function obj = set.date(obj,val)
         %Sets the object |date|
         obj.date =  val;
      end

    
      function res = get.nDataSources(obj)
         %Gets the object |nDataSources|
         res = length(obj.sources);
      end
    
    
    end

end

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
classdef session
    properties (SetAccess=private, GetAccess=private)
        definition=sessionDefinition;
        date=date;
        sources=cell(1,0);
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
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Access=private)
        idx=findDataSource(obj,id);
    end
    
end

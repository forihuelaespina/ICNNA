classdef sessionDefinition
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
%% Dependent properties
%
%   .nDataSources - Number of data sources.
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('sessionDefinition') for a list of methods
% 
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
% See also experiment, dataSourceDefinition, session, subject
%



%% Log
%
% File created: 10-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Dependent property nSources is now explicitly declared as such. 
%   + Improved some comments.
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
	    name(1,:) char='Session0001'; % The session's logical name. 
        description(1,:) char ='';  %A short description of the data.
    end

    properties (SetAccess=private, GetAccess=private)
        sources=cell(1,0);
    end
    
    properties (Dependent)
        nDataSources
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
            obj.id = varargin{1};
            obj.name=['Session' num2str(obj.id,'%04i')];
            if (nargin>1)
                obj.name = varargin{2};
            end
        end
        assertInvariants(obj);
        end
    end

    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findSource(obj,id);
    end



    methods

      %Getters/Setters

      function res = get.id(obj)
         %Gets the object |id|
         res = obj.id;
      end
      function obj = set.id(obj,val)
         %Sets the object |id|
         obj.id = val;
      end


      function res = get.name(obj)
         %Gets the object |name|
         res = obj.name;
      end
      function obj = set.name(obj,val)
         %Sets the object |name|
         obj.name = val;
      end


      function res = get.description(obj)
         %Gets the object |description|
         res = obj.description;
      end
      function obj = set.description(obj,val)
         %Sets the object |description|
         obj.description = val;
      end



      function res = get.nDataSources(obj)
         %Sets the object |nDataSources|
         res = length(obj.sources);
      end




    end
end


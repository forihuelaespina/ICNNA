classdef dataSourceDefinition
%Class dataSourceDefinition
%
%A data source definition encapsulates information about a data source
%from which experimental data is going to be collected. The definition,
%does not hold any data.
%
%It helps to ensure that session structure is respected across
%subjects within a experiment. This is critical for the unique
%identification of the sessions and data sources during the#
%analysis stage.
%
%By using a dataSourceDefinition, the experiment can enforce
%data sources to be consistent across the different sessionsDefinitions.
%Data may still be missing, but it will not be possible to add
%wrong data by mistake.It will also ensure that the dataSource
%IDs are homogenously defined across sessionDefinition in a
%experiment.
%
%
%% Properties
%
%   .id - A numerical identifier for the dataSource.
%   .type - The type of the dataSource. See attribute 'Type'
%       on dataSource.
%             The type is a string that should correspond with
%         the name of an existing class (or subclass)
%         of structuredData. However this is not checked, 
%         it is left to the user responsability!
%   .deviceNumber - A number to identify the device. It helps
%       to disambiguating between two equal data sources.
%
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('dataSourceDefinition') for a list of methods
% 
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
% See also experiment, sessionDefinition, session, subject
%



%% Log
%
% File created: 21-Jul-2008
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
	    type(1,:) char=''; % The type of the dataSource. See attribute 'Type' on dataSource.
        deviceNumber(1,1) double {mustBeInteger, mustBeNonnegative}=1; % A number to identify the device. It disambiguates between two equal data sources. 
    end
    
    methods
        function obj=dataSourceDefinition(varargin)
        %DATASOURCEDEFINITION DataSourceDefinition class constructor
        %
        % obj=dataSourceDefinition() creates a default dataSourceDefinition
        %   with ID equals 1. Type is left generic (i.e. empty string).
        %
        % obj=dataSourceDefinition(obj2) acts as a copy constructor 
        %   of dataSourceDefinition.
        %
        % obj=dataSourceDefinition(id) creates a new dataSourceDefinition
        %   with the given identifier (id).
        %
        % obj=dataSourceDefinition(id,type) creates a new sessionDefinition
        %   with the given identifier (id) and type. The device number is
        %   set to 1.
        %
        % obj=dataSourceDefinition(id,type,deviceNumber) creates a new
        %   dataSourceDefintion with the given identifier (id), type and
        %   device number.
        %
        % 
        % Copyright 2008
        % date: 21-Jul-2008
        % Author: Felipe Orihuela-Espina
        %
        % See also experiment, sessionDefinition, session
        %
        if (nargin==0)
            %Keep default values
        elseif isa(varargin{1},'dataSourceDefinition')
            obj=varargin{1};
            return;
        else
            obj.id = varargin{1};
            if (nargin>1)
                obj.type = varargin{2};
            end
            if (nargin>2)
                obj.deviceNumber = varargin{3};
            end
        end
        %assertInvariants(obj);
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
         obj.id = val;
      end


      function res = get.type(obj)
         %Gets the object |type|
         res = obj.type;
      end
      function obj = set.type(obj,val)
         %Sets the object |type|
         obj.type = val;
      end


      function res = get.deviceNumber(obj)
         %Gets the object |deviceNumber|
         res = obj.deviceNumber;
      end
      function obj = set.deviceNumber(obj,val)
         %Sets the object |deviceNumber|
         obj.deviceNumber = val;
      end




    end


end
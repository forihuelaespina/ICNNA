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
% Copyright 2008
% date: 21-Jul-2008
% Author: Felipe Orihuela-Espina
%
% See also experiment, sessionDefinition, session, subject
%
classdef dataSourceDefinition
    properties (SetAccess=private, GetAccess=private)
        id=1;
	    type='';
        deviceNumber=1;
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
            obj=set(obj,'ID',varargin{1});
            if (nargin>1)
                obj=set(obj,'Type',varargin{2});
            end
            if (nargin>2)
                obj=set(obj,'DeviceNumber',varargin{3});
            end
        end
        %assertInvariants(obj);
        end
    end

end


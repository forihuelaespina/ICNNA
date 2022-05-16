%A data source represent a stream of collected data during a session
%and it is therefore inherently linked to a single raw data
%of a certain type coming from one single device. The raw data is the data
%as obtained from the measuring device (e.g. for NIRS is the light
%intensity recordings). This raw data is converted to a structured data
%(e.g. MBLL conversion to a nirs_neuroimage), to produce an
%easily manipulable stream of data.
%
%While the class rawData must be capable of producing at least
%a rudimentary structured version of the data, any
%number of structured data can be created from the original raw
%data by using different processing
%e.g. simple raw converted, fitted, averaged, detrended, etc...
%
%
%% The 'Type' attribute
%
% The dataSource class itself is blind to the underlying
%particularities of the data, and can accomodate any type
%of rawData and structuredData subclass. However, it ensures
%that all the structuredData when they exist, are of the
%same nature or kind (i.e. of the same class).
%
%In order to ensure this, a dynamic attribute 'Type'
%is calculated on the fly. This attribute type is a simple
%string, which is empty if no structuredData has been
%defined, or take the classname of the structuredData (or its
%instanciated subclass) when at least one structuredData
%has been defined.
%
%If the 'Type' is empty, then the dataSource will accept
%any particular structuredData. But if it is not empty, and
%hence at least one structuredData has been defined, then
%all new structuredData to be added must comply with the
%'Type', or in other words, they must be of the same type
%as the one already defined. This ensures that at any moment
%a dataSource only holds structuredData of a single class.
%
%To request the Type of the dataSource use:
%
%   get(obj,'Type')
%
%% Remarks
%
% If the raw data and the structured data are lock
%(see lock attribute)
%then reseting the raw data also deletes all present
%structured data!.
%
%Also with data being locked, no structured data are
%accepted unless, a raw data has already been defined.
%
%% Properties
%
%   .id - A numerical identifier.
%   .name - The source's descriptor
%   .deviceNumber - A device number to disambiguate in case
%       of recording data from two or more equal devices. 
%   .rawData - The experimental data recorded from one source
%   .lock - Lock raw and structured data. True by default
%   .activeStructured - A pointer (ID) to the currently active
%       structured data, or 0 if none exist.
%   .structured - Set of structured data for this source.
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('dataSource') for a list of methods
% 
%
%
%
% Copyright 2008-10
% @date: 17-Apr-2008
% @author: Felipe Orihuela-Espina
% @modified: 11-Nov-2010
%
% See also subject, session, rawData, structuredData
%

%% Log
%
% 1-Sep-2016 (FOE): Class created.
%
% 20-February-2022 (ESR): Get/Set Methods created in dataSource
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside of the dataSource class.
%
% 24-March-2022 (ESR): We change the following line of code of the 
%     set method of activeStructured: && ismember(val,getStructuredDataList(obj))
%   + With the new syntax all methods are forced to pass through the get and set.
%     ismember is the one that is chosen as active must be one that exists. However, 
%     by giving 0 then ismember does not allow the conditional to be met.
%     The solution is not to remove the condition because it removes the lock. 
%     This is solved by telling it that the value will be equal 0 
%     when the structuredData list is empty.
%     The solution of the code is as follows 
%     or(and( isempty(getStructuredDataList(obj)),val==0), ismember(val,getStructuredDataList(obj)) 
%
% 02-May-2022 (ESR): All classes must be public.
%   + With the new syntax all the processes are forced to enter from class 
%     to class, this is because we have the methods inside the classes and 
%     not outside of them. The method files of each set/get class are declared 
%     only to be called correctly.
%
% 5-May-2022 (ESR): Problem in the serialization process. 
%   + The cause of the problem is the new syntax because activeStructured 
%     gets the data from structured, however, this was empty so the 
%     serialization process gave problems. The solution is to interchange 
%     the position of the attributes because the code reading is in cascade form. 
%     Now with the solution the activeStructured can obtain data from 
%     structured because this structured is not empty. 
%
classdef dataSource
    properties %(SetAccess=private, GetAccess=private)
        id=1;
        name='DataSource0001';
        deviceNumber=1;
        rawData=[];
        lock=true;
        structured=cell(1,0);
        activeStructured=0; 
    end
    
    properties (Dependent)
        type
    end
    
    methods
        function obj=dataSource(varargin)
            %DATASOURCE dataSource class constructor
            %
            % obj=dataSource() creates a default dataSource with ID equals 1.
            %
            % obj=dataSource(obj2) acts as a copy constructor of dataSource
            %
            % obj=dataSource(id) creates a new dataSource with the given
            %   identifier (id). The name of the dataSource is initialised
            %   to 'DataSourceXXXX' where is the id preceded with 0.
            %
            % obj=dataSource(id,name) creates a new dataSource
            %   with the given identifier (id) and name.
            %
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'dataSource')
                obj=varargin{1};
                return;
            else
                obj=set(obj,'ID',varargin{1});
            end
            obj=set(obj,'Name',...
                    ['DataSource' num2str(get(obj,'ID'),'%04i')]);
            if (nargin>1)
                if (ischar(varargin{2}))
                    obj.name=varargin{2};
                else
                    error('Name is not a string.');
                end
            end
            assertInvariants(obj);
        end
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %activeStructured
        function val = get.activeStructured(obj)
            % The method is converted and encapsulated. 
            % obj is the DataSource class
            % val is the value added in the object
            % get.activeStuctured(obj) = Get the data from the dataSource class
            % and look for the activeStructured object.
            val = obj.activeStructured;
        end
        function obj = set.activeStructured(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the dataSource class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type

            if (isscalar(val) && (val==floor(val)) && (val>=0)...
                && (val<=length(obj.structured))...
                && or(and( isempty(getStructuredDataList(obj)),val==0), ismember(val,getStructuredDataList(obj)) ))
                
                obj.activeStructured = val;
            else
                error('Value must be a positive integer');
            end
        end
        
        %deviceNumber
        function val = get.deviceNumber(obj)
            val = obj.deviceNumber;
        end
        function obj = set.deviceNumber(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.deviceNumber = val;
            else
                error('Value must be a positive scalar natural/integer');
            end
        end
        
        %id
        function val = get.id(obj)
            val = obj.id;
        end
        function obj = set.id(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.id = val;
            else
                error('Value must be a positive scalar natural/integer');
            end
        end
        
        %lock
        function val = get.lock(obj)
            val = obj.lock;
        end
        function obj = set.lock(obj,val)
            obj.lock=true;
            if (~val) obj.lock=false; 
            end 
        end
        
        %name
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
        
        %rawData
        function val = get.rawData(obj)
            val = obj.rawData;
        end
        
        %Type
        function val = get.type(obj)
            %Find the type on the fly
            val='';
            if ~(isempty(obj.structured))
                val=class(obj.structured{obj.activeStructured});
            else
                %Try to guess it from the rawData if it has been defined.
                r=getRawData(obj);
                if ~isempty(r)
                    %fprintf(1,['Unable to establish dataSource type from structuredData. ' ...
                    %           'Trying\nto guess it from rawData.\n']);
                val=class(convert(r,'AllowOverlappingConditions',0));
                %Temporally allow for overlapping conditions to make less
                %restrictive.
                end
            end
        end
        
        
        
        
        
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findStructuredData(obj,id);
    end
    
end

classdef dataSource
%Class dataSource
%
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
%   .id - Scalar integer. A numerical identifier.
%   .name - String. The source's descriptor
%   .deviceNumber - A device number to disambiguate in case
%       of recording data from two or more equal devices. 
%   .rawData - A rawData object. The experimental data recorded from one source
%       * Prior to ICNNA v1.1.5 this was defaulted to empty []
%       * From ICNNA v1.2 this is defaulted to rawData_Snirf
%   .lock - Boolean. Lock raw and structured data. True by default
%   .activeStructured - Scalar integer. A pointer (ID) to the currently active
%       structured data, or 0 if none exist.
%   .structured - Cell array. Set of structured data for this source.
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
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also subject, session, rawData, structuredData
%



%% Log
%
% File created: 17-Apr-2008
% File last modified (before creation of this log): 11-Nov-2010
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Improved some comments.
%   + Added dependent properties for;
%       nStructuredData
%   + Deprecated methods
%       getNStructuredData
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
        name='DataSource0001'; %The dataSource's name
        deviceNumber=1; %A device number to disambiguate in case of recording data from two or more equal devices.
        rawData(1,1) rawData = rawData_Snirf(); % The experimental data recorded from one source
        lock(1,1) logical =true; % Lock raw and structured data.
        activeStructured(1,1) double {mustBeInteger, mustBeNonnegative}=0; % A pointer (ID) to the currently active @structuredData
    end


    properties (SetAccess=private, GetAccess=private)
        structured=cell(1,0);
    end
    
    properties (Dependent)
      type
      nStructuredData % Number of @structuredData
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
                obj.id = varargin{1};
            end
            obj.name= ['DataSource' num2str(obj.id,'%04i')];
            if (nargin>1)
                if (ischar(varargin{2}))
                    obj.name=varargin{2};
                else
                    error('Name is not a string.');
                end
            end
            assertInvariants(obj);
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findStructuredData(obj,id);
    end
    
    methods

      %Getters/Setters

      function res = get.id(obj)
         %Gets the object |id|
         res = obj.id;
      end
      function obj = set.id(obj,val)
         %Sets the object |id|
         obj.id =  val;
         assertInvariants(obj);
      end


    function res = get.name(obj)
         %Gets the object |name|
         res = obj.name;
      end
      function obj = set.name(obj,val)
         %Sets the object |name|
         obj.name =  val;
         assertInvariants(obj);
      end

    function res = get.deviceNumber(obj)
         %Gets the object |deviceNumber|
         res = obj.deviceNumber;
      end
      function obj = set.deviceNumber(obj,val)
         %Sets the object |deviceNumber|
         obj.deviceNumber =  val;
         assertInvariants(obj);
      end


    function res = get.rawData(obj)
         %Gets the object |rawData|
         res = obj.rawData;
      end
      function obj = set.rawData(obj,val)
         %Sets the object |rawData|
         obj.rawData =  val;
         assertInvariants(obj);
      end

    function res = get.lock(obj)
         %Gets the object |lock|
         res = obj.lock;
      end
      function obj = set.lock(obj,val)
         %Sets the object |lock|
         obj.lock =  val;
         assertInvariants(obj);
      end

    
    function res = get.activeStructured(obj)
         %Gets the object |activeStructured|
         res = obj.activeStructured;
      end
      function obj = set.activeStructured(obj,val)
         %Sets the object |activeStructured|
         obj.activeStructured =  val;
         %assertInvariants(obj);
      end

    
    function res = get.type(obj)
         %Gets the object |type|
         %Find the type on the fly
         res='';
         if ~(isempty(obj.structured))
             if (obj.activeStructured == 0)
                %While adding the first new structruedData, first the
                %structured data is added and then the activeStructured
                %is updated. In between these two operations,
                %obj.structured is no longer empty, but obj.activeStructured
                %is still pointing to 0. Hence, a direct call to:
                %
                % res=class(obj.structured{obj.activeStructured});
                %
                %...will fail. Instead, transiently access the first
                %entry of obj.structured
                res=class(obj.structured{1});
             else
                 %General case
                res=class(obj.structured{obj.activeStructured});
             end
         else
             %Try to guess it from the rawData if it has been defined.
             r=obj.rawData;
             if ~isempty(r)
                 %fprintf(1,['Unable to establish dataSource type from structuredData. ' ...
                 %           'Trying\nto guess it from rawData.\n']);
                 warning off
                 res=class(convert(r,'AllowOverlappingConditions',0));
                     %Temporally allow for overlapping conditions
                     %to make less restrictive.
                 warning on
             end
         end
      end

    
      function res = get.nStructuredData(obj)
         %Gets the object |nStructuredData|
         res = length(obj.structured);
      end
    
    
    end


end

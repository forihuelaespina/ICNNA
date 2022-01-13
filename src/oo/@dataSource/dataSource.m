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
classdef dataSource
    properties (SetAccess=private, GetAccess=private)
        id=1;
        name='DataSource0001';
        deviceNumber=1;
        rawData=[];
        lock=true;
        activeStructured=0;
        structured=cell(1,0);
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
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findStructuredData(obj,id);
    end
    
end

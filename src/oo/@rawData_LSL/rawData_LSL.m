%Class rawData_LSL
%
%A rawData_LSL represents the recorded data
%with Lab Streaming Layer (LSL) protocol
%during a session. In contrast to other rawData implementations
%rawData_LSL does not come necessarily from a single device,
%but in the LSL fashion can come from any number of devices.
%This is an important distinction, because the convert method
%can either produced a single structuredData or a whole session
%depending on the information contained in the file.
%
%This data is not yet converted to a structured data.
%
%
% Information about LSL can be found at:
%
% https://labstreaminglayer.readthedocs.io/info/intro.html
%
%
%% LSL datafile
%
% LSL export data to raw Extensible Data Format (XDF) file.
%
% The specification for the XDF files can be found here:
%
% https://github.com/sccn/xdf/wiki/Specifications
%
%
% 
%
%
%% Superclass
%
% rawData - An abstract class for holding raw data.
%
%
%% Properties
%
%This class has only 1 attribute; .data which holds the LSL
%recorded information.
%
% Following the LSL standard, upon loading the file (using the file
%importer load_xdf at https://github.com/sccn/xdf ), all data
%is loaded onto a cell array with one cell per data stream.
%
%  == The data
%   .data - The LSL cell array with one cell per data stream.
%
%
%% Methods
%
% Type methods('rawData_LSL') for a list of methods
% 
% Copyright 2021
% @date: 23-Aug-2021
% @author: Felipe Orihuela-Espina
%
% See also rawData, 
%




%% Log
%
% 23-Aug-2021 (FOE): 
%	File and class created.
%
% 13-February-2022 (ESR): Get/Set Methods created in rawData_LSL
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside the rawData_LSL class.
%
% 02-May-2022 (ESR): rawData_LSL class SetAccess=private, GetAccess=private) removed
%   + The access from private to public was commented because before the data 
%   did not request to enter the set method and now they are forced to be executed, 
%   therefore the private accesses were modified to public.
%

classdef rawData_LSL < rawData
    properties %(SetAccess=private, GetAccess=private)
        %  == The data
        data=[];
    end
 
    %properties (Constant=true, GetAccess=public)        
    %    DATA_TRIAL=1;
    %end
    
    methods    
        function obj=rawData_LSL(varargin)
            %RAWDATA_LSL RawData_LSL class constructor
            %
            % obj=rawData_LSL() creates a default
            %   rawData_LSL with ID equals 1.
            %
            % obj=rawData_LSL(obj2) acts as a copy constructor
            %   of rawData_LSL
            %
            % obj=rawData_LSL(id) creates a new rawData_LSL
            %   with the given identifier (id). The name of the
            %   rawData_LSL is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'rawData_LSL')
                obj=varargin{1};
                return;
            else
                set(obj,'ID',varargin{1});
            end
            description=['RawData' num2str(get(obj,'ID'),'%04i')];
            set(obj,'Description',description);
            %assertInvariants(obj);

        end
        
        %% %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %The data itself!!
        function val = get.data(obj)
            % The method is converted and encapsulated. 
            % obj is the rawData_LSL class
            % val is the value added in the object
            % get.data(obj) = Get the data from the rawData_LSL class
            % and look for the data object.
            val = obj.data;
        end
  
    end

end

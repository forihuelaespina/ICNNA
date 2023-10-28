classdef rawData_LSL < rawData
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
% Copyright 2021-23
% @author: Felipe Orihuela-Espina
%
% See also rawData, 
%




%% Log
%
% File created: 23-Aug-2021
% File last modified (before creation of this log): N/A
%
% 23-Aug-2021 (FOE): 
%	File and class created.
%
% 12-Oct-2021 (FOE): 
%   + Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Migrated for struct like access to attributes.
%



    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    
    properties (SetAccess=private, GetAccess=private)
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
                obj.id = varargin{1};
            end
            description=['RawData' num2str(obj.id,'%04i')];
            obj.description = description;
            %assertInvariants(obj);

        end
  
    end

end

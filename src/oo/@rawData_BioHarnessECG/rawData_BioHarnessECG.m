%Class rawData_BioHarnessECG
%
%A rawData_BioHarness represents the experimentally recorded data
%with a Zephyr BioHarness device during a Heart Rate monitoring
%session.
%
%Although, the Zephyr BioHarness device is also capable of recording
%other type of information, this class only holds the ECG data.
%
%
%% Superclass
%
% rawData - An abstract class for holding raw data.
%
%
%% Properties
%
%   .samplingRate - The sampling rate in [Hz]
%   .startTime - Absolute start time. A row date vector (6D);
%       [YY, MM, DD, HH, MN, SS]
%   .timestamps - Timestamps in milliseconds; relative to the absolute
%       start time
%   .data - The raw ECG data.
%  
%% Methods
%
% Type methods('rawData_BioHarnessECG') for a list of methods
%
%
% Copyright 2008
% date: 12-May-2008
% Author: Felipe Orihuela-Espina
%
% See also rawData
%
%% Log
%
% 17-February-2022 (ESR): Get/Set Methods created in rawData_BioHarnessECG
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside the rawData_BioHarnessECG class.
%

classdef rawData_BioHarnessECG < rawData
    properties (SetAccess=private, GetAccess=private)
        samplingRate=250;%in [Hz]
        startTime=datevec(date);
        timeStamps=zeros(0,1); %in milliseconds
        %The data itself!!
        data=zeros(0,1);%The raw ECG data.
    end
 
    methods    
        function obj=rawData_BioHarnessECG(varargin)
            %RAWDATA_BioHarnessECG RawData_BioHarnessECG class constructor
            %
            % obj=rawData_BioHarnessECG() creates a default
            %   rawData_BioHarnessECG with ID equals 1.
            %
            % obj=rawData_BioHarnessECG(obj2) acts as a copy constructor
            %   of rawData_BioHarnessECG
            %
            % obj=rawData_BioHarnessECG(id) creates a new
            %   rawData_BioHarnessECG
            %   with the given identifier (id). The name of the
            %   rawData_BioHarnessECG is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'rawData_BioHarnessECG')
                obj=varargin{1};
                return;
            else
                obj.id=varargin{1};
                obj.description=['RawData' num2str(obj.id,'%04i')];
            end
            %assertInvariants(obj);
        end
    %% Get/Set methods    
     %Provide struct like access to properties BUT maintaining class
     %encapsulation.
     
     %data
     function val = get.data(obj)
        % The method is converted and encapsulated. 
            % obj is the rawData_BioHarnessECG class
            % val is the value added in the object
            % get.data(obj) = Get the data from the rawData_BioHarnessECG class
            % and look for the data object.
        val = obj.data;%The raw ECG data. 
     end
     function obj = set.data(obj,val)
        % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the rawData_BioHarnessECG class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type.
        if (isreal(val))
            obj.data = val;
        else
            error('A matrix of real numbers expected.');
        end 
     end
     
     %samplingRate
     function val = get.samplingRate(obj)
         val = obj.samplingRate;
     end
     function obj = set.samplingRate(obj,val)
        if (isscalar(val) && isreal(val) && val>0)
            obj.samplingRate = val;
        else
            error('Value must be a positive real');
        end 
     end
     
     %startTime
     function val = get.startTime(obj)
         val = obj.startTime;
     end
     function obj = set.startTime(obj,val)
         tmpVal=datenum(val);
        if all(tmpVal==val)
            error('Value must be a date vector; [YY, MM, DD, HH, MN, SS]');
        else
            obj.startTime = datevec(tmpVal);
        end
     end
     
     %timeStamps
     function val = get.timeStamps(obj)
        val = obj.timeStamps; 
     end
     function obj = set.timeStamps(obj,val)
            if (isvector(val) && all(floor(val)==val) && all(val>=0))
                obj.timestamps = val;
            else
                error('Value must be a vector positive integers.');
            end 
     end
     
    end
end

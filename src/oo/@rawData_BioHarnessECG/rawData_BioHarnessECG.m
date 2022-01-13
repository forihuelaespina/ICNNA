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
classdef rawData_BioHarnessECG < rawData
    properties (SetAccess=private, GetAccess=private)
        samplingRate=250;%in [Hz]
        startTime=datevec(date);
        timestamps=zeros(0,1); %in milliseconds
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
    end
end

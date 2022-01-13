%Abstract Class rawData
%
%A rawData represents the experimentally recorded data
%during a session from a particular source (neuroimaging
%device, tracker, physiological meter or other).
%Due to the variability of the sources, the external
%formats may be very different. This class
%is an extremely simple abstract class to accomodate
%all the possible raw data under a common roof.
%
%The implementing classes must know two things: How to read
%the external format and how to convert the information
%a more standard structuredData.
%
%% Remarks
%
%   This is an Abstract class.
%
%% Known subclasses
%
% rawData_BeGazeEyeTracker - An eye tracker.
%
% rawData_BioHarnessECG - An wearable ECG and breathing sensor.
%
% rawData_ETG4000 - An fNIRS raw light measurement data
%   from the Hitachi ETG-4000 fNIRS device.
%
% rawData_NDIOptotrack - An optical location tracking data
%   from the NDI Optotrack device.
%
% rawData_NDIAurora - A magnetic location tracking data
%   from the NDI Aurora device.
%
% rawData_NIRScout - An fNIRS raw light measurement data
%   from the NIRx NIRScout fNIRS device.
%
% rawData_TobiiEyeTracker - An eye tracker.
%
% rawData_ViewPointEyeTracker - An eye tracker.
%
%
%% Properties
%
%   .id - A numerical identifier.
%   .description - A short description
%   .date - A string date
%  
%% Methods
%
% Type methods('rawData') for a list of methods
%
%
% Copyright 2008-18
% @date: 12-May-2008
% @author: Felipe Orihuela-Espina
% @modified: 4-Apr-2018
%
% See also processedData,
%

%% Log
%
% 4-Apr-2018 (FOE): Added known subclasses.
%



classdef rawData
    properties (SetAccess=private, GetAccess=private)
        id=1;
        description='RawData0001';
        date=date;
    end
 
    methods    
        function obj=rawData(varargin)
            %RAWDATA RawData class constructor
            %
            % obj=rawData() creates a default rawData with ID equals 1.
            %
            % obj=rawData(obj2) acts as a copy constructor of rawData
            %
            % obj=rawData(id) creates a new rawData with the given
            %   identifier (id). The name of the rawData is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'rawData')
                obj=varargin{1};
                return;
            else
                obj.id=varargin{1};
                obj.description=['RawData' num2str(obj.id,'%04i')];
            end
            %assertInvariants(obj);

        end
   
    end

    methods (Abstract=true)
        nimg=convert(obj,varargin);
        %Convert the rawData to a structuredData
        obj=import(obj,filename,varargin);
        %Reads an external file holding the raw data
    end
end

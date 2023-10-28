classdef rawData
% rawData Data as recorded by some device
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
%   .classVersion - (Read only) The class version of the object
%   .id - A numerical identifier.
%   .description - A short description
%   .date - A string date
%  
%% Methods
%
% Type methods('rawData') for a list of methods
%
%
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also processedData,
%

%% Log
%
% File created: 12-May-2008
% File last modified (before creation of this log): 4-Apr-2018
%
% 4-Apr-2018 (FOE): Added known subclasses.
%
%
% 13-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Improved some comments.
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end



    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
        description(1,:) char ='RawData0001'; %A short description of the data.
        date=date; %Acquisition date as character vector.
            %NOTE: Datenum has now been deprecated by matlab and
            %use of datetime is recommended instead.
            %However, I'm keeping datenum for compatibility by now.
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


      function res = get.description(obj)
         %Gets the object |description|
         res = obj.description;
      end
      function obj = set.description(obj,val)
         %Sets the object |description|
         obj.description = val;
      end


      function res = get.date(obj)
         %Gets the object |date|
         res = obj.date;
      end
      function obj = set.date(obj,val)
         %Sets the object |date|
         if (ischar(val) || isvector(val) || isscalar(val) || isdatetime(val))
            obj.date = val;
         else
             error('ICNA:rawData:set:InvalidParameterValue',...
                 'Value must be a date (whether a string, datevec or datetime).');
         end
      end



    end

end

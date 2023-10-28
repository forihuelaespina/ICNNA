classdef metaDataTags
% icnna.data.snirf.metaDataTags A NIRS metadata tag as defined in the snirf file format.
%
%% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% https://github.com/fNIRS/snirf
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
%
%
%
%
%% Remarks
%
% This class requires Matlab R2022b or above (use of object dictionary).
%
%% Properties
%
% See snirf specifications
% 
%
%
%% Methods
%
% Type methods('icnna.data.snirf.metaDataTags') for a list of methods
% 
% Copyright 2022-23
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf, icnna.data.snirf.nirsDataset, icnna.data.snirf.metaDataTagsGroup
%


%% Log
%
% 16-Jul-2022: FOE
%   File and class created.
%
% 14-May-2023: FOE
%   + Imported from my LaserLab sandbox code to ICNNA. Had to adjust the
%   the package from; data.snirf.* to icnna.data.snirf.*
%   + Added property classVersion. Set to '1.0' by default.
%
%
% 16-May-2023: FOE
%   + Added validation rules to properties and simplified the code
%   accordingly.
%   + Property .additional for holding additional metadata switch
%   from cell to dictionary
%
% 19-May-2023: FOE
%   + Added constructor polymorphism for typecasting a struct.
%   + Class renamed from icnna.data.snirf.metaDataTag to
%   icnna.data.snirf.metaDataTags for consistency with snirf denomination.
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end




    properties
        subjectID(1,:) char = ''; %Subject identifier
        measurementDate(1,1) datetime; %Date of the measurement in YYYY-MM-DD format.
        measurementTime(1,1) datetime; %Time of the measurement in hh:mm:ss.sTZD format
        lengthUnit(1,:) char = ''; % Length unit (case sensitive). Sample length units include "mm", "cm", and "m". A value of "um" is the same as "μm", i.e. micrometer.                      
        timeUnit(1,:) char = '';  % Time unit (case sensitive). Sample length units include "mm", "cm", and "m". A value of "um" is the same as "μm", i.e. micrometer.                            
        frequencyUnit(1,:) char   = '';  % Frequency unit (case sensitive). Sample frequency units "Hz", "MHz" and "GHz". Please note that "mHz" is milli-Hz while "MHz" denotes "mega-Hz" according to SI unit system.
        additional(1,1) dictionary; %Additional user-defined metadata entries

    end
    
    methods
        function obj=metaDataTags(varargin)
            %ICNNA.DATA.SNIRF.METADATATAGS A icnna.data.snirf.metaDataTags class constructor
            %
            % obj=icnna.data.snirf.metaDataTags() creates a default object.
            %
            % obj=icnna.data.snirf.metaDataTags(obj2) acts as a copy constructor
            %
            % obj=icnna.data.snirf.metaDataTags(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2022-23
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.metaDataTags')
                obj=varargin{1};
                return;
            elseif isstruct(varargin{1}) %Attempt to typecast
                tmp=varargin{1};

                tmpFields = fieldnames(tmp);
                tmpAdditional = dictionary;
                for iField = 1:length(tmpFields)
                    tmpProp = tmpFields{iField};
                    if ismember(tmpProp,properties(obj))
                        obj.(tmpProp) = tmp.(tmpProp);
                    else
                        tmpAdditional(tmpProp) = tmp.(tmpProp);
                    end
                    obj.additional = tmpAdditional;
                end

                return;
            else
                error(['icnna.data.snirf.metaDataTags:metaDataTags:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

        function val = get.subjectID(obj)
        %Retrieves the subject identifier
            val = obj.subjectID;
        end
        function obj = set.subjectID(obj,val)
        %Updates the subject identifier
            obj.subjectID = val;
        end

        function val = get.measurementDate(obj)
        %Retrieves the measurement date
            val = datestr(obj.measurementDate,'yyyy-mm-dd');
        end
        function obj = set.measurementDate(obj,val)
        %Updates the measurement date
            %Note that the snirf specification indicates that this
            %attribute should be a string, but I'm keeping it as a
            %datetime.
            try
                [YY,MM,DD] = ymd(datetime(val)); %Ignore the time if given
                obj.measurementDate = datetime([YY MM DD 0 0 0]);
            catch
                error(['icnna.data.snirf.metaDataTags:set.measurementDate:InvalidPropertyValue',...
                    'String cannot be converted to date.'])
            end
        end


        function val = get.measurementTime(obj)
        %Retrieves the measurement time
            val = obj.measurementTime;
        end
        function obj = set.measurementTime(obj,val)
        %Updates the measurement time
            %Note that by the time the argument is passed, MATLAB
            %has already enforce a typecasting. That is, if you assigned
            %a char or string with a date, MATLAB has already converted
            %this to a datetime when you enter this function.

            %Note that the snirf specification indicates that this
            %attribute should be a string, but I'm keeping it as a
            %datetime.
            try
                [HH,MM,SS] = hms(datetime(val)); %Ignore the date if given
                obj.measurementTime = datetime([0 0 0 HH MM SS]);
            catch
                error(['icnna.data.snirf.metaDataTags:set.measurementTime:InvalidPropertyValue',...
                    'String cannot be converted to date.'])
            end
           %assertInvariants(obj);
        end


        function val = get.lengthUnit(obj)
        %Retrieves the length unit
            val = obj.lengthUnit;
        end
        function obj = set.lengthUnit(obj,val)
        %Updates the length unit
            obj.lengthUnit = val;
        end


        function val = get.timeUnit(obj)
        %Retrieves the time unit
            val = obj.timeUnit;
        end
        function obj = set.timeUnit(obj,val)
        %Updates the time unit
            obj.timeUnit = val;
        end

        function val = get.frequencyUnit(obj)
        %Retrieves the frequency unit
            val = obj.frequencyUnit;
        end
        function obj = set.frequencyUnit(obj,val)
        %Updates the time unit
            obj.frequencyUnit = val;
        end

        function val = get.additional(obj)
        %Retrieves the additional metadata (as a dictionary)
            val = obj.additional;
        end
        function obj = set.additional(obj,val)
        %Updates the additional metadata (as a dictionary)
            obj.additional = val;
        end



        function val = getMetadata(obj,key)
        %Retrieves the metadata indexed by the key
            val = obj.additional(key);
        end
        function obj = setMetadata(obj,key)
        %Retrieves the metadata indexed by the key
            obj.additional(key) = val;
        end
        function obj = removeMetadata(obj,key)
        %Retrieves the metadata indexed by the key
            obj.additional(key) = [];
        end




    end


end

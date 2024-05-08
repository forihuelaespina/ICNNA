classdef auxBlock
% icnna.data.snirf.auxBlock An auxiliary measurment as defined in the snirf file format.
%
%% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% https://github.com/fNIRS/snirf
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
%
%
%% Remarks
%
% DO NOT attempt to rename his class simply as @aux.
% Either MATLAB or OneDrive do not like it and "insists" on automatically
% renaming it to @_ux which basically leaves it unusable.
%
%
%% Properties
%
% See snirf specifications
% 
%
%
%% Methods
%
% Type methods('icnna.data.snirf.auxBlock') for a list of methods
% 
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf, data.snirf.NIRSDataset
%


%% Log
%
% 16-May-2022: FOE
%   File and class created.
%   Apparently I did not get this far in my LaserLab sandbox code, so
% this class is brand new.
%
%
% 19-May-2023: FOE
%   + Added constructor polymorphism for typecasting a struct.
%
% 3-Mar-2024: FOE
%   + Bug fixed: Initialization of attributes dataTimeSeries, time and
%       timeOffsets are now arrays instead of an empty string.
%   + Bug fixed: Setting of attributes dataTimeSeries, time and timeOffsets
%       are no longer required o have 2 columns.
%
%
% 6-Apr-2024: FOE
%   + Added optional property dataUnit (for reasons I dis not include this
%       originally)
%   + Added visibility flags for optional properties.
%       Some of the properties of the measurement are optional; they
%       may or may not be present. In its implementation thus far, ICNNA
%       had no way to distinguish the case when the attribute was simply
%       missing from the case it has some default value. Having visibility
%       or enabling flags solves the problem.
%       ICNNA also provides a couple of further methods; one to "remove" (hide)
%       existing optional attributes and one to check whether it has
%       been defined (e.g. to check its visibility status) which shall
%       prevent the need for try/catch in other functions using the class.
%       Regarding this latter, note that;
%       + Calling properties(measurement) will still list the "hidden"
%       properties, which ideally should not happen -but this relates back
%       to MATLAB's new way of the defining the get/set methods for struct
%       like access which requires the properties to be public.
%       + MATLAB has function isprop to determine whether a property is
%       defined by object, but again this will "see" the hidden properties.
%
%       NOTE: Making the class mutable so that it can grow organically 
%       on these optional attributes is not a good solution as this then
%       loses control on what other attributes could be defined beyond
%       those acceptable for snirf.
%   + classVersion increased to '1.0.1'
%
%


    properties (Constant, Access=private)
        %classVersion = '1.0'; %Read-only. Object's class version.
        classVersion = '1.0.1'; %Read-only. Object's class version.
    end



    properties
        name(:,1) char = ''; %Name of the auxiliary channel
        dataTimeSeries(:,:) double = nan(0,0); %Data acquired from the auxiliary channel
        dataUnit(:,1) char = ''; %Name of the auxiliary channel
        time(:,1) double = nan(0,1); %Time (in TimeUnit) for auxiliary data 
        timeOffset(:,1) double = nan(0,1); %Time offset of auxiliary channel data 
    end
    
    properties (Access = private)
        %Visibility/Availability flags:
        %The optional attributes are;
        %  1) dataUnit
        %  2) timeOffset

        flagVisible struct = struct('dataUnit',false, ...
                                'timeOffset',false); %Not visible by default
    end

    
    
    methods
        function obj=auxBlock(varargin)
            %ICNNA.DATA.SNIRF.AUXBLOCK A icnna.data.snirf.auxBlock class constructor
            %
            % obj=icnna.data.snirf.auxBlock() creates a default object.
            %
            % obj=icnna.data.snirf.auxBlock(obj2) acts as a copy constructor
            %
            % obj=icnna.data.snirf.auxBlock(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2023
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.auxBlock')
                obj=varargin{1};
                return;
            elseif isstruct(varargin{1}) %Attempt to typecast
                tmp=varargin{1};
                tmpFields = fieldnames(tmp);
                for iField = 1:length(tmpFields)
                    tmpProp = tmpFields{iField};
                    if ismember(tmpProp,properties(obj))
                        obj.(tmpProp) = tmp.(tmpProp);
                    end
                end
                return;
            else
                error(['icnna.data.snirf.auxBlock:auxBlock:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

        function val = get.name(obj)
        %Retrieves the name
            val = obj.name;
        end
        function obj = set.name(obj,val)
        %Updates the name
            obj.name = val;
        end

        function val = get.dataTimeSeries(obj)
        %Retrieves the data acquired from the auxiliary channel
            val = obj.dataTimeSeries;
        end
        function obj = set.dataTimeSeries(obj,val)
        %Updates the data acquired from the auxiliary channel
           if (ismatrix(val) && all(isnumeric(val)))
               obj.dataTimeSeries = val;
           else
               error(['icnna.data.snirf.auxBlock:set.dataTimeSeries:InvalidPropertyValue',...
                     'Value must be a MxN matrix of M temporal samples and N signals.']);
           end
           %assertInvariants(obj);
        end

        
        function val = get.dataUnit(obj)
        %Retrieves the dataUnit
            if obj.flagVisible.dataUnit
                val = obj.dataUnit;
            else
                error('ICNNA:icnna.data.snirf.auxBlock.get.dataUnit:Undefined', ...
                    'Undefined optional field dataUnit.');
            end
        end
        function obj = set.dataUnit(obj,val)
        %Updates the dataUnit
            obj.dataUnit = val;
            obj.flagVisible.dataUnit = true;
        end

        function val = get.time(obj)
        %Retrieves the time for the auxiliary data
            val = obj.time;
        end
        function obj = set.time(obj,val)
        %Updates the time for the auxiliary data
           if (ismatrix(val) && all(isnumeric(val)))
               obj.time = val;
           else
               error(['icnna.data.snirf.auxBlock:set.time:InvalidPropertyValue',...
                     'Value must be a Mx1 matrix of M timestamps.']);
           end
           %assertInvariants(obj);
        end

        
        function val = get.timeOffset(obj)
        %Retrieves the time offsets for the auxiliary data
            if obj.flagVisible.timeOffset
                val = obj.timeOffset;
            else
                error('ICNNA:icnna.data.snirf.auxBlock.get.timeOffset:Undefined', ...
                    'Undefined optional field timeOffset.');
            end
        end
        function obj = set.timeOffset(obj,val)
        %Updates the time offsets for the auxiliary data
           if (ismatrix(val) && all(isnumeric(val)))
               obj.timeOffset = val;
               obj.flagVisible.timeOffset = true;
           else
               error(['icnna.data.snirf.auxBlock:set.timeOffset:InvalidPropertyValue',...
                     'Value must be a Mx1 matrix of M time offsets.']);
           end
           %assertInvariants(obj);
        end

        




        %%Suport methods for visibility of optional attributes
        function res = isproperty(obj,propertyName)
        %Check whether existing optional attributes have been defined (i.e. checks visibility)
            propertyName = char(propertyName);
            res = isprop(obj,propertyName);
            switch(propertyName)
                case {'dataUnit','timeOffset'}
                    res = obj.flagVisible.(propertyName);
                otherwise
                    %Do nothing
            end
        end


        function obj = rmproperty(obj,propertyName)
        %"Removes" (hides) existing optional attributes
            propertyName = char(propertyName);
            switch(propertyName)
                case {'dataUnit','timeOffset'}
                    obj.flagVisible.(propertyName) = false;
                case {'name','dataTimeSeries','time'}
                    error('ICNNA:icnna.data.snirf.auxBlock.rmproperty:NonOptionalProperty', ...
                        ['Property ' propertyName ' cannot be removed. It is not optional for .snirf format.']);
                otherwise
                    error('ICNNA:icnna.data.snirf.auxBlock.rmproperty:UnknownProperty', ...
                        ['Unknown property ' propertyName '.']);
            end
        end



    end


end

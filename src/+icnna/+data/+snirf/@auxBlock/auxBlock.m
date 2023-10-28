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
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end



    properties
        name(:,1) char = ''; %Name of the auxiliary channel
        dataTimeSeries(:,:) double = ''; %Data acquired from the auxiliary channel
        time(:,1) double = ''; %Time (in TimeUnit) for auxiliary data 
        timeOffset(:,1) double = ''; %Time offset of auxiliary channel data 
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
           if (ismatrix(val) && size(val,2) == 2 && all(isnumeric(val)))
               obj.dataTimeSeries = val;
           else
               error(['icnna.data.snirf.auxBlock:set.dataTimeSeries:InvalidPropertyValue',...
                     'Value must be a MxN matrix of M temporal samples and N signals.']);
           end
           %assertInvariants(obj);
        end

        
        function val = get.time(obj)
        %Retrieves the time for the auxiliary data
            val = obj.time;
        end
        function obj = set.time(obj,val)
        %Updates the time for the auxiliary data
           if (ismatrix(val) && size(val,2) == 2 && all(isnumeric(val)))
               obj.time = val;
           else
               error(['icnna.data.snirf.auxBlock:set.time:InvalidPropertyValue',...
                     'Value must be a Mx1 matrix of M timestamps.']);
           end
           %assertInvariants(obj);
        end

        
        function val = get.timeOffset(obj)
        %Retrieves the time offsets for the auxiliary data
            val = obj.timeOffset;
        end
        function obj = set.timeOffset(obj,val)
        %Updates the time offsets for the auxiliary data
           if (ismatrix(val) && size(val,2) == 2 && all(isnumeric(val)))
               obj.timeOffset = val;
           else
               error(['icnna.data.snirf.auxBlock:set.timeOffset:InvalidPropertyValue',...
                     'Value must be a Mx1 matrix of M time offsets.']);
           end
           %assertInvariants(obj);
        end

        


    end


end

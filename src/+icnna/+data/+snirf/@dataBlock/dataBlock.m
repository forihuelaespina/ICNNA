classdef dataBlock
% icnna.data.snirf.dataBlock
%
%A NIRS data block as defined in the snirf file format.
%
%% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% https://github.com/fNIRS/snirf
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
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
% Type methods('data.snirf.dataBlock') for a list of methods
% 
% Copyright 2022-23
% @author: Felipe Orihuela-Espina
%
% See also data.snirf.snirf, data.snirf.NIRSDataset, data.snirf.dataBlockGroup
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
%
% 19-May-2023: FOE
%   + Added constructor polymorphism for typecasting a struct.
%   Simplified structure by substituting groups by array of objects;
%   + Substituted icnna.data.snirf.measurementListGroup object for array of icnna.data.snirf.measurementList
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties
        dataTimeSeries(:,:) double = zeros(0,0); %Time-varying signals from all channels or measurements
        time(:,1) double = zeros(0,1); %Time (in TimeUnit defined in metaDataTag)
        measurementList(:,1) icnna.data.snirf.measurement; %Per-channel source-detector information each of class icnna.data.snirf.measurementList

    end
    
    methods
        function obj=dataBlock(varargin)
            %ICNNA.DATA.SNIRF.DATABLOCK A icnna.data.snirf.dataBlock class constructor
            %
            % obj=icnna.data.snirf.dataBlock() creates a default object.
            %
            % obj=icnna.data.snirf.dataBlock(obj2) acts as a copy constructor
            %
            % obj=icnna.data.snirf.dataBlock(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2022-23
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.dataBlock')
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
                error(['icnna.data.snirf.dataBlock:dataBlock:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

        function val = get.dataTimeSeries(obj)
        %Retrieves the time-varying signals from all channels
            val = obj.dataTimeSeries;
        end
        function obj = set.dataTimeSeries(obj,val)
        %Updates the time-varying signals from all channels
           if (ismatrix(val))
               obj.dataTimeSeries = val;
           else
               error(['icnna.data.snirf.dataBlock:set.dataTimeSeries:InvalidPropertyValue',...
                     'Value must be a MxN matrix of M samples and N channels.']);
           end
           %assertInvariants(obj);
        end



        function val = get.time(obj)
        %Retrieves the time (in TimeUnit defined in metaDataTag)
            val = obj.time;
        end
        function obj = set.time(obj,val)
        %Updates the time (in TimeUnit defined in metaDataTag)
           if (isvector(val))
               obj.time = reshape(val,numel(val),1);
           else
               error(['icnna.data.snirf.dataBlock:set.time:InvalidPropertyValue',...
                     'Value must be a Mx1 vector of M samples.']);
           end
           %assertInvariants(obj);
        end


        
        function val = get.measurementList(obj)
        %Retrieves the group of per-channel source-detector information  
            val = obj.measurementList;
        end
        function obj = set.measurementList(obj,val)
        %Updates the group of per-channel source-detector information
            obj.measurementList = val;
        end



    end


end

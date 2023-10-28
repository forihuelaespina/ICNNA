classdef nirsDataset
% icnna.data.snirf.nirsDataset A NIRS dataset as defined in the snirf file format.
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
% Type methods('icnna.data.snirf.nirsDataset') for a list of methods
% 
% Copyright 2022-23
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf, data.snirf.nirsDatasetGroup
%


%% Log
%
% 15-Jul-2022: FOE
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
%
% 19-May-2023: FOE
%   + Added constructor polymorphism for typecasting a struct.
%   Simplified structure by substituting groups by array of objects;
%   + Substituted icnna.data.snirf.stimGroup object for array of icnna.data.snirf.stim
%   + Substituted icnna.data.snirf.auxBlockGroup object for array of icnna.data.snirf.auxBlock
%   + Substituted icnna.data.snirf.dataBlockGroup object for array of icnna.data.snirf.dataBlock
%   
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end



    properties
        metaDataTags(1,1) icnna.data.snirf.metaDataTags; %Metadata headers
        data(:,1) icnna.data.snirf.dataBlock; %The NIRS data blocks each of class @icnna.data.snirf.dataBlock
        stim(:,1) icnna.data.snirf.stim;      %Stimulus measurements each of class @icnna.data.snirf.stim
        probe(1,1) icnna.data.snirf.probe;    %NIRS probe information
        aux(:,1) icnna.data.snirf.auxBlock;   %Auxiliary measurements each of class @icnna.data.snirf.auxBlock
        
    end
    
    methods
        function obj=nirsDataset(varargin)
            %ICNNA.DATA.SNIRF.NIRSDATASET A icnna.data.snirf.nirsDataset class constructor
            %
            % obj=icnna.data.snirf.NIRSDataset() creates a default object.
            %
            % obj=icnna.data.snirf.NIRSDataset(obj2) acts as a copy constructor
            %
            % obj=icnna.data.snirf.NIRSDataset(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2022-23
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.nirsDataset')
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
                error(['icnna.data.snirf.nirsDataset:nirsDataset:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

        function val = get.metaDataTags(obj)
        %Retrieves the group of metaDataTags
            val = obj.metaDataTags;
        end
        function obj = set.metaDataTags(obj,val)
        %Updates the group of metaDataTags
            obj.metaDataTags = val;
        end

        function val = get.data(obj)
        %Retrieves the group of data blocks
            val = obj.data;
        end
        function obj = set.data(obj,val)
        %Updates the group of data blocks
            obj.data = val;
        end

        function val = get.stim(obj)
        %Retrieves the group of stimulus measurements
            val = obj.stim;
        end
        function obj = set.stim(obj,val)
        %Updates the group of data blocks
            obj.stim = val;
        end

        
        function val = get.probe(obj)
        %Retrieves the NIRS probe information
            val = obj.probe;
        end
        function obj = set.probe(obj,val)
        %Updates the NIRS probe information
            obj.probe = val;
        end

        function val = get.aux(obj)
        %Retrieves the group of auxiliary measurements
            val = obj.aux;
        end
        function obj = set.aux(obj,val)
        %Updates the group of auxiliary measurements
            obj.aux = val;
        end

        


    end


end

classdef snirf
% icnna.data.snirf.snirf An snirf data object. 
%
% This is the main object to support .snirf data. A icnna.data.snirf.snirf
%corresponds to the content of one .snirf file.
%
%% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
%
% https://github.com/fNIRS/snirf
%
% See snirf specifications
% 
%
%% Properties
%
%
%   .classVersion - (Private) The class version of the object
%
%   .formatVersion - The snirf file format version
%   .nirs - An icnna.data.snirf.nirsDatasetGroup object. Default is null.
%       Contains the fNIRS datasets.
%
%
%
%% Methods
%
% Type methods('icnna.data.snirf.snirf') for a list of methods
% 
% Copyright 2022-23
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.nirsDatasetGroup
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
% 16-May-2023: FOE
%   + Added validation rules to properties and simplified the code
%   accordingly.
%   + Added static method load to read an snirf file
%
% 19-May-2023: FOE
%   + Added static method readHD5file to...well, read HD5 files.
%       No need for external libraries. It only uses matlab h5* functions.
%   + Added static method load to read snirf files.
%   + Added constructor polymorphism for typecasting a struct.
%   Simplified structure by substituting groups by array of objects;
%   + Substituted icnna.data.snirf.nirsDatasetGroup object for array of icnna.data.snirf.nirsDataset
%
% 18-Aug-2023: FOE
%   + Added static method save to write to snirf files.
%
% 18-Aug-2023: FOE
%   + Added non-static method save to write to snirf files.
%   + Deprecated static method save 
%

    
    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties
        formatVersion(1,:) char = '0.0'; %snirf file format version
        nirs(:,1) icnna.data.snirf.nirsDataset; %The NIRS datasets each of class @icnna.data.snirf.NIRSDataset
    end

    properties (Dependent)
        nNirsDatasets;
    end
    
    methods
        function obj=snirf(varargin)
            %ICNNA.DATA.SNIRF.SNIRF A icnna.data.snirf.snirf class constructor
            %
            % obj=icnna.data.snirf.snirf() creates a default snirf
            %   with ID equals 1.
            %
            % obj=icnna.data.snirf.snirf(obj2) acts as a copy constructor of snirf
            %
            % obj=icnna.data.snirf.snirf(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2022
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.snirf')
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
                error('icnna.data.snirf.snirf:snirf:InvalidNumberOfParameters', ...
                      'Unexpected number of parameters.');

            end
        end





        %Gets/Sets

        function val = get.formatVersion(obj)
        %Retrieves the formatVersion
            val = obj.formatVersion;
        end
        function obj = set.formatVersion(obj,val)
        %Updates the formatVersion
           obj.formatVersion = val;
        end


        function val = get.nirs(obj)
        %Retrieves the NIRS datasets group
            val = obj.nirs;
        end
        function obj = set.nirs(obj,val)
        %Updates the NIRS datasets group
           obj.nirs = val;
        end
        function val = get.nNirsDatasets(obj)
        %Retrieves the number of NIRS datasets
            val = length(obj.nirs);
        end

        

        % Public methods
        [res] = save(obj,filename,varargin); %Write to snirf files
    end

    methods (Static)
        [res] = load(filename); %Read snirf files
        [res,info] = readHD5file(filename);
    end

end

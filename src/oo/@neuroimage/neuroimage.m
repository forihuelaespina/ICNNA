%Class neuroimage
%
%A neuroimage represents a image of the brain of any
%modality. Any neuroimage can be understood as a 3D
%structure (see superclass structuredData):
%
%       Signals /
%              /
%             /                       Spatial
%            +---------------------> Location
%            |                      (Channel/Pixel/Voxel)
%     Time   |
%    Samples |
%  (Temporal |
%   Elements)|
%            |
%            v
%
% With this representation the location represents the picture
%element; whether pixel, channel (NIRS), or voxel (fMRI). The two
%or three common spatial dimension are collapsed here into a
%single dimension where each picture element is identified by a
%simple numerical index.
%
%
%% Superclass
%
% structuredData
%
%% Known Subclasses
%
% nirs_neuroimage - An fNIRS neuroimage
%
%% Properties
%
% .chLocationMap - A channelLocationMap capturing the spatial
%       positioning of channels
%
%% Invariants
%
% See private/assertInvariants
%       
%% Properties
%
% None
%
%% Methods
%
% Type methods('neuroimage') for a list of methods
% 
% Copyright 2008-12
% @date: 25-Apr-2008
% @author: Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also structuredData, nirs_neuroimage, integrityStatus, get
%

%% Log
%
% 20-February-2022 (ESR): Get/Set Methods created in neuroimage class.
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions.
%

classdef neuroimage < structuredData
    properties (SetAccess=private, GetAccess=private)
        chLocationMap=channelLocationMap;
    end
    
    properties (Dependent)
       Data 
    end

    methods
        function obj=neuroimage(varargin)
            %NEUROIMAGE Neuroimage class constructor
            %
            % obj=neuroimage() creates a default neuroimage with ID equals 1.
            %
            % obj=neuroimage(obj2) acts as a copy constructor of neuroimage
            %
            % obj=neuroimage(id) creates a new neuroimage with the given
            %   identifier (id). The name of the neuroimage is initialised
            %   to 'NeuroimageXXXX' where is the id preceded with 0.
            %
            % obj=neuroimage(id,size) creates a new neuroimage with
            %   the indicated identifier and size, where size is a vector
            %       <nSamples,nChannels,nSignals>
            %
            %

            obj = obj@structuredData();

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'neuroimage')
                obj=varargin{1};
                return;
            else
                obj=set(obj,'ID',varargin{1});
                if (nargin>1) %Image size also provided
                    if ((isnumeric(varargin{2})) && (length(varargin{2})==3))
                        obj=set(obj,'Data',zeros(varargin{2}));
                        cml=channelLocationMap;
                        cml=set(cml,'nChannels',varargin{2}(2));
                        obj=set(obj,'ChannelLocationMap',cml);
                    else
                        error(['Not a valid size vector; ' ...
                            '[nSamples, nChannels, nSignals].']);
                    end
                end
                
            end
            obj=set(obj,'Description',...
                    ['Neuroimage' num2str(get(obj,'ID'),'%04i')]);
            assertInvariants(obj);
        end
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        function val = get.chLocationMap(obj)
           val = obj.chLocationMap; 
        end
        function obj = set.chLocationMap(obj,val)
           if (isa(val,'channelLocationMap'))
               obj.chLocationMap = channelLocationMap(val);
                    %Note that the channelLocationMap should
                    %have the same number of channels that the
                    %data, and if this is not the case, the
                    %assertInvariants will issue an error.
           else
               error('ICNA:neuroimage:set:InvalidPropertyValue',...
                     'Value must be of class channelLocationMap.');
           end 
        end
        
        %Data
        function obj = set.Data(obj,val)
            %Setting the data may alter the size of it (i.e. the
            %number of channels. If I call the set method directly
            %it will evaluate the assertInvariants method -of the
            %neuroimage class!! regardless of whether it is call
            %as obj=set@structuredData(...)- BEFORE the 
            %channelLocationMap has adjusted its size. Thus, the
            %neuroimage.assertInvariants will yield an error because
            %the channel capacity of the channelLocationMap mismatches
            %the channel capacity of the data. To avoid this
            %error, it is necessary to set the size of the
            %channelLocationMap BEFORE setting the data, so that
            %when the assertInvariants is called, the channelLocationMap
            %already has the appropriate size.
            try
                %ensure that the channelLocationMap has the appropriate
                %size
                obj.chLocationMap = ...
                    set(obj.chLocationMap,'nChannels',size(val,2));
                %...and only then, set the data
                obj=set@structuredData(obj,'Data',val);
            catch
               error('ICNA:neuroimage:set:InvalidPropertyValue',...
                     'Data must be a numeric.');
            end
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
end

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
classdef neuroimage < structuredData
    properties (SetAccess=private, GetAccess=private)
        chLocationMap=channelLocationMap;
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
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
end

classdef neuroimage < structuredData
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
%% Remarks
%
% 20-May-2023: FOE
%   Because of Matlab's current rigid rules about the overloaded
%   get/set methods support for struct like access to attributes,
%   class invariants can no longer be enforced when updating a property
%   as I cannot transiently violate the invariants when updating one
%   property affects another.
%   This is an undesirable side effect of this, but right now I do not
%   have a solution.
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
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also structuredData, nirs_neuroimage, integrityStatus, get
%

%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): 22-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%
% 20-May-2023: FOE
%   + Commented out ALL calls to assertInvariants in the get/set methods
%



    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties %(SetAccess=private, GetAccess=private)
        chLocationMap(1,1) channelLocationMap; %A channelLocationMap object
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
                %obj=set(obj,'ID',varargin{1});
                obj.id = varargin{1};
                if (nargin>1) %Image size also provided
                    if ((isnumeric(varargin{2})) && (length(varargin{2})==3))
                        cml=channelLocationMap;
                        %cml=set(cml,'nChannels',varargin{2}(2));
                        %obj=set(obj,'ChannelLocationMap',cml);
                        cml.nChannels = varargin{2}(2);
                        obj.chLocationMap = cml;
                        obj.data = zeros(varargin{2});
                    else
                        error(['Not a valid size vector; ' ...
                            '[nSamples, nChannels, nSignals].']);
                    end
                end
                
            end
            obj.description = ['Neuroimage' num2str(obj.id,'%04i')];
            %assertInvariants(obj);
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end


    methods


      %Getters/Setters

      function res = get.chLocationMap(obj)
         %Gets the object |chLocationMap|
         res = obj.chLocationMap;
      end
      function obj = set.chLocationMap(obj,val)
         %Sets the object |chLocationMap|
         obj.chLocationMap = val;
         %assertInvariants(obj);
      end



    end




end

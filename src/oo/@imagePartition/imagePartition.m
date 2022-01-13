%Class ImagePartition
%
%An ImagePartition represent the partition in region of interests (ROIs)
%of a rectangular area representing an image or screen.
%
%A ImagePartition can hold any number of ROIs. The image or screen
%has a certain size [width height] in pixels. Every coordinate which
%is not part of any defined ROI is considered part of the BACKGROUND.
%
%% Properties
%
%   .id - A numerical identifier.
%   .name - The imagePartition's name. By default is set to
%       'ImagePartition0001'.
%   .associatedFile - If the partition refers to an image, this property
%       holds the filename of the image.
%   .size - Image size as a pair [Width Height]. By default
%       is set to [0 0]
%   .screenResolution - Screen resolution. By default
%       is set to [1280 1024]
%   .rois - Set of ROIs.
%
% == Constants
%   .BACKGROUND - 0. Identifier for the background 
%   .OUTOFBOUNDS - -1. Identifier for points out of bounds 
%
%
%
%% Methods
%
% Type methods('imagePartition') for a list of methods
%
%
% Copyright 2008-9
% date: 22-Dec-2008
% Author: Felipe Orihuela-Espina
%
% See also roi
%
classdef imagePartition
    properties (SetAccess=private, GetAccess=private)
        id=1;
        name='ImagePartition0001';
        size=[0 0];
        screenResolution=[1280 1024];
        associatedFile='';
        rois=cell(1,0);
    end
    properties (Constant=true, SetAccess=private, GetAccess=public)
        BACKGROUND=0;
        OUTOFBOUNDS=-1;
    end

    methods
        function obj=imagePartition(varargin)
            %IMAGEPARTITION ImagePartition class constructor
            %
            % obj=imagePartition() creates a default imagePartition
            %   with ID equals 1.
            %
            % obj=imagePartition(obj2) acts as a copy constructor
            %   of imagePartition
            %
            % obj=imagePartition(id) creates a new imagePartition with the given
            %   identifier (id). The name of the imagePartition is initialised
            %   to 'ImagePartitionXXXX' where is the id preceded with 0.
            %
            % obj=imagePartition(id,name) creates a new imagePartition
            %   with the given identifier (id) and name.
            %
            % @Copyright 2008
            % date: 22-Dec-2008
            % Author: Felipe Orihuela-Espina
            %
            % See also assertInvariants, roi
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'imagePartition')
                obj=varargin{1};
                return;
            else
                obj=set(obj,'ID',varargin{1});
                obj=set(obj,'Name',['ImagePartition' num2str(obj.id,'%04i')]);
                if (nargin>1)
                    obj=set(obj,'Name',varargin{2});
                end
            end
            assertInvariants(obj);
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findROI(obj,id);
    end
end


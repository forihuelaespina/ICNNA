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

%% Log
%
% 20-February-2022 (ESR): Get/Set Methods created in imagePartition class
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside the imagePartition class.
%   + The dependent Width and Height properties are in the
%   imagePartition class.
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
    
    properties (Dependent)
       Height
       Width
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
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.  
        
        %associatedFile 
        function val = get.associatedFile(obj)
            % The method is converted and encapsulated. 
            % obj is the imagePartition class
            % val is the value added in the object
            % get.associatedFile(obj) = Get the data from the imagePartition class
            % and look for the associatedFile object.
            val = obj.associatedFile;
        end
        function obj = set.associatedFile(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the imagePartition class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type
            if (ischar(val))
            obj.associatedFile = val;
                try
                    A=imread(obj.associatedFile);
                    w=size(A,2);
                    h=size(A,1);
                    obj.size=[w h];
                    clear A
                catch ME
                    error('ICNA:imagePartition:set:InvalidPropertyValue',...
                      ['File ' obj.associatedFile ' not found.']);
                end
            
            else
                error('ICNA:imagePartition:set:InvalidPropertyValue',...
                      'Value must be a string.');
            end
        end
        
        %id
        function val = get.id(obj)
            val = obj.id;
        end
        function obj = set.id(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.id = val;
            else
                error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
            end
        end
        
        %name 
        function val = get.name(obj)
             val = obj.name;
        end
        function obj = set.name(obj,val)
            if (ischar(val))
                obj.name = val;
            else
                error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a string.');
            end
        end
        
        %screenResolution
        function val = get.screenResolution(obj)
            val = obj.screenResolution;
        end
        function obj = set.screenResolution(obj,val)
            if (numel(val)==2 && ~ischar(val) ...
                && all(val==floor(val)) && all(val>=0))
                obj.screenResolution = reshape(val,1,2);
            else
                error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Size must be a pair [width height].');
            end
        end
        
        %size
        function val = get.size(obj)
            val = obj.size;
        end
        function obj = set.size(obj,val)
            if (numel(val)==2  && ~ischar(val) ...
                && all(val==floor(val)) && all(val>=0))
                obj.size = reshape(val,1,2);
            else
                error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Size must be a pair [width height].');
            end
        end
        
        %---------------------------------------------------------------->
        %size Dependent
        %Dependent properties do not store data. 
        %The value of a dependent property depends on some other value, 
        %such as the value of a nondependent property.
        
        %Dependent properties must define get-access methods () to 
        %determine a value for the property when the property is queried: 
        %get. Height
        %For example:  Height and Width are properties
        %dependent of size property.
        
        %We create a dependent property.
        %---------------------------------------------------------------->
        
        %Height
        function val = get.Height (obj)
            val = obj.size(2);
        end
        function obj = set.Height(obj,val)
             if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (floor(val)==val) && val>=0)
                obj.size(2) = val;
            else
                error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %Width
        function val = get.Width(obj)
             val = obj.size(1);
        end
        function obj = set.Width(obj,val)
           if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (floor(val)==val) && val>=0)
                obj.size(1) = val;
           else
                error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a positive integer or 0.');
           end 
        end
        
        
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findROI(obj,id);
    end
end


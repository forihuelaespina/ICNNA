%Class ROI
%
%A region of interest (ROI) bounds 2D region
%
%A ROI can hold any number of polygon delimited subregions.
%Each subregion is a closed poligon defined
%by its vertexes.
%
%% Properties
%
%   .id - A numerical identifier.
%   .name - The ROI's name. By default is set to 'ROI0001'
%   .subregions - A cell array of subregions. Each position of the cell
%       array holds the polygon representing a subregions. Subregions
%       polygons are represented by a Nx2 matrix of vertexes; each row is
%       a vertex, the columns correspond to the 2D coordinates <X,Y>.
%           Subregions are closed, as said above; There is no need to repeat
%           the last vertex to get a closed polygon!.
%
% == Derived/Dependent
%   .area - Total area of the regions across all subregions
%
%% Methods
%
% Type methods('roi') for a list of methods
%
%
% Copyright 2008-2009
% date: 22-Dec-2008
% Author: Felipe Orihuela-Espina
%
% See also imagePartition
%

%date: 4-Feb-2009
%author: Felipe Orihuela-Espina
%The ROIS can now be composed of more than one subregions/polygons

%% Log
%
% 13-February-2022 (ESR): Get/Set Methods created in roi class
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside the roi class.
%   
%

classdef roi
    properties (SetAccess=private, GetAccess=private)
        id=1;
        name='ROI0001';
        subregions=cell(1,0);
    end
    properties (Dependent = true, SetAccess=private, GetAccess=private)
        area;
    end

    methods
        function obj=roi(varargin)
            %ROI ROI class constructor
            %
            % obj=roi() creates a default ROI with ID equals 1.
            %
            % obj=roi(obj2) acts as a copy constructor of ROI
            %
            % obj=roi(id) creates a new ROI with the given
            %   identifier (id). The name of the ROI is initialised
            %   to 'ROIXXXX' where is the id preceded with 0.
            %
            % obj=roi(id,name) creates a new ROI with the given
            %   identifier (id) and name.
            %
            % @Copyright 2008
            % date: 22-Dec-2008
            % Author: Felipe Orihuela-Espina
            %
            % See also assertInvariants, imagePartition
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'roi')
                obj=varargin{1};
                return;
            else
                obj=set(obj,'ID',varargin{1});
                obj=set(obj,'Name',['ROI' num2str(obj.id,'%04i')]);
                if (nargin>1)
                    obj=set(obj,'Name',varargin{2});
                end
            end
            %assertInvariants(obj);
        end
        %% Dependent properties
        function a = get.area(obj)
            a=0;
            for ii=1:length(obj.subregions)
                roi_polygon=getSubregion(obj,ii);
                roi_polygon=[roi_polygon; roi_polygon(1,:)];
                    %Temporally close the polygon region
                a = a+polyarea(roi_polygon(:,1),roi_polygon(:,2));
            end
        end % area get method
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.

        %ID
        function val = get.id(obj)
            % The method is converted and encapsulated. 
            % obj is the roi class
            % val is the value added in the object
            % get.deoxyRawData(obj) = Get the data from the roi class
            % and look for the id object.
            val = obj.id;
        end
        function obj = set.id(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the roi class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type.
             if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.id = val;
             else
                error('ICNA:ROI:set:InvalidPropertyValue',...
                      'Value must be a positive integer.');
             end
        end
        
        %Name
        function val = get.name(obj)
            val = obj.name;
        end
        function obj = set.name(obj,val)
            if (ischar(val))
                obj.name = val;
            else
                error('ICNA:ROI:set:InvalidPropertyValue',...
                      'Value must be a string.');
            end
        end
        
        
        
    end
    
%    methods (Access=protected)
%        assertInvariants(obj);
%    end
end


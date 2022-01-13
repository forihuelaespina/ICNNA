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
        %%Dependent properties
        function a = get.area(obj)
            a=0;
            for ii=1:length(obj.subregions)
                roi_polygon=getSubregion(obj,ii);
                roi_polygon=[roi_polygon; roi_polygon(1,:)];
                    %Temporally close the polygon region
                a = a+polyarea(roi_polygon(:,1),roi_polygon(:,2));
            end
        end % area get method
    end
    
%    methods (Access=protected)
%        assertInvariants(obj);
%    end
end


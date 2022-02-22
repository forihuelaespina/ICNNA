%Abstract Class menaGrid
%
%A 2D grid that allows easy exploration of the embedding space.
%
%The grid segregates the Projection space into cells or regions,
%for which average behaviours can be estimated.
%
%% Remarks
%
%   This is an Abstract class.
%
% The name of the class is menaGrid rather than simply grid to avoid
%conflict with MATLAB function grid.
%
%% Known Subclasses
%
% logRadialGrid - A 2D radial grid whose rings radius is logarithmically
%   proportional to the distance to the Projection Space center.
% radialGrid - A 2D radial grid whose ring radius is constant
%
% squareGrid - Classical 2D square grids with rows and cols
% hexagonalGrid - NOT YET AVAILABLE.
%
%
%% Properties
%
%   .id - A numerical identifier.
%
% == Visualization properties
%   .lineWidth - Thickness of line of the wire structure of the grid.
%       Default value is 1.5
%   .edgeColor - Color of the wireframe of the grid as a normalized
%       RGB vector. Black ([0 0 0]) by default
%
%   .highlightCells - Highlight the selected cells. Inidicate cells by
%       their index ni the grid. Example=[3 5 7]. Empty by default, so no
%       cell is highlighted
%   .highlightEdgeColor - Color as a normalized
%       RGB vector of the frame of the highlighted cell.
%       Default Magenta.
%   .highlightFaceColor - Color of the highlighted cell as a normalized
%       RGB vector.
%       Default [] (i.e. no color). You can specify an array of Mx3 colors
%       to highlight the cells in different colors. If you specify less
%       colors than regions, colors will be repeated in a circular way.
%       If there are more colors than cells to highlight, only the
%       first n colors will be used. This option of multiple colors
%       currently only works with full RGB color specifications and
%       not with MATLAB color mnemonics.
%   .highlightFaceAlpha - Transparency of the highlighted cell.
%       Default 1 (i.e. no transparency).
%   .labelCells - Label the cells with its cell index. False default
%
%   .vertexVisible - Display (true) or not the vertexes of the grid. False
%       by default
%   .vertexColor - Color of the vertex (if visible) as a normalized
%       RGB vector. Default blue
%   .vertexMarker - Marker to represent the vertex (if visible). Default '.'
%   .vertexMarkerSize - Marker size to represent the vertex (if visible).
%       Default 8 points.
%
% Type properties('menaGrid') for a list of public properties
%  
%% Methods
%
% Type methods('menaGrid') for a list of methods
% 
% Copyright 2008
% date: 14-August-2008
% Author: Felipe Orihuela-Espina
%
% See also analysis
%

%% Log
%
% 20-February-2022 (ESR): Get/Set Methods created in menaGrid
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   

classdef menaGrid
    properties (SetAccess=private, GetAccess=private)
        id=1;
        
        lineWidth=1.5;
        edgeColor = [0 0 0];

        highlightCells = [];
        highlightEdgeColor = [1 0 1];
        highlightFaceColor = [1 1 1]; %White
        highlightFaceAlpha = 1; %1 is no transparency
        labelCells = false;

        vertexVisible = false;
        vertexColor = [0 0 1];
        vertexMarker = '.';
        vertexMarkerSize = 8;
        

    end
 
    methods    
        function obj=menaGrid(varargin)
            %MENAGRID menaGrid class constructor
            %
            % obj=grid() creates a default grid with ID equals 1.
            %
            % obj=grid(obj2) acts as a copy constructor of grid
            %
            % obj=grid(id) creates a new grid with the given
            %   identifier (id).
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'grid')
                obj=varargin{1};
                return;
            else
                obj.id=varargin{1};
            end
            %assertInvariants(obj);

        end
   
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %edgeColor
        function val = get.edgeColor(obj)
            % The method is converted and encapsulated. 
            % obj is the menaGrid class
            % val is the value added in the object
            % get.edgeColor(obj) = Get the data from the edgeColor class
            % and look for the length object.
              val = obj.edgeColor; 
        end
        function obj = set.edgeColor(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the menaGrid class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type
           if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.edgeColor=rgb;
                end
           elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.edgeColor=val;
           else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
           end 
        end
        
        %highlightCells
        function val = get.highlightCells(obj)
            val = obj.highlightCells;
        end
        function obj = set.highlightCells(obj,val)
            if (all(isreal(val)) &&  ~ischar(val) ...
                  && all(val==floor(val)) && all(val>0) ...
                  && all(val<=getNCells(obj)))
                  obj.highlightCells= sort(unique(val));
           else
              error('ICNA:menaGrid:set:InvalidPropertyValue',...
                    ['Cell indexes must be a list positive ' ...
                     'integers and be within the number of ' ...
                     'existing cells.']);
           end
        end
        
        %highlightEdgeColor
        function val = get.highlightEdgeColor(obj)
            val = obj.highlightEdgeColor;
        end
        function obj = set.highlightEdgeColor(obj,val)
             if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                    if isempty(rgb)
                        error('ICNA:menaGrid:set:InvalidPropertyValue',...
                          'Invalid color descriptor.');
                    else
                        obj.highlightEdgeColor=rgb;
                    end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.highlightEdgeColor=val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end
        end
        
        %highlightFaceColor
        function val = get.highlightFaceColor(obj)
            val = obj.highlightFaceColor;
        end
        function obj = set.highlightFaceColor(obj,val)
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                    if isempty(rgb)
                        error('ICNA:menaGrid:set:InvalidPropertyValue',...
                          'Invalid color descriptor.');
                    else
                        obj.highlightFaceColor=rgb;
                    end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.highlightFaceColor=val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end
        end
        
        %highlightFaceAlpha
        function val = get.highlightFaceAlpha(obj)
            val = obj.highlightFaceAlpha;
        end
        function obj = set.highlightFaceAlpha(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                 && (val>=0) && (val<=1))
                obj.highlightFaceAlpha = val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                  'Value must be a positive real between 0 and 1.');
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
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
            end
        end
        
        %labelCells
        function val = get.labelCells(obj)
            val = obj.labelCells;
        end
        function obj = set.labelCells(obj,val)
            if (~ischar(val) && isscalar(val))
                obj.labelCells=logical(val);
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        end
        
        %lineWidth
        function val = get.lineWidth(obj)
            val = obj.lineWidth;
        end
        function obj = set.lineWidth(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.lineWidth = val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer');
            end
        end
        
        %vertexColor
        function val = get.vertexColor(obj)
            val = obj.vertexColor;
        end
        function obj = set.vertexColor(obj,val)
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                    if isempty(rgb)
                        error('ICNA:menaGrid:set:InvalidPropertyValue',...
                          'Invalid color descriptor.');
                    else
                        obj.vertexColor=rgb;
                    end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.vertexColor=val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end
        end
        
        %vertexMarker
        function val = get.vertexMarker(obj)
            val = obj.vertexMarker;
        end
        function obj = set.vertexMarker(obj,val)
            if (ischar(val) && length(val)==1)
                    if (ismember(val,'+o*.xsv^d><ph'))
                        obj.vertexMarker = val;
                    else
                        error('ICNA:menaGrid:set:InvalidPropertyValue',...
                          'Invalid marker');
                    end
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end
        end
        
        %vertexMarkerSize
        function val = get.vertexMarkerSize(obj)
            val = obj.vertexMarkerSize; 
        end
        function obj = set.vertexMarkerSize(obj,val)
            if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
                obj.vertexMarkerSize = val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Invalid markerSize. Must be a positive integer.');
            end
        end
        
        %vertexVisible
        function val = get.vertexVisible(obj)
            val = obj.vertexVisible;
        end
        function obj = set.vertexVisible(obj,val)
            if (~ischar(val) && isscalar(val))
                obj.vertexVisible=logical(val);
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        end
        
        
    end

    methods (Abstract=true)
        n=getNCells(obj);
        %Get the number of cells
        [x,y]=getCellCenter(obj,varargin);
        %Obtain the coordinates of the center of the cell
        idx=gridCell2ind(obj,varargin);
        %Obtain the index of a cell, given its position
        varargout=ind2gridCell(obj,idx);
        %Obtain position of the cell given its index
        idxs=inWhichCells(obj,pointset);
        %Gets the indexes of the cell in which lay each point in pointset
        pol=getPolygon(obj,varargin);
        %Gets the cartesian polygon of cell ready to be used in
        %MATLAB's inpolygon function
        varargout=plot(obj,varargin);
        %Displays the grid in a 2D space
    end
end

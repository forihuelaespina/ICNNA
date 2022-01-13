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

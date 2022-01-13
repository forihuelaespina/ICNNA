function val = get(obj, propName)
%MENAGRID/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - Changes the identifier of the object
% 'EdgeLineWidth' - Width of the frame lines
% 'EdgeLineColor' - The color of the frame lines as a normalized
%       RGB vector.
% 'HighlightCells' - A vector of indexes to grid cells that must be
%       highlighted
% 'HighlightEdgeColor' - The color of the cell boundaries as a normalized
%       RGB vector.
% 'HighlightFaceColor' - The color of the cell background as a normalized
%       RGB vector.
% 'HighlightFaceAlpha' - Transparency of the cell background. Value
%       must be in the range [0 1].
% 'LabelCells' - Whether to make the cell labels visible
% 'VertexVisible' - Visualize the grid vertex
% 'VertexColor' - Color of the marker representing the grid vertexes
%       as a nromalized RGB vector.
% 'VertexMarker' - Marker representing the grid vertexes
% 'VertexMarkerSize' - Size of the marker representing the grid vertexes
%
%
% Copyright 2008
% @date: 15-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also menaGrid, set
%

switch propName
case 'ID'
   val = obj.id;
case 'EdgeLineWidth'
   val = obj.lineWidth;
case 'EdgeLineColor'
   val = obj.edgeColor;
case 'HighlightCells'
   val = obj.highlightCells;
case 'HighlightEdgeColor'
   val = obj.highlightEdgeColor;
case 'HighlightFaceColor'
   val = obj.highlightFaceColor;
case 'HighlightFaceAlpha'
   val = obj.highlightFaceAlpha;
case 'LabelCells'
   val = obj.labelCells;
case 'VertexVisible'
   val = obj.vertexVisible;
case 'VertexColor'
   val = obj.vertexColor;
case 'VertexMarker'
   val = obj.vertexMarker;
case 'VertexMarkerSize'
   val = obj.vertexMarkerSize;   
otherwise
   error('ICNA:menaGrid:get:InvalidPropertyName',...
        [propName,' is not a valid property']);
end
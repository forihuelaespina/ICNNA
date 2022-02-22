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

%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the menaGrid class.
%

    val = obj.(lower(propName)); %Ignore case
end
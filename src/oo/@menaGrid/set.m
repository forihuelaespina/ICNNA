function obj = set(obj,varargin)
% MENAGRID/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
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
% See also menaGrid, get
%

%% Log
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the menaGrid class.
%  

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);

   obj.(lower(prop)) = val; %Ignore case
end
    assertInvariants(obj);

end

function rgb=getColorVector(ch)
%Returns a color vector from a caracter color descriptor
%or an empty string if the caracter is not recognised.
switch (ch)
    case 'r'
        rgb = [1 0 0];
    case 'g'
        rgb = [0 1 0];
    case 'b'
        rgb = [0 0 1];
    case 'k'
        rgb = [0 0 0];
    case 'w'
        rgb = [1 1 1];
    case 'm'
        rgb = [1 0 1];
    case 'c'
        rgb = [0 1 1];
    case 'y'
        rgb = [1 1 0];
    otherwise
        rgb=[];
end
end   
    
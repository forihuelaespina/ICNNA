function display(obj)
%MENAGRID/DISPLAY Command window display of a rawData
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 15-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also menaGrid, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   Edge Line Width: ' num2str(obj.lineWidth)]);
disp(['   Edge Color: ' mat2str(obj.edgeColor)]);

disp(['   Highlight Cells: ' mat2str(obj.highlightCells)]);
disp(['   Highlight Edge Color: ' mat2str(obj.highlightEdgeColor)]);
disp(['   Highlight Face Color: ' mat2str(obj.highlightFaceColor)]);
disp(['   Highlight Face Alpha: ' num2str(obj.highlightFaceAlpha)]);

if obj.labelCells
    disp('   Label Cells?: TRUE');
else
    disp('   Label Cells?: FALSE');
end

if obj.vertexVisible
    disp('   Vertex visible?: TRUE');
else
    disp('   Vertex visible?: FALSE');
end

disp(['   Vertex Color: ' mat2str(obj.vertexColor)]);
disp(['   Vertex Marker: ' obj.vertexMarker]);
disp(['   Vertex Marker Size: ' num2str(obj.vertexMarkerSize)]);

disp(' ');

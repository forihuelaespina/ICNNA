function display(obj)
%LOGARITHMICRADIALGRID/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 15-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');

%== Inherited
disp(['   ID: ' num2str(get(obj,'ID'))]);

disp(['   Edge Line Width: ' num2str(get(obj,'EdgeLineWidth'))]);
disp(['   Edge Color: ' mat2str(get(obj,'EdgeLineColor'))]);

disp(['   Highlight Cells: ' mat2str(get(obj,'HighlightCells'))]);
disp(['   Highlight Edge Color: ' mat2str(get(obj,'HighlightEdgeColor'))]);
disp(['   Highlight Face Color: ' mat2str(get(obj,'HighlightFaceColor'))]);
disp(['   Highlight Face Alpha: ' num2str(get(obj,'HighlightFaceAlpha'))]);

if get(obj,'LabelCells')
    disp('   Label Cells?: TRUE');
else
    disp('   Label Cells?: FALSE');
end

if get(obj,'VertexVisible')
    disp('   Vertex visible?: TRUE');
else
    disp('   Vertex visible?: FALSE');
end

disp(['   Vertex Color: ' mat2str(get(obj,'VertexColor'))]);
disp(['   Vertex Marker: ''' get(obj,'VertexMarker') '''']);
disp(['   Vertex Marker Size: ' num2str(get(obj,'VertexMarkerSize'))]);


%== this class
disp(['   Minimum Radius: ' num2str(obj.minR)]);
disp(['   Maximum Radius: ' num2str(obj.maxR)]);
disp(['   Number of Rings: ' num2str(obj.nRings)]);
disp(['   Number of Angles (degrees): ' num2str(obj.nAngles) ...
            ' (' num2str(360/obj.nAngles) ')' ]);

disp(' ');

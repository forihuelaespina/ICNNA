function res=eq(obj,obj2)
%MENAGRID/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008
% @date: 15-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also menaGrid
%

res=true;
if ~isa(obj2,'menaGrid')
    res=false;
    return
end

res = res && (get(obj,'ID')==get(obj2,'ID'));
res = res && (get(obj,'EdgeLineWidth')==get(obj2,'EdgeLineWidth'));
res = res && all(get(obj,'EdgeLineColor')==get(obj2,'EdgeLineColor'));

res = res && all(get(obj,'HighlightCells')==get(obj2,'HighlightCells'));
res = res && all(get(obj,'HighlightEdgeColor')==get(obj2,'HighlightEdgeColor'));
res = res && all(get(obj,'HighlightFaceColor')==get(obj2,'HighlightFaceColor'));
res = res && (get(obj,'HighlightFaceAlpha')==get(obj2,'HighlightFaceAlpha'));

res = res && (get(obj,'LabelCells')==get(obj2,'LabelCells'));

res = res && (get(obj,'VertexVisible')==get(obj2,'VertexVisible'));
res = res && all(get(obj,'VertexColor')==get(obj2,'VertexColor'));
res = res && strcmp(get(obj,'VertexMarker'),get(obj2,'VertexMarker'));
res = res && all(get(obj,'VertexMarkerSize')==get(obj2,'VertexMarkerSize'));


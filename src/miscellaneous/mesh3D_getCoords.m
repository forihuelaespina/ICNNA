function [coords,idx]=mesh3D_getCoords(g,tag)
%Look for a point coordinates
%
% [coords,idx]=mesh3D_getCoords(g,tag) Look for a point coordinates
%   identified by its associated tags.
%
%
%
%% Parameters
%
% g - The grid/mesh. A struct with fields for
%   coordinates (.coords), triangular faces (.faces)
%   and tags associated to vertex (.tags)
%
%
%% Output
%
% coords - The 3D coordinates of the point or empty if point is
%   not found
%
% idx - The index of the point in the g.coords, or empty if
%   the point is not found
%
%
% Copyright 2009
% @author Felipe Orihuela-Espina
% @date: 27-Mar-2009
%
% See also generateOptodePositioningSystemGrid, mesh3D_visualize,
%   mesh3D_rotation, mesh3D_traslation
%



tmp=length(g.coords);
coords=[];
idx=[];
for ii=1:tmp
    if strcmp(g.tags{ii},tag)
        coords=g.coords(ii,:);
        idx=ii;
        break
    end
end
if isempty(coords)
    warning('ICAF:mesh3D_getCoords',['Point ' tag ' not found.']);
end
end
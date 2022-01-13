function [g]=mesh3D_traslation(g,xTras,yTras,zTras)
%Translation of a 3D mesh
%
% [g]=mesh3D_traslation(g,xTras,yTras,zTras)
%
%% Parameters
% g - a Nx3 matrix representing a 3D mesh of N points
% xTras,yTras,zTras - Traslation along the axes. Use 0 for no traslation
%
% Copyright 2009
% @author Felipe Orihuela-Espina
% @date: 19-Mar-2009
%
% See also mesh3D_scale, mesh3D_reflection, mesh3D_shearing
%

%In Homogeneous Coordinates
S=eye(4);
S(1,4)=xTras;
S(2,4)=yTras;
S(3,4)=zTras;

%4x4 * 4xN= 4xN
g=S*[g'; ones(1,size(g,1))];
g(4,:)=[];
g=g';
end
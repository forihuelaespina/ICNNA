function [g]=mesh3D_scale(g,xScale,yScale,zScale)
%Deform a 3D mesh non-uniformaly along the different axes
%
% [g]=mesh3D_scale(g,xScale,yScale,zScale)
%
%
%Note that if xScale==yScale==zScale, then the scaling is uniform
%
%
%% Parameters
% g - a Nx3 matrix representing a 3D mesh of N points
% xScale,yScale,zScale - Scales along the axes. Use 1 for no scaling.
%
% Copyright 2009
%Roughly following the tutorial in:
%http://www.cs.sfu.ca/~torsten/Teaching/Cmpt466/LectureNotes/PDF/07_deformations.pdf
% @author Felipe Orihuela-Espina
% @date: 19-Mar-2009
%
% See also mesh3D_traslation, mesh3D_reflection, mesh3D_shearing
%

%In Homogeneous Coordinates
S=eye(4);
S(1,1)=xScale;
S(2,2)=yScale;
S(3,3)=zScale;

%4x4 * 4xN= 4xN
g=S*[g'; ones(1,size(g,1))];
g(4,:)=[];
g=g';
end

function [g]=mesh3D_reflection(g,xReflection,yReflection,zReflection)
%Reflection of a 3D mesh along the different axes
%
% [g]=mesh3D_reflection(g,xReflection,yReflection,zReflection
%
%% Parameters
% g - a Nx3 matrix representing a 3D mesh of N points
% xReflection,yReflection,zReflection - Reflection along the axes.
%   Use 1 or true if you want reflection around the
%   corresponding axes, or 0 or false for those
%   axes when no reflection is required.
%
% Copyright 2009
% @author Felipe Orihuela-Espina
% @date: 23-Mar-2009
%
% See also mesh3D_scale, mesh3D_traslation, mesh3D_shearing
%

%In Homogeneous Coordinates
reflection=[xReflection,yReflection,zReflection];
naxes = length(reflection);
for tmp=1:naxes
    if reflection(tmp)
        S=eye(4);
        S(tmp,tmp)=-1;
        %4x4 * 4xN= 4xN
        g=S*[g'; ones(1,size(g,1))];
        g(4,:)=[];
        g=g';
    end
end
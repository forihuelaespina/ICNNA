function [g]=mesh3D_shearing(g,vec)
%Transforms a 3D cube mesh into a general parallelepiped
%
% [g]=mesh3D_shearing(g,vec)
%
%Change in each coordinate is a linear combination of
%all three.
%
%
%       +------+              +------+
%      /      /|             /|     /|
%     +------+ +    =>      /.|..../ |
%     |      |/             | +----:-+
%     +------+              |/______/
%
% Please refer to http://www.cs.brandeis.edu/~cs155/Lecture_07_6.pdf
%for a nicer picture
%
%
%% Parameters
% g - a Nx3 matrix representing a 3D mesh of N points
% vec - a 6D vector [a b c d e f] so that
%       [1 a b 0;
%        c 1 d 0;
%        e f 1 0;
%        0 0 0 1]
%
%   where:
%       a is the contribution of y to x
%       b is the contribution of z to x
%       c is the contribution of x to y
%       d is the contribution of z to y
%       e is the contribution of x to z
%       f is the contribution of y to z
%
%
%
%
% Copyright 2009
% @author Felipe Orihuela-Espina
% @date: 19-Mar-2009
%
% See also mesh3D_scale, mesh3D_tralation, mesh3D_reflection
%

%In Homogeneous Coordinates
S=eye(4);
S(1,2)=vec(1);
S(1,3)=vec(2);
S(2,1)=vec(3);
S(2,3)=vec(4);
S(3,1)=vec(5);
S(3,2)=vec(6);

%4x4 * 4xN= 4xN
g=S*[g'; ones(1,size(g,1))];
g(4,:)=[];
g=g';
end
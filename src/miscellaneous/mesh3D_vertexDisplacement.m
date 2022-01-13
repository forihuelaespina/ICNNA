function [g]=mesh3D_vertexDisplacement(g,vIdx,newPos,k,n)
%Deform a 3D grid by vertex displacement
%
% [g]=mesh3D_vertexDisplacement(g,vIdx,newPos)
%
%
%% Algorithm
%
% See references [1] and [2]
%
% If vertex i is displaced by (x, y, z) units; then
%   displace each neighbor, j, of i by
%       (x, y, z) * f(i, j)
% The function f(i,j) is typically a function of distance:
%   - Euclidean distance
%   - Number of edges from i to j
%   - Distance along surface (Here we use the geodesic as computed
%   with Floyd algorithm)
%
%
%% Parameters
%
% g - a Nx3 matrix representing a 3D mesh of N points
% vIdx - An index to the point in g
% newPos - A 3D vector with the new position for g(vIdx,:)
% k - (Optional) Elasticity constant.
%       k=0 (default) - Linear
%       k<0 - Rigid
%       k>0 - Elastic
% n - (Optional) Range.
%           In the original algorithm (see Ref [2]) it
%       represented the maximum number of edges affected.
%           In my implementation is represents the maximum
%       geodesic distance affected.
%       By default is set to 1.
%
%% References
%
% [1] http://www.cs.sfu.ca/~torsten/Teaching/Cmpt466/
%           LectureNotes/PDF/07_deformations.pdf
% [2] Parent, Rick (2001) "Computer Animation" Morgan-Kaufmann
%       pg. 125
%
%
%
% Copyright 2009
% @author Felipe Orihuela-Espina
% @date: 19-Mar-2009
%
% See also mesh3D_scale, mesh3D_reflection, mesh3D_traslation,
%   mesh3D_rotation
%

if ~exist('k','var') || isempty(k)
    k=0;
end
if ~exist('n','var') || isempty(n)
    n=1;
end

%% Step 1: Compute distance function
D=Floyd(squareform(pdist(g)));

%% Step 2: Get reference points coordinates and displacement
v=g(vIdx,:);
d=newPos-v;

%% Step 3: Compute attenuation
%My modification about the range (so range is the maximum
%geodesic distance)
if k>=0
    S=1-(D(:,vIdx)/(n+eps)).^(k+1);
else %k<0
    S=(1-(D(:,vIdx)/(n+eps))).^(-k+1);
end
N=find(D(:,vIdx)>n); %Attenuation beyond range must be complete
                %so points outside range remain unmoved
S(N)=0;

%%Original in Ref [2]
% if k>=0
%     S=1-(D(:,vIdx)/(n+1)).^(k+1);
% else %k<0
%     S=(1-(D(:,vIdx)/(n+1))).^(-k+1);
% end

%% Step 4: Vertex displacement
nDims = size(g,2);
for dim=1:nDims
    g(:,dim)=g(:,dim)+d(dim)*S(:);
end

% nPoints = size(g,1);
% for pp=1:nPoints
%     p=g(pp,:);
%     g(pp,:)=p+d*S(pp);
% end



function v=volumeOfTriangulation(X,T)
%Computes the volume (or area in 2D) of a given triangulation
%
% v=volumeOfTriangulation(X,T)
%
%
%% Algorithm
%
% The algorithm is naive; The volume of the triangulation is the sum
%of the individual volumes of the simplexes in the triangulation.
%
%% Volume of n-dimensional simplex
%
% From Wikipedia: http://en.wikipedia.org/wiki/Simplex
%
% "The oriented volume of an n-simplex in n-dimensional space
%with vertices (v0, ..., vn) is
%
% Volume=(1/n!)*det(v1-v0 v2-v0 ... vn-v0)
%
% where each column of the n × n determinant is the difference
%between the vectors representing two vertices."
%
% Actually, it is necessary to take the absolute value of the formula
%above since the determinant may be negative representing the "direction"
%of the matrix.
%
%
%% Parameters:
% X - the data set of points. One row per point and one column per
%   dimension
% T - A triangulation. It can be the Delaunay trinagulation, the convex
%   hull or the alpha complex. Each row
%   is a simplex. The simplex is indicated as the indexes to the points
%   in the dataset X.
%
%% Output:
%
% v - The volume (or area in 2D) enclosed by the triangulation
%
%
%
% Copyright 2012
% @date: 17-Jun-2012
% @author: Felipe Orihuela-Espina
% @modified: 17-Jun-2012
%
% See also nsphere, myAlphaComplex
%

nSimplexes = size(T,1);

v=0;
for ss=1:nSimplexes
    pIdx=T(ss,:);
    v=v+simplexVolume(X(pIdx,:));
end

end

%%Auxiliar function
function v=simplexVolume(X)
%Volume of an n-dimensional simplex
%
% X - Simplex vertices. Each row is a point.
[nPoints,Dim]=size(X);
assert(nPoints==Dim+1,'A n-dimensional simplex requires n+1 points.');
X=X'; %Now each column is a point
D=X(:,2:end)-repmat(X(:,1),1,nPoints-1);
v=abs(det(D))/factorial(Dim);
end
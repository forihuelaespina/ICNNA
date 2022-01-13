function D=Floyd(D)
%Compute shortest path using Floyd's algorithm
%
%
% D=Floyd(D)
%
%Implements Floyd's algorithm to compute shortest path
%
% Floyd's algorithm produces the best performance in Matlab [Tenenbaum, 2000]. 
% Dijkstra's algorithm is significantly more efficient for sparse graphs, 
% but requires for-loops that are very slow to run in Matlab.
%
%
%% References
%
%  J. B. Tenenbaum, V. de Silva, J. C. Langford (2000).  A global
%  geometric framework for nonlinear dimensionality reduction.  
%  Science 290 (5500): 2319-2323, 22 December 2000.  
%
%% Parameters
%
% D - A (square) pairwaise distance matrix.
%
%% Output
%
% D - A (symmetric) pairwise distance matrix where original
%distances have been replace by the shortest path distances
%wherever necessary.
%
%
% Date: 1-Oct-2007
% Author: Felipe Orihuela Espina
%    Code is a simple extraction (with minor modifications) from
%      Tenenbaum's Isomap.m function [Tenenbaum, 2000].
%
%See also: pruneDistances, geodesic
%
N = size(D,1); 
if ~(N==size(D,2))
     error('D must be a square matrix'); 
end; 


%Note that the classical sequential algorithm has been
%improved by tiling and replicating the part of the
%distance matrix that remains to be explored. That saves
%a couple of for-loops.
%
% See http://www-unix.mcs.anl.gov/dbpp/text/node35.html for
%the pseudocode of the sequential algorithm.
% 
tic; 
for k=1:N
     D = min(D,repmat(D(:,k),[1 N])+repmat(D(k,:),[N 1])); 
     if (rem(k,50) == 0) 
          disp([' Iteration: ' num2str(k) '     Estimated time to completion: ' num2str((N-k)*toc/k/60) ' minutes']); 
     end
end

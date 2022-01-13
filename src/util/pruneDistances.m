function [D, INF, E]=pruneDistances(D, n_fcn, n_size)
%Prune distances not belonging to neighbourhood (non adjacent)
%
%
% DD=pruneDistances(D, n_fcn, n_size, options)
%
%Take a full (square) matrix of pairwise distances between
%nodes in a (non-directed) weighted graph and prune
%those distances not belonging to each point neighbourhood. The
%fact that the graph is non-directed means that the weights or
%distance matrix is symmetric.
%
%There are two ways to indicate a neighbourhood [Belkin, 2003],
%[Tenenbaum, 2000]:
%
%   (a) Epsilon-neighbourhoods: Nodes are neighbours if the distance
%           between them is smaller than epsilon
%   (b) keep k nearest neighbours.
%
%   Epsilon neighbourhoods often lead to graphs with several connected
%components, and is difficult to choose the parameter epsilon, but
%the result is more naturally symmetric. On the contrary, keeping
%k nearest neighbours is easier to choose, and does not tend to lead
%to disconnected graphs, however it is less geometrically intuitive.
%
%% References:
%
%  J. B. Tenenbaum, V. de Silva, J. C. Langford (2000).  A global
%  geometric framework for nonlinear dimensionality reduction.  
%  Science 290 (5500): 2319-2323, 22 December 2000.  
%
%  Belkin, Mikhail and Niyogi, Partha; (2003). Laplacian eigenmaps
%   for dimensionality reduction and data representation.
%   Neural Computation 15:1373-1396
%
%% Parameters:
%
% D - A (square) pairwaise distance matrix
% n_fcn - neighborhood function ('epsilon' or 'k') 
% n_size - neighborhood size (value for epsilon or k) 
%
%
%% Output:
%
% D - A (symmetric) pairwise distance matrix where distances
%outside the neighbourhood have been substituted by a value
%which is to practical terms effectively infinite.
%
% INF - A very high value which in practical terms is
%effectively infinite. It is calculated from original D so
%it is different everytime.
%
% E - edge matrix for neighborhood graph
%
%
%
% Date: 1-Oct-2007
% Author: Felipe Orihuela Espina
%     Code is a simple extraction (with minor modifications) from
%       Tenenbaum's Isomap.m function [Tenenbaum, 2000].
%
%See also: Floyd, geodesic
%

%Deal with options
N = size(D,1); 
if ~(N==size(D,2))
     error('D must be a square matrix'); 
end; 
if n_fcn=='k'
     K = n_size; 
     if ~(K==round(K))
         error('Number of neighbors for k method must be an integer');
     end
elseif strcmp(n_fcn,'epsilon')
     epsilon = n_size; 
else 
     error('Neighborhood function must be either epsilon or k'); 
end
INF =  1000*max(max(D))*N;  %% effectively infinite distance

%Prune everything outside the neighbour
if n_fcn == 'k'
     [tmp, ind] = sort(D); 
     for i=1:N
          D(i,ind((2+K):end,i)) = INF; 
     end
elseif strcmp(n_fcn,'epsilon')
     warning off    %% Next line causes an unnecessary warning, so turn it off
     D =  D./(D<=epsilon); 
     D = min(D,INF); 
     warning on
end
D = min(D,D');    %% Make sure distance matrix is symmetric

% Finite entries in D now correspond to distances between
%neighboring points. 
% Infinite entries (really, equal to INF) in D now correspond to 
%   non-neighoring points. 

E = int8(1-(D==INF));  %%  Edge information
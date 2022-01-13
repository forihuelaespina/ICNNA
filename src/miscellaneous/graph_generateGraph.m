function A=graph_generateGraph(optodeArray,varargin)
%Generate a graph (regular, small-world or random) for a certain optode
%array type (3x3, 3x5, 4x4)
%
%
% A=graph_generateGraph(optodeArray,graphType) Generate a graph (regular,
%   small-world or random) for a certain optode array type
%   (3x3, 3x5, 4x4).
%
% A=graph_generateGraph(optodeArray,p) Generate a graph for a
%   certain optode array type (3x3, 3x5, 4x4). From a regular graph
%   edges are rewired with probability p. When p=0, then the graph
%   is the regular graph. When p->1, then the graph is a random grap.
%   When p is small a small-world network is generated.
%
%
%% Graph types
%
%Node neighbourhood is determined by the optode array type.
%
% * Regular network (or lattice): Nodes are connected to their
%   neighbours. These networks are highly clustered but their
%   minimum averaged pathlength is long.
%
% * Random: Edges are randomly distributed over the network. These
%   networks exhibit short minimum averaged pathlength but clustering
%   is low.
%
% * Small-world: A type of graph resulting from rewiring a few edges
%   in a regular network. It exhibits high clustering yet achieveing
%   short pathlength.
%
%
% Rewiring algorithm is that in [WattsDJ1998]
%
%% Parameters
%
% optodeArray - A string identifying the optode array type (e.g.
%   '3x3', '3x5' or '4x4'). This determines channel (node) neighbours.
%
% graphType - The type of graph to be generated. The default is 'regular'
%   with rewiring probability 0.
%   For 'random' a rewiring proability of 1 is assigned. For 'smallworld'
%   a rewiring probability of 0.1 is used.
%
%           NOTE: For small-world, a common p rewiring value is 0.01.
%           However, this is for large networks. In small networks,
%           this probability means that often rewiring only affects
%           just 1 or 2 edges, so a slightly larger rewiring probability
%           is used.
%
% p - The edge rewiring probability. When p=0, then the graph
%   is the regular graph. When p->1, then the graph is a random grap.
%   When p is small a small-world network is generated.
%
%
%
%% Output
%
% A - The adjacency matrix of the graph. The number of nodes
%   depend on the optode array type.
%
%% References:
%
% [WattsDJ1998] Watts, D. J. and Strogatz, S. H. (1998) "Collective
%   dynamics of small-world networks" Nature, 393:440-442
%
% [SmithBassetD2006] Smith Basset, D. and Bullmore, E. (2006) "Small-world
%   brain networks" Neuroscientist, 12(6):512-523
%
% [SpornsO2004] Sporns, O. and Zwi, J. D. (2004) "The small-world
%   of the cerebral cortex" Neuroinformatics, Special Issue on
%   Functional Connectivity, 2004, 2, 145-162
%
% [StrogatzSH2001] Steven H. Strogatz (2001) "Exploring
%   complex networks" Nature 410:268-276
%
%
%
% Copyright 2011
% @date: 19-May-2011
% @author: Felipe Orihuela-Espina
% @modified: 19-May-2011
%
% See also 
%

p=0;
if ischar(varargin{1})
    graphType = varargin{1};
else
    p = varargin{1};
end

%Generate a base regular network based on the neighbourhood
%determined by the optode array
A = generateRegularGraph(optodeArray);

if exist('graphType','var')
    switch(graphType)
        case 'regular'
            p=0;
        case 'random'
            p=1;
        case 'smallworld'
            p=0.1;
        otherwise
            error('Invalid graph type.');
    end
end

nNodes = size(A,1);
P=(rand(nNodes)<p) & A;
%Rewire as required
for ee=1:numel(A)
    if P(ee)
        A(ee) = 0;
        ff = round(1 + (numel(A)-1).*rand(1));
        A(ff) = 1;
    end
end

end

%% AUXILIAR FUNCTION
function A = generateRegularGraph(optodeArray)
%Generate a reular graph for a certain optode array type
% optodeArray - String identifying the optode array type (e.g.
%   '3x3', '3x5' or '4x4'). This determines channel (node) neighbours.
% A - The adjacency matrix
A=[];
switch (optodeArray)
    case '3x3'
        A = eye(24);
        A(1,[2 3 4]) = 1;
        A(2,[1 4 5]) = 1;
        A(3,[1 4 6 8]) = 1;
        A(4,[1 2 3 5 6 7]) = 1;
        A(5,[2 4 7 10]) = 1;
        A(6,[3 4 7 8 9]) = 1;
        A(7,[4 5 6 9 10]) = 1;
        A(8,[3 6 9 11]) = 1;
        A(9,[6 7 8 10 11 12]) = 1;
        A(10,[5 7 9 12]) = 1;
        A(11,[8 9 12]) = 1;
        A(12,[9 10 11]) = 1;
        
        A(13,[14 15 16]) = 1;
        A(14,[13 16 17]) = 1;
        A(15,[13 16 18 20]) = 1;
        A(16,[13 14 15 17 18 19]) = 1;
        A(17,[14 16 19 22]) = 1;
        A(18,[15 16 19 20 21]) = 1;
        A(19,[16 17 18 21 22]) = 1;
        A(20,[15 18 21 23]) = 1;
        A(21,[18 19 20 22 23 24]) = 1;
        A(22,[17 19 21 24]) = 1;
        A(23,[20 21 24]) = 1;
        A(24,[21 22 23]) = 1;
        
    case '3x5'
        A = eye(22);
        A(1,[2 5 6]) = 1;
        A(2,[1 3 6 7]) = 1;
        A(3,[2 4 7 8]) = 1;
        A(4,[3 8 9]) = 1;
        A(5,[1 6 10 14]) = 1;
        A(6,[1 2 5 7 10 11]) = 1;
        A(7,[2 3 6 8 11 12]) = 1;
        A(8,[3 4 7 9 12 13]) = 1;
        A(9,[4 8 13 18]) = 1;
        A(10,[5 6 11 14 15]) = 1;
        A(11,[6 7 10 12 15 16]) = 1;

        A(12,[7 8 11 13 16 17]) = 1;
        A(13,[8 9 12 17 18]) = 1;
        A(14,[5 10 15 19]) = 1;
        A(15,[10 11 14 16 19 20]) = 1;
        A(16,[11 12 15 17 20 21]) = 1;
        A(17,[12 13 16 18 21 22]) = 1;
        A(18,[9 13 17 22]) = 1;
        A(19,[14 15 20]) = 1;
        A(20,[15 16 19 21]) = 1;
        A(21,[16 17 20 22]) = 1;
        A(22,[17 18 21]) = 1;
        
    case '4x4'
        A = eye(24);
        A(1,[2 4 5]) = 1;
        A(2,[1 3 5 6]) = 1;
        A(3,[2 6 7]) = 1;
        A(4,[1 5 8 11]) = 1;
        A(5,[1 2 4 6 8 9]) = 1;
        A(6,[2 3 5 7 9 10]) = 1;
        A(7,[3 6 10 14]) = 1;
        A(8,[4 5 9 11 12]) = 1;
        A(9,[5 6 8 10 12 13]) = 1;
        A(10,[6 7 9 13 14]) = 1;
        A(11,[4 8 12 15 18]) = 1;
        A(12,[8 9 11 13 15 16]) = 1;
        
        A(13,[9 10 12 14 16 17]) = 1;
        A(14,[7 10 13 17 21]) = 1;
        A(15,[11 12 16 18 19]) = 1;
        A(16,[12 13 15 17 19 20]) = 1;
        A(17,[13 14 16 20 21]) = 1;
        A(18,[11 15 19 22]) = 1;
        A(19,[15 16 18 20 22 23]) = 1;
        A(20,[16 17 19 21 23 24]) = 1;
        A(21,[14 17 20 24]) = 1;
        A(22,[18 19 23]) = 1;
        A(23,[19 20 22 24]) = 1;
        A(24,[20 21 23]) = 1;
     otherwise
        error('Unexpected optode array type.');
end
end


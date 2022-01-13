function obj=setCluster(obj,id,c)
% ANALYSIS/SETCLUSTER Replace a cluster
%
% obj=setCluster(obj,id,newCluster) Replace cluster whose ID==id
%   with the new cluster. If the cluster whose ID==id has not been
%   defined, then nothing is done.
%
% Copyright 2008
% @date: 26-May-2008
% @author Felipe Orihuela-Espina
%
% See also addCluster, removeCluster
%

idx=findCluster(obj,id);
if (~isempty(idx))
    obj.clusters(idx)={cluster(c)}; %Ensuring that c is a cluster
end
assertInvariants(obj);
function obj=addCluster(obj,c)
% ANALYSIS/ADDCLUSTER Add a new cluster to the analysis
%
% obj=addCluster(obj,c) Add a new cluster to the analysis. If
%   a cluster with the same ID has already been defined within
%   the analysis, then a warning is issued
%   and nothing is done.
%
% Copyright 2008
% @date: 26-May-2008
% @author Felipe Orihuela-Espina
%
% See also removeCluster, setCluster, clearClusters
%

%Ensure that c is a cluster
if isa(c,'cluster')
    idx=findCluster(obj,get(c,'ID'));
    if isempty(idx)
        obj.clusters(end+1)={c};
    else
        warning('ICNA:analysis:addCluster:RepeatedID',...
            'A cluster with the same ID has already been defined.');
    end
else
    error('ICNA:analysis:addCluster:InvalidInputParameter',...
            [inputname(2) ' is not a cluster']);
end
assertInvariants(obj);
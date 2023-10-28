function obj=addCluster(obj,c)
% ANALYSIS/ADDCLUSTER Add a new cluster to the analysis
%
% obj=addCluster(obj,c) Add a new cluster to the analysis. If
%   a cluster with the same ID has already been defined within
%   the analysis, then a warning is issued
%   and nothing is done.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also removeCluster, setCluster, clearClusters
%



%% Log
%
% File created: 26-May-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%




%Ensure that c is a cluster
if isa(c,'cluster')
    idx=findCluster(obj,c.id);
    if isempty(idx)
        obj.clusters(end+1)={c};
    else
        warning('ICNNA:analysis:addCluster:RepeatedID',...
            'A cluster with the same ID has already been defined.');
    end
else
    error('ICNNA:analysis:addCluster:InvalidInputParameter',...
            [inputname(2) ' is not a cluster']);
end
assertInvariants(obj);


end
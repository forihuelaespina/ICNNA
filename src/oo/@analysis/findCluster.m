function idx=findCluster(obj,id)
%ANALYSIS/FINDCLUSTER Finds a cluster within the analysis
%
% idx=findCluster(obj,id) returns the index of the cluster.
%   If the cluster has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also analysis, assertInvariants



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


nElements=obj.nClusters;
idx=[];
for ii=1:nElements
    tmp = obj.clusters{ii};
    if (id == tmp.id)
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end


end
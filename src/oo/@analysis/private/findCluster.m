function idx=findCluster(obj,id)
%ANALYSIS/FINDCLUSTER Finds a cluster within the analysis
%
% idx=findCluster(obj,id) returns the index of the cluster.
%   If the cluster has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008
% @date: 26-May-2008
% @author Felipe Orihuela-Espina
%
% See also analysis, assertInvariants

nElements=length(obj.clusters);
idx=[];
for ii=1:nElements
    tmpID=get(obj.clusters{ii},'ID');
    if (id==tmpID)
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end
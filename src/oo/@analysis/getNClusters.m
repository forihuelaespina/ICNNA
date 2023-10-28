function n=getNClusters(obj)
%ANALYSIS/GETNCLUSTERS DEPRECATED (v1.2). Gets the number of clusters defined in the analysis
%
% n=getNClusters(obj) Gets the number of clusters defined in the analysis
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also findCluster, getClusterList
%


%% Log
%
% File created: 26-May-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%


warning('ICNNA:analysis:getNClusters:Deprecated',...
        ['Method DEPRECATED (v1.2). Use analysis.nClusters instead.']); 
    %Maintain method by now to accept different capitalization though.


%n=length(obj.clusters);
n = obj.nClusters;

end

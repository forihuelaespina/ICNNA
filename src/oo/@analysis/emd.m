function [emdDistances]=emd(obj,highlow)
% ANALYSIS/EMD Calculates EMD between all clusters
%
% [emdDistances]=emd(obj) Calculates EMD between all clusters
%   in the Projection Space.
%
% [emdDistances]=emd(obj,'low') Calculates EMD between all
%   clusters in the Projection Space.
%
% [emdDistances]=emd(obj,'high') Calculates EMD between all
%   clusters in the Feature Space.
%
%
% EMD (Earth Mover's Distance) [Rubner,1998] is a general
% method for matching multidimensional distributions
% (i.e. sets of points in a space).
%
% Please note that in the original paper by Rubner, each point of the
%distribution is called a cluster, which cluster actually does not
%mean a set cluster of points, but actually the
%<point coordinates, point weight>. The set of points is actually the
%distribution or signature!
%
% In this function the analysis clusters are the signatures
%to be compared. All clusters (visible or not) are included in the
%analysis.
%
%               | Cluster 1 | Cluster 2 | ... | Cluster n |
%       --------+-----------+-----------+-----+-----------+
%     Cluster 1 |    d11    |    d12    | ... |     d1n   |
%       --------+-----------+-----------+-----+-----------+
%     Cluster 2 |    d21    |    d22    | ... |     d2n   |
%       --------+-----------+-----------+-----+-----------+
%          ...  |    ...    |    ...    | ... |     ...   |
%       --------+-----------+-----------+-----+-----------+
%     Cluster n |     d1n   |    d12    | ... |     dnn   |
%       --------+-----------+-----------+-----+-----------+
%
% This square matrix have some particularities. The diagonal
%elements dii MUST be 0, i.e. Signature i (Cluster i) is equal
%to itself, and thus no effort is required to transform a
%distribution i (Cluster i) into a "different" distribution i
%(Cluster i). Also, is a simetrical matrix, which
%means that dij=dji, i.e. transforming signature i into
%signature j requires the same effort as transforming
%signature j into signature i.
%
% A signature (the behaviour a each cluster across different
%channels) in the underlying space Y is made up of a set
%of points which describes it. Each <clm,subject,channel> is
%a point of the distribution. Each point is represented by
%a center (e.g. the coordinates) and a size, a.k.a. weight,
%of that point. In the case of MENA, each point in the clsuter
%has the same weight, so the weight are 1/nPoints.
%
%
%% Remarks
%
% This function requires the analysis to have been run
%('RunStatus' equals true). Please refer to method run.
%
%If one cluster has no points attached, a warning is issued
%and the EMD distance to any other cluster is set to -1. 
%
% The function calculates the distance between ALL defined
%clusters, regardless of whether they are visible or not.
%
%% Known Bugs
%
% EMD implementation has a limitation of the number of
%points that can be included in the signatures.
%
% EMD implementation may reach the maximum number of iterations
%without converging.
%
%% Parameters
%
% obj - An analysis object
%
% high/low - A string to indicate whether the EMD analysis is to be
%computed in the Feature ('high') or in the Projection Space ('low').
%The default value is 'low'.
%
%
%% Output
%
% The EMD distances between clusters
%
%                     +-------> Cluster
%                     |
%             Cluster |
%                     |
%                     v
%
%   So for instance M(cli,clj) will give you the distance between
%  clusters i and j.
%
%
%
%% References
%
% [Rubner, 1998] Rubner, Yossi; Tomasi, Carlo and Guibas, Leonidas J.
%   "A Metric for Distributions with Applications to Image Databases"
%   Sixth International Conference on Computer Vision (1998). pgs 59-66
%   4-7 Jan Bombay India, DOI: 10.1109/ICCV.1998.710701
%
%
% Copyright 2008-23
% Copyright EMD Rubner et al
% @author: Felipe Orihuela Espina
%
% See also: analysis, run, mena_metric
%



%% Log
%
% File created: 12-Aug-2008
% File last modified (before creation of this log): 23-Aug-2012
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Started to use get/set methods for struct like access.
%   + Error codes changed from ICNA to ICNNA.
%



if ~obj.runStatus
    error('ICNNA:analysis:emd:AnalysisNotRun',...
        'Analysis must be run prior to computing EMD.');
end


%% Deal with options
HL='low';
if exist('highlow','var')
    switch (highlow)
        case 'low'
            HL=highlow;
        case 'high'
            HL=highlow;
        otherwise
            warning('ICNNA:analysis:emd:InvalidParameterValue',...
                ['Invalid parameter value. ' ...
                 'Use ''high'' or ''low'' for the Feature and ' ...
                 'Projection Space respectively.']);
    end
end


hWait = waitbar(0,'Computing pairwise distances - 0%',...
                'Name','EMD');

if strcmp(HL,'low')
    %Recalculate pairwise distances in the low dimensional space
    tmpD=mena_metric(obj.Y,'euc'); %Now the Euclidean distance is
                 %representative of the high dimensional distances.
else
    %Simply re-use existing distance matrix (whatever the criteria!!)
    tmpD=obj.D;
end

%% Compute cluster pairwise EMD
clusters = obj.getClusterList;
nClusters= obj.nClusters;
x=0.05;
waitbar(x,hWait,['Computing EMD - ' num2str(round(x*100)) '%']);
nSteps=nClusters*(nClusters-1)/2;
step=0.95/nSteps;
emdDistances=zeros(1,nClusters*(nClusters-1)/2);
pos=1;
for cl1Idx=1:nClusters-1
    cl1=clusters(cl1Idx);
    %disp(['-- Cluster 1=' num2str(cl1) ' ---'])
    tmp1 = obj.getCluster(cl1);
    idx1 = tmp1.patternIndexes;
        %Indexes of points belonging to Cluster 1
        
    %Construct weights for cluster 1.
    %%%All points have the same weight, so simply use 1/nPoints as the
    %%%weight
    weights1(1:length(idx1))=1/length(idx1);
    for cl2Idx=(cl1Idx+1):nClusters
        cl2 = clusters(cl2Idx);
        tmp2 = obj.getCluster(cl2);
        idx2 = tmp2.patternIndexes;
            %Indexes of points belonging to Class 2
            
        
        if (isempty(idx1) || isempty(idx2))
            warning('ICNNA:analysis:emd',...
                    ['Empty cluster. Setting distance ' ...
                    'between clusters ' num2str(cl1) ' and ' ...
                    num2str(cl2)' to -1.']);
            emdDistances(pos)=-1;

        else
            
            %Construct weights for class 2.
            weights2(1:length(idx2))=1/length(idx2);
        
            %Construct the cost (ground distances) matrix
            cost=mena_getGroundCosts(tmpD,idx1,idx2);
        
            %Finally calculate EMD distances between the clusters
            %cl1 and cl2
            [e,Flow]=emd_mex(weights1,weights2,cost);
            emdDistances(pos)=e;
        
            clear weights2 cost
        end
        
        
        pos=pos+1;
        clear idx2
        
        x=x+step;
        waitbar(x,hWait,['Computing EMD - ' num2str(round(x*100)) '%']);
        
    end
    clear idx1 weights1
end

emdDistances=squareform(emdDistances);

close(hWait);

end

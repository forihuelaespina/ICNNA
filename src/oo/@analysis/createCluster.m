function c=createCluster(obj,varargin)
%ANALYSIS/CREATECLUSTER Generate a new cluster
%
% c=createCluster(obj,'DIMESION',values,...) Generate a new cluster
%   by selecting a number of points from the Feature space.
%
%This method is the one responsible for the creation of clusters
%in the composition relation between one analysis and its
%clusters. The generated cluster will have all the default
%configuration for colors and visualization. The critical
%aspect of this method is that it will get the indexes of
%the patterns (see attribute patternIdxs in class cluster)
%based on its own Feature Space and Projection Space indexes.
%
%This function also calculates the cluster centroid, furthest
%point and average and maximum distances to the centroid.
%
%   +============================================+
%   | The generated cluster is NOT automatically |
%   | added to the analysis. See method          |
%   | addCluster for more information.           |
%   +============================================+
%
%Accepted dimensions are
%
%   * 'SubjectsIDs'
%   * 'SessionsIDs'
%   * 'StimuliIDs'
%   * 'BlocksIDs'
%   * 'ChannelGroups'
%
%An non-defined value or an empty value indicates that all values
%for the particular dimension will be accepted (i.e. no filter
%for those values will be applied). Note that indicating an empty
%value or indicating all posible values is exactly the same.
%
% Examples: A cluster with all points referring to the
%   first stimulus of the first and second session:
%
%       c=createCluster(obj,'SessionIDs',[1,2],'StimuliIDs',1)
%
%% Remarks
%
% In order to create a cluster, it is necessary that the analysis
%has been run (i.e. 'RunStatus' equals true).
%
%This function internally uses the function k-means ((c) NETLAB,
%Ian T Nabney (1996-2001))
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also analysis, cluster, addCluster, removeCluster
%



%% Log
%
% File created: 29-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%   + Dimension parameters are now case insensitive.
%   + Error codes are now ICNNA instead of ICNA.
%



if ~obj.runStatus
    error('ICNNA:analysis:createCluster:NotRun',...
          ['Analysis must be run before clusters can be ' ...
          'generated.'])
end   


%By default use all...
subjectsIDs = unique(obj.I(:,obj.COL_SUBJECT));
sessionsIDs = unique(obj.I(:,obj.COL_SESSION));
stimuliIDs  = unique(obj.I(:,obj.COL_STIMULUS));
blocksIDs   = unique(obj.I(:,obj.COL_BLOCK));
channelGroups=unique(obj.I(:,obj.COL_CHANNELGROUP));

tmpSubjects = [];
tmpSessions = [];
tmpStimuli  = [];
tmpBlocks   = [];
tmpChannels = [];

maxSubject = max(obj.I(:,obj.COL_SUBJECT));
maxSessions= max(obj.I(:,obj.COL_SESSION));
maxStimuli = max(obj.I(:,obj.COL_STIMULUS));
maxBlocks  = max(obj.I(:,obj.COL_BLOCK));
maxChannelGroups=size(obj.channelGrouping,1);


%% Read the cluster definition
propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'subjectsids'
        if isempty(val)
            %Do nothing, keep the default values
        elseif (~ischar(val) && isreal(val) ...
                && all(all(val))>0 && all(all(floor(val)==val)) ...
                && all(all(val))<=maxSubject)
            subjectsIDs=val;
            tmpSubjects=val;
        else
            error('ICNNA:analysis:createCluster:InvalidArgument',...
                ['Property ''' prop ''' contains invalid values.'])
        end
            
    case 'sessionsids'
        if isempty(val)
            %Do nothing, keep the default values
        elseif (~ischar(val) && isreal(val) ...
                && all(all(val))>0 && all(all(floor(val)==val)) ...
                && all(all(val))<=maxSessions)
            sessionsIDs=val;
            tmpSessions=val;
        else
            error('ICNNA:analysis:createCluster:InvalidArgument',...
                ['Property ''' prop ''' contains invalid values.'])
        end
            
    case 'stimuliids'
        if isempty(val)
            %Do nothing, keep the default values
        elseif (~ischar(val) && isreal(val) ...
                && all(all(val))>0 && all(all(floor(val)==val)) ...
                && all(all(val))<=maxStimuli)
            stimuliIDs=val;
            tmpStimuli=val;
        else
            error('ICNNA:analysis:createCluster:InvalidArgument',...
                ['Property ''' prop ''' contains invalid values.'])
        end
            
    case 'blocksids'
        if isempty(val)
            %Do nothing, keep the default values
        elseif (~ischar(val) && isreal(val) ...
                && all(all(val))>0 && all(all(floor(val)==val)) ...
                && all(all(val))<=maxBlocks)
            blocksIDs=val;
            tmpBlocks=val;
        else
            error('ICNNA:analysis:createCluster:InvalidArgument',...
                ['Property ''' prop ''' contains invalid values.'])
        end
            
    case 'channelgroups'
        if isempty(val)
            %Do nothing, keep the default values
        elseif (~ischar(val) && isreal(val) ...
                && all(all(val))>0 && all(all(floor(val)==val)) ...
                && all(all(val))<=maxChannelGroups)
            channelGroups=val;
            tmpChannels=val;
        else
            error('ICNNA:analysis:createCluster:InvalidArgument',...
                ['Property ''' prop ''' contains invalid values.'])
        end
            
    otherwise
      error('ICNNA:analysis:set:UndefinedProperty',...
            ['Property ' prop ' not valid.'])
   end
end


%% Find the indexes for the cluster
idx=find(ismember(obj.I(:,obj.COL_SUBJECT),subjectsIDs) ...
         & ismember(obj.I(:,obj.COL_SESSION),sessionsIDs) ...
         & ismember(obj.I(:,obj.COL_STIMULUS),stimuliIDs) ...
         & ismember(obj.I(:,obj.COL_BLOCK),blocksIDs) ...
         & ismember(obj.I(:,obj.COL_CHANNELGROUP),channelGroups));

     
%% Create a default cluster
c=cluster;
%...and set the patterns indexes
c.patternIndexes = idx;
c.subjectsIDs = tmpSubjects;
c.sessionsIDs = tmpSessions;
c.stimuliIDs  = tmpStimuli;
c.blocksIDs   = tmpBlocks;
c.channelGroupsIDs=tmpChannels;

%% Calculate the centroid, furthestPoint, and average distance

%Define a single "initial" centroid
clusterData=obj.Y(idx,:);
centroid(1,:)=zeros(1,length(clusterData(1,:)));
%...and run the k-means algorithm
options=zeros(1,14);
centroid(1,:) = kmeans(centroid(1,:),clusterData,options);
c.centroid = centroid;
c.centroidCriteria =  'kmeans';

%Calculates the distances for each point in the cluster to the centroid
nPoints=size(clusterData,1);
distances=zeros(nPoints,1);
for pp=1:nPoints
    distances(pp,1)=norm(clusterData(pp,:)-centroid);
end
%And now the avg and max distances...
[maxDistance,fpClusterInternalIdx]=max(distances); %Note that this idx is only partial
            %to the clusters points
avgDistance=mean(distances);
c.averageDistance = avgDistance;
c.maximumDistance = maxDistance;

%Finally the furthest point (i.e. the "global" idx rather than the partial)
%fpCoordinates = clusterData(fpClusterInternalIdx,:);
fpGeneralIdx = idx(fpClusterInternalIdx);
c.furthestPoint = fpGeneralIdx;



end



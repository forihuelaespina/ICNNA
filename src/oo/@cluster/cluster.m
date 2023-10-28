classdef cluster
%A cluster (or class) simply holds a record of points which
%share some conceptual link together.
%
%A cluster is nothing else than a simple filter applicable
%to the index registry of the analysis (see class analysis).
%In this sense, a point in the Feature
%Space can belong to none or several clusters depending on
%how the clusters are specified.
%
%For visualization purposes an analysis holds a number of clusters
%which can be set to visible or hided as desired. The creation
%or removal of clusters DO NOT AFFECT the analysis embedding.
%Hence, hiding a cluster
%does not change the output configuration (projection data),
%but only helps to enhance visualization.
%By adding/removing clusters to the analysis and hiding
%or unhiding them, it should be possible to customize the
%visualization of the projection.
%
%Through the definition of clusters it is possible to
%mantain different views over the same analysis.
%For instance, let a experiment involves three groups of subject
%with different surgical skill and that we measure their brain
%activity in two regions (frontal and parietal). It is possible
%that in this dataset, we might be first interested in looking
%at groups with different expertise level (e.g. Consultants,
%Registrars and Novices), and later on, focus on the general
%differences between frontal activity and parietal activity. Or even
%further look at handedness differences. For each particular
%interest, a number of clusters may be defined to highlight
%the particular groups of interest.
%
%
%% The filter record
%
% The key important attribute in the cluster class is .patternIdxs
%which hold the indexes to those patterns (points) belonging
%to the cluster. As such the cluster does not know how these
%points where selected from the Feature Space. However, most of
%the time, these points will almost certainly not be picked
%randomly, but following a certain criteria e.g. experts subjets,
%or control session. When this is the case, it will then be
%possible to describe the cluster in terms of the IDs of the
%elements of interest. For instance, if control session is
%identified by ID==1, then selecting all those patterns for
%which their session ID is 1 from the pool of indexes in the
%analysis, should result in the cluster list of points.
%For keeping record of this, the cluster class can keep track
%of these cluster generating IDs in a set of attributes defined
%to this effect. However it must be emphasized that the class
%offers no guarantee that the list of indexes present in
%.patternIdxs indeed correspond to the filter resulting from
%this record, and it is up to the user to keep them up-to-date.
%
%Currently, the attributes to keep track of the cluster generating
%IDs are:
%
%    .subjectIDs
%    .sessionIDs
%    .stimulusIDs
%    .blockIDs
%    .channelGroupIDs
%
%
%
%% REMARKS
%
% A cluster is tighlty linked to the analysis to which its
%patterns it refers. The indexes to the patterns refers to
%those in field I of class Analysis. A cluster has no meaning
%outside an analysis (hence a composition relation between
%class Analysis and class Cluster).
%
%Methods createCluster and removeCluster in the class analysis
%helps to maintain this relationship.
%
%
%% PROPERTIES
%
%   .id - A numerical identifier.
%   .tag - A tag for the cluster. This is used in legends when appropriate.
%   .description - A short description for the cluster
%   .patternIndexes - Indexes to patterns (points) belonging
%       to the cluster. Default value is empty; i.e. the cluster
%       holds no point.
%   .visible - Boolean value to indicate whether the cluster
%           is visible or should be hide during visualization.
%
%
% ==Cluster generating IDs (Please read section "The filter record")
%
%    .subjectIDs - IDs of the selected subjects belonging to the
%       cluster or empty if the subjects are not used as a filter
%       criteria. Default value is empty matrix.
%    .sessionIDs - IDs of the selected sessions belonging to the
%       cluster or empty if the sessions are not used as a filter
%       criteria. Default value is empty matrix.
%    .stimulusIDs - IDs of the selected stimuli belonging to the
%       cluster or empty if the stimuli are not used as a filter
%       criteria. Default value is empty matrix.
%    .blockIDs - IDs of the selected blocks belonging to the
%       cluster or empty if the blocks are not used as a filter
%       criteria. Default value is empty matrix.
%    .channelGroupIDs - IDs of the selected channel groups belonging to the
%       cluster or empty if the channel groups are not used as a filter
%       criteria. Default value is empty matrix.
%
% ==Cluster descriptors
%
%   .centroid - Cluster centroid coordinates
%   .centroidCriteria - Criteria used to calulate the cluster centroid
%   .furthestPoint - Index to the furthest point from centroid
%   .averageDistance - Average distance of all points to the centroid
%   .maximumDistance - Distance from the furthest point to the centroid
%
% ==Visualization attributes
%   .showPatternPoints - Indicates whether to display the
%       pattern points when visualizing the cluster. Default true.
%   .showCentroid - Indicates whether to display the
%       centroid when visualizing the cluster. Default true.
%   .showFurthestPoint - Indicates whether to display the
%       furthestPoint when visualizing the cluster. Default true.
%   .showLink - Indicates whether to display a link between
%       the cluster centroid and the furthest point when
%       visualizing the cluster. Default true.
%   .showAverageDistanceCircle - Indicates whether to display the
%       avarage distance circle when visualizing the cluster.
%       Default true.
%
% ==== Patterns (data) visualization properties
%   .dataMarker - The marker to use when representing the patterns.
%       Default '.'
%   .dataMarkerSize - The marker size to use. Default 8
%   .dataColor - The color to use when representing this cluster.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%
% ==== Centroid visualization properties
%   .centroidMarker - The marker to use when representing the centroid.
%       Default 'o'
%   .centroidMarkerSize - The marker size for the centroid. Default 8
%   .centroidColor - The color to use when representing the centroid.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%
% ==== Furthest Point and link visualization properties
%   .furthestPointMarker - The marker to use when representing the furthest
%       point to the centroid. Default 'x'
%   .furthestPointMarkerSize - The marker size. Default 8
%   .furthestPointColor - The color to use when representing the furthest point.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%   .linkColor - The color of the line linking the centroid and the
%       furthest point.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%   .linkLineWidth - Line width for the line linking the
%       centroid and the furthest point. Default 1.5
%
% ====Average distance circle visualization properties
%   .averageDistanceCircleLineWidth - Line width for the average distance circle.
%       Default 1.5
%   .averageDistanceCircleColor - The color to use when representing the average
%       distance circle.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%
%
%All color properties can be set at once using set(obj,'Color',colorSpec)
%
%% Dependent properties
%
%   .nPatterns - Number of patterns (data points) included in the cluster.
%       Length of the |patternIdxs| property.
%
%% INVARIANTS
%
% See private/assertInvariants
%       
%% METHODS
%
% Type methods('cluster') for a list of methods
% 
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
% See also analysis
%


%% Log
%
% File created: 26-May-2008
% File last modified (before creation of this log): N/A. This class had
%   not been modfied since creation.
%
% 28-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Dependent property nPatterns is now
%   explicitly declared as such. Also added comments for these
%   in the class description.
%   + Improved some comments.
%   + Internally improved names of several attributes e.g cColor -> centroidColor.
%       Note that the interface should not have changed though!
%   + Added static method getColorVector (extracted from previous
%   nested method in method set).
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
        tag(1,:) char ='Cluster0001'; %A tag for the cluster
        description(1,:) char =''; %A short description of the data.
        patternIndexes(1,:) double {mustBeInteger, mustBeNonnegative}=[]; %Indexes to patterns (points) belonging to the cluster.   
        visible(1,1) logical = true; %Whether the cluster is visible or hidden during visualization.
     
% ==Cluster generating IDs
        subjectIDs(1,:) double {mustBeInteger, mustBeNonnegative} = []; %IDs of the selected subjects belonging to the cluster
        sessionIDs(1,:) double {mustBeInteger, mustBeNonnegative} = []; %IDs of the selected sessions belonging to the cluster
        stimulusIDs(1,:) double {mustBeInteger, mustBeNonnegative} = []; %IDs of the selected stimuli belonging to the cluster
        blockIDs(1,:) double {mustBeInteger, mustBeNonnegative} = []; %IDs of the selected blocks belonging to the cluster
        channelGroupIDs(1,:) double {mustBeInteger, mustBeNonnegative} = []; %IDs of the selected channel groups belonging to the cluster

% ==Cluster descriptors
        centroid(1,:) double = []; %Cluster centroid coordinates
        centroidCriteria(1,:) char =''; %Criteria used to calulate the cluster centroid
        furthestPoint(1,:) double=[]; %Index to the furthest point
        averageDistance(1,1) double = 0; %Average distance of all points to the centroid
        maximumDistance(1,1) double = 0; %Distance from the furthest point to the centroid

% ==Visualization attributes
        showPatternPoints(1,1) logical =true; %Indicates whether to display the pattern points when visualizing the cluster.
        showCentroid(1,1) logical =true; %Indicates whether to display the centroid when visualizing the cluster.
        showFurthestPoint(1,1) logical =true; %Indicates whether to highlight the furthest point when visualizing the cluster.
        showLink(1,1) logical =true;  %Indicates whether to display the link between the furthest point and the centroid when visualizing the cluster.
        showAverageDistanceCircle(1,1) logical =true; %Indicates whether to display the average distance circule when visualizing the cluster.

% ==== Patterns (data) visualization properties
        dataMarker(1,1) char {mustBeMember(dataMarker,{'+','o','*','.','x','s','v','^','d','>','<','p','h'})} = '.'; % Marker used to represent the patterns
        dataMarkerSize(1,1) double {mustBeNonnegative} =8;  % Marker size used to represent the patterns
        dataColor(1,3) double {mustBeNonnegative} = [0 0 0];  % Marker color to represent the patterns

% ==== Centroid visualization properties
        centroidMarker(1,1) char {mustBeMember(centroidMarker,{'+','o','*','.','x','s','v','^','d','>','<','p','h'})} = 'o';  % Marker used to represent the centroid
        centroidMarkerSize(1,1) double {mustBeNonnegative} =8; % Marker size used to represent the centroid
        centroidColor(1,3) double {mustBeNonnegative}=[0 0 0]; % Marker color used to represent the centroid

% ==== Furthest Point and link visualization properties
        furthestPointMarker(1,1) char {mustBeMember(furthestPointMarker,{'+','o','*','.','x','s','v','^','d','>','<','p','h'})} = 'x'; % Marker used to represent the furthest point
        furthestPointMarkerSize(1,1) double {mustBeNonnegative} =8; % Marker size used to represent the furthest point
        furthestPointColor(1,3) double {mustBeNonnegative}=[0 0 0]; % Marker color used to represent the furthest point
        linkColor(1,3) double {mustBeNonnegative}=[0 0 0]; % Color of the link between the furthest point and the centroid
        linkLineWidth(1,1) double {mustBeNonnegative} = 1.5; % Thickness of the link between the furthest point and the centroid

% ====Average distance circle visualization properties
        averageDistanceCircleLineWidth(1,1) double {mustBeNonnegative} =1.5; % Thickness of the line of the average distance circle
        averageDistanceCircleColor(1,3) double {mustBeNonnegative}=[0 0 0]; % Color of the average distance circle
        
    end
    
    properties (Dependent)
        nPatterns
    end
    
    methods
        function obj=cluster(varargin)
        %CLUSTER Cluster class constructor
        %
        % obj=cluster() creates a default cluster with ID equals 1.
        %
        % obj=cluster(obj2) acts as a copy constructor of cluster
        %
        % obj=cluster(id) creates a new cluster with the given
        %   identifier (id). The tag of the cluster is initialised
        %   to 'ClusterXXXX' where is the id preceded with 0.
        %
        % obj=cluster(id,tag) creates a new cluster with the given
        %   identifier (id) and tag.
        if (nargin==0)
            %Keep default values
        elseif isa(varargin{1},'cluster')
            obj=varargin{1};
            return;
        else
            obj.id = varargin{1};
            obj.tag = ['Cluster' num2str(obj.id,'%04i')];
            if (nargin>1)
                obj.tag = varargin{2};
            end
        end
        %assertInvariants(obj);
        end
    end


    methods (Static)
        rgb=getColorVector(ch)
    end

    methods

      %Getters/Setters

      function res = get.id(obj)
         %Gets the object |id|
         res = obj.id;
      end
      function obj = set.id(obj,val)
         %Sets the object |id|
         obj.id = val;
      end


      function res = get.tag(obj)
         %Gets the object |tag|
         res = obj.tag;
      end
      function obj = set.tag(obj,val)
         %Sets the object |tag|
         obj.tag = val;
      end


      function res = get.description(obj)
         %Gets the object |description|
         res = obj.description;
      end
      function obj = set.description(obj,val)
         %Sets the object |description|
         obj.description = val;
      end


      function res = get.patternIndexes(obj)
         %Gets the list of pattern (data) indexes assigned to the cluster |patternIdxs|
         res = obj.patternIndexes;
      end
      function obj = set.patternIndexes(obj,val)
         %Sets the list of pattern (data) indexes assigned to the cluster |patternIdxs|
         obj.patternIndexes = val;
      end


      function res = get.visible(obj)
         %Gets the cluster's visibility |visible|
         res = obj.visible;
      end
      function obj = set.visible(obj,val)
         %Sets the cluster's visibility |visible|
         obj.visible = val;
      end

% ==Cluster generating IDs

      function res = get.subjectIDs(obj)
         %Gets the IDs of subjects included in the cluster |subjectIDs|
         res = obj.subjectIDs;
      end
      function obj = set.subjectIDs(obj,val)
         %Sets the IDs of subjects included in the cluster |subjectIDs|
         obj.subjectIDs = val;
      end


      function res = get.sessionIDs(obj)
         %Gets the IDs of sessions included in the cluster |sessionIDs|
         res = obj.sessionIDs;
      end
      function obj = set.sessionIDs(obj,val)
         %Sets the IDs of sessions included in the cluster |sessionIDs|
         obj.sessionIDs = val;
      end


      function res = get.stimulusIDs(obj)
         %Gets the IDs of stimuli included in the cluster |stimulusIDs|
         res = obj.stimulusIDs;
      end
      function obj = set.stimulusIDs(obj,val)
         %Sets the IDs of stimuli included in the cluster |stimulusIDs|
         obj.stimulusIDs = val;
      end



      function res = get.blockIDs(obj)
         %Gets the IDs of blocks included in the cluster |blockIDs|
         res = obj.blockIDs;
      end
      function obj = set.blockIDs(obj,val)
         %Sets the IDs of blocks included in the cluster |blockIDs|
         obj.blockIDs = val;
      end



      function res = get.channelGroupIDs(obj)
         %Gets the IDs of channel groups (ROIs) included in the cluster |channelGroupIDs|
         res = obj.channelGroupIDs;
      end
      function obj = set.channelGroupIDs(obj,val)
         %Sets the IDs of channel groups (ROIs) included in the cluster |channelGroupIDs|
         obj.channelGroupIDs = val;
      end

% ==Cluster descriptors

      function res = get.centroid(obj)
         %Gets the cluster's centroid |centroid|
         res = obj.centroid;
      end
      function obj = set.centroid(obj,val)
         %Sets the cluster's centroid |centroid|
         obj.centroid = val;
      end


      function res = get.centroidCriteria(obj)
         %Gets the criteria to estimate the centroid |centroidCriteria|
         res = obj.centroidCriteria;
      end
      function obj = set.centroidCriteria(obj,val)
         %Sets the criteria to estimate the centroid |centroidCriteria|
         obj.centroidCriteria = val;
      end


      function res = get.furthestPoint(obj)
         %Gets the pattern (data) index to the furthest point |furthestPoint|
         res = obj.furthestPoint;
      end
      function obj = set.furthestPoint(obj,val)
         %Sets the pattern (data) index to the furthest point |furthestPoint|
         obj.furthestPoint = val;
      end


      function res = get.averageDistance(obj)
         %Gets the cluster average distance |averageDistance|
         res = obj.averageDistance;
      end
      function obj = set.averageDistance(obj,val)
         %Sets the cluster average distance |averageDistance|
         obj.averageDistance = val;
      end


      function res = get.maximumDistance(obj)
         %Gets the cluster longest distance  |maximumDistance|
         res = obj.maximumDistance;
      end
      function obj = set.maximumDistance(obj,val)
         %Sets the cluster longest distance |maximumDistance|
         obj.maximumDistance = val;
      end




% ==Visualization attributes

      function res = get.showPatternPoints(obj)
         %Gets the object's flag to visualize the patterns |showPatternPoints|
         res = obj.showPatternPoints;
      end
      function obj = set.showPatternPoints(obj,val)
         %Sets the object's flag to visualize the patterns |showPatternPoints|
         obj.showPatternPoints = val;
      end


      function res = get.showCentroid(obj)
         %Gets the object's flag to visualize the centroid |showCentroid|
         res = obj.showCentroid;
      end
      function obj = set.showCentroid(obj,val)
         %Sets the object's flag to visualize the centroid |showPatternPoints|
         obj.showCentroid = val;
      end


      function res = get.showFurthestPoint(obj)
         %Gets the object's flag to emphasize the furthest point |showFurthestPoint|
         res = obj.showFurthestPoint;
      end
      function obj = set.showFurthestPoint(obj,val)
         %Sets the object's flag to emphasize the furthest point |showFurthestPoint|
         obj.showFurthestPoint = val;
      end


      function res = get.showLink(obj)
         %Gets the object's flag to visualize the link between the centroid and the furthest point |showLink|
         res = obj.showLink;
      end
      function obj = set.showLink(obj,val)
         %Sets the object's flag to visualize the link between the centroid and the furthest point |showLink|
         obj.showLink = val;
      end


      function res = get.showAverageDistanceCircle(obj)
         %Gets the object's flag to visualize the average distance circle |showAverageDCircle|
         res = obj.showAverageDistanceCircle;
      end
      function obj = set.showAverageDistanceCircle(obj,val)
         %Sets the object's flag to visualize the average distance circle |showAverageDCircle|
         obj.showAverageDistanceCircle = val;
      end


% ==== Patterns (data) visualization properties

      function res = get.dataMarker(obj)
         %Gets the patterns (data) marker |dataMarker|
         res = obj.dataMarker;
      end
      function obj = set.dataMarker(obj,val)
         %Sets the patterns (data) marker |dataMarker|
         obj.dataMarker = val;
      end


      function res = get.dataMarkerSize(obj)
         %Gets the patterns (data) marker size |dataMarkerSize|
         res = obj.dataMarkerSize;
      end
      function obj = set.dataMarkerSize(obj,val)
         %Sets the patterns (data) marker size|dataMarkerSize|
         obj.dataMarkerSize = val;
      end


      function res = get.dataColor(obj)
         %Gets the patterns (data) color |dataColor|
         res = obj.dataColor;
      end
      function obj = set.dataColor(obj,val)
         %Sets the patterns (data) color |dataColor|
         %
         %= Remark
         % If you want to use a matlab color name assign as:
         %  c.dataColor = cluster.getColorVector('r')
         % If you try to set it like:
         %  c.dataColor = 'r'
         % Matlab will automatically attempt to typecast the color;
         %  e.g. 'r' will became [114 114 114]
         %  ...even BEFORE entering this method!

         %%NOT WORKING
         % if (ischar(val) && length(val)==1)
         %     val = cluster.getColorVector(val);
         % end
         obj.dataColor = val;
      end


% ==== Centroid visualization properties

      function res = get.centroidMarker(obj)
         %Gets the centroid marker |centroidMarker|
         res = obj.centroidMarker;
      end
      function obj = set.centroidMarker(obj,val)
         %Sets the centroid marker |centroidMarker|
         obj.centroidMarker = val;
      end


      function res = get.centroidMarkerSize(obj)
         %Gets the centroid marker size |centroidMarkerSize|
         res = obj.centroidMarkerSize;
      end
      function obj = set.centroidMarkerSize(obj,val)
         %Sets the centroid marker size |centroidMarkerSize|
         obj.centroidMarkerSize = val;
      end


      function res = get.centroidColor(obj)
         %Gets the centroid color |centroidColor|
         res = obj.centroidColor;
      end
      function obj = set.centroidColor(obj,val)
         %Sets the centroid color |centroidColor|
         %
         %= Remark
         % If you want to use a matlab color name assign as:
         %  c.centroidColor = cluster.getColorVector('r')
         % If you try to set it like:
         %  c.centroidColor = 'r'
         % Matlab will automatically attempt to typecast the color;
         %  e.g. 'r' will became [114 114 114]
         %  ...even BEFORE entering this method!

         %%NOT WORKING
         % if (ischar(val) && length(val)==1)
         %     val = cluster.getColorVector(val);
         % end
         obj.centroidColor = val;
      end



% ==== Furthest Point and link visualization properties


      function res = get.furthestPointMarker(obj)
         %Gets the furthest point marker |furthestPointMarker|
         res = obj.furthestPointMarker;
      end
      function obj = set.furthestPointMarker(obj,val)
         %Sets the furthest point marker |furthestPointMarker|
         obj.furthestPointMarker = val;
      end


      function res = get.furthestPointMarkerSize(obj)
         %Gets the furthest point marker size |furthestPointMarkerSize|
         res = obj.furthestPointMarkerSize;
      end
      function obj = set.furthestPointMarkerSize(obj,val)
         %Sets the furthest point marker size |furthestPointMarkerSize|
         obj.furthestPointMarkerSize = val;
      end


      function res = get.furthestPointColor(obj)
         %Gets the furthest point color |furthestPointColor|
         res = obj.furthestPointColor;
      end
      function obj = set.furthestPointColor(obj,val)
         %Sets the furthest point color |furthestPointColor|
         %
         %= Remark
         % If you want to use a matlab color name assign as:
         %  c.furthestPointColor = cluster.getColorVector('r')
         % If you try to set it like:
         %  c.furthestPointColor = 'r'
         % Matlab will automatically attempt to typecast the color;
         %  e.g. 'r' will became [114 114 114]
         %  ...even BEFORE entering this method!

         %%NOT WORKING
         % if (ischar(val) && length(val)==1)
         %     val = cluster.getColorVector(val);
         % end
         obj.furthestPointColor = val;
      end


      function res = get.linkColor(obj)
         %Gets the link color |linkColor|
         res = obj.linkColor;
      end
      function obj = set.linkColor(obj,val)
         %Sets the link color |linkColor|
         %
         %= Remark
         % If you want to use a matlab color name assign as:
         %  c.linkColor = cluster.getColorVector('r')
         % If you try to set it like:
         %  c.linkColor = 'r'
         % Matlab will automatically attempt to typecast the color;
         %  e.g. 'r' will became [114 114 114]
         %  ...even BEFORE entering this method!

         %%NOT WORKING
         % if (ischar(val) && length(val)==1)
         %     val = cluster.getColorVector(val);
         % end
         obj.linkColor = val;
      end



      function res = get.linkLineWidth(obj)
         %Gets the link line thickness |linkLineWidth|
         res = obj.linkLineWidth;
      end
      function obj = set.linkLineWidth(obj,val)
         %Sets the link line thickness |linkLineWidth|
         obj.linkLineWidth = val;
      end



% ====Average distance circle visualization properties


      function res = get.averageDistanceCircleColor(obj)
         %Gets the average distance circle color |averageDistanceCircleColor|
         res = obj.averageDistanceCircleColor;
      end
      function obj = set.averageDistanceCircleColor(obj,val)
         %Sets the object |averageDistanceCircleColor|
         %
         %= Remark
         % If you want to use a matlab color name assign as:
         %  c.verageDistanceCircleColor = cluster.getColorVector('r')
         % If you try to set it like:
         %  c.verageDistanceCircleColor = 'r'
         % Matlab will automatically attempt to typecast the color;
         %  e.g. 'r' will became [114 114 114]
         %  ...even BEFORE entering this method!

         %%NOT WORKING
         % if (ischar(val) && length(val)==1)
         %     val = cluster.getColorVector(val);
         % end
         obj.averageDistanceCircleColor = val;
      end



      function res = get.averageDistanceCircleLineWidth(obj)
         %Gets the average distance circle line thickness |averageDistanceCircleLineWidth|
         res = obj.averageDistanceCircleLineWidth;
      end
      function obj = set.averageDistanceCircleLineWidth(obj,val)
         %Sets the object |averageDistanceCircleLineWidth|
         obj.averageDistanceCircleLineWidth = val;
      end



% =====DEPENDENT

      function res = get.nPatterns(obj)
         %(DEPENDENT) Gets the object |nPatterns|
         %
         % The number of patterns (data points) included in the cluster.
         res = length(obj.patternIdxs);
      end






    end


end

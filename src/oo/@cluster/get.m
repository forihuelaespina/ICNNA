function val = get(obj, propName)
% CLUSTER/GET DEPRECATED (v1.2). Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%
%% Properties
%
% 'ID' - The cluster identifier
% 'Tag' - The cluster tag
% 'Description' - The description
% 'NumPatterns' - Number of patterns
% 'PatternIndexes' - List of Patterns Indexes
% 'Visible' - Visibility status
%
% ==Cluster generating IDs
% 'SubjectsIDs' - List of subject IDs used to filter the cluster points
% 'SessionsIDs' - List of session IDs used to filter the cluster points
% 'StimuliIDs' - List of stimuli IDs used to filter the cluster points
% 'BlocksIDs' - List of blocks IDs used to filter the cluster points
% 'ChannelGroupsIDs' - List of channel groups IDs used to filter the
%       cluster points
%
% ==Cluster descriptors
% 'Centroid' - Coordinates of the centroid
% 'CentroidCriteria' - Criteria used to defined the centroid
% 'FurthestPoint' - Index of the furthest point
% 'AverageDistance' - Average distance of cluster points to centroid
% 'MaximumDistance' - Distance from furthest point to centroid
%
% ==Visualization attributes
% 'ShowPatternPoints' - Display the data points
% 'ShowCentroid' - Display the centroid
% 'ShowFurthestPoint' - Display the furthest point
% 'ShowLink' - Display a line fromthe centroid to the furthes point
% 'ShowAverageDistance' - Display a circle centred at the centroid and
%       with radius equal the average distance of all points to the
%       centroid.
%
% ==== Patterns (data) visualization properties
% 'DataMarker' - Marker to be used for data points.
% 'DataMarkerSize' - Marker size to be used for data points.
% 'DataColor' - Color use for the data points
%
% ==== Centroid visualization properties
% 'CentroidMarker' - Marker to be used for centroid
% 'CentroidMarkerSize' - Marker size to be used for centroid
% 'CentroidColor' - Color use for the centroid
%
% ==== Furthest Point and link visualization properties
% 'FurthestPointMarker' - Marker to be used for the furthest point
% 'FurthestPointMarkerSize' - Marker size to be used for the furthest point
% 'FurthestPointColor' - Color use for the furthest point
% 'LinkColor' - Color of the line linking the centroid and the furthest
%   point.
% 'LinkLineWidth' - Line width in points for the line linking the centroid
%   and the furthest point.
%
% ====Average distance circle visualization properties
% 'AverageDistanceColor' - Color of the average distance circle.
% 'AverageDistanceLineWidth' - Line width in points for the
%   average distance circle.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also cluster, set
%



%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This method had
%   not been modified since creation.
%
% 28-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%   Bug fixed:
%   + 1 error was still not using error code.
%

warning('ICNNA:cluster:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. cluster.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.


switch lower(propName)
case 'id'
   val = obj.id;
case 'tag'
   val = obj.tag;
case 'description'
   val = obj.description;
case 'npatterns'
   val = obj.nPatterns;
case 'patternindexes'
   val = obj.patternIdxs;
case 'visible'
   val = obj.visible;
    
% ==Cluster generating IDs
case 'subjectsids'
    val = obj.subjectIDs;
case 'sessionsids'
    val = obj.sessionIDs;
case 'stimuliids'
    val = obj.stimulusIDs;
case 'blocksids'
    val = obj.blockIDs;
case 'channelgroupsids'
    val = obj.channelGroupIDs;

% ==Cluster descriptors
case 'centroid'
    val = obj.centroid;
case 'centroidcriteria'
    val = obj.centroidCriteria;
case 'furthestpoint'
    val = obj.furthestPoint;
case 'averagedistance'
    val = obj.avgDistance;
case 'maximumdistance'
    val = obj.maxDistance;


% ==Visualization attributes
case 'showpatternpoints'
    val = obj.showPatternPoints;
case 'showcentroid'
    val = obj.showCentroid;
case 'showfurthestpoint'
    val = obj.showFurthestPoint;
case 'showlink'
    val = obj.showLink;
case 'showaveragedistance'
    val = obj.showAverageDistanceCircle;
case 'showaveragedistancecircle'
    val = obj.showAverageDistanceCircle;

% ==== Patterns (data) visualization properties
case 'datamarker'
   val = obj.dataMarker;
case 'datamarkersize'
   val = obj.dataMarkerSize;
case 'datacolor'
   val = obj.dataColor;

% ==== Centroid visualization properties
case 'centroidmarker'
   val = obj.centroidMarker;
case 'centroidmarkersize'
   val = obj.centroidMarkerSize;
case 'centroidcolor'
   val = obj.centroidColor;

% ==== Furthest Point and link visualization properties
case 'furthestpointmarker'
   val = obj.furthestpointMarker;
case 'furthestpointmarkersize'
   val = obj.furthestpointMarkerSize;
case 'furthestpointcolor'
   val = obj.furthestpointColor;

case 'linkcolor'
   val = obj.linkColor;
case 'linklinewidth'
   val = obj.linkLineWidth;

% ====Average distance circle visualization properties
case 'averagedistancecolor'
   val = obj.averageDistanceCircleColor;
case 'averagedistancecirclecolor'
   val = obj.averageDistanceCircleColor;
   
case 'averagedistancelinewidth'
   val = obj.averageDistanceCircleLineWidth;
case 'averagedistancecirclelinewidth'
   val = obj.averageDistanceCircleLineWidth;
   
otherwise
   error('ICNNA:cluster:get:InvalidProperty',...
        [propName,' is not a valid property'])
end
function val = get(obj, propName)
% CLUSTER/GET Get properties from the specified object
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
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also cluster, set
%

switch propName
case 'ID'
   val = obj.id;
case 'Tag'
   val = obj.tag;
case 'Description'
   val = obj.description;
case 'NPatterns'
   val = length(obj.patternIdxs);
case 'PatternIndexes'
   val = obj.patternIdxs;
case 'Visible'
   val = obj.visible;
    
% ==Cluster generating IDs
case 'SubjectsIDs'
    val = obj.subjectIDs;
case 'SessionsIDs'
    val = obj.sessionIDs;
case 'StimuliIDs'
    val = obj.stimulusIDs;
case 'BlocksIDs'
    val = obj.blockIDs;
case 'ChannelGroupsIDs'
    val = obj.channelGroupIDs;

% ==Cluster descriptors
case 'Centroid'
    val = obj.centroid;
case 'CentroidCriteria'
    val = obj.centroidCriteria;
case 'FurthestPoint'
    val = obj.furthestPoint;
case 'AverageDistance'
    val = obj.avgDistance;
case 'MaximumDistance'
    val = obj.maxDistance;


% ==Visualization attributes
case 'ShowPatternPoints'
    val = obj.displayPatternPoints;
case 'ShowCentroid'
    val = obj.displayCentroid;
case 'ShowFurthestPoint'
    val = obj.displayFurthestPoint;
case 'ShowLink'
    val = obj.displayLink;
case 'ShowAverageDistance'
    val = obj.displayAvgDCircle;

% ==== Patterns (data) visualization properties
case 'DataMarker'
   val = obj.dMarker;
case 'DataMarkerSize'
   val = obj.dMarkerSize;
case 'DataColor'
   val = obj.dColor;

% ==== Centroid visualization properties
case 'CentroidMarker'
   val = obj.cMarker;
case 'CentroidMarkerSize'
   val = obj.cMarkerSize;
case 'CentroidColor'
   val = obj.cColor;

% ==== Furthest Point and link visualization properties
case 'FurthestPointMarker'
   val = obj.fpMarker;
case 'FurthestPointMarkerSize'
   val = obj.fpMarkerSize;
case 'FurthestPointColor'
   val = obj.fpColor;

case 'LinkColor'
   val = obj.linkColor;
case 'LinkLineWidth'
   val = obj.linkLineWidth;

% ====Average distance circle visualization properties
case 'AverageDistanceColor'
   val = obj.avgcColor;
case 'AverageDistanceLineWidth'
   val = obj.avgcLineWidth;
   
otherwise
   error([propName,' is not a valid property'])
end
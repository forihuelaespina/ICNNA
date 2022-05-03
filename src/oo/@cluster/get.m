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

%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the cluster class.
%   + We create a dependent property inside of the cluster class 
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.
%
     tmp = lower(propName);
    
    switch (tmp)

               case 'id'
                    val = obj.id;  
               case 'tag'
                    val = obj.tag;
               case 'npatterns'
                    val = obj.nPatterns;
               case 'description'
                    val = obj.description;
               case 'patternindexes'
                    val = obj.patternIdxs;
               case 'visible'
                    val = obj.visible;
                    
               % ==Cluster generating IDs
               case 'subjectids'
                    val = obj.subjectIDs;
               case 'sessionids'
                    val = obj.sessionIDs;     
               case 'stimulusids'
                    val = obj.stimulusIDs;  
               case 'blockids'
                    val = obj.blockIDs;
               case 'channelgroupids'
                    val = obj.channelGroupIDs;
                    
               % ==Cluster descriptors
               case 'centroid'
                    val = obj.centroid;
               case 'centroidcriteria'
                    val = obj.centroidCriteria;
               case 'furthestpoint'
                    val = obj.furthestPoint;
               case 'avgdistance'
                    val = obj.avgDistance; 
               case 'maxdistance'
                    val = obj.maxDistance;  
                    
               % ==Visualization attributes
               case 'displaypatternpoints'
                    val = obj.displayPatternPoints;
               case 'displaycentroid'
                    val = obj.displayCentroid;
               case 'displayfurthestpoint'
                    val = obj.displayFurthestPoint;
               case 'displaylink'
                    val = obj.displayLink;
               case 'displayavgdcircle'
                    val = obj.displayAvgDCircle;
                    
               % ==== Patterns (data) visualization properties
               case 'dmarker'
                    val = obj.dMarker; 
               case 'dmarkersize'
                    val = obj.dMarkerSize;  
               case 'dcolor'
                    val = obj.dColor;
               
               % ==== Centroid visualization properties
               case 'cmarker'
                    val = obj.cMarker;
               case 'cmarkersize'
                    val = obj.cMarkerSize;
               case 'ccolor'
                    val = obj.cColor;
                    
               % ==== Furthest Point and link visualization properties
               case 'fpmarker'
                    val = obj.fpMarker;
               case 'fpmarkersize'
                    val = obj.fpMarkerSize; 
               case 'fpcolor'
                    val = obj.fpColor;
               case 'linkcolor'
                    val = obj.linkColor;
               case 'linklinewidth'
                    val = obj.linkLineWidth;
                    
               % ====Average distance circle visualization properties
               case 'avgccolor'
                    val = obj.avgcColor;
               case 'avgclinewidth'
                    val = obj.avgcLineWidth; 

        otherwise 
            error([propName,' is not a valid property'])
    end
end
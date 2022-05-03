function obj = set(obj,varargin)
%CLUSTER/SET Set object properties and return the updated object
%
%% Properties
%
% 'ID' - The cluster identifier
% 'Tag' - The cluster tag
% 'Description' - The description
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
% All color properties can be set at once using 'Color'. This affects
%the following properties: 'DataColor', 'CentroidColor',
%'FurthestPointColor', 'LinkColor', 'AverageDistanceColor'.
%
%
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also cluster, get
%

%% Log
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + All cases are in the cluster class.
%   + We create a dependent property inside the cluster class.
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.

propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);
       
       tmp = lower(prop);
    
        switch (tmp)

               case 'id'
                     obj.id = val;  
               case 'tag'
                    obj.tag = val;
               case 'description'
                    obj.description = val;
               case 'patternindexes'
                    obj.patternIdxs = val;
               case 'visible'
                    obj.visible = val;
                    
               % ==Cluster generating IDs
               case 'subjectids'
                    obj.subjectIDs = val;
               case 'sessionids'
                    obj.sessionIDs = val;     
               case 'stimulusids'
                    obj.stimulusIDs = val;  
               case 'blockids'
                    obj.blockIDs = val;
               case 'channelgroupids'
                    obj.channelGroupIDs = val;
                    
               % ==Cluster descriptors
               case 'centroid'
                    obj.centroid = val;
               case 'centroidcriteria'
                    obj.centroidCriteria = val;
               case 'furthestpoint'
                    obj.furthestPoint = val;
               case 'avgdistance'
                    obj.avgDistance = val; 
               case 'maxdistance'
                    obj.maxDistance = val;  
                    
               % ==Visualization attributes
               case 'displaypatternpoints'
                    obj.displayPatternPoints = val;
               case 'displaycentroid'
                    obj.displayCentroid = val;
               case 'displayfurthestpoint'
                    obj.displayFurthestPoint = val;
               case 'displaylink'
                    obj.displayLink;
               case 'displayavgdcircle'
                    obj.displayAvgDCircle = val;
                    
               % ==== Patterns (data) visualization properties
               case 'dmarker'
                    obj.dMarker = val; 
               case 'dmarkersize'
                    obj.dMarkerSize = val;  
               case 'dcolor'
                    obj.dColor = val;
               
               % ==== Centroid visualization properties
               case 'cmarker'
                    obj.cMarker = val;
               case 'cmarkersize'
                    obj.cMarkerSize = val;
               case 'ccolor'
                    obj.cColor = val;
                    
               % ==== Furthest Point and link visualization properties
               case 'fpmarker'
                    obj.fpMarker = val;
               case 'fpmarkersize'
                    obj.fpMarkerSize = val; 
               case 'fpcolor'
                    obj.fpColor = val;
               case 'linkcolor'
                    obj.linkColor = val;
               case 'linklinewidth'
                    obj.linkLineWidth = val;
                    
               % ====Average distance circle visualization properties
               case 'avgccolor'
                    obj.avgcColor = val;
               case 'avgclinewidth'
                    obj.avgcLineWidth = val; 
               case 'color'
                    obj.color = val;    

            otherwise
                error('ICNA:cluster:set:InvalidPropertyName',...
                  ['Property ' prop ' not valid.'])
        end
   end

end

function rgb=getColorVector(ch)
%Returns a color vector from a caracter color descriptor
%or an empty string if the caracter is not recognised.
switch (ch)
    case 'r'
        rgb = [1 0 0];
    case 'g'
        rgb = [0 1 0];
    case 'b'
        rgb = [0 0 1];
    case 'k'
        rgb = [0 0 0];
    case 'w'
        rgb = [1 1 1];
    case 'm'
        rgb = [1 0 1];
    case 'c'
        rgb = [0 1 1];
    case 'y'
        rgb = [1 1 0];
    otherwise
        rgb=[];
end
end   
    
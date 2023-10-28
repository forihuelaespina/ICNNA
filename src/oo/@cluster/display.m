function display(obj)
%CLUSTER/DISPLAY Command window display of a cluster
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also cluster, get, set
%


%% Log
%
% File created: 26-May-2008
% File last modified (before creation of this log): N/A. This method had
%   not been modified since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Now also displays new attribute classVersion
%




disp(' ');
disp([inputname(1),'= ']);
disp(' ');
try
    disp(['   Class version: ' num2str(obj.classVersion)]);
catch
    disp('   Class version: N/A');
end
disp(['   id: ' num2str(obj.id)]);
disp(['   tag: ' obj.tag]);
disp(['   description: ' obj.description]);
disp(['   num. Patterns: ' num2str(length(obj.patternIndexes))]);
if (obj.visible)
    disp('   visible: TRUE');
else
    disp('   visible: FALSE');
end    

% ==Cluster generating IDs
if (~isempty(obj.subjectIDs) ...
    || ~isempty(obj.sessionIDs) ...
    || ~isempty(obj.stimulusIDs) ...
    || ~isempty(obj.blockIDs) ...
    || ~isempty(obj.channelGroupIDs))
    disp('   Cluster generation details:');
end
if (~isempty(obj.subjectIDs))
    disp(['      Subjects: ' mat2str(obj.subjectIDs)]);
end
if (~isempty(obj.sessionIDs))
    disp(['      Sessions: ' mat2str(obj.sessionIDs)]);
end
if (~isempty(obj.stimulusIDs))
    disp(['      Stimuli: ' mat2str(obj.stimulusIDs)]);
end
if (~isempty(obj.blockIDs))
    disp(['      Blocks: ' mat2str(obj.blockIDs)]);
end
if (~isempty(obj.channelGroupIDs))
    disp(['      Channel group: ' mat2str(obj.channelGroupIDs)]);
end


% ==Clsuter descriptors

disp(['   Centroid: ' mat2str(obj.centroid)]);
if (~isempty(obj.centroid))
    disp(['   Centroid criteria: ' obj.centroidCriteria]);
end
disp(['   Average distance to centroid: ' num2str(obj.averageDistance)]);
disp(['   Furthest point index: ' num2str(obj.furthestPoint)]);
disp(['   Furthest point distance to centroid: ' num2str(obj.maximumDistance)]);

% ==Visualization attributes

% ==== Patterns (data) visualization properties
if (obj.showPatternPoints)
    disp('   Display pattern points: TRUE');
    disp(['   Pattern points marker: ''' obj.dataMarker '''']);
    disp(['   Pattern points marker size: ' num2str(obj.dataMarkerSize)]);
    disp(['   Pattern points color: ' mat2str(obj.dataColor)]);
else
    disp('   Display pattern points: FALSE');
end    

% ==== Centroid visualization properties
if (obj.showCentroid)
    disp('   Display centroid: TRUE');
    disp(['   Centroid marker: ''' obj.centroidMarker '''']);
    disp(['   Centroid marker size: ' num2str(obj.centroidMarkerSize)]);
    disp(['   Centroid color: ' mat2str(obj.centroidColor)]);
else
    disp('   Display centroid: FALSE');
end    

% ==== Furthest Point and link visualization properties
if (obj.showFurthestPoint)
    disp('   Display furthest point: TRUE');
    disp(['   Furthest point marker: ''' obj.furthestPointMarker '''']);
    disp(['   Furthest point marker size: ' num2str(obj.furthestPointMarkerSize)]);
    disp(['   Furthest point color: ' mat2str(obj.furthestPointColor)]);
else
    disp('   Display furthest point: FALSE');
end    
if (obj.showLink)
    disp('   Display link between furthest point and centroid: TRUE');
    disp(['   Link line width: ' num2str(obj.linkLineWidth)]);
    disp(['   Link color: ' mat2str(obj.linkColor)]);
else
    disp('   Display link between furthest point and centroid: FALSE');
end    

% ====Average distance circle visualization properties
if (obj.showAverageDistanceCircle)
    disp('   Display average distance to centroid circle: TRUE');
    disp(['   Avg. distance to centroid circle line width: ' num2str(obj.averageDistanceCircleLineWidth)]);
    disp(['   Avg. distance to centroid circle color: ' mat2str(obj.averageDistanceCircleColor)]);
else
    disp('   Display average distance to centroid circle: FALSE');
end    
disp(' ');


end

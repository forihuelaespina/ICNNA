function display(obj)
%CLUSTER/DISPLAY Command window display of a cluster
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 26-May-2008
% @author Felipe Orihuela-Espina
%
% See also cluster, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   tag: ' obj.tag]);
disp(['   description: ' obj.description]);
disp(['   Num. Patterns: ' num2str(length(obj.patternIdxs))]);
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
disp(['   Average distance to centroid: ' num2str(obj.avgDistance)]);
disp(['   Furthest point index: ' num2str(obj.furthestPoint)]);
disp(['   Furthest point distance to centroid: ' num2str(obj.maxDistance)]);

% ==Visualization attributes

% ==== Patterns (data) visualization properties
if (obj.displayPatternPoints)
    disp('   Display pattern points: TRUE');
    disp(['   Pattern points marker: ''' obj.dMarker '''']);
    disp(['   Pattern points marker size: ' num2str(obj.dMarkerSize)]);
    disp(['   Pattern points color: ' mat2str(obj.dColor)]);
else
    disp('   Display pattern points: FALSE');
end    

% ==== Centroid visualization properties
if (obj.displayCentroid)
    disp('   Display centroid: TRUE');
    disp(['   Centroid marker: ''' obj.cMarker '''']);
    disp(['   Centroid marker size: ' num2str(obj.cMarkerSize)]);
    disp(['   Centroid color: ' mat2str(obj.cColor)]);
else
    disp('   Display centroid: FALSE');
end    

% ==== Furthest Point and link visualization properties
if (obj.displayFurthestPoint)
    disp('   Display furthest point: TRUE');
    disp(['   Furthest point marker: ''' obj.fpMarker '''']);
    disp(['   Furthest point marker size: ' num2str(obj.fpMarkerSize)]);
    disp(['   Furthest point color: ' mat2str(obj.fpColor)]);
else
    disp('   Display furthest point: FALSE');
end    
if (obj.displayLink)
    disp('   Display link between furthest point and centroid: TRUE');
    disp(['   Link line width: ' num2str(obj.linkLineWidth)]);
    disp(['   Link color: ' mat2str(obj.linkColor)]);
else
    disp('   Display link between furthest point and centroid: FALSE');
end    

% ====Average distance circle visualization properties
if (obj.displayAvgDCircle)
    disp('   Display average distance to centroid circle: TRUE');
    disp(['   Avg. distance to centroid circle line width: ' num2str(obj.linkLineWidth)]);
    disp(['   Avg. distance to centroid circle color: ' mat2str(obj.linkColor)]);
else
    disp('   Display average distance to centroid circle: FALSE');
end    
disp(' ');

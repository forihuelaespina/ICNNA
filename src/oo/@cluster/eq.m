function res=eq(obj,obj2)
%CLUSTER/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also cluster
%


%% Log
%
% File created: 17-Nov-2008
% File last modified (before creation of this log): N/A. This method had
%   not been modified since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Added support for new attribute classVersion
%





res=true;
if ~isa(obj2,'cluster')
    res=false;
    return
end

res = res && strcmp(obj.classVersion,obj2.classVersion);
res = res && (obj.id==obj2.id);
res = res && strcmp(obj.tag,obj2.tag);
res = res && strcmp(obj.description,obj2.description);
res = res && all(obj.patternIndexes==obj2.patternIndexes);
res = res && (obj.visible==obj2.visible);
if ~res
    return
end

res = res && all(obj.subjectsID==obj2.subjectsID);
res = res && all(obj.sessionsID==obj2.sessionsID);
res = res && all(obj.stimuliID==obj2.stimuliID);
res = res && all(obj.blocksID==obj2.blocksID);
res = res && all(obj.channelGroupsID==obj2.channelGroupsID);
if ~res
    return
end

res = res && all(obj.centroid==obj2.centroid);
res = res && strcmp(obj.centroidCriteria,...
                    obj2.centroidCriteria);
res = res && (obj.furthestPoint==obj2.furthestPoint);
res = res && (obj.averageDistance==obj2.averageDistance);
res = res && (obj.maximumDistance==obj2.maximumDistance);
if ~res
    return
end

res = res && (obj.showPatternPoints==obj2.showPatternPoints);
res = res && (obj.showCentroid==obj2.showCentroid);
res = res && (obj.showFurthestPoint==obj2.showFurthestPoint);
res = res && (obj.showLink==obj2.showLink);
res = res && (obj.showAverageDistance==obj2.showAverageDistance);
if ~res
    return
end


res = res && all(obj.dataColor==obj2.dataColor);
res = res && strcmp(obj.dataMarker,obj2.dataMarker);
res = res && (obj.dataMarkerSize==obj2.dataMarkerSize);
if ~res
    return
end

res = res && all(obj.centroidColor==obj2.centroidColor);
res = res && strcmp(obj.centroidMarker,obj2.centroidMarker);
res = res && (obj.centroidMarkerSize==obj2.centroidMarkerSize);
if ~res
    return
end

res = res && all(obj.furthestPointColor==obj2.furthestPointColor);
res = res && strcmp(obj.furthestPointMarker,obj2.furthestPointMarker);
res = res && (obj.furthestPointMarkerSize==obj.furthestPointMarkerSize);
if ~res
    return
end

res = res && all(obj.linkColor==obj2.linkColor);
res = res && (obj.linkLineWidth==obj2.linkLineWidth);
if ~res
    return
end

res = res && all(obj.averageDistanceColor==obj2.averageDistanceColor);
res = res && (obj.averageDistanceLineWidth==obj2.averageDistanceLineWidth);
if ~res
    return
end

end
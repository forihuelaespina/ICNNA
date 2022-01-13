function res=eq(obj,obj2)
%CLUSTER/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008
% @date: 17-Nov-2008
% @author Felipe Orihuela-Espina
%
% See also cluster
%

res=true;
if ~isa(obj2,'cluster')
    res=false;
    return
end

res = res && get(obj,'ID')==get(obj2,'ID');
res = res && strcmp(get(obj,'Tag'),get(obj2,'Tag'));
res = res && strcmp(get(obj,'Description'),get(obj2,'Description'));
res = res && all(get(obj,'PatternIndexes')==...
                     get(obj2,'PatternIndexes'));
res = res && get(obj,'Visible')==get(obj2,'Visible');
if ~res
    return
end

res = res && all(get(obj,'SubjectsID')==get(obj2,'SubjectsID'));
res = res && all(get(obj,'SessionsID')==get(obj2,'SessionsID'));
res = res && all(get(obj,'StimuliID')==get(obj2,'StimuliID'));
res = res && all(get(obj,'BlocksID')==get(obj2,'BlocksID'));
res = res && all(get(obj,'ChannelGroupsID')==get(obj2,'ChannelGroupsID'));
if ~res
    return
end

res = res && all(get(obj,'Centroid')==get(obj2,'Centroid'));
res = res && strcmp(get(obj,'CentroidCriteria'),...
                    get(obj2,'CentroidCriteria'));
res = res && get(obj,'FurthestPoint')==get(obj2,'FurthestPoint');
res = res && get(obj,'AverageDistance')==get(obj2,'AverageDistance');
res = res && get(obj,'MaximumDistance')==get(obj2,'MaximumDistance');
if ~res
    return
end

res = res && get(obj,'ShowPatternPoints')==get(obj2,'ShowPatternPoints');
res = res && get(obj,'ShowCentroid')==get(obj2,'ShowCentroid');
res = res && get(obj,'ShowFurthestPoint')==get(obj2,'ShowFurthestPoint');
res = res && get(obj,'ShowLink')==get(obj2,'ShowLink');
res = res && get(obj,'ShowAverageDistance')==get(obj2,'ShowAverageDistance');
if ~res
    return
end


res = res && all(get(obj,'DataColor')==get(obj2,'DataColor'));
res = res && strcmp(get(obj,'DataMarker'),get(obj2,'DataMarker'));
res = res && get(obj,'DataMarkerSize')==get(obj2,'DataMarkerSize');
if ~res
    return
end

res = res && all(get(obj,'CentroidColor')==get(obj2,'CentroidColor'));
res = res && strcmp(get(obj,'CentroidMarker'),get(obj2,'CentroidMarker'));
res = res && get(obj,'CentroidMarkerSize')==get(obj2,'CentroidMarkerSize');
if ~res
    return
end

res = res && all(get(obj,'FurthestPointColor')==...
                 get(obj2,'FurthestPointColor'));
res = res && strcmp(get(obj,'FurthestPointMarker'),...
                 get(obj2,'FurthestPointMarker'));
res = res && get(obj,'FurthestPointMarkerSize')==...
                 get(obj2,'FurthestPointMarkerSize');
if ~res
    return
end

res = res && all(get(obj,'LinkColor')==get(obj2,'LinkColor'));
res = res && get(obj,'LinkLineWidth')==get(obj2,'LinkLineWidth');
if ~res
    return
end

res = res && all(get(obj,'AverageDistanceColor')==...
                 get(obj2,'AverageDistanceColor'));
res = res && get(obj,'AverageDistanceLineWidth')==...
                 get(obj2,'AverageDistanceLineWidth');
if ~res
    return
end

end
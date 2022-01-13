function [h]=plotCluster2D(Y,c)
%Plots a cluster
%
%A convinient function for easy visualization of a cluster in a 2D space
%
% h=plotCluster2D(pointsCoordinates,cluster) Visualize the cluster
%   into the current axes.
%
%
%Parameters:
%-----------
%
% pointsCoordinates - The pattern (rows) coordinates (cols)
%   in the projection space.
%   See property 'ProjectionSpace' in analysis.get
%
% cluster - A cluster. See class cluster 
%
%
%Output:
%-------
%
% A vector of handles to the cluster components:
%
%  [hDataPoints hCentroid hFurthestPoint hLinkCenterFurthest hAvgDCircle]
%
% Those parts not painted will hold a -1 as a handler
%
%
% Copyright 2008
% @date: 28-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also guiAnalysis, guiVisualize, analysis, cluster
%

dim=size(Y,2);
if (dim~=2)
    errordlg({'ICNA:plotCluster2D:InvalidProjectionDimensionality',...
          'Unexpected projection dimensionality.'});
    return
end


h=[-1 -1 -1 -1 -1];
hold('on');

%Display data points if necessary
if get(c,'ShowPatternPoints')
    clusterData=Y(get(c,'PatternIndexes'),:);
    h(1)=line('XData',clusterData(:,1),...
            'YData',clusterData(:,2),...
            'LineStyle','none',...
            'Marker',get(c,'DataMarker'),...
            'Color',get(c,'DataColor'),...
            'MarkerSize',get(c,'DataMarkerSize'));
            
end
%Display centroid if necessary
centroid=get(c,'Centroid');
if get(c,'ShowCentroid')
    h(2)=line('XData',centroid(:,1),...
            'YData',centroid(:,2),...
            'LineStyle','none',...
            'Marker',get(c,'CentroidMarker'),...
            'Color',get(c,'CentroidColor'),...
            'MarkerSize',get(c,'CentroidMarkerSize'));
end
%Display furthest point if necessary
fpCoordinates=Y(get(c,'FurthestPoint'),:);
if get(c,'ShowFurthestPoint')
    h(3)=line('XData',fpCoordinates(1),...
            'YData',fpCoordinates(2),...
            'LineStyle','none',...
            'Marker',get(c,'FurthestPointMarker'),...
            'Color',get(c,'FurthestPointColor'),...
            'MarkerSize',get(c,'FurthestPointMarkerSize'));
end
%Display link centroid-furthest point if necessary
if get(c,'ShowLink')
    XX=[fpCoordinates(1) centroid(1)];
    YY=[fpCoordinates(2) centroid(2)];
    h(4)=line('XData',XX,...
            'YData',YY,...
            'Color',get(c,'LinkColor'),...
            'LineWidth',get(c,'LinkLineWidth'));
end
%Display cluster circle if necessary
if get(c,'ShowAverageDistance')
    tempOpt.lineStyle='-';
    tempOpt.color=get(c,'AverageDistanceColor');
    tempOpt.lineWidth=get(c,'AverageDistanceLineWidth');
    h(5)=circle(centroid,get(c,'AverageDistance'),tempOpt);
end

hold('off');

end
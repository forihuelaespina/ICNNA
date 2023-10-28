function obj = set(obj,varargin)
%CLUSTER/SET DEPRECATED (v1.2). Set object properties and return the updated object
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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also cluster, get
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
%   + Method getColorVector has now been isolated as a separate static
%   method
%



warning('ICNNA:cluster:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. cluster.' lower(varargin{1}) ' = ... ']); 


propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch lower(prop)
        case 'id'
            obj.id = val;
            % if (isscalar(val) && isreal(val) && ~ischar(val) ...
            %     && (val==floor(val)) && (val>0))
            % %Note that a char which can be converted to scalar
            % %e.g. will pass all of the above (except the ~ischar)
            %     obj.id = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a scalar natural/integer');
            % end

        case 'tag'
            obj.tag = val;
            % if (ischar(val))
            %     obj.tag = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a string');
            % end

        case 'description'
            obj.description = val;
            % if (ischar(val))
            %     obj.description = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a string');
            % end

        case 'patternindexes'
            obj.patternIndexes=val;
            % if isempty(val)
            %     obj.patternIdxs=[];
            % else
            %     val=unique(reshape(val,1,numel(val)));
            %     if (isreal(val) && all(floor(val)==val) && all(val>=0))
            %         obj.patternIdxs=val;
            %     else
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Pattern indexes must be positive integers.');
            %     end
            % end
            
        case 'visible'
            obj.visible=val;
            % if (~ischar(val) && isscalar(val))
            %     obj.visible=logical(val);
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be boolean');
            % end

% ==Cluster generating IDs
        case 'subjectsids'
            obj.subjectIDs=val;
            % if (ischar(val))
            %     val=str2num(val);
            % end
            % val=reshape(val,1,numel(val));
            % if (all(isreal(val)) && all(floor(val)==val))
            %     obj.subjectIDs=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Unrecognised value');
            % end
            
        case 'sessionsids'
            obj.sessionIDs=val;
            % if (ischar(val))
            %     val=str2num(val);
            % end
            % val=reshape(val,1,numel(val));
            % if (all(isreal(val)) && all(floor(val)==val))
            %     obj.sessionIDs=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Unrecognised value');
            % end
            
        case 'stimuliids'
            obj.stimulusIDs=val;
            % if (ischar(val))
            %     val=str2num(val);
            % end
            % val=reshape(val,1,numel(val));
            % if (all(isreal(val)) && all(floor(val)==val))
            %     obj.stimulusIDs=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Unrecognised value');
            % end
            
        case 'blocksids'
            obj.blockIDs=val;
            % if (ischar(val))
            %     val=str2num(val);
            % end
            % val=reshape(val,1,numel(val));
            % if (all(isreal(val)) && all(floor(val)==val))
            %     obj.blockIDs=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Unrecognised value');
            % end
            
        case 'channelgroupsids'
            obj.channelGroupIDs=val;
            % if (ischar(val))
            %     val=str2num(val);
            % end
            % val=reshape(val,1,numel(val));
            % if (all(isreal(val)) && all(floor(val)==val))
            %     obj.channelGroupIDs=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Unrecognised value');
            % end
            

% ==Cluster descriptors
        case 'centroid'
            obj.centroid=val;
            % val=reshape(val,1,numel(val));
            % if (all(isreal(val)))
            %     obj.centroid=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Unrecognised value');
            % end

        case 'centroidcriteria'
            obj.centroidCriteria = val;
            % if (ischar(val))
            %     obj.centroidCriteria = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a string');
            % end
       
        case 'furthestpoint'
            obj.furthestPoint = val;
            % if (isscalar(val) && isreal(val) && ~ischar(val) ...
            %     && (val==floor(val)) && (val>0))
            % %Note that a char which can be converted to scalar
            % %e.g. will pass all of the above (except the ~ischar)
            %     obj.furthestPoint = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a positive scalar natural/integer.');
            % end

        case 'averagedistance'
            obj.averageDistance = val;
            % if (isscalar(val) && isreal(val) && ~ischar(val) ...
            %     && (val>=0))
            % %Note that a char which can be converted to scalar
            % %e.g. will pass all of the above (except the ~ischar)
            %     obj.avgDistance = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a scalar natural/integer.');
            % end

        case 'maximumdistance'
            obj.maximumDistance = val;
            % if (isscalar(val) && isreal(val) && ~ischar(val) ...
            %     && (val>=0))
            % %Note that a char which can be converted to scalar
            % %e.g. will pass all of the above (except the ~ischar)
            %     obj.maxDistance = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a scalar natural/integer.');
            % end

% ==Visualization attributes
        case 'showpatternpoints'
            obj.showpPatternPoints = val;
            % if (~ischar(val) && isscalar(val))
            %     obj.displayPatternPoints=logical(val);
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be boolean');
            % end

        case 'showcentroid'
             obj.showpCentroid = val;
            % if (~ischar(val) && isscalar(val))
            %     obj.displayCentroid=logical(val);
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be boolean');
            % end

        case 'showfurthestpoint'
            obj.showpFurthestPoint = val;
            % if (~ischar(val) && isscalar(val))
            %     obj.displayFurthestPoint=logical(val);
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be boolean');
            % end

        case 'showlink'
            obj.showpLink = val;
            % if (~ischar(val) && isscalar(val))
            %     obj.displayLink=logical(val);
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be boolean');
            % end

        case 'showaveragedistance'
            obj.showpAverageDistanceCircle = val;
        case 'showaveragedistancecircle'
            obj.showpAverageDistanceCircle = val;
            % if (~ischar(val) && isscalar(val))
            %     obj.displayAvgDCircle=logical(val);
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be boolean');
            % end

% ==== Patterns (data) visualization properties
        case 'datamarker'
            obj.dataMarker = val;
            % if (ischar(val) && length(val)==1)
            %     if (ismember(val,'+o*.xsv^d><ph'))
            %         obj.dMarker = val;
            %     else
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Invalid marker');
            %     end
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Value must be a char');
            % end

        case 'datamarkersize'
            obj.dataMarkerSize = val;
            % if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
            %     obj.dMarkerSize = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Invalid markerSize. Must be a positive integer.');
            % end

        case 'datacolor'
            if (ischar(val) && length(val)==1)
                val = cluster.getColorVector(val);
            end
            obj.dataColor=val;
            % if (ischar(val) && length(val)==1)
            %     rgb=getColorVector(val);
            %     if isempty(rgb)
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Invalid color descriptor.');
            %     else
            %         obj.dColor=rgb;
            %     end
            % elseif (isreal(val) && all([1 3]==size(val)) && ...
            %         all(val<=1) &&  all(val>=0))
            %     obj.dColor=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Value must be a char');
            % end


% ==== Centroid visualization properties
        case 'centroidmarker'
            obj.centroidMarker = val;
            % if (ischar(val) && length(val)==1)
            %     if (ismember(val,'+o*.xsv^d><ph'))
            %         obj.cMarker = val;
            %     else
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Invalid marker');
            %     end
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Value must be a char');
            % end

        case 'centroidmarkersize'
            obj.centroidMarkerSize = val;
            % if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
            %     obj.cMarkerSize = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Invalid markerSize. Must be a positive integer.');
            % end

        case 'centroidcolor'
            if (ischar(val) && length(val)==1)
                val = cluster.getColorVector(val);
            end
            obj.centroidColor=val;
            % if (ischar(val) && length(val)==1)
            %     rgb=getColorVector(val);
            %     if isempty(rgb)
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Invalid color descriptor.');
            %     else
            %         obj.cColor=rgb;
            %     end
            % elseif (isreal(val) && all([1 3]==size(val)) && ...
            %         all(val<=1) &&  all(val>=0))
            %     obj.cColor=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Value must be a char');
            % end

% ==== Furthest Point and link visualization properties
        case 'furthestpointmarker'
            obj.furthestPointMarker = val;
            % if (ischar(val) && length(val)==1)
            %     if (ismember(val,'+o*.xsv^d><ph'))
            %         obj.fpMarker = val;
            %     else
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Invalid marker');
            %     end
            % else
            %     error('ICNA:cluster:set:FurthestPointMarker',...
            %             'Value must be a char');
            % end

        case 'furthestpointmarkersize'
            obj.furthestPointMarkerSize = val;
            % if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
            %     obj.fpMarkerSize = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Invalid markerSize. Must be a positive integer.');
            % end

        case 'furthestpointcolor'
            if (ischar(val) && length(val)==1)
                val = cluster.getColorVector(val);
            end
            obj.furthestPointColor=val;
            % if (ischar(val) && length(val)==1)
            %     rgb=getColorVector(val);
            %     if isempty(rgb)
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Invalid color descriptor.');
            %     else
            %         obj.fpColor=rgb;
            %     end
            % elseif (isreal(val) && all([1 3]==size(val)) && ...
            %         all(val<=1) &&  all(val>=0))
            %     obj.fpColor=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Value must be a char');
            % end


        case 'linkcolor'
            if (ischar(val) && length(val)==1)
                val = cluster.getColorVector(val);
            end
            obj.linkColor=val;
            % if (ischar(val) && length(val)==1)
            %     rgb=getColorVector(val);
            %     if isempty(rgb)
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Invalid color descriptor.');
            %     else
            %         obj.linkColor=rgb;
            %     end
            % elseif (isreal(val) && all([1 3]==size(val)) && ...
            %         all(val<=1) &&  all(val>=0))
            %     obj.linkColor=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Value must be a char');
            % end

        case 'linklinewidth'
            obj.linkLineWidth = val;
            % if (isscalar(val) && isreal(val) && ~ischar(val) ...
            %     && (val>0))
            % %Note that a char which can be converted to scalar
            % %e.g. will pass all of the above (except the ~ischar)
            %     obj.linkLineWidth = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a scalar natural/integer');
            % end


%
% ====Average distance circle visualization properties
        case 'averagedistancecirclecolor'
            if (ischar(val) && length(val)==1)
                val = cluster.getColorVector(val);
            end
            obj.averageDistanceCircleColor = val;
        case 'averagedistancecolor'
            if (ischar(val) && length(val)==1)
                val = cluster.getColorVector(val);
            end
            obj.averageDistanceCircleColor = val;
            % if (ischar(val) && length(val)==1)
            %     rgb=getColorVector(val);
            %     if isempty(rgb)
            %         error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Invalid color descriptor.');
            %     else
            %         obj.avgcColor=rgb;
            %     end
            % elseif (isreal(val) && all([1 3]==size(val)) && ...
            %         all(val<=1) &&  all(val>=0))
            %     obj.avgcColor=val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %             'Value must be a char');
            % end

        case 'averagedistancecirclelinewidth'
            obj.averageDistanceCircleLineWidth = val;
        case 'averagedistancelinewidth'
            obj.averageDistanceCircleLineWidth = val;
            % if (isscalar(val) && isreal(val) && ~ischar(val) ...
            %     && (val>0))
            % %Note that a char which can be converted to scalar
            % %e.g. will pass all of the above (except the ~ischar)
            %     obj.avgcLineWidth = val;
            % else
            %     error('ICNA:cluster:set:InvalidPropertyValue',...
            %           'Value must be a scalar natural/integer');
            % end
            
        case 'color'
            if (ischar(val) && length(val)==1)
                val = cluster.getColorVector(val);
            end
            obj.dataColor = val;
            obj.centroidColor = val;
            obj.furthestPointColor = val;
            obj.linkColor = val;
            obj.averageDistanceCircleColor = val;
            % obj=set(obj,'DataColor',val,...
            %             'CentroidColor',val,...
            %             'FurthestPointColor',val,...
            %             'LinkColor',val,...
            %             'AverageDistanceColor',val);
            


        otherwise
            error('ICNA:cluster:set:InvalidPropertyName',...
                  ['Property ' prop ' not valid.'])
    end
end

end

% function rgb=getColorVector(ch)
% %Returns a color vector from a caracter color descriptor
% %or an empty string if the caracter is not recognised.
% switch (ch)
%     case 'r'
%         rgb = [1 0 0];
%     case 'g'
%         rgb = [0 1 0];
%     case 'b'
%         rgb = [0 0 1];
%     case 'k'
%         rgb = [0 0 0];
%     case 'w'
%         rgb = [1 1 1];
%     case 'm'
%         rgb = [1 0 1];
%     case 'c'
%         rgb = [0 1 1];
%     case 'y'
%         rgb = [1 1 0];
%     otherwise
%         rgb=[];
% end
% end   
    
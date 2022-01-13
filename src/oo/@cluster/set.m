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
propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case 'ID'
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.id = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer');
            end

        case 'Tag'
            if (ischar(val))
                obj.tag = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a string');
            end

        case 'Description'
            if (ischar(val))
                obj.description = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a string');
            end

        case 'PatternIndexes'
            if isempty(val)
                obj.patternIdxs=[];
            else
                val=unique(reshape(val,1,numel(val)));
                if (isreal(val) && all(floor(val)==val) && all(val>=0))
                    obj.patternIdxs=val;
                else
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Pattern indexes must be positive integers.');
                end
            end
            
        case 'Visible'
            if (~ischar(val) && isscalar(val))
                obj.visible=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end

% ==Cluster generating IDs
        case 'SubjectsIDs'
            if (ischar(val))
                val=str2num(val);
            end
            val=reshape(val,1,numel(val));
            if (all(isreal(val)) && all(floor(val)==val))
                obj.subjectIDs=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Unrecognised value');
            end
            
        case 'SessionsIDs'
            if (ischar(val))
                val=str2num(val);
            end
            val=reshape(val,1,numel(val));
            if (all(isreal(val)) && all(floor(val)==val))
                obj.sessionIDs=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Unrecognised value');
            end
            
        case 'StimuliIDs'
            if (ischar(val))
                val=str2num(val);
            end
            val=reshape(val,1,numel(val));
            if (all(isreal(val)) && all(floor(val)==val))
                obj.stimulusIDs=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Unrecognised value');
            end
            
        case 'BlocksIDs'
            if (ischar(val))
                val=str2num(val);
            end
            val=reshape(val,1,numel(val));
            if (all(isreal(val)) && all(floor(val)==val))
                obj.blockIDs=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Unrecognised value');
            end
            
        case 'ChannelGroupsIDs'
            if (ischar(val))
                val=str2num(val);
            end
            val=reshape(val,1,numel(val));
            if (all(isreal(val)) && all(floor(val)==val))
                obj.channelGroupIDs=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Unrecognised value');
            end
            

% ==Cluster descriptors
        case 'Centroid'
            val=reshape(val,1,numel(val));
            if (all(isreal(val)))
                obj.centroid=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Unrecognised value');
            end

        case 'CentroidCriteria'
            if (ischar(val))
                obj.centroidCriteria = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a string');
            end
       
        case 'FurthestPoint'
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.furthestPoint = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a positive scalar natural/integer.');
            end
        case 'AverageDistance'
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>=0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.avgDistance = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer.');
            end
        case 'MaximumDistance'
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>=0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.maxDistance = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer.');
            end

% ==Visualization attributes
        case 'ShowPatternPoints'
            if (~ischar(val) && isscalar(val))
                obj.displayPatternPoints=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end

        case 'ShowCentroid'
            if (~ischar(val) && isscalar(val))
                obj.displayCentroid=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        case 'ShowFurthestPoint'
            if (~ischar(val) && isscalar(val))
                obj.displayFurthestPoint=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        case 'ShowLink'
            if (~ischar(val) && isscalar(val))
                obj.displayLink=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        case 'ShowAverageDistance'
            if (~ischar(val) && isscalar(val))
                obj.displayAvgDCircle=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end

% ==== Patterns (data) visualization properties
        case 'DataMarker'
            if (ischar(val) && length(val)==1)
                if (ismember(val,'+o*.xsv^d><ph'))
                    obj.dMarker = val;
                else
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Invalid marker');
                end
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Value must be a char');
            end

        case 'DataMarkerSize'
            if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
                obj.dMarkerSize = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Invalid markerSize. Must be a positive integer.');
            end

        case 'DataColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.dColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.dColor=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Value must be a char');
            end


% ==== Centroid visualization properties
        case 'CentroidMarker'
            if (ischar(val) && length(val)==1)
                if (ismember(val,'+o*.xsv^d><ph'))
                    obj.cMarker = val;
                else
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Invalid marker');
                end
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Value must be a char');
            end

        case 'CentroidMarkerSize'
            if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
                obj.cMarkerSize = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Invalid markerSize. Must be a positive integer.');
            end

        case 'CentroidColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.cColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.cColor=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Value must be a char');
            end

% ==== Furthest Point and link visualization properties
        case 'FurthestPointMarker'
            if (ischar(val) && length(val)==1)
                if (ismember(val,'+o*.xsv^d><ph'))
                    obj.fpMarker = val;
                else
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Invalid marker');
                end
            else
                error('ICNA:cluster:set:FurthestPointMarker',...
                        'Value must be a char');
            end

        case 'FurthestPointMarkerSize'
            if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
                obj.fpMarkerSize = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Invalid markerSize. Must be a positive integer.');
            end

        case 'FurthestPointColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.fpColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.fpColor=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Value must be a char');
            end


        case 'LinkColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.linkColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.linkColor=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Value must be a char');
            end
        case 'LinkLineWidth'
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.linkLineWidth = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer');
            end


%
% ====Average distance circle visualization properties
        case 'AverageDistanceColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.avgcColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.avgcColor=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Value must be a char');
            end
        case 'AverageDistanceLineWidth'
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.avgcLineWidth = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer');
            end
            
        case 'Color'
            obj=set(obj,'DataColor',val,...
                        'CentroidColor',val,...
                        'FurthestPointColor',val,...
                        'LinkColor',val,...
                        'AverageDistanceColor',val);

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
    
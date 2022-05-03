%A cluster (or class) simply holds a record of points which
%share some conceptual link together.
%
%A cluster is nothing else than a simple filter applicable
%to the index registry of the analysis (see class analysis).
%In this sense, a point in the Feature
%Space can belong to none or several clusters depending on
%how the clusters are specified.
%
%For visualization purposes an analysis holds a number of clusters
%which can be set to visible or hided as desired. The creation
%or removal of clusters DO NOT AFFECT the analysis embedding.
%Hence, hiding a cluster
%does not change the output configuration (projection data),
%but only helps to enhance visualization.
%By adding/removing clusters to the analysis and hiding
%or unhiding them, it should be possible to customize the
%visualization of the projection.
%
%Through the definition of clusters it is possible to
%mantain different views over the same analysis.
%For instance, let a experiment involves three groups of subject
%with different surgical skill and that we measure their brain
%activity in two regions (frontal and parietal). It is possible
%that in this dataset, we might be first interested in looking
%at groups with different expertise level (e.g. Consultants,
%Registrars and Novices), and later on, focus on the general
%differences between frontal activity and parietal activity. Or even
%further look at handedness differences. For each particular
%interest, a number of clusters may be defined to highlight
%the particular groups of interest.
%
%
%% The filter record
%
% The key important attribute in the cluster class is .patternIdxs
%which hold the indexes to those patterns (points) belonging
%to the cluster. As such the cluster does not know how these
%points where selected from the Feature Space. However, most of
%the time, these points will almost certainly not be picked
%randomly, but following a certain criteria e.g. experts subjets,
%or control session. When this is the case, it will then be
%possible to describe the cluster in terms of the IDs of the
%elements of interest. For instance, if control session is
%identified by ID==1, then selecting all those patterns for
%which their session ID is 1 from the pool of indexes in the
%analysis, should result in the cluster list of points.
%For keeping record of this, the cluster class can keep track
%of these cluster generating IDs in a set of attributes defined
%to this effect. However it must be emphasized that the class
%offers no guarantee that the list of indexes present in
%.patternIdxs indeed correspond to the filter resulting from
%this record, and it is up to the user to keep them up-to-date.
%
%Currently, the attributes to keep track of the cluster generating
%IDs are:
%
%    .subjectIDs
%    .sessionIDs
%    .stimulusIDs
%    .blockIDs
%    .channelGroupIDs
%
%
%
%% REMARKS
%
% A cluster is tighlty linked to the analysis to which its
%patterns it refers. The indexes to the patterns refers to
%those in field I of class Analysis. A cluster has no meaning
%outside an analysis (hence a composition relation between
%class Analysis and class Cluster).
%
%Methods createCluster and removeCluster in the class analysis
%helps to maintain this relationship.
%
%
%% PROPERTIES
%
%   .id - A numerical identifier.
%   .tag - A tag for the cluster. This is used in legends when appropriate.
%   .description - A short description for the cluster
%   .patternIdxs - Indexes to patterns (points) belonging
%       to the cluster. Default value is empty; i.e. the cluster
%       holds no point.
%   .visible - Boolean value to indicate whether the cluster
%           is visible or should be hide during visualization.
%
%
% ==Cluster generating IDs (Please read section "The filter record")
%
%    .subjectIDs - IDs of the selected subjects belonging to the
%       cluster or empty if the subjects are not used as a filter
%       criteria. Default value is empty matrix.
%    .sessionIDs - IDs of the selected sessions belonging to the
%       cluster or empty if the sessions are not used as a filter
%       criteria. Default value is empty matrix.
%    .stimulusIDs - IDs of the selected stimuli belonging to the
%       cluster or empty if the stimuli are not used as a filter
%       criteria. Default value is empty matrix.
%    .blockIDs - IDs of the selected blocks belonging to the
%       cluster or empty if the blocks are not used as a filter
%       criteria. Default value is empty matrix.
%    .channelGroupIDs - IDs of the selected channel groups belonging to the
%       cluster or empty if the channel groups are not used as a filter
%       criteria. Default value is empty matrix.
%
% ==Cluster descriptors
%
%   .centroid - Cluster centroid coordinates
%   .centroidCriteria - Criteria used to calulate the cluster centroid
%   .furthestPoint - Index to the furthest point from centroid
%   .avgDistance - Average distance of all points to the centroid
%   .maxDistance - Distance from the furthest point to the centroid
%
% ==Visualization attributes
%   .displayPatternPoints - Indicates whether to display the
%       pattern points when visualizing the cluster. Default true.
%   .displayCentroid - Indicates whether to display the
%       centroid when visualizing the cluster. Default true.
%   .displayFurthestPoint - Indicates whether to display the
%       furthestPoint when visualizing the cluster. Default true.
%   .displayLink - Indicates whether to display a link between
%       the cluster centroid and the furthest point when
%       visualizing the cluster. Default true.
%   .displayAvgDCircle - Indicates whether to display the
%       avarage distance circle when visualizing the cluster.
%       Default true.
%
% ==== Patterns (data) visualization properties
%   .dMarker - The marker to use when representing the patterns.
%       Default '.'
%   .dMarkerSize - The marker size to use. Default 8
%   .dColor - The color to use when representing this cluster.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%
% ==== Centroid visualization properties
%   .cMarker - The marker to use when representing the centroid.
%       Default 'o'
%   .cMarkerSize - The marker size for the centroid. Default 8
%   .cColor - The color to use when representing the centroid.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%
% ==== Furthest Point and link visualization properties
%   .fpMarker - The marker to use when representing the furthest
%       point to the centroid. Default 'x'
%   .fpMarkerSize - The marker size. Default 8
%   .fpColor - The color to use when representing the furthest point.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%   .linkColor - The color of the line linking the centroid and the
%       furthest point.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%   .linkLineWidth - Line width for the line linking the
%       centroid and the furthest point. Default 1.5
%
% ====Average distance circle visualization properties
%   .avgcLineWidth - Line width for the average distance circle.
%       Default 1.5
%   .avgcColor - The color to use when representing the average
%       distance circle.
%       Default 'k' (black). You can use either MATLAB color
%       identifiers or an RGB normalized vector.
%
%
%All color properties can be set at once using set(obj,'Color',colorSpec)
%
%% INVARIANTS
%
% See private/assertInvariants
%       
%% METHODS
%
% Type methods('cluster') for a list of methods
% 
% Copyright 2008
% date: 26-May-2008
% Author: Felipe Orihuela-Espina
%
% See also analysis
%

%% Log
%
% 1-Sep-2016 (FOE): Class created.
%
% 20-February-2022 (ESR): Get/Set Methods created in cluster class
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside of the cluster class.
%
% 02-May-2022 (ESR): cluster class SetAccess=private, GetAccess=private) removed
%   + The access from private to public was commented because before the data 
%   did not request to enter the set method and now they are forced to be executed, 
%   therefore the private accesses were modified to public.
%
classdef cluster
    properties %(SetAccess=private, GetAccess=private)
        id=1;
        tag='Cluster0001';
        description='';
        patternIdxs=[];       
        visible=true;
     
% ==Cluster generating IDs
        subjectIDs = [];
        sessionIDs = [];
        stimulusIDs = [];
        blockIDs = [];
        channelGroupIDs = [];

% ==Cluster descriptors
        centroid=[];
        centroidCriteria='';
        furthestPoint=[]; %Index to the furthest point
        avgDistance=0; %Average distance of all points to the centroid
        maxDistance=0; %Distance from the furthest point to the centroid

% ==Visualization attributes
        displayPatternPoints=true;
        displayCentroid=true;
        displayFurthestPoint=true;
        displayLink=true;
        displayAvgDCircle=true;

% ==== Patterns (data) visualization properties
        dMarker='.';
        dMarkerSize=8;
        dColor=[0 0 0];

% ==== Centroid visualization properties
        cMarker='o';
        cMarkerSize=8;
        cColor=[0 0 0];

% ==== Furthest Point and link visualization properties
        fpMarker='x';
        fpMarkerSize=8;
        fpColor=[0 0 0];
        linkColor=[0 0 0];
        linkLineWidth=1.5;

% ====Average distance circle visualization properties
        avgcLineWidth=1.5;
        avgcColor=[0 0 0];
        
    end
    
    properties (Dependent)
       nPatterns
       color
    end
    
    methods
        function obj=cluster(varargin)
        %CLUSTER Cluster class constructor
        %
        % obj=cluster() creates a default cluster with ID equals 1.
        %
        % obj=cluster(obj2) acts as a copy constructor of cluster
        %
        % obj=cluster(id) creates a new cluster with the given
        %   identifier (id). The tag of the cluster is initialised
        %   to 'ClusterXXXX' where is the id preceded with 0.
        %
        % obj=cluster(id,tag) creates a new cluster with the given
        %   identifier (id) and tag.
        if (nargin==0)
            %Keep default values
        elseif isa(varargin{1},'cluster')
            obj=varargin{1};
            return;
        else
            obj=set(obj,'ID',varargin{1});
            obj.tag=['Cluster' num2str(obj.id,'%04i')];
            if (nargin>1)
                obj=set(obj,'Tag',varargin{2});
            end
        end
        %assertInvariants(obj);
        end
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %id
        function val = get.id(obj)
            % The method is converted and encapsulated. 
            % obj is the cluster class
            % val is the value added in the object
            % get.id(obj) = Get the data from the cluster class
            % and look for the id object.
            val = obj.id;
        end
        function obj = set.id(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the cluster class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                    obj.id = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer');
            end
        end
        
        %tag
        function val = get.tag(obj)
            val = obj.tag;
        end
        function obj = set.tag(obj,val)
            if (ischar(val))
                obj.tag = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a string');
            end
        end
        
        %description
        function val = get.description(obj)
            val = obj.description;
        end
        function obj = set.description(obj,val)
            if (ischar(val))
                obj.description = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a string');
            end
        end
        
        %patternIdxs
        function val = get.patternIdxs(obj)
            val = obj.patternIdxs;
        end
        function obj = set.patternIdxs(obj,val)
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
        end
        
        %visible
        function val = get.visible(obj)
            val = obj.visible;
        end
        function obj = set.visible(obj,val)
            if (~ischar(val) && isscalar(val))
                obj.visible=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        end
        
        % ==Cluster generating IDs -------------------------------------->

        %subjectIDs
        function val = get.subjectIDs(obj)
            val = obj.subjectIDs;
        end
        function obj = set.subjectIDs(obj,val)
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
        end
        
        %sessionIDs
        function val = get.sessionIDs(obj)
            val = obj.sessionIDs;
        end
        function obj = set.sessionIDs(obj,val)
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
        end
        
        %stimulusIDs
        function val = get.stimulusIDs(obj)
            val = obj.stimulusIDs;
        end
        function obj = set.stimulusIDs(obj,val)
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
        end
        
        %blockIDs
        function val = get.blockIDs(obj)
            val = obj.blockIDs;
        end
        function obj = set.blockIDs(obj,val)
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
        end
        
        %channelGroupIDs
        function val = get.channelGroupIDs(obj)
            val = obj.channelGroupIDs;
        end
        function obj = set.channelGroupIDs(obj,val)
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
        end
        
        % ==Cluster descriptors ----------------------------------------->
        
        %centroid
        function val = get.centroid(obj)
             val = obj.centroid;
        end
        function obj = set.centroid(obj,val)
                val=reshape(val,1,numel(val));
            if (all(isreal(val)))
                obj.centroid=val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Unrecognised value');
            end
        end
        
        %centroidCriteria
        function val = get.centroidCriteria(obj)
            val = obj.centroidCriteria;
        end
        function obj = set.centroidCriteria(obj,val)
             if (ischar(val))
                obj.centroidCriteria = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a string');
            end
        end
        
        %furthestPoint
        function val = get.furthestPoint(obj)
            val = obj.furthestPoint;
        end
        function obj = set.furthestPoint(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.furthestPoint = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a positive scalar natural/integer.');
            end
        end
        
        %avgDistance
        function val = get.avgDistance(obj)
            val = obj.avgDistance;
        end
        function obj = set.avgDistance(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>=0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.avgDistance = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer.');
            end
        end
        
        %maxDistance
        function val = get.maxDistance(obj)
            val = obj.maxDistance;
        end
        function obj = set.maxDistance(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>=0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.maxDistance = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer.');
            end
        end
        
        % ==Visualization attributes ------------------------------------>
        
        %displayPatternPoints
        function val = get.displayPatternPoints(obj)
            val = obj.displayPatternPoints;
        end
        function obj = set.displayPatternPoints(obj,val)
            if (~ischar(val) && isscalar(val))
                obj.displayPatternPoints=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        end
        
        %displayCentroid
        function val = get.displayCentroid(obj)
            val = obj.displayCentroid;
        end
        function obj = set.displayCentroid(obj,val)
            if (~ischar(val) && isscalar(val))
                obj.displayCentroid=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        end
        
        %displayFurthestPoint
        function val = get.displayFurthestPoint(obj)
            val = obj.displayFurthestPoint;
        end
        function obj = set.displayFurthestPoint(obj,val)
            if (~ischar(val) && isscalar(val))
                obj.displayFurthestPoint=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        end
        
        %displayLink
        function val = get.displayLink(obj)
            val = obj.displayLink;
        end
        function obj = set.displayLink(obj,val)
            if (~ischar(val) && isscalar(val))
                obj.displayLink=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        end
        
        %displayAvgDCircle
        function val = get.displayAvgDCircle(obj)
            val = obj.displayAvgDCircle;
        end
        function obj = set.displayAvgDCircle(obj,val)
            if (~ischar(val) && isscalar(val))
                obj.displayAvgDCircle=logical(val);
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end
        end
        
        % ==== Patterns (data) visualization properties ------------------>
        
        %dMarker
        function val = get.dMarker(obj)
           val = obj.dMarker;
        end
        function obj = set.dMarker(obj,val)
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
        end
        
        %dMarkerSize
        function val = get.dMarkerSize(obj)
           val = obj.dMarkerSize;
        end
        function obj = set.dMarkerSize(obj,val)
           if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
                obj.dMarkerSize = val;
           else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Invalid markerSize. Must be a positive integer.');
           end
        end
        
        %dColor
        function val = get.dColor(obj)
           val = obj.dColor;
        end
        function obj = set.dColor(obj,val)
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
        end

        % ==== Centroid visualization properties ------------------------->
        
        %cMarker
        function val = get.cMarker(obj)
           val = obj.cMarker;
        end
        function obj = set.cMarker(obj,val)
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
        end
        
        %cMarkerSize
        function val = get.cMarkerSize(obj)
           val = obj.cMarkerSize;
        end
        function obj = set.cMarkerSize(obj,val)
             if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
                obj.cMarkerSize = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Invalid markerSize. Must be a positive integer.');
            end
        end
        
        %cColor
        function val = get.cColor(obj)
           val = obj.cColor;
        end
        function obj = set.cColor(obj,val)
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
        end
        
        % ==== Furthest Point and link visualization properties----------->
        
        %fpMarker
        function val = get.fpMarker(obj)
           val = obj.fpMarker;
        end
        function obj = set.fpMarker(obj,val)
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
        end
        
        %fpMarkerSize
        function val = get.fpMarkerSize(obj)
           val = obj.fpMarkerSize;
        end
        function obj = set.fpMarkerSize(obj,val)
            if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
                obj.fpMarkerSize = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                        'Invalid markerSize. Must be a positive integer.');
            end
        end
        
        %fpColor
        function val = get.fpColor(obj)
           val = obj.fpColor;
        end
        function obj = set.fpColor(obj,val)
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
        end
        
        %linkColor
        function val = get.linkColor(obj)
           val = obj.linkColor;
        end
        function obj = set.linkColor(obj,val)
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
        end
        
        %linkLineWidth
        function val = get.linkLineWidth(obj)
           val = obj.linkLineWidth;
        end
        function obj = set.linkLineWidth(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.linkLineWidth = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer');
            end
        end
      
        % ====Average distance circle visualization properties------------>
        
        %avgcLineWidth
        function val = get.avgcLineWidth(obj)
           val = obj.avgcLineWidth;
        end
        function obj = set.avgcLineWidth(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.avgcLineWidth = val;
            else
                error('ICNA:cluster:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer');
            end
        end
        
        %avgcColor
        function val = get.avgcColor(obj)
           val = obj.avgcColor;
        end
        function obj = set.avgcColor(obj,val)
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
        end

        %---------------------------------------------------------------->
        %Dependent
        %Dependent properties do not store data. 
        %The value of a dependent property depends on some other value, 
        %such as the value of a nondependent property.
        
        %Dependent properties must define get-access methods () to 
        %determine a value for the property when the property is queried: 
        %get.Color
        
        %We create a dependent property.
        %---------------------------------------------------------------->
        
        %Color
        function obj = set.color(obj,val)
            obj=set(obj,'DataColor',val,...
                        'CentroidColor',val,...
                        'FurthestPointColor',val,...
                        'LinkColor',val,...
                        'AverageDistanceColor',val);
        end
        
        %NPatterns
        function val = get.nPatterns(obj)
            val = length(obj.patternIdxs);
        end
        

        
    end
end

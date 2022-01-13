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
classdef cluster
    properties (SetAccess=private, GetAccess=private)
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
    end
end

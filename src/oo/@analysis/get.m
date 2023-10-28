function val = get(obj, propName)
% ANALYSIS/GET DEPRECATED (v1.2). Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
% 'ID' - The numeric identifier
% 'Name' - The instance name
% 'Description' -  The instance description
% 'Metric' -  Current selected metric
% 'Embedding' -  Current selected embedding technique
% 'ExperimentSpace' -  The associated Experiment Space
% 'FeatureSpace' -  The Feature Space
% 'ProjectionSpace' -  The Projection Space
% 'PatternDistance' - Matrix of pairwise distances in the Feature Space
% 'PatternIndexes' -  List of pattern indexes linking Feature and
%           Projection Spaces
% 'NPatterns' -  Number of patterns in the Feature and Projection Space
% 'RunStatus' - Current status
% 'ProjectionDimensionality' - Dimension of the Projection Space
% 'SubjectsIncluded' - List of subjects' ID included in the analysis
% 'SessionsIncluded' - List of sessions' ID included in the analysis
% 'ChannelGroups' - List of channel groups included in the analysis
% 'SignalDescriptors' - List of signals (2nd col) and the generating
%       data sources (2nd col) included in the analysis
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also analysis, set
%



%% Log
%
% File created: 26-May-2008
% File last modified (before creation of this log): 28-Nov-2008
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%   Bug fixed:
%   + 1 error was still not using error code.
%

warning('ICNNA:analysis:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. analysis.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.

switch lower(propName)
case 'id'
   val = obj.id;
case 'name'
   val = obj.name;
case 'description'
   val = obj.description;
case 'metric'
   val = obj.metric;
case 'embedding'
   val = obj.embedding;
case 'experimentspace'
   val = obj.F;
case 'featurespace'
   val = obj.H;
case 'projectionspace'
   val = obj.Y;
case 'patterndistances'
   val = obj.D;
case 'patternindexes'
   val = obj.I;
case 'npatterns'
   val = size(obj.H,1);
case 'runstatus'
   val = obj.runStatus;
case 'projectiondimensionality'
   val = obj.projectionDimensionality;
case 'subjectsincluded'
   val = obj.subjectsIncluded;
case 'sessionsincluded'
   val = obj.sessionsIncluded;
case 'channelgroups'
   val = obj.channelGrouping;
case 'signaldescriptors'
   val = obj.signalDescriptors;
otherwise
   error('ICNNA:analysis:get:InvalidProperty',...
        [propName,' is not a valid property'])
end




end
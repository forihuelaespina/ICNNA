function val = get(obj, propName)
% ANALYSIS/GET Get properties from the specified object
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
% Copyright 2008
% @date: 26-May-2008
% last update: 28-Nov-2008
% @author Felipe Orihuela-Espina
%
% See also analysis, set
%

switch propName
case 'ID'
   val = obj.id;
case 'Name'
   val = obj.name;
case 'Description'
   val = obj.description;
case 'Metric'
   val = obj.metric;
case 'Embedding'
   val = obj.embedding;
case 'ExperimentSpace'
   val = obj.F;
case 'FeatureSpace'
   val = obj.H;
case 'ProjectionSpace'
   val = obj.Y;
case 'PatternDistances'
   val = obj.D;
case 'PatternIndexes'
   val = obj.I;
case 'NPatterns'
   val = size(obj.H,1);
case 'RunStatus'
   val = obj.runStatus;
case 'ProjectionDimensionality'
   val = obj.projectionDimensionality;
case 'SubjectsIncluded'
   val = obj.subjectsIncluded;
case 'SessionsIncluded'
   val = obj.sessionsIncluded;
case 'ChannelGroups'
   val = obj.channelGrouping;
case 'SignalDescriptors'
   val = obj.signalDescriptors;
otherwise
   error([propName,' is not a valid property'])
end
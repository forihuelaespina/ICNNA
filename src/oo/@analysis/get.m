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


%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 23-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the analysis class.
%   + We create a dependent property inside of the analysis class 
%
%
      tmp = lower(propName);
    
    switch (tmp)

           case 'description'
                val = obj.description;
           case 'id'
                val = obj.id;  
           case 'name'
                val = obj.name;           
           case 'metric'
                val = obj.metric;
           case 'embedding'
                val = obj.embedding;
           case 'projectiondimensionality'
                val = obj.projectionDimensionality;
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
                val = obj.nPatterns;  
           case 'runstatus'
                val = obj.runStatus;           
           case 'subjectsincluded'
                val = obj.subjectsIncluded;
           case 'sessionsincluded'
                val = obj.sessionsIncluded;
           case 'channelgrouping'
                val = obj.channelGrouping;
           case 'signaldescriptors'
                val = obj.signalDescriptors;  
        
        otherwise 
            error([propName,' is not a valid property'])
    end

end
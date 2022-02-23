function obj = set(obj,varargin)
% ANALYSIS/SET Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue) Set object properties
%       and return the updated object
%
%% Properties
% 'ID' - The numeric identifier
% 'Name' - The instance name. Updating the analsyis name, also
%       updates the name of the associated Experiment Space.
% 'Description' -  The instance description. Updating the analsyis
%       description, also
%       updates the description of the associated Experiment Space.
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
% Copyright 2008-9
% @date: 26-May-2008
% last update: 28-Nov-2008
% @author Felipe Orihuela-Espina
%
% See also analysis, get
%

%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 23-February-2022 (ESR): We simplify the code
%   + All cases are in the analysis class.
%   + We create a dependent property inside of the rawData_UCLWireless class.
%   

propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);
       
       obj.(lower(prop)) = val; %Ignore case
   end
end
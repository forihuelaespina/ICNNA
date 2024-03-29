function obj = run(obj)
%ANALYSIS/RUN Run MENA analysis
%
% obj = run(obj) Run MENA analysis over the current Experiment
%   Space using the current object configuration.
%
%To be able to run the analysis, the associated Experiment Space
%must have been computed.
%
%The time to run the analysis strongly depends on the selected
%embedding techniques and the topology imposed using any
%particular metric. It is also dependent on the number of points
%in the Feature Space which is the result of the channel and
%signal groupings selected over the underlying Experiment Space.
%
%
%
%% Remarks
%
%Running the analysis sets the RunStatus to true, and clear all
%defined clusters.
%
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also analysis, experimentSpace, getFeatureSpace, mena_metric,
%   mena_embedding
%



%% Log
%
% File created: 25-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%   + Error codes updated from ICNA to ICNNA.
%




%1) Check that the Experiment Space has been computed
tmp = obj.F;
if ~tmp.runStatus
    error('ICNNA:analysis:run:ExperimentSpaceNotComputed',...
        'Experiment Space has not been computed.');
end

%2) Clear existing clusters
obj.clusters=cell(1,0);

%3) Compute the Feature Space
obj=getFeatureSpace(obj);


%4) Impose a metric of signal similarity to ambient
%Euclidean Feature Space H to create a manifold.
obj.D=mena_metric(obj.H,obj.metric);

%5) Embed the data with MENA
%obj=embed(obj);
options.projectionDimensionality = obj.projectionDimensionality; %Output dimensionality
options.embedding = obj.embedding;
if (strcmp(obj.embedding,'cca'))
    options.featureSpace = obj.H;
end
options.verbose = false;
obj.Y = mena_embedding(obj.D,options);
%5) set runStatus to true
obj.runStatus = true;

assertInvariants(obj);


end
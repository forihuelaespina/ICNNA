function obj = setVectors(obj,tmpFindex,tmpFvectors,tmpRunStatus)
% EXPERIMENTSPACE/SETVECTORS. Set the experiment space vectors manually
%
% obj = setVectors(obj,Findex,Fvectors,runStatus) Set the experiment space vector
%       manually as opposed to using experimentSpace.compute.
%
%% Parameters
%
%   .Fvectors - A cell array with the Experimental Space vectors
%       NOTE that the vectors are not guaranteed to have the same
%       length (e.g. data is only averaged across blocks, or not even
%       that, but not resampled or windowed)
%   .Findex - The index to locations of the vectors
%       within theExperimental Space 
%   .runStatus - Boolean flag to indicate whether the Experiment
%       Space has been computed with the current configuration.
%       The only way to set it to true
%       is to computeExperimentSpace. It can be set to false
%       by redefining any of the computing parameters or
%       resetting the object instance.
%       Default false.
%
%
% Copyright 2024
% @author Felipe Orihuela-Espina
%
% See also experimentSpace, compute
%



%% Log
%
% 19-Apr-2024: FOE
%   + File created
%


assert(size(tmpFindex,1) == numel(tmpFvectors),...
        'ICNNA:experimentSpace:setVectors:InvalidParameters');
assert(size(tmpFindex,2) == 8,...
        'ICNNA:experimentSpace:setVectors:InvalidParameters');

tmpFvectors = reshape(tmpFvectors,numel(tmpFvectors),1);

obj.Findex = tmpFindex;
obj.Fvectors = tmpFvectors;


if exist('runStatus','var')
    obj.runStatus = tmpRunStatus;
end

end

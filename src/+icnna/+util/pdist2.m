function [D] = pdist2(X,Y,distance)
%Pairwise distance between two sets of observations
%
% [D] = icnna.util.pdist2(X,Y,distance)
%
% If X and Y have the same number of entries and you are
% interested only in the one-to-one pairings, you need
% to get the main diagonal of D, i.e.:
%
%   diag(D)
%
%% Remarks
%
% This function requires
%   * Statistics and Machine Learning Toolbox
%
%
% Right now this is just a wrapper over MATLAB's pdist2
% but having the wrapper facilitates decoupling ICNNA
% from specific calls to this function e.g. to add
% additional distance functions e.g. 'geodesic', or to
% remove the dependence from the toolbox in the future.
%
%
%% Input parameters
%
% X,Y - double[nPointsxnDims]
%   The two cloud of points among which the destances shall
%   be computed.
%
% distance - (Optional) char[]. Default is 'euclidean'
%   The name of the distance function.
%
%% Output
%
% D - double[nPointsXxnPointsY]
%   The matrix of pairwise distances
% 
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also assertInvariant
%




%% Log
%
%   + Function available since ICNNA v1.4.0
%
% 23-Dec-2024: FOE
%   + File and function created
%

if ~exist('distance','var')
    distance = 'euclidean';
end

D = pdist2(X,Y,distance);

end
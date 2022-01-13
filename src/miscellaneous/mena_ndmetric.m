function [D]=mena_ndmetric(H,s)
%Calculates the matrix of pairwise distances between n-dimensional signals
%
% [D]=mena_metric(H,s) Calculates the matrix of pairwise distances
%   among N-dimensional signals
%
%% N-dimensional Signals
%
% A N-dimensional signal is a function of time:
%
%   <x_t^1, x_t^2, ..., x_t^n> = f(t)    | t = 0..T
%
% embedded in a N-dimensional space X = <X^1, X^2, ..., X^n>. Thus
%considering the inherent temporal aspect of the signal it becomes
%an <NxT> dimensional Space X_t = <X_0^1, X_0^2, ..., X_T^n>.
%
% All signals must all have the same dimensionality and the same
%number of samples. All signals are indicated in the 3D parameter
%matrix H as follows:
%
% + Rows are samples. Signals are assumed to be sampled at the same
%   frequency.
% + Columns are dimensions. Signals are assumed to be represented in the
%   same ambient Euclidean space.
% + 3rd dimensional elements are the different signals to be compared.
%
% The different metrics can be defined either over the ambient space X
%(and thus each sample is considered at a time), or over the super
%space X_t and thus time is just another dimension.
%In the first case, i.e. signal is in N-dimensional X space,
%distances are computed "at each sample" and then
%accumulated across the signal. Note that some metrics such as
%Dynamic Time Warping (DTW) may warp the temporal aspects, and
%need to compute distances between non paired samples.
% In the latter case, i.e. signal is in <NxT>-dimensional X_t space,
%the whole signal can be reshaped into
%a vector, where the temporal aspect of the signal is ignored.
%Samples can be rearranged with no consequence.
%
%   +===========================================+
%   | NOTE: Space X_t can be easily modelled as |
%   |an ambient Euclidean Space, R^n. Space X   |
%   |however, is a spatio-temporal structure    |
%   |that requires modelling as a Minkowski     |
%   |Space (or more general Lorenzian Space),   |
%   |R^(1,N).                                   |
%   +===========================================+
%   
%
%% Manifold embedding
%
% Regardless of whether signals are considered in X or X_t spaces,
%all signals (among which pairwise distances are to be computed), can
%be considered independent or to actually form a manifold.
%Importantly, in the latter case, the pairwise distances among
%points (signals) are computed along the manifold, i.e. geodesics.
%The geodesic distance can be formally computed in the tangent
%space of the manifold. Or alternatively, can be approximated
%from the pairwise distances as computed from the ambient metric.
%
%   d_m(i,j) = G(d(i,j))
%
%This is for instance, exactly what Isomap does. Note however,
%that being an approximation can result in instability in case
%of noise, holes in the sampling of the manifold, concave manifolds,
%etc.
%
% A manifold is by definition locally flat. Imposing a topology
%(a given metric or pseudo-metric) into a set of points other
%than the space induced metric (i.e. the usual Euclidean dot
%product in a R^n space), may not necessarily result in a
%manifold (or pseudo-manifold in case of a pseudo-metric)!.
%
%   +===========================================+
%   | A pseudo-Reimannian manifold is a         |
%   |generalization of a Riemannian manifold.   |
%   |On a pseudo-Riemannian manifold the metric |
%   |tensor need not be positive-definite.      |
%   |Instead a weaker condition of nondegeneracy|
%   |is imposed.                                |
%   +===========================================+
%
%
%
%% Supported metrics / distances
%
%Currently the following distances are supported:
%
% 1) Flat distances    - Ambient space induced metric (Euclidean or Minskowski)
% 2) 1-(cross)correlation     - Pseudo-metric
% 3) JSM               - Square root of the Jensen-Shannon divergence
% 4) DTW               - Dynamic time warping
% 5) EMD               - Earth Mover's Distance
%
% In addition to these basic metrics, over the ambient
%space, distances can be computed over the manifold, i.e. using
%the geodesic.
% A) Geodesic    - Used in union with Euclidean distance and cMDS
%                   then M-ENA == Isomap!
%
%   +===========================================+
%   | I haven't prove or disprove whether the   |
%   |supported metrics, do actually yield a     |
%   |manifold or pseudo-manifold. I'm just      |
%   |assuming this to be the case. Note that    |
%   |in fact, it is this assumption, which      |
%   |permits approximating the geodesic from    |
%   |the pairwise distances as computed from the|
%   |ambient metric. Note that for              |
%   |pseudo-Riemannian metrics the arclength of |
%   |a curve may NOT always be defined.         |
%   +===========================================+
%
%
%
%% Parameters
%
% H - The matrix of coordinates of the points in a N-Dimensional space
%   Each column represents a sample and each row represents an spatial-like
%   dimension. The 3rd-dimensional elements are the different signals
%   for which the pairwise distances are to be computed.
%
% s - Metric to use
%Currently the following distances are supported:
%
% 1) 'euclidean' or 'euc'   - Euclidean (Default)
%   NOTE: The use of 'euc' is DEPREATED
% 2) 'corr'                 - 1-correlation
% 3) 'jsm'                  - Square root of JSD
%or with the geodesic
% 4) 'geo_euclidean' or 'geo'  - Geodesic based on the Euclidean
%   NOTE: The use of 'geo' is DEPREATED
% 5) 'geo_corr'             - Geodesic based on the 1-correlation
% 6) 'geo_jsm'              - Geodesic based on the square root of JSD
%
%% Output
%
% A (square) matrix of distances between each point in H.
%
%
% Copyright 2008-9
% @date: 4-Feb-2007
% @author Felipe Orihuela-Espina
% 
% See also analysis, run, getFeatureSpace, geodesic, ic_pdist,
%




NOT YET EVEN STARTED!!!



if (~exist('s','var'))
    s='euclidean';
end

%Update deprecated usage
if strcmp(s,'euc')
    s='euclidean';
end
if strcmp(s,'geo')
    s='geo_euclidean';
end

%Parameters for computing the geodesic in case it is necessary
n_fcn='k'; n_size=10;


switch lower(s)
    case 'euclidean'
        %1) Euclidean
        %%These two should actually produce the same matrix
        %%of distances...
        D=squareform(pdist(H)); %MATLAB's
        %D=L2_distance(H',H',1); %Isomap package (meant to be faster)
        
    case 'corr'
        %2) 1-Correlation
        tmpD=pdist(H,'correlation');
        tmpD(find(tmpD<0))=0; %Small computational errors might
                        %lead to some numbers being negative        
        D = squareform(tmpD); %MATLAB's

    case 'jsm'
        %3) JSM - Information Theory Related measures
        D = squareform(ic_pdist(H,'jsm'));
        
    case 'geo_euclidean'
        %4) Geodesic on Euclidean
        D = geodesic(H, n_fcn, n_size);
        
    case 'geo_corr'
        %4) Geodesic on 1-Correlation
        tmpD=pdist(H,'correlation');
        tmpD(find(tmpD<0))=0; %Small computational errors might
                        %lead to some numbers being negative        
        D = geodesic(H, n_fcn, n_size, squareform(tmpD));
        
    case 'geo_jsm'
        %4) Geodesic on JSM
        D = geodesic(H, n_fcn, n_size, squareform(ic_pdist(H,'jsm')));
        
    otherwise
        warning('ICNA:analysis:mena_metric:MetricNotRecognised',...
            'Metric not recognised - Switching to Euclidean.');
        D=mena_metric(H,'euclidean');
end
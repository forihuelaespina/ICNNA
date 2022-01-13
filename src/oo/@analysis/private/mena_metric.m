function [D]=mena_metric(H,s)
%Calculates the matrix of pairwise distances accordding to the MENA metric
%
% [D]=mena_metric(H,s)
%
%Calculates the matrix of pairwise distances accordding
%to the MENA metric.
%
%Currently the following distances are supported:
%
% 1) Euclidean distances    - Ambient space
% 2) 1-correlation          - Pseudo-metric
% 3) JSM                    - Square root of the Jensen-Shannon divergence
%
% In addition to these three basic metrics, over the ambient
%space, distances can be computed over the manifold, i.e. using
%the geodesic.
% A) Geodesic    - Used in union with Euclidean distance and cMDS
%                   then M-ENA == Isomap!
%
%
%% Parameters
%
% H - The matrix of coordinates of the points ni a N-Dimensional space
%   Each column represents a feature or dimension in the space
%   and each row represents a point/pattern in the space.
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
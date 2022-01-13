function [cost]=emd_calculateCosts(XX,YY,s)
%Calculates the ground distances (EMD costs) between set of points
%
% Earth Mover's Distance (EMD) is a metric distance between set of
%points (a.k.a. distributions). See Ref [Rubner, 1998]
%
% [cost]=emd_calculateCosts(XX,YY,s) Calculates the ground distances
%   (EMD costs) between points in set XX and points in set YY.
%   Both set of points should lay on the same space (i.e.
%   have the same number of dimensions).
%
% By default, the ground distance is considered to be the
%Euclidean distance between points (norm). But other choices
%are now available.
%
% The output of this function can be input to the emd algorithm.
%
%% Parameters:
%
% XX and YY - n-dimensional set of points. Rows represents different points
%       Columns represents different dimensions.
%
% s - Optional. The distance criterion. Choices are:
%       'euc' - Euclidean distance (Default)
%       'jsm'- Square root of Jensen-Shannon divergence
%
%% Output:
%
% A matrix with the distance between all points.
%
%           | YY1 | YY2 | ... | YYn |
%      -----+-----+-----+-----+-----+
%       XX1 | d11 | d12 | ... | d1n |
%      -----+-----+-----+-----+-----+
%       XX2 | d21 | d12 | ... | d2n |
%      -----+-----+-----+-----+-----+
%       ... | ... | ... | ... | ... |
%      -----+-----+-----+-----+-----+
%       XXm | dm1 | dm2 | ... | dmn |
%
%Note that this matrix may not be square as the number of points in set XX
%might not be the same number of points in set YY.
%
%
%% REFERENCES:
%
% [Rubner, 1998] Rubner, Yossi; Tomasi, Carlo and Guibas, Leonidas J.
%   "A Metric for Distributions with Applications to Image Databases"
%   Sixth International Conference on Computer Vision (1998). pgs 59-66
%   4-7 Jan Bombay India, DOI: 10.1109/ICCV.1998.710701
%
% Copyright 2007-9
% Date: 27-Feb-2007
% Author: Felipe Orihuela Espina
%
% See also mena_getGroundCosts
%


if (nargin<3)
    s='euc';
end

[nPointsXX,dimXX]=size(XX);
[nPointsYY,dimYY]=size(YY);

if (dimXX==dimYY)
    cost=zeros(nPointsXX, nPointsYY); %Allocate memory
    for ppXX=1:nPointsXX
        for ppYY=1:nPointsYY
            switch (s)
                case 'euc'
                    %Calculate the ground distance (cost) between both points
                    cost(ppXX,ppYY)=norm(XX(ppXX,:)-YY(ppYY,:));
                case 'jsm'
                    cost(ppXX,ppYY)=ic_jsm(XX(ppXX,:),YY(ppYY,:));
                otherwise %Euclidean distance
                    warning('ICNA:analysis:emd_calculateCosts:DistanceNotRecognised',...
                        'Distance not recognised: Switching to Euclidean');
                    %Calculate the ground distance (cost) between both points
                    cost(ppXX,ppYY)=norm(XX(ppXX,:)-YY(ppYY,:));
            end
        end
    end
    
else
    error('ICNA:analysis:emd_calculateCosts:DimensionMismatch',...
          'Sets dimension mismatch')
end
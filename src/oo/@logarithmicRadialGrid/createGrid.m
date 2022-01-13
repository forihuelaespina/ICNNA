function [r,th]=createGrid(obj,minR,maxR,nRings,nAngles)
%LOGARITHMICRADIALGRID/CREATEGRID Generates a logarithmic radial grid
%
% [r,th]=createGrid(obj,minR,maxR,nRings,nAngles) Creates a log radial grid
%
%% Parameters
%
% minR - Radius of the central cell
% maxR - Maximus radius of the grid
% nRings - Number of rings
% nAngles - Number of angular regions
%    
% Copyright 2008
% Date: 21-Feb-2008
% Author: Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, meshgrid
%

alpha=exp((log(maxR)-nRings*log(minR))/(1-nRings));
beta=log(minR)-log(alpha);

t=1:nRings;
tempRGrid=alpha*exp(beta*t);

%plot(tempRGrid')
[th,r] = meshgrid((0:360/nAngles:360)*pi/180,tempRGrid);

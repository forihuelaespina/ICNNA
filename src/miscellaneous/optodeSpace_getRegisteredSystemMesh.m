function [g,estimatedScale]=optodeSpace_getRegisteredSystemMesh(optodeSpace,probe)
%DEPRECATED Gets a 3D mesh of the 10/5 system registered to the optode system
%
% g=optodeSpace_getRegisteredSystemMesh(optodeSpace)
%
% g=optodeSpace_getRegisteredSystemMesh(optodeSpace, probe)
%
%
%
%% Deprecated
%
% This function has now been deprecated. Use new class channelLocationMap
%instead.
%
%
%% Parameters
%
% optodeSpace - An optodeSpace struct as specified in function
%   import3DOptodeSpace
%
% probe - Optional. The probe set. Set to 1 by default.
%
%
%% Output
%
% g - A 3D mesh/grid of the 10/5 system with a struct representation
%       as specified in function generateOptodePositioningSystemGrid.
%
% estimatedScale -  Estimated scale. A default mesh is initially
%       scale to this estimatedScale before proceeding to the
%       deformation to avoid massive distortion. This estimatedScale
%       is calculated as the mean between the length of the two axes
%       LE-RE and Nz-Iz.
%
% 
% Copyright 2009-13
% @date: 27-Mar-2009
% @author: Felipe Orihuela-Espina
% @modified: 27-Aug-2013
%
% See also rawData_ETG4000, optodeSpace_import, optodeSpace_plot3
%   generateOptodePositioningSystemGrid
%

if ~exist('probe','var') || isempty(probe)
    probe=1;
end

h = waitbar(0,'Generating default grid...',...
    'Name','Registering System Mesh');


%% Scale estimation
NzCoords=optodeSpace.probes(probe).nasion;
IzCoords=optodeSpace.probes(probe).inion;
LECoords=optodeSpace.probes(probe).leftear; %T9
RECoords=optodeSpace.probes(probe).rightear; %T10
CzCoords=optodeSpace.probes(probe).top;

estimatedScale=mean([norm(LECoords-RECoords)/2,...
                    norm(NzCoords-IzCoords)/2]);
                %% Get the default mesh
[g]=generateOptodePositioningSystemGrid(estimatedScale);
[tmpCoords,NzIdx]=mesh3D_getCoords(g,'Nz');
[tmpCoords,IzIdx]=mesh3D_getCoords(g,'Iz');
[tmpCoords,LEIdx]=mesh3D_getCoords(g,'T9');
[tmpCoords,REIdx]=mesh3D_getCoords(g,'T10');
[tmpCoords,CzIdx]=mesh3D_getCoords(g,'Cz');

%% Distort the grid to fit the control points
k=1; %elasticity
n=estimatedScale*(pi/2); %Further distance to be distorted
disp('Registering Nasion (Nz)');
waitbar(0.02,h,'Registering Nasion (Nz) - 5%');
vIdx=NzIdx; pDest=NzCoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
disp('Registering Inion (Iz)');
waitbar(0.20,h,'Registering Inion (Iz) - 20%');
vIdx=IzIdx; pDest=IzCoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
disp('Registering Left ear (T9)');
waitbar(0.40,h,'Registering Left ear (T9) - 40%');
vIdx=LEIdx; pDest=LECoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
disp('Registering Right ear (T10)');
waitbar(0.60,h,'Registering Right ear (T10) - 60%');
vIdx=REIdx; pDest=RECoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
disp('Registering Top (Cz)');
waitbar(0.80,h,'Registering Top (Cz) - 80%');
vIdx=CzIdx; pDest=CzCoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
%Note that the faces and tags are already in place!!


waitbar(1,h,'Done - 100%');
close(h);
clear h


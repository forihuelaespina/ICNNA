function [g,estimatedScale]=generateRegistrationMesh(clm)
%Generates a 3D mesh of the 10/5 system registered to the channelLocationMap
%
% [g,estimatedScale]=generateRegistrationMesh(clm) Generates a 3D mesh
%       of the 10/5 system registered to the channelLocationMap
%
%
%
%
%% Parameters
%
% clm - A channelLocationMap. It is required that the channelLocationMap
%       has the following reference points defined:
%                   + 'nasion' or 'Nz': dent at the upper root of the
%                       nose bridge;
%                   + 'inion' or 'Iz': external occipital protuberance;
%                   + 'leftear' or 'LPA': left preauricular point, an
%                       anterior root of the center of the peak
%                       region of the tragus;
%                   + 'rightear' or 'RPA': right preauricular point
%                   + 'top' or 'Cz': Midpoint between Nz and Iz
%           
%
%
%% Output
%
% g - A 3D mesh of the 10/5 system with a struct representation
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
% @modified: 7-Sep-2013
%
% See also rawData_ETG4000, optodeSpace_import, optodeSpace_plot3
%   generatePositioningSystemMesh
%


%% Log
%
% 7-Sep-2013: Now the function throws an informed error if reference
%       points have not been defined.
%


% h = waitbar(0,'Generating default mesh...',...
%     'Name','Registering System Mesh');


%% Scale estimation
refPoints = getReferencePoints(clm);

if isempty(refPoints)
    error('ICNA:generateRegistrationMesh:ReferencePointsMissing',...
        'Reference points missing. Unable to generate registered mesh.');
end

idx=findReferencePoint(refPoints,{'nasion','Nz'});
    %It is not necessary to check that idx is empty since
    %it is required that the channelLocationMap
    %has these reference points defined. In fact, if it
    %is empty that should produce an error, as the point
    %would have not been defined.
if isempty(idx)
    error('ICNA:generateRegistrationMesh:ReferencePointsMissing',...
        '''Nasion'' reference point missing. Unable to generate registered mesh.');
end
NzCoords=refPoints(idx(1)).location;

idx=findReferencePoint(refPoints,{'inion','Iz'});
if isempty(idx)
    error('ICNA:generateRegistrationMesh:ReferencePointsMissing',...
        '''Inion'' reference point missing. Unable to generate registered mesh.');
end
IzCoords=refPoints(idx(1)).location;

idx=findReferencePoint(refPoints,{'leftear','LPA'});
if isempty(idx)
    error('ICNA:generateRegistrationMesh:ReferencePointsMissing',...
        ['Left preauricular ''LeftEar'' or ''LPA'' reference point ' ...
        'missing. Unable to generate registered mesh.']);
end
LECoords=refPoints(idx(1)).location; %T9

idx=findReferencePoint(refPoints,{'rightear','RPA'});
if isempty(idx)
    error('ICNA:generateRegistrationMesh:ReferencePointsMissing',...
        ['Right preauricular ''RightEar'' or ''RPA'' reference point ' ...
        'missing. Unable to generate registered mesh.']);
end
RECoords=refPoints(idx(1)).location; %T10

idx=findReferencePoint(refPoints,{'top','Cz'});
if isempty(idx)
    error('ICNA:generateRegistrationMesh:ReferencePointsMissing',...
        '''Cz'' reference point missing. Unable to generate registered mesh.');
end
CzCoords=refPoints(idx(1)).location;

estimatedScale=mean([norm(LECoords-RECoords)/2,...
                    norm(NzCoords-IzCoords)/2]);
                
%% Get the default mesh
[g]=generatePositioningSystemMesh(estimatedScale);
[~,NzIdx]=mesh3D_getCoords(g,'Nz');
[~,IzIdx]=mesh3D_getCoords(g,'Iz');
[~,LEIdx]=mesh3D_getCoords(g,'T9');
[~,REIdx]=mesh3D_getCoords(g,'T10');
[~,CzIdx]=mesh3D_getCoords(g,'Cz');

%% Distort the grid to fit the control points
k=1; %elasticity
n=estimatedScale*(pi/2); %Further distance to be distorted
disp('Registering Nasion (Nz)');
%waitbar(0.02,h,'Registering Nasion (Nz) - 5%');
vIdx=NzIdx; pDest=NzCoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
disp('Registering Inion (Iz)');
%waitbar(0.20,h,'Registering Inion (Iz) - 20%');
vIdx=IzIdx; pDest=IzCoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
disp('Registering Left ear (T9)');
%waitbar(0.40,h,'Registering Left ear (T9) - 40%');
vIdx=LEIdx; pDest=LECoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
disp('Registering Right ear (T10)');
%waitbar(0.60,h,'Registering Right ear (T10) - 60%');
vIdx=REIdx; pDest=RECoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
disp('Registering Top (Cz)');
%waitbar(0.80,h,'Registering Top (Cz) - 80%');
vIdx=CzIdx; pDest=CzCoords;
[g.coords]=mesh3D_vertexDisplacement(g.coords,vIdx,pDest,k,n);
%Note that the faces and tags are already in place!!


% waitbar(1,h,'Done - 100%');
% close(h);
% clear h

end



%% AUXILIAR FUNCTIONS

function idx=findReferencePoint(refPoints,pointsTags)
%Find the indexes to the points
%
% refPoints - A struct array of reference points as retrieved
%       from a channelLocationMap using getReferencePoints(clm)
% pointsTags - A cell array of reference points names or tags
%
% idx - Indexes to all points whose names are members of pointsTags

nRP=length(refPoints);
idx=[];
for ii=1:nRP
    if ismember(refPoints(ii).name,pointsTags)
        idx=[idx ii];
    end
end
end


function [DOptodes, DChannels]=registration_getDistances(g,clm)
%Compute the distance from every point in the mesh (g) to
%every optode and channel in the channelLocationMap
%
%% Parameters
%
% g - A 3D mesh as specified in generateOptodePositioningSystemGrid
% clm - A channelLocationMap
%
%% Output
%
% DOptodes- Matrix of distances between points in mesh and optodes.
%   Rows represents points in the mesh, and columns represents optodes.
%
% DChannels- Matrix of distances between points in mesh and channels.
%   Rows represents points in the mesh, and columns represents channels.
%
%
%       +========================================+
%       | "Irrelevant" mesh vertexes (those with |
%       | empty tag) are also included!!, i.e.   |
%       | they also produce an entry in the      |
%       | distance matrices.                     |
%       +========================================+
%
%
% Copyright 2013
% @date: 15-Sep-2013
% @author Felipe Orihuela-Espina
% @modified: 15-Sep-2013
%
% See also guiRegistration, optodeSpace_import, mesh3D_visualize,
% generateOptodePositioningSystemGrid
%

optodeCoords=getOptode3DLocations(clm);
channelCoords=getChannel3DLocations(clm);
nOptodes=size(optodeCoords,1);
nChannels=size(channelCoords,1);
nMeshPoints=size(g.coords,1);

DOptodes=zeros(nMeshPoints,nOptodes);
DChannels=zeros(nMeshPoints,nChannels);
for pp=1:nMeshPoints
    pTag=g.tags{pp};
    pCoords=g.coords(pp,:);
    if isempty(pTag) %Untagged vertex
        pTag='untagged vertex';
    end
    
    %Distances to optodes
    tmp=[optodeCoords(:,1)-pCoords(1), ...
        optodeCoords(:,2)-pCoords(2), ...
        optodeCoords(:,3)-pCoords(3)];
    DOptodes(pp,:)=sqrt(sum(tmp.^2,2))';

    %Distances to channels
    tmp=[channelCoords(:,1)-pCoords(1), ...
        channelCoords(:,2)-pCoords(2), ...
        channelCoords(:,3)-pCoords(3)];
    DChannels(pp,:)=sqrt(sum(tmp.^2,2))';
end

end
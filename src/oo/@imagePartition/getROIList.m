function idList=getROIList(obj)
%IMAGEPARTITION/GETROILIST Get a list of IDs of defined ROIs
%
% idList=getROIList(obj) Get a list of IDs of defined ROIs or an
%     empty list if no ROIs have been defined.
%
% It is possible to navigate through the ROIs using the idList
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also findROI, getROI
%

nElements=getNROIs(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(obj.rois{ii},'ID');
end
idList=sort(idList);
function referencePoints=getReferencePoints(obj,idx)
%CHANNELLOCATIONMAP/GETREFERENCEPOINTS Gets the names and 3D locations for reference points
%
% referencePoints=getReferencePoints(obj) Gets the names and 3D locations for all
%   reference points as an array of struct. The array may be empty if the
%   number of reference points is 0.
%
% referencePoints=getReferencePoints(obj,idx) Gets the names and  3D locations 
%   for the selected reference points as an array of struct.
%   If any of the indexes to a reference point is beyond the 
%   number of existing reference points, it will be ignored. The array
%   may be empty if the number of reference points is 0, or none of the
%   indexes is valid.
%
%
%
% Copyright 2013
% @date: 27-Aug-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also addReferencePoints, 
%   getChannel3DLocations, setChannel3DLocations,
%   getOptode3DLocations, setOptode3DLocations
%

%% Log
%
% 8-Sep-2013: Updated "links" of the See also call to other methods
%


referencePoints=obj.referencePoints;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nReferencePoints'))=[];
    referencePoints=referencePoints(idx,:);
end
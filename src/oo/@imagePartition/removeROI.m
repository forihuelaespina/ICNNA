function obj=removeROI(obj,id)
% IMAGEPARTITION/REMOVESESSION Removes a ROI from the imagePartition
%
% obj=removeROI(obj,id) Removes ROI whose ID==id from the
%   imagePartition. If the ROI does not exist, nothing is done.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also addROI, setROI, clear
%

idx=findROI(obj,id);
if (~isempty(idx))
    obj.rois(idx)=[];
end
assertInvariants(obj);
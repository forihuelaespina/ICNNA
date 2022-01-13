function obj=setROI(obj,id,s)
% IMAGEPARTITION/SETSESSION Replace a ROI
%
% obj=setROI(obj,id,newROI) Replace ROI whose ID==id
%   with the new ROI. If the ROI whose ID==id has not been
%   defined, then nothing is done.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also addROI, removeROI
%

idx=findROI(obj,id);
if (~isempty(idx))
    obj.rois(idx)={roi(s)}; %Ensuring that s is a ROI
end
assertInvariants(obj);
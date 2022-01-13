function obj=clear(obj)
% IMAGEPARTITION/CLEAR Removes all existing ROIs from the imagePartition
%
% obj=clear(obj) Removes all existing ROIs from the imagePartition.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also addROI, setROI, removeROI
%

obj.rois=cell(1,0);
assertInvariants(obj);
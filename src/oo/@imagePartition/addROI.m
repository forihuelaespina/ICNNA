function obj=addROI(obj,s,m)
% IMAGEPARTITION/ADDROI Add a new ROI to the imagePartition
%
% obj=addROI(obj,s) Add a new ROI to the imagePartition. If
%   a ROI with the same ID has already been defined within
%   the imagePartition, then a warning is issued and nothing is done.
%
% obj=addROI(obj,s,merge) Add a new ROI to the imagePartition. If
%   a ROI with the same ID has already been defined then the merge
%   parameter defines the method behaviour:
%       If merge==0, then a warning is issued and nothing is done.
%           This is the default option, and is equal to omitting
%           the parameter.
%       If merge==1, then the subregions of s are merged with
%           existing ones. If the name of the existing ROI and
%           the name of s are different, the existing name is kept.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also removeROI, setROI
%

merge=0;
if exist('m','var') && (islogical(m) || isnumeric(m))
    merge=m;
end

%Ensure that s is a ROI
if isa(s,'roi')
    idx=findROI(obj,get(s,'ID'));
    if isempty(idx)
        obj.rois(end+1)={s};
    else
        %The region already exists
        if merge
            tmpROI=getROI(obj,idx);
            for subr=1:getNSubregions(s) %Add all subregions of s
                tmpROI=addSubregion(tmpROI,getSubregion(s,subr));
            end
            obj.rois(idx)={tmpROI};
        else
           warning('ICNA:imagePartition:addROI:RepeatedID',...
                   ['A ROI with the same ID (' ...
                   num2str(get(s,'ID')) ') has already been defined.']);
        end
    end
else
    error([inputname(2) ' is not a ROI']);
end
assertInvariants(obj);
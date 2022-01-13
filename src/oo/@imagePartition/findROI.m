function idx=findROI(obj,id)
%IMAGEPARTITION/FINDROI Finds a ROI within the imagePartition
%
% idx=findROI(obj,id) returns the index of the ROI.
%   If the ROI has not been defined it returns an empty
%   matrix [].
%
% idx=findROI(obj,name) returns the index/es of the ROI/s
%   with the indicated name, where name is a string.
%   If there is not any ROI with the indicated name it
%   returns an empty matrix []. This search is case sensitive.
%
%
%% Remarks
%
% While IDs are uniquely defined, ROIs names are not. Hence
%searching by ID is more precise and only return 1 hit at
%the maximum, wheras searching by ROI name may return more than
%one hit!.
%
%
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also imagePartition, assertInvariants

%date: 5-Feb-2009
%author: Felipe Orihuela-Espina
%The search can now be done by name

if ~ischar(id)
    %Classical behaviour

    nElements=length(obj.rois);
    idx=[];
    for ii=1:nElements
        tmpID=get(obj.rois{ii},'ID');
        if (id==tmpID)
            idx=ii;
            % Since the id cannot be repeated we can stop as
            %soon as it is found.
            break
        end
    end


else
    %Parameter id is char, an hence it really "mean" name
    name=id;
    
    nElements=length(obj.rois);
    idx=[];
    for ii=1:nElements
        tmpID=get(obj.rois{ii},'Name');
        if strcmp(name,tmpID)
            idx=[idx ii];
        end
    end

end

function idx=findCondition(obj,tag)
%TIMELINE/FINDCONDITION Finds a condition within the timeline
%
% idx=findCondition(obj,tag) returns the index of the condition
%   within the field .conditions in which the condition is stored.
%   If the condition has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also timeline

nConditions=length(obj.conditions);
idx=[];
for ii=1:nConditions
    ctag=obj.conditions{ii}.tag;
    if (strcmp(tag,ctag))
        idx=ii;
        % Since the conditions tag cannot be repeated we can stop as
        %soon as the condition is found.
        break
    end
end
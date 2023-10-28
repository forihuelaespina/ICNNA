function [obj,res]=cropOrRemoveEvents(obj,newLength)
% TIMELINE/CROPORREMOVEEVENTS. PRIVATE. Crop of remove events when updating the timeline's length
% 
% res=cropOrRemoveEvents(newLength) Crop of remove events when updating the timeline's length
%
% This method is private.
%
%% Input parameters
%
% obj - A timeline object.
%
% newLength - Scalar Integer (double). The timeline new length
%
%% Output parameters
%
% obj - An updated timeline object.
%
% res - Boolean. True if the execution resulted in some events
%   being cropped or removed. False (default) otherwise.
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also set.length
%


%% Log
%
% This function was nested in method timeline.set
%
% File created: 13-May-2023
% 
% 13-May-2023: FOE
%   + Added this log. 
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also extracted this
%   method from set and declared it separatedly.
%

res=false;
nCond=obj.nConditions;
for cc=1:nCond
    ctag=getConditionTag(obj,cc);
    [e,eInfo]=getConditionEvents(obj,ctag);
    if (~isempty(e))
        onsets=e(:,1);
        %Remove those events which start after the new length
        idx=find(onsets>newLength);
        if (~isempty(idx))
            res=true;
        end
        e(idx,:)=[];
        eInfo(idx)=[];
        %Crop those events which start before the new lengh
        %but last beyond that length
        onsets=e(:,1);
        durations=e(:,2);
        endings=onsets+durations;
        idx=find(endings>newLength);
        if (~isempty(idx))
            res=true;
        end
        e(idx,2)=newLength-onsets(idx);
    end
    obj=setConditionEvents(obj,ctag,e,eInfo);
end


end
function res=cropOrRemoveEvents(obj,newLength)
    res=false;
    nCond=get(obj,'NConditions');
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
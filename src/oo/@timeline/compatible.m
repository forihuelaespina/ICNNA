function degree=compatible(obj,t)
%TIMELINE/COMPATIBLE DEPRECATED Check compatibility among timelines
%
% This method has been deprecated. However, it has not been replaced
%by any other method. From now on, it is strongly recommended that
%you check the degree of compatibility of your timeline manually.
%You still have the method eq for testing whether 2 timelines are
%exactly equals.
%
%
% degree=isCompatible(obj,t) Check compatibility degree
%   between two timelines. Return 0 if they are not compatible.
%
%The timelines obj and t are not compatible if they contain
%different conditions (either in number or tags).
%
%
%Compatibility degree 1 (softest):
%   Two timelines are compatibles to degree 1 if they contain the
%same conditions (condition tags are the same). However
%the events defined in each one may differ.
%Exclusory behaviour and length may be different
%
%Compatibility degree 2:
%   Two timelines are compatibles to degree 2 if they contain the
%same conditions (condition tags are the same). The events
%defined in each case may also differ. Length
%may be different, but Exclusory behaviour MUST BE THE SAME.
%
%Compatibility degree 3:
%   Two timelines are compatibles to degree 3 if they contain the
%same conditions (condition tags are the same). Exclusory
%behaviour must be the same.
%The number of events defined for each condition
%MUST BE THE SAME, although they may occur at different
%times. Length may be different.
%
%Compatibility degree 4 (hardest):
%   Two timelines are compatibles to degree 4 if they contain the
%same conditions (condition tags are the same). Ordering of
%the conditions is also the same. Exclusory behaviour must be the same.
%The number of EVENTS defined for each condition must be the same
%as well as they MUST OCCURR AT THE SAME TIME, AND LAST EQUALLY.
%Length also MUST BE THE SAME.
%
%
% Copyright 2008-12
% @date: 18-Jun-2008
% @author Felipe Orihuela-Espina
% @modified: 29-Dec-2012
%
%See also timeline, eq
%

warning('ICNA:timeline:compatible:Deprecated',...
        ['The use of ''compatible'' has now been deprecated. ' ...
         'From now on, it is strongly recommended that ' ...
         'you check the degree of compatibility of your ' ...
         'timeline manually. ' ...
         'You still have the method eq for testing whether ' ...
         '2 timelines are exactly equals.']);


degree=0;
if (get(obj,'NConditions')~=get(t,'NConditions'))
    return;
end;


sametags=true;
sameNEvents=true;
equalEvents=true;
for ii=1:get(obj,'NConditions')
    tag2=getConditionTag(t,ii);
    idx=findCondition(obj,tag2);
    if (isempty(idx))
        sametags=false;
        break;
    end
    tag1=getConditionTag(obj,idx);
    
    events1=getConditionEvents(obj,tag1);
    events2=getConditionEvents(t,tag2);

    if (~(size(events1,1)==size(events2,1)))
        sameNEvents=false;
    end
    if (~isequal(events1,events2))
        equalEvents=false;
    end

end

if (sametags)
    degree=1;
else
    return
end

if (isequal(getExclusory(obj),getExclusory(t)))
    degree=2;
else
    return
end
   
if (sameNEvents)
    degree=3;
else
    return
end

if (equalEvents && (get(obj,'Length')==get(t,'Length')))
    degree=4;
end

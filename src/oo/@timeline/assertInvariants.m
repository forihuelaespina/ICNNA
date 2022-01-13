function assertInvariants(obj)
%TIMELINE/ASSERTINVARIANTS Ensures the invariants of timeline is met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: Timeline length is always 0 or positive
%       obj.length>=0
%
%   Invariant: Number of timestamps matches the timeline length
%       size(obj.timestamps,1) == obj.length
%
%   Invariant: Timestamps are sorted in increasing order
%       all(obj.timestamps(1:end-1) < obj.timestamps(2:end))
%
%   Invariant: For all conditions c
%       c.tag~=''
%
%   Invariant: For all pair of conditions ci and cj
%       ci.tag~=cj.tag
%
%   Invariant: For all conditions c and all events i
%       c.onset(i)+c.duration(i)-1 < c.onset(i+1)
%
%          Note that the above imply that events are sorted
%           according to their onsets!!
%
%   Invariant: For all conditions c and all events i
%       c.onset(i) > 0
%
%   Invariant: For all conditions c and all events i
%       c.duration(i) >= 0
%
%   Invariant: For all conditions c and all events i
%       c.onset(i)+c.duration(i)-1 <= timeline.length
%
%   Invariant: For all conditions c, the number of eventsInfo
%       matches the number of events
%       size(c.events,1) == size(c.eventsInfo,1) 
%
%
%   Invariant: Exclusory state matrix is squared, symmetric and
%	has the same number of rows (and columns) as there
%	are conditions.
%
%   Invariant: A condition cannot be exclusory with itself
%	The main diagonal of exclusory state matrix is always 0.
%
%   Invariant: For exclusory cond_i and cond_j |i~=j then
%	their events do not overlap
%
%       
% Copyright 2008-12
% @date: 18-Apr-2008
% @author: Felipe Orihuela-Espina
% @modified: 30-Dec-2012
%
% See also timeline
%

assert(obj.length>=0,...
    ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
    'Timeline length must be 0 or positive.']);

assert(size(obj.timestamps,1) == obj.length,...
    ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
    'Number of timestamps mismatches timeline length.']);

assert(all(obj.timestamps(1:end-1) < obj.timestamps(2:end)),...
    ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
    'Timestamps must be monotonically increasing.']);


nConditions=length(obj.conditions);
for ii=1:nConditions
    tag=obj.conditions{ii}.tag;
    events=obj.conditions{ii}.events;
    eventsInfo=obj.conditions{ii}.events;
    [nEvents,temp]=size(events);
    
    assert(~strcmp(tag,''), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %d: Empty Tag'],ii);
    tagIdx=findCondition(obj,tag);
    assert(ii==tagIdx, ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Tag already defined'],tag);
    assert(temp==2, ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Events structure is corrupted'],tag);
    onsets = events(:,1);
    assert(all(onsets>0), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Onsets must be bigger than 0'],tag);
    assert(all(floor(onsets)==onsets), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Onsets must be positive integers'],tag);
    assert(issorted(onsets), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Onsets are not sorted'],tag);
    durations = events(:,2);
    assert(all(floor(durations)==durations), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
         'Condition %s: Durations must be positive integers'],tag);
    assert(all(durations>=0), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Durations cannot be negative'],tag);
    for jj=1:nEvents-1
        assert(onsets(jj)+durations(jj)-1<onsets(jj+1), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Invariant ' ...
        '(onsets(jj)+durations(jj)<onsets(jj+1)) does not hold.'],tag);
        assert(onsets(jj)+durations(jj)-1<=obj.length, ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Invariant ' ...
        '(onsets(jj)+durations(jj)<=obj.length) does not hold.'],tag)
    end
    if (nEvents>0)
        assert(onsets(end)+durations(end)-1<=obj.length, ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Invariant ' ...
        '(onsets(jj)+durations(jj)<=obj.length) does not hold.'],tag)
    end
    
    assert(nEvents == size(eventsInfo,1), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Events information records do' ...
        ' not match the number of events.'],tag);


end

%Exclusory behaviour
 %Check square
 [nRows,nCols]=size(obj.exclusory);
 assert(nRows==nCols, ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Exclusory state matrix is not square']);
 %Check symmetry
 assert(all(all(obj.exclusory==obj.exclusory')), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Exclusory state matrix is not symmetric']);
 %Has the same number of rows as there are conditions
 assert(nRows==length(obj.conditions), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Exclusory state matrix size does not ' ...
        'correspond with number of conditions.']);
 %A condition is not exclusory with itself
 B=1-eye(length(obj.conditions));
 assert(all(diag(obj.exclusory)==diag(B)), ...
        ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
        'Conditions cannot be exclusory with themselves']);
 %Now check that there's no overlap     
 for row=2:nRows
    for col=1:row-1
        if (obj.exclusory(row,col))
            events=[obj.conditions{row}.events; ...
                obj.conditions{col}.events];
            events=sortrows(events);
            onsets = events(:,1);
            durations = events(:,2);
            nEvents=size(events,1);
            for jj=1:nEvents-1
                assert(onsets(jj)+durations(jj)-1<onsets(jj+1), ...
                    ['ICNA:timeline:assertInvariants:InvariantViolation ' ...
                     'Events overlap in exclusory conditions.']);
            end
        end
    end
end

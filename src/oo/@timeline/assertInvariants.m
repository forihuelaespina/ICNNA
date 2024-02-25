function assertInvariants(obj)
%TIMELINE/ASSERTINVARIANTS Ensures the invariants of timeline is met
%
% assertInvariants(obj) Asserts the invariants
%
%% Remarks
%
%   +=====================================================+
%   | WATCH OUT!!! Because of the limitations of Matlab's |
%   | support with the struct like syntax correct (e.g.   |
%   | for these specific get/set methods, Matlab does not |
%   | support overriding), maintenance of interdependent  |
%   | properties becomes more difficult. This is because  |
%   | it is now not possible to transiently violate       |
%   | postconditions  invariants. Although, there may be  |
%   | ah-doc solutions for some specific invariants which |
%   | have been implemented, but we have not been able to |
%   | solve the problem in general. Hence, from version   |
%   | 1.2, some of ICNNA's traditional hard class         |
%   | invariants have been relaxed and changed from       |
%	| errors into warnings, or simply removed.            |
%   +=====================================================+
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
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also timeline
%




%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 30-Dec-2012
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%   + Some class invariants have been relaxed to warnings or removed.
%   + Error codes using 'ICNA' have been updated to 'ICNNA'
%   + Improved some comments.
%
% 23-Feb-2024: FOE
%   + Bug fixed: Invariants related to onset or durations were being check
%   regardless of whether the condition events were empty. Since MATLAB
%   does not permit certain checks on empty arrays e.g. all(onsets>0) this
%   lead to an uncaught exception. Now these invariants are only check
%   when the events are not empty.
%





assert(obj.length>=0,...
    ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
    'Timeline length must be 0 or positive.']);

% assert(size(obj.timestamps,1) == obj.length,...
%     ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
%     'Number of timestamps mismatches timeline length.']);
    

assert(all(obj.timestamps(1:end-1) < obj.timestamps(2:end)),...
    ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
    'Timestamps must be monotonically increasing.']);


nConditions=length(obj.conditions);
for ii=1:nConditions
    tag=obj.conditions{ii}.tag;
    events=obj.conditions{ii}.events;
    eventsInfo=obj.conditions{ii}.events;
    [nEvents,temp]=size(events);
    
    assert(~strcmp(tag,''), ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %d: Empty Tag'],ii);
    tagIdx=findCondition(obj,tag);
    assert(ii==tagIdx, ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Tag already defined'],tag);
    assert(temp==2, ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Events structure is corrupted'],tag);
    onsets = events(:,1);
    if ~isempty(onsets)
        assert(all(onsets>0), ...
            ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
            'Condition %s: Onsets must be bigger than 0'],tag);
        assert(all(floor(onsets)==onsets), ...
            ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
            'Condition %s: Onsets must be positive integers'],tag);
        assert(issorted(onsets), ...
            ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
            'Condition %s: Onsets are not sorted'],tag);
    end
    durations = events(:,2);
    if ~isempty(durations)
        assert(all(floor(durations)==durations), ...
            ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
             'Condition %s: Durations must be positive integers'],tag);
        assert(all(durations>=0), ...
            ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
            'Condition %s: Durations cannot be negative'],tag);
    end
    for jj=1:nEvents-1
        assert(onsets(jj)+durations(jj)-1<onsets(jj+1), ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Invariant ' ...
        '(onsets(jj)+durations(jj)<onsets(jj+1)) does not hold.'],tag);
        assert(onsets(jj)+durations(jj)-1<=obj.length, ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Invariant ' ...
        '(onsets(jj)+durations(jj)<=obj.length) does not hold.'],tag)
    end
    if (nEvents>0)
        assert(onsets(end)+durations(end)-1<=obj.length, ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Invariant ' ...
        '(onsets(jj)+durations(jj)<=obj.length) does not hold.'],tag)
    end
    
    assert(nEvents == size(eventsInfo,1), ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Condition %s: Events information records do' ...
        ' not match the number of events.'],tag);


end

%Exclusory behaviour
 %Check square
 [nRows,nCols]=size(obj.exclusory);
 assert(nRows==nCols, ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Exclusory state matrix is not square']);
 %Check symmetry
 assert(all(all(obj.exclusory==obj.exclusory')), ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Exclusory state matrix is not symmetric']);
 %Has the same number of rows as there are conditions
 assert(nRows==length(obj.conditions), ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
        'Exclusory state matrix size does not ' ...
        'correspond with number of conditions.']);
 %A condition is not exclusory with itself
 B=1-eye(length(obj.conditions));
 assert(all(diag(obj.exclusory)==diag(B)), ...
        ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
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
                    ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
                     'Events overlap in exclusory conditions.']);
            end
        end
    end
end

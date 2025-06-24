function [T] = unfoldTimeline(elem)
%Unfold the timeline(s) in a given object into a table
%
%   [T] = unfoldTimeline(elem)
%
%
%% Remarks
%
% This function can operate on a number of classes of ICNNA's experimental
%   tree. It basically (recursively) traverses the element until it
%   reaches the structuredData and then retrives the timeline and unfolded
%   to a table.
%
%% Parameters
%
% elem - An object of ICNNA's experimental tree.
%       This can be one of the following:
%       - An @experiment
%       - A @subject
%       - A @session
%       - A @dataSource - Only the active structured is unfolded.
%       - A @structuredData
%       - A @timeline
%
%% Outputs
%
% T - A table sized (nEventsInElement x k+6)
%   The number of columns of the table depends on the type of object.
%   The 6 fixed output columns correspond to:
%       - the condition ID
%       - the condition tag
%       - the event onset in samples
%       - the event offset in samples
%       - the event onset in timestamps
%       - the event offset in timestamps
%   The rest of the k columns correspond to the indexing columns e.g.
%   subjID, subjName, sessID, sessName, etc
%
%
% 
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also 
%

%% Log
%
% 11-Apr-2025: FOE
%   + File created. Reused code from series ARSLA0005
%


T = [];

if isa(elem,'experiment')

    subjectsList = getSubjectList(elem);
    for iSubj = subjectsList
        subj = getSubject(elem,iSubj);
        T2 = unfoldTimeline(subj);
        nEvents = size(T2,1);
        T3 = table(repmat(subj.id,nEvents,1),...
                   repmat(string(subj.name),nEvents,1),...
                   'VariableNames',{'SubjID','SubjName'});
        if isempty(T)
            T = [T3 T2];
        else
            T = [T; T3 T2];
        end
    end

elseif isa(elem,'subject')

    sessionsList = getSessionList(elem);
    for iSess= sessionsList
        sess = getSession(elem,iSess);
        T2 = unfoldTimeline(sess);
        nEvents = size(T2,1);
        T3 = table(repmat(sess.definition.id,nEvents,1),...
                   repmat(string(sess.definition.name),nEvents,1),...
                   'VariableNames',{'SessID','SessName'});
        if isempty(T)
            T = [T3 T2];
        else
            T = [T; T3 T2];
        end
    end

elseif isa(elem,'session')

    dsList = getDataSourceList(elem);
    for iDS= dsList
        ds = getDataSource(elem,iDS);
        T2 = unfoldTimeline(ds);
        nEvents = size(T2,1);
        T3 = table(repmat(ds.id,nEvents,1),...
                   repmat(string(ds.name),nEvents,1),...
                   'VariableNames',{'DataSourceID','DataSourceName'});
        if isempty(T)
            T = [T3 T2];
        else
            T = [T; T3 T2];
        end
    end

elseif isa(elem,'dataSource')

    sd = getStructuredData(elem,elem.activeStructured);
    T2 = unfoldTimeline(sd);
    nEvents = size(T2,1);
    T3 = table(repmat(sd.id,nEvents,1),...
               'VariableNames',{'StructuredDataID'});
        if isempty(T)
            T = [T3 T2];
        else
            T = [T; T3 T2];
        end

elseif isa(elem,'structuredData')

    t = elem.timeline;
    if isempty(T)
        T = unfoldTimeline(t);
    else
        T = [T; unfoldTimeline(t)];
    end

elseif isa(elem,'timeline') %Base case

    theTimestampts = elem.timestamps;
    for iCond = 1:elem.nConditions
        cond    = elem.getCondition(iCond);
        cEvents = cond.events;
        nEvents = size(cEvents,1);
        onsets  = cEvents(:,1);
        offsets = cEvents(:,1) + cEvents(:,2);
        T2 = table(repmat(iCond,nEvents,1),...
                   repmat(string(cond.tag),nEvents,1),...
                   onsets, offsets, ...
                   theTimestampts(onsets), theTimestampts(offsets), ...
                   'VariableNames',{'ConditionID','ConditionTag',...
                                      'Onsets [samples]','Offsets [samples]',...
                                      'Onsets [secs]','Offsets [secs]'});

        if isempty(T)
            T = T2;
        else
            T = [T; T2];
        end
    end


end




    

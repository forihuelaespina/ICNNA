function addVisualIntegrity
%"Manually" update some integrity codes collected by visual assessment
%
% addVisualIntegrity
%
% This function "manually" updates some integrity codes collected
%by visual assessment.
%
% 
% Copyright 2009
% date: 1-Dec-2009
% Author: Felipe Orihuela-Espina
% modified: 1-Dec-2009
%
% See also icna
%


experimentName = 'GCMC';
srcDir = ['../NIRS/experimentalData/' experimentName '/'];
opt.destinationFolder= srcDir;
opt.save=true;


COL_SUBJECT = 1;
COL_SESSION = 2;
COL_DATASOURCE = 3;


%% Load the experiment
dataset = []; %Otherwise MATLAB gets crazy
load([srcDir 'icna_' experimentName '.mat']);

[I,VisIc]=getVisualCodes(experimentName); %Load codes for update
%...where ic contains the integrity codes obtained by visual inspection

subjects = getSubjectList(dataset);
for subjID=subjects
    disp([datestr(now,13) ': Subject ' num2str(subjID)]);
    tmpIdx_1 = find(I(:,COL_SUBJECT) == subjID);
    if ~isempty(tmpIdx_1)
        subj = getSubject(dataset,subjID);
        sessions = getSessionList(subj);
        for sessID=sessions
            tmpIdx_2 = find(I(:,COL_SUBJECT) == subjID ...
                          & I(:,COL_SESSION) == sessID);
            if ~isempty(tmpIdx_2)
                sess = getSession(subj,sessID);
                datasources = getDataSourceList(sess);
                for dsID=datasources
                    tmpIdx_3 = find(I(:,COL_SUBJECT) == subjID ...
                                & I(:,COL_SESSION) == sessID...
                                & I(:,COL_DATASOURCE) == dsID);
                    if ~isempty(tmpIdx_3)
                        if length(tmpIdx_3) > 1
                           warning('ICAF:addVisualIntegrity:Ambiguity',...
                               ['Duplicate or ambiguous integrity ' ...
                                'codes found. Picking only first set ' ...
                                'of codes.']);
                            tmpIdx_3 = tmpIdx_3(1);
                        end
                        ds = getDataSource(sess,dsID);
                        sd = getStructuredData(ds,get(ds,'ActiveStructured'));
                        curr_integrity = double(get(sd,'Integrity'));
                        tmp_VisIc = VisIc(tmpIdx_3,:); %get the visual
                                        %integrity codes for this
                                        %<subject, session, DataSource>
                        
%Watch out! A value 0 in visual ic is not that the channel
%is fine. The channel may have already been tested for
%integrity automatically, and already have another code.
%so just update those which are not fine!
                        newIntegrity = curr_integrity;
                        affectedChannels = ...
                            find(tmp_VisIc ~= integrityStatus.UNCHECK ...
                               & tmp_VisIc ~= integrityStatus.FINE);
                        newIntegrity(affectedChannels) = tmp_VisIc(affectedChannels);
                        
                        tmpIntegrity = integrityStatus(get(sd,'NChannels'));
                        tmpIntegrity = setStatus(tmpIntegrity,...
                                            1:get(sd,'NChannels'),...
                                            newIntegrity);
                        sd = set(sd,'Integrity',tmpIntegrity);
                        ds = setStructuredData(ds,get(ds,'ActiveStructured'),sd);
                        sess = setDataSource(sess,dsID,ds);
                    end
                end
                subj = setSession(subj,sessID,sess);
            end
        end
        dataset = setSubject(dataset,subjID,subj);
    end
end

save([srcDir 'icna_' experimentName '_VisualIntegrityAdded.mat'],...
    'dataset');





end


%% AUXILIARY FUNCTIONS
function [I,ic]=getVisualCodes(expName)
%Load the visual codes

switch (expName)
    case 'GCMC'
        filename = '../NIRS/experimentalData/GCMC/VisualIntegrity.xls';
        %[typ, desc, fmt] = xlsfinfo(filename);
        %<Subject,Session,DataSource>
        I = xlsread(filename,1,'A2:C43');
        %Integrity codes
        %%%See sheet INTEGRITY_CODES in this file
        ic_Dave =xlsread(filename,1,'D2:AA43');
        ic_Foe =xlsread(filename,2,'D2:AA43');
        
        %Policy: conservative
        ic = max(ic_Dave,ic_Foe); %Conciliation
        ic(ic>100) = 0; %preserve mild contamination
        maxContaminatedChannels = 5; %if more than this channels are gone, ignore full subject
        badSubjectsRowIdx = find(sum(ic~=0,2)>maxContaminatedChannels);
        ic(badSubjectsRowIdx,:) = integrityStatus.OTHER; %Just by now, give priority to Dave's marking
    otherwise
        error('Unexpected experiment.');
end

end
 %%%See sheet INTEGRITY_CODES in this file
        ic_Dave =xlsread(filename,1,'D2:AA43');
        ic_Foe =xlsread(filename,2,'D2:AA43');
        
        %Policy: conservative
        ic = max(ic_Dave,ic_Foe); %Conciliation
        ic(ic>100) = 0; %preserve mild contamination
        maxContaminatedChannels = 5; %if more than this channels are gone, ignore full subject
        badSubjectsRowIdx = find(sum(ic~=0,2)>maxContaminatedChannels);
        ic(badSubjectsRowIdx,:) = integrityStatus.OTHER; %Just by now, give priority to Dave's marking
    case 'DaVinci'
        filename = '../NIRS/experimentalData/DaVinci/ManualIntegrity_SaturationAndComplex.xls';
        %[typ, desc, fmt] = xlsfinfo(filename);
        %<Subject,Session,DataSource>
        I = xlsread(filename,1,'A2:C9');
        %Integrity codes
        %%%See sheet INTEGRITY_CODES in this file
        ic =xlsread(filename,1,'D2:AA9');
        
    case 'NN'
        filename = '../NIRS/experimentalData/NN/ManualIntegrity.xls';
        %[typ, desc, fmt] = xlsfinfo(filename);
        %<Subject,Session,DataSource>
        I = xlsread(filename,1,'A2:C30');
        %Integrity codes
        %%%See sheet INTEGRITY_CODES in this file
        ic =xlsread(filename,1,'D2:AA30');
        
    otherwise
        error('Unexpected experiment.');
end

end

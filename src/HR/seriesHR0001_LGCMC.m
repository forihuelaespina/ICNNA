function seriesHR0001_LGCMC()
%Prepares a HR database for the LGCMC experiment
%
% seriesHR0001_LGCMC() Prepares a HR database for the LGCMC experiment
%
%
%% The HR database
%
% From Dave James' mail (18-Nov-2010):
%
%   Columns required:
%       - Subject
%       - Group (Control or GCMC)
%       - Session
%       - Channel
%       - Brain Region (PFC/PC)
%       - Block: Will have to include
%           - baseline rest
%           - Task 1
%           - Rest
%           - Task 2
%           - etc
%           - Task 5
%           - Post rest
%       - Mean HR
%       - SDnn
%       - Mean baseline HbO2
%       - Mean baseline HHb
%       - Mean task HbO2
%       - Mean task HHb
%       - Change in HbO2
%       - Change in HHb
%
%% The split algorithm:
%
% An initial algorithm was already in splitECGbyRawNIRS, but
%this may require alteration as it does not cover intertrial rests.
%
%
%
% Copyright 2010
% @date: 27-Nov-2010
% @author Felipe Orihuela-Espina
% @modified: 28-Nov-2010
%
% See also rawData_BioHarnessECG, ecg, dataSource, rawData_ETG4000,
%   guiSplitECG
%

opt.destinationFolder = '../NIRS/experimentalData/LGCMC/HR_Files_For_DataBase/';
if exist('options','var')
    if isfield(options,'destinationFolder')
        opt.destinationFolder = options.destinationFolder;
    end
end

files =getFilesToProcess(); %Auxiliar function
nFiles = length(files);

% %%Step 1: Split the ECG files
% disp('== Step 1: Splitting ECGs =========================');
% splitECGs=struct('subject',{},'session',{},'stim',{},'block',{},'splitecg',{});;
% for ff=1:nFiles
%     disp(['Splitting file ' num2str(ff) ' out of ' num2str(nFiles) ': ' ...
%             'Subject=' num2str(files(ff).subject) '; ' ...
%             'Session=' files(ff).session]);
%         files(ff)
%     ecgFile = files(ff).ecg;
%     nirsFile = files(ff).nirs;
%     
%     theData=dataSource;
%     load(ecgFile); %Loads 'theData' element
%     elem = getStructuredData(theData,get(theData,'ActiveStructured'));
%     clear theData
%     
%     [baseECG,blocksECGs,lastECG]=...
%                     splitECGbyRawNIRS(elem,nirsFile);
%     splitECGs(end+1).subject = files(ff).subject;
%     splitECGs(end).session = files(ff).session;
%     splitECGs(end).stim = 'Base';
%     splitECGs(end).block = 0; %Block 0 for baseECG
%     splitECGs(end).splitecg = getStructuredData(baseECG,...
%                                     get(baseECG,'ActiveStructured'));
%     
%     for ll=1:length(blocksECGs)
%         splitECGs(end+1).subject = files(ff).subject;
%         splitECGs(end).session = files(ff).session;
%         splitECGs(end).stim = blocksECGs(ll).stim;
%         splitECGs(end).block = blocksECGs(ll).block; %Block 0 for baseECG
%         splitECGs(end).splitecg = getStructuredData(blocksECGs(ll).taskecg,...
%                                     get(blocksECGs(ll).taskecg,'ActiveStructured'));
%     end
% 
%     splitECGs(end+1).subject = files(ff).subject;
%     splitECGs(end).session = files(ff).session;
%     splitECGs(end).stim = 'Last';
%     splitECGs(end).block = -1; %Block -1 for lastECG
%     splitECGs(end).splitecg = getStructuredData(lastECG,...
%                                     get(lastECG,'ActiveStructured'));
%     
%     clear elem baseECG bloackECGs lastECG
% end
% 
% save([opt.destinationFolder 'splitECGs.mat'],'splitECGs');
load([opt.destinationFolder 'splitECGs.mat']);

%%Step 2: Construct the database
disp('== Step 2: Constructing HR DB =========================');

dbHb = dlmread('../NIRS/experimentalData/LGCMC/LGCMCSUB_1_21_DB0001.csv');
dbCons = getDBConstants;


nElem = length(splitECGs);
nChannels = 24;
db=nan(nElem*nChannels,14); %See database structure above.
pos=1;
for ee=1:nElem
    subjID = splitECGs(ee).subject;
    sessID = getSessionID(subjID,splitECGs(ee).session);
    block = splitECGs(ee).block;
    
    ee_bpm=getBPM(splitECGs(ee).splitecg);
    ee_bpm_mean = nanmean(ee_bpm);
    ee_sdann=sdnn(splitECGs(ee).splitecg);
    for ch=1:nChannels
        %Temporally set changeOxy and changeDeoxy to NaN
        baselineOxy = nan;
        baselineDeoxy = nan;
        taskOxy = nan;
        taskDeoxy = nan;
        changeOxy = nan;
        changeDeoxy = nan;
        if block > 0 %i.e. not base or last
            idxOxy = find(dbHb(:,dbCons.COL_SUBJECT) == subjID ...
                & dbHb(:,dbCons.COL_SESSION) == sessID ...
                & dbHb(:,dbCons.COL_CHANNEL) == ch ...
                & dbHb(:,dbCons.COL_STIMULUS) == double(splitECGs(ee).stim)-64 ...
                & dbHb(:,dbCons.COL_BLOCK) == block ...
                & dbHb(:,dbCons.COL_SIGNAL) == nirs_neuroimage.OXY);
            if isempty(idxOxy) %Channel may be not clean
                %Do nothing
            else
                idxOxy = idxOxy(1);
                baselineOxy = dbHb(idxOxy,dbCons.COL_MEAN_BASELINE);
                taskOxy = dbHb(idxOxy,dbCons.COL_MEAN_TASK);
                changeOxy = dbHb(idxOxy,dbCons.COL_TASK_MINUS_BASELINE);
            end
            idxDeoxy = find(dbHb(:,dbCons.COL_SUBJECT) == subjID ...
                & dbHb(:,dbCons.COL_SESSION) == sessID ...
                & dbHb(:,dbCons.COL_CHANNEL) == ch ...
                & dbHb(:,dbCons.COL_STIMULUS) == double(splitECGs(ee).stim)-64 ...
                & dbHb(:,dbCons.COL_BLOCK) == block ...
                & dbHb(:,dbCons.COL_SIGNAL) == nirs_neuroimage.DEOXY);
            if isempty(idxDeoxy) %Channel may be not clean
                %Do nothing
            else
                idxDeoxy = idxDeoxy(1);
                baselineDeoxy = dbHb(idxDeoxy,dbCons.COL_MEAN_BASELINE);
                taskDeoxy = dbHb(idxDeoxy,dbCons.COL_MEAN_TASK);
                changeDeoxy = dbHb(idxDeoxy,dbCons.COL_TASK_MINUS_BASELINE);
            end
        end
        
        db(pos,:)=[subjID ...
                   getSubjectGroup(subjID) ...
                   sessID ...
                   ch ...
                   getRegion(ch) ...
                   block ...
                   ee_bpm_mean ...
                   ee_sdann ...
                   baselineOxy ...
                   baselineDeoxy...
                   taskOxy ...
                   taskDeoxy...
                   changeOxy ...
                   changeDeoxy];
        pos=pos+1;
    end
end

dlmwrite([opt.destinationFolder 'splitECGs_DB0002.csv'],db);

disp('== Done!');

end



%% AUXILIAR FUNCTION
function files=getFilesToProcess()
%Construct a list of ECG files to process and their corresponding
%raw NIRS file (HITACHI ETG4000) to guide the split.
%
%files - A struct array with the following files
%       .subject - Subject number
%       .session - From 'a' to 'f'
%       .ecg - An ECG file (*.mat)
%       .nirs - Raw NIRS filename (A HITACHI ETG4000 MES file)

ecgSrcDir = '../NIRS/experimentalData/LGCMC/HR_Files_For_DataBase/';
nirsSrcDir = '../../FINAL/NIRS/experimentalData/LGCMC/';

%Subject 1
files(1).subject = 1;
files(1).session = 'a';
files(1).ecg = [ecgSrcDir 'LGCMC0001a.mat'];
files(1).nirs = [nirsSrcDir 'LGCMC0001a/LGCMC0001a_MES_Probe1.csv'];
files(end+1).subject = 1;
files(end).session = 'b';
files(end).ecg = [ecgSrcDir 'LGCMC0001b.mat'];
files(end).nirs = [nirsSrcDir 'LGCMC0001b/LGCMC0001b_MES_Probe1.csv'];
%Subject 2
for subject=2:21
  for session='abcdef'
    files(end+1).subject = subject;
    files(end).session = session;
    files(end).ecg = [ecgSrcDir 'LGCMC' num2str(subject,'%04d') ...
                                  session ...
                                  '_ECG_cropped.mat'];
    files(end).nirs = [nirsSrcDir 'LGCMC' num2str(subject,'%04d') ...
                                  session ...
                                  '/LGCMC' num2str(subject,'%04d') ...
                                  session ...
                                  '_MES_Probe1.csv'];


    %%Known Exceptions: Missing files
    if ((subject==3 && session=='c') ...
    	|| (subject==3 && session=='d') ...
    	|| (subject==4 && session=='c') ...
    	|| (subject==4 && session=='d') ...
    	|| (subject==4 && session=='e') ...
    	|| (subject==8 && session=='e') ...
    	|| (subject==9 && session=='c') ...
    	|| (subject==11 && session=='d') ...
    	|| (subject==15 && session=='b') ...
    	|| (subject==17 && session=='a') ...
    	|| (subject==19 && session=='d') ...
    	|| (subject==20 && session=='e') ...
    	|| (subject==21 && session=='c'))
        files(end) = [];
    end
    %%Known Exceptions: Erroneuos files
    if ((subject==8 && session=='d'))
        files(end) = [];
    end
  end
end


end


function group=getSubjectGroup(subject)
%Return 1 for control and 2 for GCMC

%controlSubjects = [1 3 4 8 10 11 12 14 16 17 21];
GCMCSubjects = [2 5 6 7 9 13 15 18 19 20];

group=1;
if ismember(subject,GCMCSubjects)
    group=2;
end

end

function sessID=getSessionID(subject,session)
%Return the session ID
group = getSubjectGroup(subject);
sessID=nan;    
if group==1 %Control
    switch(session)
        case 'a'
            sessID = 1;
        case 'b'
            sessID = 2;
        case 'c'
            sessID = 3;
        case 'd'
            sessID = 4;
        case 'e'
            sessID = 5;
        case 'f'
            sessID = 6;
    end
else %GCMC
    switch(session)
        case 'a'
            sessID = 7;
        case 'b'
            sessID = 8;
        case 'c'
            sessID = 9;
        case 'd'
            sessID = 10;
        case 'e'
            sessID = 11;
        case 'f'
            sessID = 12;
    end
end

end

function region=getRegion(ch)
%Return 1 for PFC and 2 for PC
region=1; %PFC
if ch<13
    region=2; %PC
end

end

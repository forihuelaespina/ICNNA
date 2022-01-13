function [M,P,S,Im,hFig]=getActivityMatrixPerRecording(db,options)
%Computes and plot the channel (significant) activation matrix
%
% [M,P,S,Im,hFig]=getActivityMatrixPerRecording(db,options)
%   computes and plot the channel (significant) activation
%   matrix.
%
%Similar to function getActivityMatrix channel (significant)
%activation matrix is generated. However rather than averaging
%across subjects, datasources and blocks, to yield a row
%per <session,stimulus>, this function yields a row on a per
%recording basis, averaging only across blocks.
%
%
%
%% The database structure
%
% The database parameter is a database that can be obtained from ICNA.
%This database has the following colums
%
% 1 - COL_SUBJECT
% 2 - COL_SESSION
% 3 - COL_DATASOURCE
% 4 - COL_STRUCTUREDDATA
% 5 - COL_CHANNEL
% 6 - COL_SIGNAL of which signal Oxy is coded as 1 and deoxy is coded as 2
% 7 - COL_STIMULUS
% 8 - COL_BLOCK
% 
% 9 - COL_MEAN_BASELINE
% 10 - COL_STD_BASELINE
% 11 - COL_MEAN_TASK
% 12 - COL_STD_TASK
% 13 - COL_TASK_MINUS_BASELINE
% 14 - COL_AREA_UNDER_CURVE_TASK
% 
%
%% The activity patterns
%
% The activity patterns depend on the activity matrix type:
%
% A) For 'Combined' activity matrix i.e. using both Oxy and Deoxy data
% 16 activity patterns can be distinguish in total:
%
%   HbO2\HHb | ++| + | - | --|
%      ------+---+---+---+---+
%         ++ | 1 | 2 | 3 | 4 |
%      ------+---+---+---+---+
%          + | 5 | 6 | 7 | 8 |
%      ------+---+---+---+---+
%          - | 9 | 10| 11| 12|
%      ------+---+---+---+---+
%         -- | 13| 14| 15| 16|
%      ------+---+---+---+---+
%
%  ++ - Increment reached statistical significance
%   + - Increment did not reach statistical significance
%   - - Decrement did not reach statistical significance
%  -- - Decrement reached statistical significance
%
%
% Thus:
%  + Pattern 4 is classical activation
%  + Pattern 13 is classical deactivation
%
%In addition a pattern 17 identifies missing data.
%
% B) For 'Oxy' or 'Deoxy' activity matrix i.e. using both Oxy and Deoxy data
% 4 activity patterns can be distinguish in total:
%
%   HbO2\HHb | ++| + | - | --|
%      ------+---+---+---+---+
%            | 1 | 2 | 3 | 4 |
%      ------+---+---+---+---+
%
%In addition a pattern 5 identifies missing data.
%
%
%% Parameter
%
% db - a database as obtained from ICNA with the follwoing columns:
%
%
%
% options - An struct of options
%   .fontSize - Font size to be used in the figure series
%   .destinationFolder - Destination folder. Default value is
%       './images/'
%   .outputFilename - OutputFilename WITHOUT EXTENSION.Default
%       value is
%       'ActivityMatrix_SignRank'
%   .save - True if you want the figure to be saved. False (default)
%       otherwise. Figures are saved in MATLAB .fig format and in
%       .tif format non-compressed at 300dpi.      
%   .sessionLabels - A cell array with the session labels. By default
%       is set to {'Control','Stimulus'} if there are two sessions
%       or {'Session 1',...,'Session N'} for more than 2 sessions. If
%       sessions IDs are not sequential or do not start in 1 include
%       empty strings where appropriate '', e.g. if sessions IDs are
%       {2 3 5} then indicate
%           {'', 'Session 2', 'Session 3', '', 'Session 5'}.
%   .significanceLevel -  Perform statistical tests at the indicated
%       significance level. Default values is 0.05 i.e. alpha=5% (p<0.05)
%   .stimulusLabels - A cell array with the stimulus labels. By default
%       is set to {'A'} if there is only one stimulus
%       or {'A','B',...} for more than one stimulus. If
%       stimuli IDs are not sequential or do not start in 1 include
%       empty strings where appropriate '', e.g. if stimuli IDs are
%       {2 3 5} then indicate
%           {'', 'Stim 2', 'Stim 3', '', 'Stim 5'}.
%   .type - Indicates which haemodynamic data must be used. It can be:
%       + 'combined' - Default. Uses both Oxy and Deoxy data
%       + 'oxy' - Uses only HbO2 data
%       + 'deoxy' - Uses only HbO2 data
%
%% Output
%
% M - The activity matrix
%
% P - The p-values underlying the activity matrix. If the matrix is
%   combined (i.e. taking into account Oxy and Deoxy signals), then
%   P is a three dimensional matrix where (:,:,1) contains the p-values
%   corresponding to the Oxy signal, and (:,:,2) contains the p-values
%   corresponding to the Deoxy signal. Otherwise, P has the same size
%   as M.
%
% S - The sign of the change underlying the activity matrix. If the matrix
%   is combined (i.e. taking into account Oxy and Deoxy signals), then
%   S is a three dimensional matrix where (:,:,1) contains the sign
%   corresponding to the Oxy signal, and (:,:,2) contains the sign
%   corresponding to the Deoxy signal. Otherwise, S has the same size
%   as M.
%       The sign matrix is valued 1 for increments, -1 for decrements
%   and 0 for no changes.
%
% Im - Index to the activity matrix, with the follwoing columns
%   <Subject, Session, DataSource, Stimulus>
%
% hFig - Handle to the activity matrix figure
%
%
% Copyright 2010-16
% @date: 31-Jan-2010
% @author: Felipe Orihuela-Espina
% @modified: 15-May-2016
%
% See also experimentSpace, getActivityMatrix, generateDB_withBreak
%



%% Log
%
% 15-May-2016 (FOE): Updated version.
%   MATLAB has recently changed the way gcf returns its output. It affects
%   the call of matlab's function print for saving figures. Saving
%   the activity matrix figure file is now done through the
%   util/mySaveFig.m function
%
%


%internalOpt_Test='SingRank';
internalOpt_Test='ttest2';

%% Deal with options
opt.save=false;
opt.destinationFolder='./images/';
opt.outputFilename=['ActivityMatrixByRecording_' internalOpt_Test];
%opt.mainTitle='';
opt.fontSize=13;
opt.significanceLevel = 0.05;
opt.sessionTags={'Control','Stimulus'};
% opt.sessionTags={'Controla','Controlb','Controlc',...
%             'Controld','Controle','Controlf',...
%             'GCMCa','GCMCb','GCMCc',...
%             'GCMCd','GCMCe','GCMCf'};
sessionLabelsProvided=false;
%Session 1: Without GCMC feedback (Control)
%Session 2: With GCMC feedback
%sessionLabels={'Size No Matter','Size Matter'};
opt.stimulusTags={'A'};
%stimulusLabels={'A','B','Shadow','No Shadow'};
stimulusLabelsProvided=false;
opt.type='combined';
if exist('options','var')
    if isfield(options,'save')
        opt.save=options.save;
    end
    if isfield(options,'destinationFolder')
        opt.destinationFolder=options.destinationFolder;
    end
    if isfield(options,'significanceLevel')
        opt.significanceLevel=options.significanceLevel;
        opt.outputFilename=[opt.outputFilename ...
                            '_p' num2str(opt.significanceLevel)];
    end
    if isfield(options,'outputFilename')
        opt.outputFilename=options.outputFilename;
    end
    if isfield(options,'fontSize')
        opt.fontSize=options.fontSize;
    end
    if isfield(options,'sessionLabels')
        opt.sessionTags=options.sessionLabels;
        sessionLabelsProvided=true;
    end
    if isfield(options,'stimulusLabels')
        opt.stimulusTags=options.stimulusLabels;
        stimulusLabelsProvided=true;
    end
    if isfield(options,'type')
        opt.type=lower(options.type);
    end
end

%Some constants to make my life easier:
[dbCons,~]=getDBConstants;
% COL_SUBJECT = 1;
% COL_SESSION = 2;
% COL_DATASOURCE = 3;
% COL_STRUCTUREDDATA = 4;
% COL_CHANNEL = 5;
% COL_SIGNAL = 6;
% COL_STIMULUS = 7;
% COL_BLOCK = 8;
% 
% COL_MEAN_BASELINE = 9;
% COL_STD_BASELINE = 10;
% COL_MEAN_TASK = 11;
% COL_STD_TASK = 12;
% COL_TASK_MINUS_BASELINE = 13;
% COL_AREA_UNDER_CURVE_TASK = 14;


OXY=1;
DEOXY=2;


nSubjects = max(db(:,dbCons.COL_SUBJECT));
nSessions = max(db(:,dbCons.COL_SESSION));
nDataSources = max(db(:,dbCons.COL_DATASOURCE));
nStimulus = max(db(:,dbCons.COL_STIMULUS));
nChannels = max(db(:,dbCons.COL_CHANNEL));
M=zeros(0,nChannels);
P=zeros(0,nChannels,2);
S=zeros(0,nChannels,2);

if ~sessionLabelsProvided
    %Need to regenerate the session tags so there
    %are as many tags as sessions
    if nSessions ~=2
        opt.sessionTags=cell(1,nSessions);
        for ss=1:nSessions
            opt.sessionTags(ss)={['Sess. ' num2str(ss)]};
        end
    end
end
if ~stimulusLabelsProvided
    %Need to regenerate the stimulus tags so there
    %are as many tags as stimulus
    if nStimulus ~=1
        opt.stimulusTags=cell(1,nStimulus);
        for ss=1:nStimulus
            tmpPrefix = floor((ss-1)/26);
            s='';
            if tmpPrefix ~=0, s=char(64+tmpPrefix); end;
            tmpss = mod(ss,26);
            if tmpss ==0,
                s=[s 'Z'];
            else
                s=[s char(64+tmpss)];
            end;
            opt.stimulusTags(ss)={s};
        end
    end
end

sessLabels=cell(0,1);
Im=zeros(0,4);


subjects = unique(db(:,dbCons.COL_SUBJECT))';
sessions = unique(db(:,dbCons.COL_SESSION))';
dataSources = unique(db(:,dbCons.COL_DATASOURCE))';

for subj=subjects
for sess=sessions
for ds=dataSources
 %The subject may have not record this session...
 tmpIdx = find(db(:,dbCons.COL_SUBJECT) == subj ...
                 & db(:,dbCons.COL_SESSION) == sess ...
                 & db(:,dbCons.COL_DATASOURCE) == ds);
 if ~isempty(tmpIdx)
	stimuli=unique(db(tmpIdx,dbCons.COL_STIMULUS))';

  for stim=stimuli %1:nStimulus
    for ch=1:nChannels
        idx = find(db(:,dbCons.COL_SUBJECT) == subj ...
                 & db(:,dbCons.COL_SESSION) == sess ...
                 & db(:,dbCons.COL_DATASOURCE) == ds ...
                 & db(:,dbCons.COL_STIMULUS) == stim ...
                 & db(:,dbCons.COL_CHANNEL) == ch ...
                 & db(:,dbCons.COL_SIGNAL) == OXY);
        %Some channel may be missing due to integrity
        if ~isempty(idx)

            tmpDB = db(idx,:);
            oxy_Sign = sign(mean(tmpDB(:,dbCons.COL_MEAN_TASK)...
                -tmpDB(:,dbCons.COL_MEAN_BASELINE)));
            switch (internalOpt_Test)
                case 'SingRank'
                    oxy_pValue = signrank(tmpDB(:,dbCons.COL_MEAN_TASK),...
                        tmpDB(:,dbCons.COL_MEAN_BASELINE),...
                        'alpha',opt.significanceLevel);
                case 'ttest2'
                    [~,oxy_pValue] = ttest2(tmpDB(:,dbCons.COL_MEAN_TASK),...
                        tmpDB(:,dbCons.COL_MEAN_BASELINE),...
                        opt.significanceLevel,'both');
                otherwise
                    error('Unexpected test of significance.');
            end
            
            idx = find(db(:,dbCons.COL_SUBJECT) == subj ...
                & db(:,dbCons.COL_SESSION) == sess ...
                & db(:,dbCons.COL_DATASOURCE) == ds ...
                & db(:,dbCons.COL_STIMULUS) == stim ...
                & db(:,dbCons.COL_CHANNEL) == ch ...
                & db(:,dbCons.COL_SIGNAL) == DEOXY);
            tmpDB = db(idx,:);
            deoxy_Sign = sign(mean(tmpDB(:,dbCons.COL_MEAN_TASK)...
                -tmpDB(:,dbCons.COL_MEAN_BASELINE)));
            switch (internalOpt_Test)
                case 'SingRank'
                    deoxy_pValue = signrank(tmpDB(:,dbCons.COL_MEAN_TASK),...
                        tmpDB(:,dbCons.COL_MEAN_BASELINE),...
                        'alpha',opt.significanceLevel);
                case 'ttest2'
                    [~,deoxy_pValue] = ttest2(tmpDB(:,dbCons.COL_MEAN_TASK),...
                        tmpDB(:,dbCons.COL_MEAN_BASELINE),...
                        opt.significanceLevel,'both');
                otherwise
                    error('Unexpected test of significance.');
            end
            
            chActivity_Sign(:,ch)=[oxy_Sign deoxy_Sign];
            chActivity_pValue(:,ch)=[oxy_pValue deoxy_pValue];
        else
            chActivity_Sign(:,ch)=[NaN NaN];
            chActivity_pValue(:,ch)=[NaN NaN];
        end
    end
    P(end+1,:,:)=NaN; %Allocate space
    P(end,:,1)=chActivity_pValue(1,:); %Oxy p-values
    P(end,:,2)=chActivity_pValue(2,:); %Deoxy p-values
    S(end+1,:,:)=NaN; %Allocate space
    S(end,:,1)=chActivity_Sign(1,:); %Oxy p-values
    S(end,:,2)=chActivity_Sign(2,:); %Deoxy p-values

    %M=[M; getPatterns(chActivity_Sign,...
    %                  chActivity_pValue)];
    switch (opt.type)
        case 'combined'
            M=[M; getPatterns_Combined(chActivity_Sign,...
                chActivity_pValue,opt.significanceLevel)];
        case 'deoxy'
            M=[M; getPatterns_Deoxy(chActivity_Sign,...
                chActivity_pValue,opt.significanceLevel)];
        case 'oxy'
            M=[M; getPatterns_Oxy(chActivity_Sign,...
                chActivity_pValue,opt.significanceLevel)];
        otherwise
            error('ICNA:getActivityMatrixPerRecording:InvalidType',...
                'Invalid activity matrix type.');
    end

    if nStimulus == 1 && nSessions == 1          
        sessLabels(end+1)={['Subj' num2str(subj,'%03d') ...
            '; DS' num2str(ds,'%03d')]};
    elseif nStimulus == 1              
        sessLabels(end+1)={['Subj' num2str(subj,'%03d') ...
            '; Sess' opt.sessionTags{sess} ...
            '; DS' num2str(ds,'%03d')]};
    elseif nSessions == 1
        sessLabels(end+1)={['Subj' num2str(subj,'%03d') ...
            '; DS' num2str(ds,'%03d') ...
            '; Stim' opt.stimulusTags{stim}]};
    else
        sessLabels(end+1)={['Subj' num2str(subj,'%03d') ...
            '; Sess' opt.sessionTags{sess} '; ' ...
            '; DS' num2str(ds,'%03d') ...
            '; Stim' opt.stimulusTags{stim}]};
    end
    Im(end+1,:) = [subj, sess, ds, stim];
    
  end
 end
end
end
end

switch (opt.type)
    case 'combined'
        %Do nothing
    case 'deoxy'
        P(:,:,1)=[]; %Remove oxy p-values
        P=squeeze(P);
        S(:,:,1)=[]; %Remove oxy p-values
        S=squeeze(S);
    case 'oxy'
        P(:,:,2)=[]; %Remove deoxy p-values
        P=squeeze(P);
        S(:,:,2)=[]; %Remove deoxy p-values
        S=squeeze(S);
    otherwise
        error('ICNA:getActivityMatrixPerRecording:InvalidType',...
                'Invalid activity matrix type.');
end


%% Plot the matrix
hFig= figure;
%Colormaps:
opt.colormapOpt =2;
switch (opt.colormapOpt)
    case 1
        cmap=colormap(jet(16));
    case 2
        %%Option 2
        cmap = [ ...
            1.0000    1.0000    1.0000; ...
            1.0000    1.0000    0.6745; ...
            1.0000    0.5020    0.5020; ...
            1.0000    0.2000         0; ...
            0.6745    1.0000    1.0000; ...
            1.0000    1.0000    1.0000; ...
            1.0000    0.8078    0.6863; ...
            1.0000    0.5020    0.5020; ...
            0.5020    0.5020    1.0000; ...
            0.6863    0.8078    1.0000; ...
            1.0000    1.0000    1.0000; ...
            1.0000    1.0000    0.6745; ...
            0         0.2000    1.0000; ...
            0.5020    0.5020    1.0000; ...
            0.6745    1.0000    1.0000; ...
            1.0000    1.0000    1.0000];
    case 3
        %%Option 3
        cmap = [ ...
            1.0000    0.2000         0; ...
            1.0000    0.2000    0.3333; ...
            1.0000    0.2000    0.6667; ...
            1.0000    0.2000    1.0000; ...
            0.6600    0.2000         0; ...
            0.6600    0.2000    0.3333; ...
            0.6600    0.2000    0.6667; ...
            0.6600    0.2000    1.0000; ...
            0.3300    0.2000         0; ...
            0.3300    0.2000    0.3333; ...
            0.3300    0.2000    0.6667; ...
            0.3300    0.2000    1.0000; ...
            0    0.2000         0; ...
            0    0.2000    0.3333; ...
            0    0.2000    0.6667; ...
            0    0.2000    1.0000];
    otherwise
        cmap=colormap(jet(16));
end

switch (opt.type)
    case 'oxy'
        cmap=cmap([4 7 10 13],:);
    case 'deoxy'
        cmap=cmap([13 10 7 4],:);
end

%and add one colour for pattern 17 (missing data)
cmap=[cmap; 0 0 0];

colormap(cmap);

        
%subplot(1,7,1:6);
hMain=axes();
set(gca,'OuterPosition',[0 0.15 1 0.85]);


image(M);
%Paint the grid manually
ylim=axis;
for ii=-1:(ylim(4)-ylim(3))
    line('XData',[ylim(1) ylim(2)],...
        'YData',[ii+0.5 ii+0.5],'Color','k','LineStyle','-',...
        'LineWidth',1);
end
nChannels=size(M,2);
for ii=1:nChannels
    line('XData',[ii+0.5 ii+0.5],...
        'YData',[ylim(3) ylim(4)],'Color','k','LineStyle','-',...
        'LineWidth',1);
end
box on


set(gca,'YTick',[1:size(M,1)]);
set(gca,'YTickLabel',sessLabels);
%set(gca,'YTickLabel',{'Control','Stimulus'})
xlabel('Channels');
switch (opt.type)
    case 'combined'
        title(['Pattern 4 is classical activation; ' ...
            ' Pattern 13 is classical deactivation']);
    case 'deoxy'
        title(['Pattern 4 is classical activation; ' ...
            ' Pattern 1 is classical deactivation']);
    case 'oxy'
        title(['Pattern 1 is classical activation; ' ...
            ' Pattern 4 is classical deactivation']);
end

%subplot(1,7,7);
hLegend=axes();
set(gca,'OuterPosition',[0 0 1 0.15]);
switch (opt.type)
    case 'combined'
        tmp = reshape(1:16,4,4)';
        image(tmp);
        set(gca,'XTick',[1:4]);
        set(gca,'YTick',[1:4]);
        set(gca,'XTickLabel',{'++','+','-','--'})
        set(gca,'YTickLabel',{'++','+','-','--'})
        xlabel('\Delta HHb');
        ylabel('\Delta HbO_2');
        title('Pattern color coding');
    case 'deoxy'
        tmp = 1:4;
        image(tmp);
        set(gca,'XTick',[1:4]);
        set(gca,'YTick',[]);
        set(gca,'XTickLabel',{'++','+','-','--'})
        xlabel('\Delta HHb');
        title('Pattern color coding');
    case 'oxy'
        tmp = 1:4;
        image(tmp);
        set(gca,'XTick',[1:4]);
        set(gca,'YTick',[]);
        set(gca,'XTickLabel',{'++','+','-','--'})
        xlabel('\Delta HbO_2');
        title('Pattern color coding');
end


if (opt.save)
    view(2);
    outputFilename=opt.outputFilename;
    mySaveFig(gcf,[opt.destinationFolder outputFilename]);
    
    close gcf
    %And save the matrix itself
    save([opt.destinationFolder outputFilename '.mat'],...
        'M','P','S','Im','sessLabels');
end



end




%% AUXILIAR FUNCTIONS
function p=getPatterns_Combined(Ms,Mp,alpha)
%Convert change directions and p values to patterns
%
% 16 activity patterns can be distinguish in total:
%
%   HbO2\HHb | ++| + | - | --|
%      ------+---+---+---+---+
%         ++ | 1 | 2 | 3 | 4 |
%      ------+---+---+---+---+
%          + | 5 | 6 | 7 | 8 |
%      ------+---+---+---+---+
%          - | 9 | 10| 11| 12|
%      ------+---+---+---+---+
%         -- | 13| 14| 15| 16|
%      ------+---+---+---+---+
%
%  ++ - Increment reached statistical significance
%   + - Increment did not reach statistical significance
%   - - Decrement did not reach statistical significance
%  -- - Decrement reached statistical significance
%
% Ms - Matrix of sign (direction of change)
% Mp - Matrix of p values (statistical significance)
% alpha - Optional. Statistical significance threshold (Default 0.05)

if ~exist('alpha','var')
    alpha=0.05;
end

tmpM=Ms.*Mp;
tmpM_HbO2=tmpM(1,:);
tmpM_HHb=tmpM(2,:);
p=zeros(1,length(tmpM)); %Patterns

%Check all 16 patterns:
idx=find((tmpM_HbO2 < alpha & tmpM_HbO2 >= 0) ...
        & (tmpM_HHb < alpha & tmpM_HHb >= 0));
p(idx)=1;

idx=find((tmpM_HbO2 < alpha & tmpM_HbO2 >= 0) ...
        & (tmpM_HHb >= alpha));
p(idx)=2;

idx=find((tmpM_HbO2 < alpha & tmpM_HbO2 >= 0) ...
        & (tmpM_HHb <= -alpha));
p(idx)=3;

idx=find((tmpM_HbO2 < alpha & tmpM_HbO2 >= 0) ...
        & (tmpM_HHb > -alpha & tmpM_HHb < 0));
p(idx)=4;


idx=find((tmpM_HbO2 >= alpha) ...
        & (tmpM_HHb < alpha & tmpM_HHb >= 0));
p(idx)=5;

idx=find((tmpM_HbO2 >= alpha) ...
        & (tmpM_HHb >= alpha));
p(idx)=6;

idx=find((tmpM_HbO2 >= alpha) ...
        & (tmpM_HHb <= -alpha));
p(idx)=7;

idx=find((tmpM_HbO2 >= alpha) ...
        & (tmpM_HHb > -alpha & tmpM_HHb < 0));
p(idx)=8;


idx=find((tmpM_HbO2 <= -alpha) ...
        & (tmpM_HHb < alpha & tmpM_HHb >= 0));
p(idx)=9;

idx=find((tmpM_HbO2 <= -alpha) ...
        & (tmpM_HHb >= alpha));
p(idx)=10;

idx=find((tmpM_HbO2 <= -alpha) ...
        & (tmpM_HHb <= -alpha));
p(idx)=11;

idx=find((tmpM_HbO2 <= -alpha) ...
        & (tmpM_HHb > -alpha & tmpM_HHb < 0));
p(idx)=12;


idx=find((tmpM_HbO2 > -alpha & tmpM_HbO2 < 0) ...
        & (tmpM_HHb < alpha & tmpM_HHb >= 0));
p(idx)=13;

idx=find((tmpM_HbO2 > -alpha & tmpM_HbO2 < 0) ...
        & (tmpM_HHb >= alpha));
p(idx)=14;

idx=find((tmpM_HbO2 > -alpha & tmpM_HbO2 < 0) ...
        & (tmpM_HHb <= -alpha));
p(idx)=15;

idx=find((tmpM_HbO2 > -alpha & tmpM_HbO2 < 0) ...
        & (tmpM_HHb > -alpha & tmpM_HHb < 0));
p(idx)=16;

%...and missing data
idx=find(any(isnan(tmpM_HbO2)) || any(isnan(tmpM_HHb)));
p(idx)=17;

end


function p=getPatterns_Oxy(Ms,Mp,alpha)
%Convert change directions and p values to patterns
%
% 4 activity patterns can be distinguish in total:
%
%   HbO2\HHb | ++| + | - | --|
%      ------+---+---+---+---+
%            | 1 | 2 | 3 | 4 |
%      ------+---+---+---+---+
%
%  ++ - Increment reached statistical significance
%   + - Increment did not reach statistical significance
%   - - Decrement did not reach statistical significance
%  -- - Decrement reached statistical significance
%
% Ms - Matrix of sign (direction of change)
% Mp - Matrix of p values (statistical significance)
% alpha - Optional. Statistical significance threshold (Default 0.05)

if ~exist('alpha','var')
    alpha=0.05;
end

tmpM=Ms.*Mp;
tmpM_HbO2=tmpM(1,:); %Ignore Deoxy
p=zeros(1,length(tmpM)); %Patterns

%Check all 16 patterns:
idx=find((tmpM_HbO2 < alpha & tmpM_HbO2 >= 0));
p(idx)=1;

idx=find((tmpM_HbO2 >= alpha));
p(idx)=2;

idx=find((tmpM_HbO2 <= -alpha));
p(idx)=3;

idx=find((tmpM_HbO2 > -alpha & tmpM_HbO2 < 0));
p(idx)=4;

%...and missing data
idx=find(any(isnan(tmpM_HbO2)));
p(idx)=5;


end



function p=getPatterns_Deoxy(Ms,Mp,alpha)
%Convert change directions and p values to patterns
%
% 4 activity patterns can be distinguish in total:
%
%   HbO2\HHb | ++| + | - | --|
%      ------+---+---+---+---+
%            | 1 | 2 | 3 | 4 |
%      ------+---+---+---+---+
%
%  ++ - Increment reached statistical significance
%   + - Increment did not reach statistical significance
%   - - Decrement did not reach statistical significance
%  -- - Decrement reached statistical significance
%
% Ms - Matrix of sign (direction of change)
% Mp - Matrix of p values (statistical significance)
% alpha - Optional. Statistical significance threshold (Default 0.05)

if ~exist('alpha','var')
    alpha=0.05;
end

tmpM=Ms.*Mp;
tmpM_HHb=tmpM(2,:); %Ignore oxy
p=zeros(1,length(tmpM)); %Patterns

%Check all 16 patterns:
idx=find((tmpM_HHb < alpha & tmpM_HHb >= 0));
p(idx)=1;

idx=find((tmpM_HHb >= alpha));
p(idx)=2;

idx=find((tmpM_HHb <= -alpha));
p(idx)=3;

idx=find((tmpM_HHb > -alpha & tmpM_HHb < 0));
p(idx)=4;

%...and missing data
idx=find(any(isnan(tmpM_HHb)));
p(idx)=5;


end



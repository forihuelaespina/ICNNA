function batchBasicVisualization(E,options)
%Batch for basic visualization
%
% batchBasicVisualization(E) generates all kind of basic plots for a
%   NIRS experiment.
%
% batchBasicVisualization(E,options) generates all kind of basic
%   plots for a NIRS experiment with the indicated options.
%
%
%% Parameter
%
% E - An (NIRS) experiment
%
% options - An struct of options
%   .fontSize - Font size to be used in the figure series
%   .destinationFolder - Destination folder. Default value is
%       '.\Images\<experimentName>\'
%
%   .whichSubjects - Select a subset of subjects
%       Use MATLAB matrix notation to indicate valid subject's IDs.
%       Use the empty notation [] to include all (default).
%   .whichSessions - Select a subset of sessions
%       Use MATLAB matrix notation to indicate valid session's IDs.
%       Use the empty notation [] to include all (default).
%   .whichDataSources - Select a subset of dataSources
%       Use MATLAB matrix notation to indicate valid dataSource's IDs.
%       Use the empty notation [] to include all (default).
%
%
%   .save - True (default) if you want your figures to be saved. False
%       otherwise. Figures will be saved in MATLAB .fig format
%       and in .tif format at 300dpi.
%
%
% == Temporal / Timecourse Series ==
%   .seriesSCHAVG - Generate series of figures showing single channels
%       averaged across block. One figure per <subject, session, 
%       dataSource, channel, stimulus>. False by default.
%           Currently only work using 5 baseline
%           samples and 10 rest samples for the block splitting.
%           It only generates the figures for those clean channels
%   .seriesSCHNBA - Generate series of figures showing single channels
%       non block averaged. One figure per <subject, session, 
%       dataSource, channel>. False by default.
%           It only generates the figures for those clean channels
%   .seriesACHNBA - Generate series of figures showing all channels
%       non block averaged at once. One figure per <subject, session,
%       dataSource>. True by default.
%           It include all channels even if they are not clean
%           NOTE: Currently assumes 24 channels
%   .seriesACHAVG - Generate series of figures showing all channels
%       at once block averaged by stimulus. One figure per
%       <subject, session, dataSource, stimulus>. False by default.
%           It include all channels even if they are not clean
%           NOTE: Currently assumes 24 channels
%   .seriesGAACHAVG - Generate grand average figure showing all channels
%       at once block averaged by stimulus. One figure per stimulus
%       across all selected subject, session and dataSource.
%       False by default.
%           This series:
%           + Currently assumes that all elements share the probe mode,
%           and number of channels.
%           + Averaging is made across elements on a sample by sample
%           basis over clean data without taking into consideration
%           the timeline. This is specially relevant for self pace
%           tasks.
%           + The timeline of the first element of the set is use
%           as the grand average total timeline. Note that this
%           assumption is INCORRECT for self pace tasks.
%
% == Spatial / Topographic Series ==
%   .seriesTOPONBA - Generate series of figures showing all channels
%       at once non-block averaged by stimulus. One figure per
%       <subject, session, dataSource, stimulus, Block, Hbspecies>.
%       False by default.
%           It include all channels even if they are not clean
%   .seriesTOPOAVG - Generate series of figures showing all channels
%       at once block averaged by stimulus. One figure per
%       <subject, session, dataSource, stimulus, Hbspecies>.
%       False by default.
%           It include all channels even if they are not clean
%
%
% == Parameters for subseries SCHAVG adn ACHAVG
%
%
%   .blockBaseline - Scalar int. Default value is 10;
%       Window of baseline samples to be considered for the averaging.
%       Available only from v1.2.0 onwards
%   .blockMaxRest - Scalar int. Default value is 20;
%       Window of recovery period samples to be considered for the averaging.
%       Available only from v1.2.0 onwards
%   .blockResampling - Bool. Default value is true;
%       Should the block be resampled?
%       Set this to true for self-paced tasks.
%       Available only from v1.2.0 onwards
%   .blockResamplingBaseline - Scalar int. Default value is 15;
%       If .blockResampling is true, the number of output baseline samples 
%       after resampling.
%       Available only from v1.2.0 onwards
%   .blockResamplingTask - Scalar int. Default value is 30;
%       If .blockResampling is true, the number of output task samples 
%       after resampling.
%       Available only from v1.2.0 onwards
%   .blockResamplingRest - Scalar int. Default value is 20;
%       If .blockResampling is true, the number of output recovery samples 
%       after resampling.
%       Available only from v1.2.0 onwards
%
%
% == The following options are to be passed directly to plotTopo:
%   .seriesTOPO_taskOnly - True (default) if the plot is to represent data
%       from the task alone, or false if the plot is to represent
%       differential data of task-baseline.
%   .seriesTOPO_baselineLength - Number of samples to be taken from
%       the baseline.
%       By default is set to 5. If there are not enough samples in
%       the baseline, the maximum number of available samples in the
%       baseline are taken. Set it to -1 to use all available baseline
%       samples. This option is only taken into account
%       if the option .taskOnly is set to false.
%   .seriesTOPO_breakDelay - Number of samples to delay the window of data
%       to be used from the stimulus onset. By default is set
%       to 0 (no break delay).
%       If the break delay is large enough to cause the data window
%       exceeds available samples, only as many samples as remaining
%       will be used.
%       Note: A negative value shifts the window prior to the onset.
%
% == Channel positioning and labelling
%
%   .channelPositioning - Choose how to arrange the channels spatially.
%       Available only from v1.2.0 onwards
%       'legacy' - (Default) Channels are arranged topologically according to the
%           optode array in which they are attached.
%       'use2DChannelLocation' - Channels are arraged according to their
%           registered locations in the channel location map.
%
%   .channelLabelling - String or cell.
%       Available only from v1.2.0 onwards
%       If string;
%       'serial' - (Default) Channels are labelled numerically i.e. 1, 2,
%           3, ...
%               NOTE: If you are rendering some subset of channels
%               using the option .whichChannels the original channel
%               numbering will be lost which can be confusing. If you want
%               to keep the original channel numbering use option
%               'fullSerial' instead.
%       'fullSerial' - Channels are labelled numerically i.e. 1, 2, 3, ...
%           but the number correspond to the number it would have had
%           should all channels in the image be displayed.
%       'srcdet' - Channels are labelled according to the source and
%           detector pair e.g. 'S3-D14'
%       If cell:
%       A <nChannels,1> cell array with the labels of the channels. 
%
%
%
% Copyright 2009-23
% @author: Felipe Orihuela-Espina
%
% See also plotChannel, plotTopo, guiBasicVisualization
%

%% Log
%
% File created: 30-Apr-2009
% File last modified (before creation of this log): N/A
%
% 9-Dec-2013 (FOE): Ammended bugs by which:
%       1) "old" function channelLocationMap.getOptodeArrays was
%       still being called. This has been updated by current method
%       channelLocationMap.getChannelOptodeArrays
%       2) Calls to field oaInfo.topoArrangement has been updated to
%       oaInfo.chTopoArrangement
%
%
% 15-May-2016 (FOE): Abandon feature:
%       batchBasicVisualization.m no longer permits choosing export formats.
%       Instead it still permits choosing whether to save the figure or not,
%       but upon saving it automatically saves the figure in .fig and .tiff
%       (300dpi) formats.
%
% 27-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated (most) calls to get attributes using the struct like syntax
%   + Removed some very old commented/abandoned code.
%
% 25-Aug-2023: FOE
%   + Added option to filter by channel.
%   + Bug fixing; In the presence of short channels, the automatic
%       sizeing of channel subplots was yielding a tiny value hence,
%       channel plots were not discernible. Channel subplots now get
%       a minimum size in the presence of short channels for a better
%       visualization.
%   + Estimation of figure size now capture screen size on the fly.
%
% 25-Aug-2023: FOE
%   + Added option to position the channels according to their real
%   positions rather than the previous optode array based (now referred 
%   to as 'legacy' option.
%
% 26-Aug-2023: FOE
%   + Added option to label the channels in different manners.
%
% 11-Sep-2023: FOE
%   + Updated calls to get attributes using the struct like syntax
%   for the GA* series
%   + The options for the GA* series are now accesible (but remain
%   undocumented).
%


expName= E.name;
%Remove spaces (to avoid problems with MATLAB)
expName(expName==' ')='_';


%% Deal with options
opt.whichSubjects=[];
opt.whichSessions=[];
opt.whichDataSources=[];
opt.whichChannels=[];

opt.save=true;
opt.destinationFolder=['.' filesep 'Images' filesep expName filesep];
opt.fontSize=13;
opt.seriesSCHAVG = false;
opt.seriesSCHNBA = false;
opt.seriesACHNBA = true;
opt.seriesACHAVG = false;
opt.seriesGAACHAVG = false;

%%= To construct the experiment space for SCHAVG/ACHAVG series =====================
%These options were already considered before v1.2.0 but they were not
% available to the user
opt.blockBaseline=10;
opt.blockMaxRest=20;
opt.blockResampling=true;
opt.blockResamplingBaseline=15;
opt.blockResamplingTask=30;
opt.blockResamplingRest=20;


%%= To construct the experiment space for GA series =====================
%Block Splitting parameters
opt.seriesGA_BaselineSamples=15;
opt.seriesGA_RestSamples=-1;   
%Window Selection parameters
opt.seriesGA_wsOnset=-10; %i.e. 10 samples baseline
opt.seriesGA_wsDuration=40; %i.e. 20 samples into the task
opt.seriesGA_BreakDelay=0;
%Resample parameters
opt.seriesGA_resampleFlag=true;
opt.seriesGA_rsBaseline=10;   
opt.seriesGA_rsTask=20;
opt.seriesGA_rsRest=10;
%Normalization parameters
opt.seriesGA_normalizationFlag=false;
opt.seriesGA_nScope='blockIndividual'; %'BlockIndividual'
                                       %'Individual'
                                       %'Collective'
opt.seriesGA_nDimension='combined'; %'Channel'
                                   %'Signal'
                                   %'Combined'
opt.seriesGA_nMethod='normal'; %'Normal'
                               %'Range'
opt.seriesGA_nMean=0;    
opt.seriesGA_nVar=1;    
opt.seriesGA_nMin=-1;    
opt.seriesGA_nMax=1;
%%================================

opt.seriesTOPONBA = false;
opt.seriesTOPOAVG = false;
opt.seriesTOPO_taskOnly=true;
opt.seriesTOPO_baselineLength=5; %only valid if taskOnly is false.
opt.seriesTOPO_breakDelay=0;

%%== Options added for v1.2.0
opt.lineWidth=1.5; %Surprisingly, these were fixed.
opt.fontSize=8;
opt.channelPositioning = 'legacy';
opt.channelLabelling   = 'serial';


if exist('options','var')
    if isfield(options,'whichSubjects')
        opt.whichSubjects=options.whichSubjects;
    end
    if isfield(options,'whichSessions')
        opt.whichSessions=options.whichSessions;
    end
    if isfield(options,'whichDataSources')
        opt.whichDataSources=options.whichDataSources;
    end
    if isfield(options,'whichChannels')
        opt.whichChannels=options.whichChannels;
    end
    if isfield(options,'save')
        opt.save=options.save;
    end
    if isfield(options,'destinationFolder')
        opt.destinationFolder=options.destinationFolder;
    end
    if isfield(options,'fontSize')
        opt.fontSize=options.fontSize;
    end
    if isfield(options,'seriesSCHAVG')
        opt.seriesSCHAVG=options.seriesSCHAVG;
    end
    if isfield(options,'seriesSCHNBA')
        opt.seriesSCHNBA=options.seriesSCHNBA;
    end
    if isfield(options,'seriesACHNBA')
        opt.seriesACHNBA=options.seriesACHNBA;
    end
    if isfield(options,'seriesACHAVG')
        opt.seriesACHAVG=options.seriesACHAVG;
    end
    if isfield(options,'seriesGAACHAVG')
        opt.seriesGAACHAVG=options.seriesGAACHAVG;
    end
    if isfield(options,'seriesTOPONBA')
        opt.seriesTOPONBA=options.seriesTOPONBA;
    end
    if isfield(options,'seriesTOPOAVG')
        opt.seriesTOPOAVG=options.seriesTOPOAVG;
    end
    if isfield(options,'seriesTOPO_taskOnly')
        opt.seriesTOPO_taskOnly=options.seriesTOPO_taskOnly;
    end
    if isfield(options,'seriesTOPO_baselineLength')
        opt.seriesTOPO_baselineLength=options.seriesTOPO_baselineLength;
    end
    if isfield(options,'seriesTOPO_breakDelay')
        opt.seriesTOPO_breakDelay=options.seriesTOPO_breakDelay;
    end

    %From v1.2.0
    if isfield(options,'lineWidth')
        opt.lineWidth=options.lineWidth;
    end
    if isfield(options,'fontSize')
        opt.fontSize=options.fontSize;
    end
    if isfield(options,'channelPositioning')
        opt.channelPositioning=options.channelPositioning;
    end
    if isfield(options,'channelLabelling')
        opt.channelLabelling=options.channelLabelling;
    end

    if isfield(options,'blockBaseline')
        opt.blockBaseline=options.blockBaseline;
    end
    if isfield(options,'blockMaxRest')
        opt.blockMaxRest=options.blockMaxRest;
    end
    if isfield(options,'blockResampling')
        opt.blockResampling=options.blockResampling;
    end
    if isfield(options,'blockResamplingBaseline')
        opt.blockResamplingBaseline=options.blockResamplingBaseline;
    end
    if isfield(options,'blockResamplingTask')
        opt.blockResamplingTask=options.blockResamplingTask;
    end
    if isfield(options,'blockResamplingRest')
        opt.blockResamplingRest=options.blockResamplingRest;
    end




    %From v1.2.0; The following options were available from within the
    % code but not accesible from outside. From v1.2.0 they are now
    % made available. They remain undocumented (11-Sep-2023).
    if isfield(options,'seriesGA_BaselineSamples')
        opt.seriesGA_BaselineSamples=options.seriesGA_BaselineSamples;
    end
    if isfield(options,'seriesGA_RestSamples')
        opt.seriesGA_RestSamples=options.seriesGA_RestSamples;
    end
    
    if isfield(options,'seriesGA_wsOnset')
        opt.seriesGA_wsOnset=options.seriesGA_wsOnset;
    end
    if isfield(options,'seriesGA_wsDuration')
        opt.seriesGA_wsDuration=options.seriesGA_wsDuration;
    end
    if isfield(options,'seriesGA_BreakDelay')
        opt.seriesGA_BreakDelay=options.seriesGA_BreakDelay;
    end
    
    if isfield(options,'seriesGA_resampleFlag')
        opt.seriesGA_resampleFlag=options.seriesGA_resampleFlag;
    end
    if isfield(options,'seriesGA_rsBaseline')
        opt.seriesGA_rsBaseline=options.seriesGA_rsBaseline;
    end
    if isfield(options,'seriesGA_rsTask')
        opt.seriesGA_rsTask=options.seriesGA_rsTask;
    end
    if isfield(options,'seriesGA_rsRest')
        opt.seriesGA_rsRest=options.seriesGA_rsRest;
    end
    
    if isfield(options,'seriesGA_normalizationFlag')
        opt.seriesGA_normalizationFlag=options.seriesGA_normalizationFlag;
    end
    if isfield(options,'seriesGA_nScope')
        opt.seriesGA_nScope=options.seriesGA_nScope;
    end
    if isfield(options,'seriesGA_nDimension')
        opt.seriesGA_nDimension=options.seriesGA_nDimension;
    end
    if isfield(options,'seriesGA_nMethod')
        opt.seriesGA_nMethod=options.seriesGA_nMethod;
    end
    if isfield(options,'seriesGA_nMean')
        opt.seriesGA_nMean=options.seriesGA_nMean;
    end
    if isfield(options,'seriesGA_nVar')
        opt.seriesGA_nVar=options.seriesGA_nVar;
    end
    if isfield(options,'seriesGA_nMin')
        opt.seriesGA_nMin=options.seriesGA_nMin;
    end
    if isfield(options,'seriesGA_nMax')
        opt.seriesGA_nMax=options.seriesGA_nMax;
    end 




end

[I,F,COL]=unfoldExperiment(E);
%Filter
if ~isempty(opt.whichSubjects)
    idx = ismember(I(:,COL.SUBJECT),opt.whichSubjects);
    I = I(idx,:);
    F = F(idx);
else %if is empty, then choose all
    opt.whichSubjects = unique(I(:,COL.SUBJECT))';
end
if ~isempty(opt.whichSessions)
    idx = ismember(I(:,COL.SESSION),opt.whichSessions);
    I = I(idx,:);
    F = F(idx);
else %if is empty, then choose all
    opt.whichSessions = unique(I(:,COL.SESSION))';
end
if ~isempty(opt.whichDataSources)
    idx = ismember(I(:,COL.DATASOURCE),opt.whichDataSources);
    I = I(idx,:);
    F = F(idx);
else %if is empty, then choose all
    opt.whichDataSources = unique(I(:,COL.DATASOURCE))';
end
if ~isempty(opt.whichChannels)
    %No need to filter index matrix I but need to filter F
    %Note that this "assumes" all entries in F to share the same channels
    %and in the same order.
    nElem = length(F);
    for iElem = 1:nElem
        f = F{iElem};
        if isa(f,'structuredData')

            %Capture the original channel numbers before the filtering
            if ((isstring(opt.channelLabelling) || ischar(opt.channelLabelling)) ...
                && strcmpi(opt.channelLabelling,'fullSerial'))
                opt.channelLabelling = cell(0:1);
                for iCh = 1:f.nChannels
                    opt.channelLabelling(ch) = {num2str(ch)};
                end
            end



            %Filter the data
            f.data  = f.data(:,opt.whichChannels,:);
    
            %Filter the channelLocationMap
            tmpClm = channelLocationMap(f.chLocationMap.id);
            tmpClm.nChannels = numel(opt.whichChannels);
    
            tmpClm.description = f.chLocationMap.description;
            tmpClm.chLocations = f.chLocationMap.chLocations(opt.whichChannels,:);
            tmpClm.chOptodeArrays = f.chLocationMap.chOptodeArrays(opt.whichChannels,:);
            tmpClm.chStereotacticPositions = f.chLocationMap.chStereotacticPositions(opt.whichChannels,:);
            tmpClm.chProbeSets = f.chLocationMap.chProbeSets(opt.whichChannels,:);
            tmpClm.pairings = f.chLocationMap.pairings(opt.whichChannels,:);

            %Keep the optode information though
            tmpClm.optodeArrays = f.chLocationMap.optodeArrays;
            tmpClm.optodesTypes = f.chLocationMap.optodesTypes;
            tmpClm.nOptodes = f.chLocationMap.nOptodes;
            tmpClm.optodesLocations = f.chLocationMap.optodesLocations;
            tmpClm.optodesProbeSets = f.chLocationMap.optodesProbeSets;
            tmpClm.optodesOptodeArrays = f.chLocationMap.optodesOptodeArrays;
            
            

            f.chLocationMap = tmpClm;
            F(iElem) = {f};



    
        else
            warning('ICNNA:batchBasicVisualization',...
                    ['Ignoring observation ' num2str(iElem) '. Entry is not '...
                    'a structuredData. Channel hiding is not possible.'])
        end
    end
else %if is empty, then no need to filter F
    %Do nothing
end







%% Individual series

nElem = size(I,1);
for ee=1:nElem
    
    subjID = I(ee,COL.SUBJECT);
    sessID = I(ee,COL.SESSION);
    dataSourceID = I(ee,COL.DATASOURCE);
    sd=F{ee};
    t = sd.timeline;
    
    nChannels = sd.nChannels;
    integrity = sd.integrity;
    for ch=1:nChannels
        if isClean(integrity,ch)
            
            %Series SCHAVG
            if (opt.seriesSCHAVG)
                opt.blockAveraging=true;
                
                nConds = t.nConditions;
                for stim=1:nConds
                    opt.blockCondTag=getConditionTag(t,stim);
                    try
                        [h]=plotChannel(sd,ch,opt);
                            %This may crash for self pace tasks,
                            %or different length rests
                    catch
                        %%ONLY NECESSARY FOR SELF PACE TASKS
                        %%OR DIFFERENT LENGTH RESTS
                        if isfield(opt,'blockResampling')
                            tmp1 =opt.blockResampling;
                        else
                            tmp1=false;
                        end
                        opt.blockResampling=true;
                        opt.blockResamplingBaseline=15;
                        opt.blockResamplingTask=30;
                        opt.blockResamplingRest=20;
                        
                        [h]=plotChannel(sd,ch,opt);
                        opt.blockResampling=tmp1;
                    end
                    
                    title(['Subj=' num2str(subjID,'%04i') ...
                        '; Sess=' num2str(sessID,'%04i') ...
                        '; DS=' num2str(dataSourceID,'%04i') ...
                        '; Stim=' opt.blockCondTag ...
                        '; Ch=' getChannelLabel(ch,clm,opt)],...
                        'FontSize',opt.fontSize+2);
                    
                    if (opt.save)
                        outputFilename=[expName ...
                            '_SCHAVG_'...
                            'Subj' num2str(subjID,'%02i') ...
                            'Sess' num2str(sessID,'%02i') ...
                            'DS' num2str(dataSourceID,'%02i') ...
                            'Stim' opt.blockCondTag ...
                            'Ch' getChannelLabel(ch,clm,opt)];
                        mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                        close gcf
                    end
                end
            end %Series SCHAVG
            
            
            %Series SCHNBA
            if (opt.seriesSCHNBA)
                tmpopt.blockAveraging=false;
                [h]=plotChannel(sd,ch,tmpopt);
                title(['Subj= ' num2str(subjID,'%04i') ...
                    '; Sess= ' num2str(sessID,'%04i') ...
                    '; DS= ' num2str(dataSourceID,'%04i') ...
                    '; Ch=' getChannelLabel(ch,clm,opt)],...
                    'FontSize',opt.fontSize+2);
                
                if (opt.save)
                    outputFilename=[expName ...
                        '_SCHNBA_'...
                        'Subj' num2str(subjID,'%02i') ...
                        'Sess' num2str(sessID,'%02i') ...
                        'DS' num2str(dataSourceID,'%02i') ...
                        'Ch' getChannelLabel(ch,clm,opt)];
                    mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                    close gcf
                end
            end %Series SCHNBA
            
        end
    end
    
    %Series ACHNBA
    if (opt.seriesACHNBA)
        [h]=plotAllChannels(sd,opt); %Auxiliar function
%         axes(h(2));
%         title(['Subj= ' num2str(subjID,'%04i') ...
%             '; Sess= ' num2str(sessID,'%04i') ...
%             '; DS= ' num2str(dataSourceID,'%04i')]);
        [~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
            '; Sess= ' num2str(sessID,'%04i') ...
            '; DS= ' num2str(dataSourceID,'%04i')],'t');
        
        if (opt.save)
            outputFilename=[expName ...
                '_ACHNBA'...
                '_Subj' num2str(subjID,'%02i') ...
                '_Sess' num2str(sessID,'%02i') ...
                '_DS' num2str(dataSourceID,'%02i')];
            mySaveFig(gcf,[opt.destinationFolder outputFilename]);
            close gcf
        end
    end %Series ACHNBA
    
    %Series ACHAVG
    if (opt.seriesACHAVG)
        nConds = t.nConditions;
        for stim=1:nConds
            condTag=getConditionTag(t,stim);
            [h]=plotAllChannelsAvg(sd,condTag,opt); %Auxiliar function
%             axes(h(2));
%             title(['Subj= ' num2str(subjID,'%04i') ...
%                 '; Sess= ' num2str(sessID,'%04i') ...
%                 '; DS= ' num2str(dataSourceID,'%04i')...
%                 '; Stim= ' condTag]);
            [~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
                '; Sess= ' num2str(sessID,'%04i') ...
                '; DS= ' num2str(dataSourceID,'%04i')...
                '; Stim= ' condTag],'t');
            
            if (opt.save)
                outputFilename=[expName ...
                    '_ACHAVG'...
                    '_Subj' num2str(subjID,'%02i') ...
                    '_Sess' num2str(sessID,'%02i') ...
                    '_DS' num2str(dataSourceID,'%02i') ...
                    '_Stim' condTag];
                mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                close gcf
            end
        end
    end %Series ACHAVG

    %Series TOPONBA
    if (opt.seriesTOPONBA)
        nConds = t.nConditions;
        for stim=1:nConds
            condTag=getConditionTag(t,stim);
            nBlocks = getNEvents(t,condTag);
            optTopo.save = false;
            optTopo.taskOnly = opt.seriesTOPO_taskOnly;
            optTopo.baselineLength = opt.seriesTOPO_baselineLength;
            optTopo.breakDelay = opt.seriesTOPO_breakDelay;
            taskOnlyStr = ['Task-Baseline[' ...
                            num2str(optTopo.baselineLength) ...
                            ']'];
            if optTopo.taskOnly
                taskOnlyStr = 'TaskDataOnly';
            end
            
            for bb=1:nBlocks
                optTopo.whichBlocks=bb;
                [hOxy,hDeoxy,hTotal,hDiff]=plotTopo(sd,condTag,'nba',optTopo);
                
                %Oxy
                figure(hOxy(bb));
                %[~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
                %    '; Sess= ' num2str(sessID,'%04i') ...
                %    '; DS= ' num2str(dataSourceID,'%04i') ...
                %    '; Stim= ' condTag ...
                %    '; ' taskOnlyStr ...
                %    '; Break delay= ' num2str(optTopo.breakDelay)]);
                %For some reason suplabel doesn't want to work now
                %so replicate here what suplabel does.
                hSupAxis=findobj(hOxy(bb),'type','axes');
                    %The last one (i.e. the one at the top) is the
                    %one holding the suplabel
                title(hSupAxis(1),['HbO_2; Subj=' num2str(subjID,'%04i') ...
                    '; Sess=' num2str(sessID,'%04i') ...
                    '; DS=' num2str(dataSourceID,'%04i') ...
                    '; Stim=' condTag ...
                    '; Block=' num2str(bb,'%02i') ...
                    '; ' taskOnlyStr ...
                    '; Break delay=' num2str(optTopo.breakDelay)],...
                    'FontSize',opt.fontSize);
                
                if (opt.save)
                    outputFilename=[expName ...
                        '_TOPONBA'...
                        '_Subj' num2str(subjID,'%02i') ...
                        '_Sess' num2str(sessID,'%02i') ...
                        '_DS' num2str(dataSourceID,'%02i') ...
                        '_Stim' condTag ...
                        '_Block' num2str(bb,'%02i') ...
                        '_' taskOnlyStr ...
                        '_BrkDel' num2str(optTopo.breakDelay) ...
                        '_Oxy'];
                    mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                    close gcf
                end
                
                
                %Deoxy
                figure(hDeoxy(bb));
                %[~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
                %    '; Sess= ' num2str(sessID,'%04i') ...
                %    '; DS= ' num2str(dataSourceID,'%04i') ...
                %    '; Stim= ' condTag ...
                %    '; ' taskOnlyStr ...
                %    '; Break delay= ' num2str(optTopo.breakDelay)]);
                %For some reason suplabel doesn't want to work now
                %so replicate here what suplabel does.
                hSupAxis=findobj(hDeoxy(bb),'type','axes');
                    %The last one (i.e. the one at the top) is the
                    %one holding the suplabel
                title(hSupAxis(1),['HHb; Subj=' num2str(subjID,'%04i') ...
                    '; Sess=' num2str(sessID,'%04i') ...
                    '; DS=' num2str(dataSourceID,'%04i') ...
                    '; Stim=' condTag ...
                    '; Block=' num2str(bb,'%02i') ...
                    '; ' taskOnlyStr ...
                    '; Break delay=' num2str(optTopo.breakDelay)],...
                    'FontSize',opt.fontSize);
                
                if (opt.save)
                    outputFilename=[expName ...
                        '_TOPONBA'...
                        '_Subj' num2str(subjID,'%02i') ...
                        '_Sess' num2str(sessID,'%02i') ...
                        '_DS' num2str(dataSourceID,'%02i') ...
                        '_Stim' condTag ...
                        '_Block' num2str(bb,'%02i') ...
                        '_' taskOnlyStr ...
                        '_BrkDel' num2str(optTopo.breakDelay) ...
                        '_Deoxy'];
                    mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                    close gcf
                end
                
                %HbT
                figure(hTotal(bb));
                %[~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
                %    '; Sess= ' num2str(sessID,'%04i') ...
                %    '; DS= ' num2str(dataSourceID,'%04i') ...
                %    '; Stim= ' condTag ...
                %    '; ' taskOnlyStr ...
                %    '; Break delay= ' num2str(optTopo.breakDelay)]);
                %For some reason suplabel doesn't want to work now
                %so replicate here what suplabel does.
                hSupAxis=findobj(hTotal(bb),'type','axes');
                    %The last one (i.e. the one at the top) is the
                    %one holding the suplabel
                title(hSupAxis(1),['HbT; Subj=' num2str(subjID,'%04i') ...
                    '; Sess=' num2str(sessID,'%04i') ...
                    '; DS=' num2str(dataSourceID,'%04i') ...
                    '; Stim=' condTag ...
                    '; Block=' num2str(bb,'%02i') ...
                    '; ' taskOnlyStr ...
                    '; Break delay=' num2str(optTopo.breakDelay)],...
                    'FontSize',opt.fontSize);
                
                if (opt.save)
                    outputFilename=[expName ...
                        '_TOPONBA'...
                        '_Subj' num2str(subjID,'%02i') ...
                        '_Sess' num2str(sessID,'%02i') ...
                        '_DS' num2str(dataSourceID,'%02i') ...
                        '_Stim' condTag ...
                        '_Block' num2str(bb,'%02i') ...
                        '_' taskOnlyStr ...
                        '_BrkDel' num2str(optTopo.breakDelay) ...
                        '_HbT'];
                    mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                    close gcf
                end
                
                %HbDiff
                figure(hDiff(bb));
                %[~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
                %    '; Sess= ' num2str(sessID,'%04i') ...
                %    '; DS= ' num2str(dataSourceID,'%04i') ...
                %    '; Stim= ' condTag ...
                %    '; ' taskOnlyStr ...
                %    '; Break delay= ' num2str(optTopo.breakDelay)]);
                %For some reason suplabel doesn't want to work now
                %so replicate here what suplabel does.
                hSupAxis=findobj(hDiff(bb),'type','axes');
                    %The last one (i.e. the one at the top) is the
                    %one holding the suplabel
                title(hSupAxis(1),['HbDiff; Subj=' num2str(subjID,'%04i') ...
                    '; Sess=' num2str(sessID,'%04i') ...
                    '; DS=' num2str(dataSourceID,'%04i') ...
                    '; Stim=' condTag ...
                    '; Block=' num2str(bb,'%02i') ...
                    '; ' taskOnlyStr ...
                    '; Break delay=' num2str(optTopo.breakDelay)],...
                    'FontSize',opt.fontSize);
                
                if (opt.save)
                    outputFilename=[expName ...
                        '_TOPONBA'...
                        '_Subj' num2str(subjID,'%02i') ...
                        '_Sess' num2str(sessID,'%02i') ...
                        '_DS' num2str(dataSourceID,'%02i') ...
                        '_Stim' condTag ...
                        '_Block' num2str(bb,'%02i') ...
                        '_' taskOnlyStr ...
                        '_BrkDel' num2str(optTopo.breakDelay) ...
                        '_HbDiff'];
                    mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                    close gcf
                end
            end
            
        end
    end %Series TOPONBA
    clear optTopo


    %Series TOPOAVG
    if (opt.seriesTOPOAVG)
        nConds = t.nConditions;;
        for stim=1:nConds
            condTag=getConditionTag(t,stim);
            optTopo.save = false;
            optTopo.taskOnly = opt.seriesTOPO_taskOnly;
            optTopo.baselineLength = opt.seriesTOPO_baselineLength;
            optTopo.breakDelay = opt.seriesTOPO_breakDelay;
            [hOxy,hDeoxy,hTotal,hDiff]=plotTopo(sd,condTag,'avg');
            
            taskOnlyStr = ['Task-Baseline[' ...
                            num2str(optTopo.baselineLength) ...
                            ']'];
            if optTopo.taskOnly
                taskOnlyStr = 'TaskDataOnly';
            end
            %Oxy
            figure(hOxy);
            %[~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
            %    '; Sess= ' num2str(sessID,'%04i') ...
            %    '; DS= ' num2str(dataSourceID,'%04i')...
            %    '; Stim= ' condTag ...
            %    '; ' taskOnlyStr ...
            %    '; Break delay= ' num2str(optTopo.breakDelay)]);
            %For some reason suplabel doesn't want to work now
            %so replicate here what suplabel does.
            hSupAxis=findobj(hOxy,'type','axes');
            %The last one (i.e. the one at the top) is the
            %one holding the suplabel
            title(hSupAxis(1),['HbO_2; Subj=' num2str(subjID,'%04i') ...
                '; Sess=' num2str(sessID,'%04i') ...
                '; DS=' num2str(dataSourceID,'%04i')...
                '; Stim=' condTag ...
                '; Block=AVG' ...
                '; ' taskOnlyStr ...
                '; Break delay=' num2str(optTopo.breakDelay)],...
                'FontSize',opt.fontSize);
            
            if (opt.save)
                outputFilename=[expName ...
                    '_TOPOAVG'...
                    '_Subj' num2str(subjID,'%02i') ...
                    '_Sess' num2str(sessID,'%02i') ...
                    '_DS' num2str(dataSourceID,'%02i') ...
                    '_Stim' condTag ...
                    '_' taskOnlyStr ...
                    '_BrkDel' num2str(optTopo.breakDelay) ...
                    '_Oxy'];
                mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                close gcf
            end
            
            
            %Deoxy
            figure(hDeoxy);
            %[~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
            %    '; Sess= ' num2str(sessID,'%04i') ...
            %    '; DS= ' num2str(dataSourceID,'%04i')...
            %    '; Stim= ' condTag ...
            %    '; ' taskOnlyStr ...
            %    '; Break delay= ' num2str(optTopo.breakDelay)]);
            hSupAxis=findobj(hDeoxy,'type','axes');
            %The last one (i.e. the one at the top) is the
            %one holding the suplabel
            title(hSupAxis(1),['HHb; Subj=' num2str(subjID,'%04i') ...
                '; Sess=' num2str(sessID,'%04i') ...
                '; DS=' num2str(dataSourceID,'%04i')...
                '; Stim=' condTag ...
                '; Block=AVG' ...
                '; ' taskOnlyStr ...
                '; Break delay=' num2str(optTopo.breakDelay)],...
                'FontSize',opt.fontSize);
            
            if (opt.save)
                outputFilename=[expName ...
                    '_TOPOAVG'...
                    '_Subj' num2str(subjID,'%02i') ...
                    '_Sess' num2str(sessID,'%02i') ...
                    '_DS' num2str(dataSourceID,'%02i') ...
                    '_Stim' condTag ...
                    '_' taskOnlyStr ...
                    '_BrkDel' num2str(optTopo.breakDelay) ...
                    '_Deoxy'];
                mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                close gcf
            end
            
            %HbT
            figure(hTotal);
            %[~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
            %    '; Sess= ' num2str(sessID,'%04i') ...
            %    '; DS= ' num2str(dataSourceID,'%04i')...
            %    '; Stim= ' condTag ...
            %    '; ' taskOnlyStr ...
            %    '; Break delay= ' num2str(optTopo.breakDelay)]);
            hSupAxis=findobj(hTotal,'type','axes');
            %The last one (i.e. the one at the top) is the
            %one holding the suplabel
            title(hSupAxis(1),['HbT; Subj=' num2str(subjID,'%04i') ...
                '; Sess=' num2str(sessID,'%04i') ...
                '; DS=' num2str(dataSourceID,'%04i')...
                '; Stim=' condTag ...
                '; Block=AVG' ...
                '; ' taskOnlyStr ...
                '; Break delay=' num2str(optTopo.breakDelay)],...
                'FontSize',opt.fontSize);
            
            if (opt.save)
                outputFilename=[expName ...
                    '_TOPOAVG'...
                    '_Subj' num2str(subjID,'%02i') ...
                    '_Sess' num2str(sessID,'%02i') ...
                    '_DS' num2str(dataSourceID,'%02i') ...
                    '_Stim' condTag ...
                    '_' taskOnlyStr ...
                    '_BrkDel' num2str(optTopo.breakDelay) ...
                    '_HbT'];
                mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                close gcf
            end
            
            %HbDiff
            figure(hDiff);
            %[~,h3]=suplabel(['Subj= ' num2str(subjID,'%04i') ...
            %    '; Sess= ' num2str(sessID,'%04i') ...
            %    '; DS= ' num2str(dataSourceID,'%04i')...
            %    '; Stim= ' condTag ...
            %    '; ' taskOnlyStr ...
            %    '; Break delay= ' num2str(optTopo.breakDelay)]);
            hSupAxis=findobj(hDiff,'type','axes');
            %The last one (i.e. the one at the top) is the
            %one holding the suplabel
            title(hSupAxis(1),['HbDiff; Subj=' num2str(subjID,'%04i') ...
                '; Sess=' num2str(sessID,'%04i') ...
                '; DS=' num2str(dataSourceID,'%04i')...
                '; Stim=' condTag ...
                '; Block=AVG' ...
                '; ' taskOnlyStr ...
                '; Break delay=' num2str(optTopo.breakDelay)],...
                'FontSize',opt.fontSize);
            
            if (opt.save)
                outputFilename=[expName ...
                    '_TOPOAVG'...
                    '_Subj' num2str(subjID,'%02i') ...
                    '_Sess' num2str(sessID,'%02i') ...
                    '_DS' num2str(dataSourceID,'%02i') ...
                    '_Stim' condTag ...
                    '_' taskOnlyStr ...
                    '_BrkDel' num2str(optTopo.breakDelay) ...
                    '_HbDiff'];
                mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                close gcf
            end
            
        end
    end %Series TOPOAVG


end %for elements 




%% Grand average series
%Across all selected subjects, sessions and dataSources
%
%+ Currently assumes that all elements share the probe mode,
%and number of channels.
%+ Averaging is made after resampling (compulsory and currently
% defaulted to [10 20 10]) across elements on a
%sample by sample basis over clean data without taking into
%consideration the timeline. This is specially relevant for
%self pace tasks.
%+ The timeline of the first element of the set is used
%to establish the condition/stimulus tags.
%

%Series GAACHAVG
if (opt.seriesGAACHAVG)


%Note that the experiment unfolding is insufficient here as it will
%lead to a two stage averaging (first, one across subject, and then
%one across blocks), thus resulting in incorrect standard deviations
%which will only reflects the deviation across the second averaging.
%
%In this sense, I need either to split each recording into its
%blocks before averaging across subjects and blocks in a single
%step, or to get a full experimentSpace.
%
%Moreover the plotAllChannelsAvg will no longer be suitable, so
%I need to plot the Std by hand.
%

s=experimentSpace;
%Block Splitting parameters
s.baselineSamples = opt.seriesGA_BaselineSamples;
s.restSamples     = opt.seriesGA_RestSamples;   
%Window Selection parameters
s.ws_onset      = opt.seriesGA_wsOnset;
s.ws_duration   = opt.seriesGA_wsDuration;
s.ws_breakDelay = opt.seriesGA_BreakDelay;
%Resample parameters
s.resampled = opt.seriesGA_resampleFlag;
s.rs_baseline = opt.seriesGA_rsBaseline;   
s.rs_task = opt.seriesGA_rsTask;
s.rs_rest = opt.seriesGA_rsRest;
%Average parameters 
s.averaged = false; %I do not want the experimentSpace to average
                           %otherwise I will be still in a double stage
                           %averaging situation
%Normalization parameters
s.normalized = opt.seriesGA_normalizationFlag;
s.normalizationScope = opt.seriesGA_nScope; %'BlockIndividual'
                                                   %'Individual'
                                                   %'Collective'
s.normalizationDimension = opt.seriesGA_nDimension; %'Channel'
                                                   %'Signal'
                                                   %'Combined'
s.normalizationMethod = opt.seriesGA_nMethod; %'Normal'
                                                   %'Range'
s.normalizationMean = opt.seriesGA_nMean;    
s.normalizationVar  = opt.seriesGA_nVar;    
s.normalizationMin  = opt.seriesGA_nMin;    
s.normalizationMax  = opt.seriesGA_nMax;    

%Now compute
s=compute(s,E);


%Filter the subset of interest
subsetDefinition{1}.dimension = experimentSpace.DIM_SUBJECT;
subsetDefinition{1}.values = opt.whichSubjects;
subsetDefinition{2}.dimension = experimentSpace.DIM_SESSION;
subsetDefinition{2}.values = opt.whichSessions;
subsetDefinition{3}.dimension = experimentSpace.DIM_DATASOURCE;
subsetDefinition{3}.values = opt.whichDataSources;
subsetDefinition{3}.dimension = experimentSpace.DIM_CHANNEL;
subsetDefinition{3}.values = opt.whichChannels;
[I2,Fvectors]=s.getSubset(subsetDefinition);




% if ~isempty(opt.whichChannels)
%     %No need to filter index matrix I but need to filter F
%     %Note that this "assumes" all entries in F to share the same channels
%     %and in the same order.
%     nElem = length(Fvectors);
%     for iElem = 1:nElem
%         f = Fvectors{iElem};
%         if isa(f,'structuredData')
% 
%             %Capture the original channel numbers before the filtering
%             if ((isstring(opt.channelLabelling) || ischar(opt.channelLabelling)) ...
%                 && strcmpi(opt.channelLabelling,'fullSerial'))
%                 opt.channelLabelling = cell(0:1);
%                 for iCh = 1:f.nChannels
%                     opt.channelLabelling(ch) = {num2str(ch)};
%                 end
%             end
% 
% 
% 
%             %Filter the data
%             f.data  = f.data(:,opt.whichChannels,:);
% 
%             %Filter the channelLocationMap
%             tmpClm = channelLocationMap(f.chLocationMap.id);
%             tmpClm.nChannels = numel(opt.whichChannels);
% 
%             tmpClm.description = f.chLocationMap.description;
%             tmpClm.chLocations = f.chLocationMap.chLocations(opt.whichChannels,:);
%             tmpClm.chOptodeArrays = f.chLocationMap.chOptodeArrays(opt.whichChannels,:);
%             tmpClm.chStereotacticPositions = f.chLocationMap.chStereotacticPositions(opt.whichChannels,:);
%             tmpClm.chProbeSets = f.chLocationMap.chProbeSets(opt.whichChannels,:);
%             tmpClm.pairings = f.chLocationMap.pairings(opt.whichChannels,:);
% 
%             %Keep the optode information though
%             tmpClm.optodeArrays = f.chLocationMap.optodeArrays;
%             tmpClm.optodesTypes = f.chLocationMap.optodesTypes;
%             tmpClm.nOptodes = f.chLocationMap.nOptodes;
%             tmpClm.optodesLocations = f.chLocationMap.optodesLocations;
%             tmpClm.optodesProbeSets = f.chLocationMap.optodesProbeSets;
%             tmpClm.optodesOptodeArrays = f.chLocationMap.optodesOptodeArrays;
% 
% 
% 
%             f.chLocationMap = tmpClm;
%             Fvectors(iElem) = {f};
% 
% 
% 
% 
%         else
%             warning('ICNNA:batchBasicVisualization',...
%                     ['Ignoring observation ' num2str(iElem) '. Entry is not '...
%                     'a structuredData. Channel hiding is not possible.'])
%         end
%     end
% else %if is empty, then no need to filter F
%     %Do nothing
% end









%Get probe mode from first item
tmpSubjId = I2(1,experimentSpace.DIM_SUBJECT);
tmpSessId = I2(1,experimentSpace.DIM_SESSION);
tmpDsId = I2(1,experimentSpace.DIM_DATASOURCE);
ee = find(I(:,COL.SUBJECT) == tmpSubjId ...
               & I(:,COL.SESSION) == tmpSessId ...
               & I(:,COL.DATASOURCE) == tmpDsId);
sd = F{ee};
%sd = Fvectors{ee};
clm = sd.chLocationMap;
t  = sd.timeline; %Currently I am counting on this one
                        %to contain all stimulus
                        %so I can retrieve all condition tags

%I need to produce a figure per stimulus
stimulus=unique(I2(:,experimentSpace.DIM_STIMULUS))';
nChannels=max(I2(:,experimentSpace.DIM_CHANNEL))';

% opt.lineWidth=1.5;
% opt.fontSize=8;
for st=stimulus
    condTag=getConditionTag(t,st);
    
    figure('Units','normalized','Position',[0.05,0.05,0.85,0.85]);

    for ch=1:nChannels
        idxOxy = find(I2(:,experimentSpace.DIM_STIMULUS)==st...
            & I2(:,experimentSpace.DIM_CHANNEL)==ch...
            & I2(:,experimentSpace.DIM_SIGNAL)==nirs_neuroimage.OXY);
        idxDeoxy = find(I2(:,experimentSpace.DIM_STIMULUS)==st...
            & I2(:,experimentSpace.DIM_CHANNEL)==ch...
            & I2(:,experimentSpace.DIM_SIGNAL)==nirs_neuroimage.DEOXY);
        chData_oxy = cell2mat(Fvectors(idxOxy));
        chData_deoxy = cell2mat(Fvectors(idxDeoxy));
        %chData_totalHb = chData_oxy+chData_deoxy;
        %chData_Hbdiff = chData_oxy-chData_deoxy;
        
        chData_oxy_mean=mean(chData_oxy,2);
        chData_oxy_std=std(chData_oxy,0,2);
        chData_deoxy_mean=mean(chData_deoxy,2);
        chData_deoxy_std=std(chData_deoxy,0,2);
        
        %plot channel
        nSamples = length(chData_oxy_mean);
        %location=getLocation(ch,get(sd,'ProbeMode')); %DEPRECATED CODE
        location=getAxesPosition(ch,clm,opt.channelPositioning);
        
        h(ch)=axes('OuterPosition',location);
        %     line('XData',1:nSamples,...
        %          'YData',channelData(:,1)+channelData(:,2),'Color','g',...
        %             'LineStyle','--','LineWidth',opt.lineWidth);
        %     line('XData',1:nSamples,...
        %          'YData',channelData(:,1)-channelData(:,2),'Color','m',...
        %             'LineStyle','--','LineWidth',opt.lineWidth);
        
        %Oxy
        if (any(imag(chData_oxy_mean)))
            %plot what has been collected
            line('XData',real(chData_oxy_mean),...
                'YData',imag(chData_oxy_mean),'Color','r',...
                'LineStyle','-','LineWidth',opt.lineWidth);
            %...and only the real part of it
            line('XData',1:nSamples,...
                'YData',real(chData_oxy_mean),'Color','y',...
                'LineStyle','-','LineWidth',opt.lineWidth);
        else
            line('XData',1:nSamples,...
                'YData',chData_oxy_mean,'Color','r',...
                'LineStyle','-','LineWidth',opt.lineWidth);
        end
        %Display Oxy Std
        X=[1:nSamples nSamples:-1:1]';
        tmp=chData_oxy_mean-chData_oxy_std;
        Y=[chData_oxy_mean+chData_oxy_std; ...
            tmp(end:-1:1)];
        patch(X,Y,'r','EdgeColor','none','FaceAlpha',0.2)
        
        %Deoxy
        if (any(imag(chData_deoxy_mean)))
            %plot what has been collected
            line('XData',real(chData_deoxy_mean),...
                'YData',imag(chData_deoxy_mean),'Color','b',...
                'LineStyle','-','LineWidth',opt.lineWidth);
            %...and only the real part of it
            line('XData',1:nSamples,...
                'YData',real(chData_deoxy_mean),'Color','m',...
                'LineStyle','-','LineWidth',opt.lineWidth);
        else
            line('XData',1:nSamples,...
                'YData',chData_deoxy_mean,'Color','b',...
                'LineStyle','-','LineWidth',opt.lineWidth);
        end
        %Display Deoxy Std
        X=[1:nSamples nSamples:-1:1]';
        tmp=chData_deoxy_mean-chData_deoxy_std;
        Y=[chData_deoxy_mean+chData_deoxy_std; ...
            tmp(end:-1:1)];
        patch(X,Y,'b','EdgeColor','none','FaceAlpha',0.2)
        
        set(gca,'XTick',[]);
        box on, grid on
        %%Shade the "Timeline"
        %%Shade the regions of stimulus
        
        %onset = -get(s,'WS_Onset') + get(s,'WS_BreakDelay');
        %endingMark = get(s,'WS_Duration');
        %onset = -get(s,'WS_Onset') + get(s,'WS_BreakDelay');
        onset = -s.ws_onset;
        endingMark = onset + s.ws_duration;
        getY=axis;
        limits=[getY(3) getY(4) getY(4) getY(3)];
        tmph=patch([onset onset ...
            endingMark endingMark],...
            limits,0.1,...
            'EdgeColor','none',...
            'FaceAlpha',0.3,...
            'FaceColor','flat');
        set(tmph,'FaceColor','g');
        
        %Throw a vertical line on the break Delay if necessary
        xBreakDelay = -s.ws_onset + s.ws_breakDelay;
        if (s.ws_breakDelay ~= 0)
            line('XData',[xBreakDelay xBreakDelay],...
                'YData',[getY(3) getY(4)],...
                'LineStyle','--','LineWidth',opt.lineWidth,...
                'Color','k')
        end
        
        if ~(isnan(nSamples) || nSamples == 0)
            set(gca,'XLim',[1 nSamples]);
        end
        
        ylim=axis;
        hText=text(0.85*ylim(2),0.85*ylim(4),getChannelLabel(ch,clm,opt));
        set(hText,'FontSize',opt.fontSize,...
            'FontWeight','bold',...
            'BackgroundColor','y');
        
    end
    
    
    
    if length(opt.whichSubjects)==1
        subjectsStr = ['[' num2str(opt.whichSubjects(1),'%d') ']'];
    else
        subjectsStr = ['[' num2str(opt.whichSubjects(1),'%d') ...
            num2str(opt.whichSubjects(2:end),',%d') ']'];
    end
    if length(opt.whichSessions)==1
        sessionsStr = ['[' num2str(opt.whichSessions(1),'%d') ']'];
    else
        sessionsStr = ['[' num2str(opt.whichSessions(1),'%d') ...
            num2str(opt.whichSessions(2:end),',%d') ']'];
    end
    if length(opt.whichDataSources)==1
        dataSourcesStr = ['[' num2str(opt.whichDataSources(1),'%d') ']'];
    else
        dataSourcesStr = ['[' num2str(opt.whichDataSources(1),'%d') ...
            num2str(opt.whichDataSources(2:end),',%d') ']'];
    end
    [~,h3]=suplabel(['Subj= ' subjectsStr ...
        '; Sess= ' sessionsStr ...
        '; DS= ' dataSourcesStr ...
        '; Stim= ' condTag],'t');
    %set(h3,'VerticalAlignment','bottom')
    
    if (opt.save)
        subjectsStr = ['[' num2str(opt.whichSubjects(1),'%d') ...
            num2str(opt.whichSubjects(2:end),'_%d') ']'];
        sessionsStr = ['[' num2str(opt.whichSessions(1),'%d') ...
            num2str(opt.whichSessions(2:end),'_%d') ']'];
        dataSourcesStr = ['[' num2str(opt.whichDataSources(1),'%d') ...
            num2str(opt.whichDataSources(2:end),'_%d') ']'];
        outputFilename=[expName ...
            '_GAACHAVG'...
            '_Subj' subjectsStr ...
            '_Sess' sessionsStr ...
            '_DS' dataSourcesStr ...
            '_Stim' condTag];
        mySaveFig(gcf,[opt.destinationFolder outputFilename]);
        close gcf
    end
end



end %if opt.seriesGAACHAVG

end



%% AUXILIAR FUNCTION
function [h]=plotAllChannels(sd,opt)
%Plots all channels at the same time
%
% sd - A NIRS_neuroimage data
%

clm = sd.chLocationMap;
    
figure('Units','normalized','Position',[0.05,0.05,0.85,0.85]);

if ~exist('opt','var')
    opt.lineWidth=1.5;
    opt.fontSize=8;
    opt.channelPositioning = 'legacy';
end




nChannels = sd.nChannels;
for ch=1:nChannels
    channelData=getChannel(sd,ch);
    nSamples=size(channelData,1);
    
    %location=getLocation(ch,get(sd,'ProbeMode')); %DEPRECATED CODE
    location=getAxesPosition(ch,clm,opt.channelPositioning);
    h(ch)=axes('OuterPosition',location);
%     line('XData',1:nSamples,...
%          'YData',channelData(:,1)+channelData(:,2),'Color','g',...
%             'LineStyle','--','LineWidth',opt.lineWidth);
%     line('XData',1:nSamples,...
%          'YData',channelData(:,1)-channelData(:,2),'Color','m',...
%             'LineStyle','--','LineWidth',opt.lineWidth);

    %Oxy
    if (any(imag(channelData(:,1))))
        %plot what has been collected
        line('XData',real(channelData(:,1)),...
            'YData',imag(channelData(:,1)),'Color','r',...
            'LineStyle','-','LineWidth',opt.lineWidth);
        %...and only the real part of it
        line('XData',1:nSamples,...
            'YData',real(channelData(:,1)),'Color','y',...
            'LineStyle','-','LineWidth',opt.lineWidth);
    else
        line('XData',1:nSamples,...
            'YData',channelData(:,1),'Color','r',...
            'LineStyle','-','LineWidth',opt.lineWidth);
    end
    %Deoxy
    if (any(imag(channelData(:,2))))
        %plot what has been collected
        line('XData',real(channelData(:,2)),...
            'YData',imag(channelData(:,2)),'Color','b',...
            'LineStyle','-','LineWidth',opt.lineWidth);
        %...and only the real part of it
        line('XData',1:nSamples,...
            'YData',real(channelData(:,2)),'Color','m',...
            'LineStyle','-','LineWidth',opt.lineWidth);
    else
        line('XData',1:nSamples,...
            'YData',channelData(:,2),'Color','b',...
            'LineStyle','-','LineWidth',opt.lineWidth);
    end
    
    
    set(gca,'XTick',[]);
    box on, grid on
    %%Plot the Timeline
    %%Shade the regions of stimulus
    %%%IMPORTANT NOTE: If I try to first paint stimulus regions and
    %%%later the signal, at the moment will not work...
    shadeTimeline(gca, sd.timeline);
    set(gca,'XLim',[1 nSamples]);
    
    
    ylim=axis;
    hText=text(0.85*ylim(2),0.85*ylim(4),getChannelLabel(ch,clm,opt));
    set(hText,'FontSize',opt.fontSize,...
            'FontWeight','bold',...
            'BackgroundColor','y');
end
end


function [h]=plotAllChannelsAvg(sd,condTag,opt)
%Plots all channels at the same time (block averaged).
%
% sd - A NIRS_neuroimage data
%
% condTag - A stimulus to average across
%

clm = sd.chLocationMap;

figure('Units','normalized','Position',[0.05,0.05,0.85,0.85]);

if ~exist('opt','var')
    opt.lineWidth=1.5;
    opt.fontSize=8;
    opt.channelPositioning = 'legacy';
end

nChannels =  sd.nChannels;

%integrity= sd.integrity;
for ch=1:nChannels
%    if isClean(integrity,ch)
        location=getAxesPosition(ch,clm,opt.channelPositioning);
        h(ch)=axes('OuterPosition',location);
        opt.axesHandle=h(ch);
        opt.blockAveraging=true;
        opt.blockCondTag=condTag;
        % opt.blockBaseline=10;
        % opt.blockMaxRest=20;
        % opt.blockResampling=true;
        % opt.blockResamplingBaseline=15;
        % opt.blockResamplingTask=30;
        % opt.blockResamplingRest=20;
        opt.displayLegend = false;
        plotChannel(sd,ch,opt);
        nSamples=sum([opt.blockResamplingBaseline ...
                        opt.blockResamplingTask ...
                        opt.blockResamplingRest]);
    
        set(gca,'XTick',[]);
%        set(gca,'XLim',[1 nSamples]);
        xlabel([]);
        ylabel([]);
        title([]);
        
        
        ylim=axis;
        hText=text(0.85*ylim(2),0.85*ylim(4),getChannelLabel(ch,clm,opt));
        set(hText,'FontSize',opt.fontSize,...
            'FontWeight','bold',...
            'BackgroundColor','y');
%    end
end
end


function pos=getAxesPosition(ch,clm,positioning)
%Return an (outer) position vector to place the channel axes
%
% The distribution of channel axes will allocate room within the
%figure for every channel in the dataset.
%
% ch - Channel number
% clm - A channelLocationMap
% positioning - (Optional) String. A strategy to choose the positioning
%       of the channels. This option was added for ICNNA version
%       1.2.0 (27-Aug-2023). The possible values are:
%       'legacy' - (Default) Matches ICCNA's previous strategy for backward
%           compatibility. The axes position depends on the channel topological
%           arragement within the optode array, but also on the number of
%           optode arrays in the channelLocationMap. Also channels not
%           associated to a particular optode array will be assigned a
%           default position as if they were in a separate optode array.
%       'use2DChannellocations' - Added for v1.2.0
%           As it says on the tin, this option will use the channel
%           locations in the property clm.chLocations (ignoring the 3rd
%           dimension.
%       


if ~exist('positioning','var')
    positioning = 'legacy';
end


switch(lower(positioning))
    case 'legacy'
        oas = getChannelOptodeArrays(clm);
        if any(isnan(oas))
            oaList = unique(oas(~isnan(oas)));
            oaList = [oaList NaN]; %count NaNs only once as if equal
        else
            oaList = unique(oas);
        end
        nOptodeArrays = length(oaList);
        
        %Decide the best arrangement (meta-subplots)
        switch nOptodeArrays
            case 0
                pos=[0 0 1 1];
                return;
            case 1
                nRows=1;
                nCols=1;
            case 2
                nRows=1;
                nCols=2;
            case 3
                nRows=1;
                nCols=3;
            case 4
                nRows=2;
                nCols=2;
            case 5
                nRows=2;
                nCols=3;
            case 6
                nRows=2;
                nCols=3;
            otherwise
                nRows = 3; %For no particular reason
                nCols = ceil(nOptodeArrays/nRows);
        end
        
        %Find the optode array to which this channel is associated,
        %and retrieve its info
        oa = oas(ch); %This channel optode array
        oaChannels = find(oas==oa); %All channels in this optode array
        
        %Calculate this channel's optode array meta-subplot offset
        row = ceil(oa/nCols);
        col = oa-((row-1)*nCols);
        oa_HorzOffset = (col-1)*(1/nCols); %from left to right
        oa_VertOffset = (nRows-row)*(1/nRows); %from top to bottom
        
        
        if isnan(oa)
            %Arrange the "nan" optode array vertically from top to bottom
            idx=find(isnan(oas));
            tmpAbstractArrangement = find(ismember(idx,ch)); %Get a default location
            %and translate this location to an axes position
                nChannelsInTheSameArray = length(idx);
            left = oa_HorzOffset + 0;
            bottom = oa_VertOffset + ...
                        (nChannelsInTheSameArray-tmpAbstractArrangement)...
                            *(1/nChannelsInTheSameArray);
            width  = 1/nCols;
            height  = (1/nRows)*(1/nChannelsInTheSameArray);
        else
            oaInfo = getOptodeArraysInfo(clm,oa);
            %mode = oaInfo.mode;
            %Normalize the abstract topological arragement
            tmp=repmat(min(oaInfo.chTopoArrangement),size(oaInfo.chTopoArrangement,1),1);
            oaInfo.chTopoArrangement = oaInfo.chTopoArrangement+(tmp*-1);
            tmp=repmat(max(oaInfo.chTopoArrangement),size(oaInfo.chTopoArrangement,1),1);
            oaInfo.chTopoArrangement = oaInfo.chTopoArrangement./tmp;
            oaInfo.chTopoArrangement(isnan(oaInfo.chTopoArrangement))=0;
            %A NaN may occur if any(tmp==0) or if any location in the
            %topoArrangement was already NaN
            
            %Find out the maximum room that an axes can take
            rtmp = pdist(oaInfo.chTopoArrangement);
            rtmp(rtmp<0.2) = []; %Ignore short channels. Note that distances are normalized
                %Note that this is conservative
            r=min(rtmp);
                %In the presence of short channels, the original formula;
                % 
                % r=min(pdist(oaInfo.chTopoArrangement))
                %
                % yield a tiny values. Hence the correction above to ignore
                % the short channels.
        
        
            %...and correct the topological arrangement to accout for this needed
            %space (in all dimensions)
            tmp=repmat(max(oaInfo.chTopoArrangement+r),size(oaInfo.chTopoArrangement,1),1);
            oaInfo.chTopoArrangement = oaInfo.chTopoArrangement./tmp;
        
            %Finally, get the abstract location...
            thisChannelIdxWithinTheOptodeArray = find(ismember(oaChannels,ch));
            tmpAbstractArrangement = ...
                oaInfo.chTopoArrangement(thisChannelIdxWithinTheOptodeArray,:);
            %and translate this location to an axes position
            left   = oa_HorzOffset + tmpAbstractArrangement(1)*(1/nCols);
            bottom = oa_VertOffset + tmpAbstractArrangement(2)*(1/nRows);
            width  = r/(2*tmp(1,1));
            height = r/(2*tmp(1,2));
                
        end
    case 'use2dchannellocation'

        tmpLocations  = clm.chLocations - min(clm.chLocations);
        montageWidth  = max(tmpLocations(:,1));
        montageHeight = max(tmpLocations(:,2));
        
        width  = 1/(clm.nChannels^(3/4));
        height = 1/(clm.nChannels^(3/4));
        w_offset = 0;
        if width<0.1; w_offset = 0.05; end
        h_offset = 0;
        if height<0.1; h_offset = 0.05; end
        left   = 0.8*(tmpLocations(ch,1)/(montageWidth))+w_offset;
        bottom = 0.8*(tmpLocations(ch,2)/(montageHeight))+h_offset;

        

    otherwise
        warning('ICNNA:batchBasicVisuzalization:getAxesPosition:InvalidPositioning',...
                ['Positioning ' positioning ' not recognized. Reattempting using ' ...
                'the default option.'])
        pos=getAxesPosition(ch,clm,'legacy');
        left   = pos(1);
        bottom = pos(2);
        width  = pos(3);
        height = pos(4);
end


pos = [left bottom width height];


end







function chLabel = getChannelLabel(ch,clm,opt)
% Decide the format of the channel label based on the option
%channelLabelling

%NOTE: The case 'fullSerial' is captured outside this function before
%the channel filtering. By the time it gets to this function, the
%option channelLabelling would be already set to a cell array.


if iscell(opt.channelLabelling)
    if (ch<1 || ch>numel(opt.channelLabelling))
        error('ICNNA:batchBasicVisuzalization:getChannelLabel:InvalidChannelNumber',...
              ['Channel ' num2str(ch) ' not found.']);
    end
    chLabel = opt.channelLabelling{ch};
elseif (isstring(opt.channelLabelling) || ischar(opt.channelLabelling))

    switch (lower(opt.channelLabelling))
        case 'serial'
            %Prepare the channel labels
            chLabel = num2str(ch);

        case 'srcdet'
            %Prepare the channel labels
            nSources = sum(clm.optodesTypes == 1);
            chLabel = ['S' num2str(clm.pairings(ch,1)) '-D' num2str(clm.pairings(ch,2)-nSources)];

        otherwise
            error('ICNNA:batchBasicVisuzalization:getChannelLabel:InvalidLabelling',...
                  ['Option channelLabelling value must be ''serial'', ' ...
                  '''fullSerial'' or ''srcdet''.']);
    end
else
    error('ICNNA:batchBasicVisuzalization:getChannelLabel:InvalidLabelling',...
          'Option channelLabelling must be char/string or cell.');
end


end






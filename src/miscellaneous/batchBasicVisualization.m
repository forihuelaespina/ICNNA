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
% %%The following options are to be passed directly to plotTopo:
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
%
%
%
% Copyright 2009-16
% @date: 30-Apr-2009
% @author: Felipe Orihuela-Espina
% @modified: 15-May-2016
%
% See also plotChannel, plotTopo, guiBasicVisualization
%

%% Log
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
%




expName=get(E,'Name');
%Remove spaces (to avoid problems with MATLAB)
expName(expName==' ')='_';


%% Deal with options
opt.whichSubjects=[];
opt.whichSessions=[];
opt.whichDataSources=[];

opt.save=true;
opt.destinationFolder=['.\Images\' expName '\'];
opt.fontSize=13;
opt.seriesSCHAVG = false;
opt.seriesSCHNBA = false;
opt.seriesACHNBA = true;
opt.seriesACHAVG = false;
opt.seriesGAACHAVG = false;
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
opt.seriesGA_nScope='BlockIndividual'; %'BlockIndividual'
                                       %'Individual'
                                       %'Collective'
opt.seriesGA_nDimension='Combined'; %'Channel'
                                   %'Signal'
                                   %'Combined'
opt.seriesGA_nMethod='Normal'; %'Normal'
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


%% Individual series

nElem = size(I,1);
for ee=1:nElem
    
    subjID = I(ee,COL.SUBJECT);
    sessID = I(ee,COL.SESSION);
    dataSourceID = I(ee,COL.DATASOURCE);
    sd=F{ee};
    t=get(sd,'Timeline');
    
    nChannels=get(sd,'NChannels');
    integrity=get(sd,'Integrity');
    for ch=1:nChannels
        if isClean(integrity,ch)
            
            %Series SCHAVG
            if (opt.seriesSCHAVG)
                opt.blockAveraging=true;
                
                nConds=get(t,'NConditions');
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
                        '; Ch=' num2str(ch)],...
                        'FontSize',opt.fontSize+2);
                    
                    if (opt.save)
                        outputFilename=[expName ...
                            '_SCHAVG_'...
                            'Subj' num2str(subjID,'%02i') ...
                            'Sess' num2str(sessID,'%02i') ...
                            'DS' num2str(dataSourceID,'%02i') ...
                            'Stim' opt.blockCondTag ...
                            'Ch' num2str(ch,'%02i')];
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
                    '; Ch=' num2str(ch)],...
                    'FontSize',opt.fontSize+2);
                
                if (opt.save)
                    outputFilename=[expName ...
                        '_SCHNBA_'...
                        'Subj' num2str(subjID,'%02i') ...
                        'Sess' num2str(sessID,'%02i') ...
                        'DS' num2str(dataSourceID,'%02i') ...
                        'Ch' num2str(ch,'%02i')];
                    mySaveFig(gcf,[opt.destinationFolder outputFilename]);
                    close gcf
                end
            end %Series SCHNBA
            
        end
    end
    
    %Series ACHNBA
    if (opt.seriesACHNBA)
        [h]=plotAllChannels(sd); %Auxiliar function
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
        nConds=get(t,'NConditions');
        for stim=1:nConds
            condTag=getConditionTag(t,stim);
            [h]=plotAllChannelsAvg(sd,condTag); %Auxiliar function
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
        nConds=get(t,'NConditions');
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
        nConds=get(t,'NConditions');
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
s=set(s,'BaselineSamples',opt.seriesGA_BaselineSamples);
s=set(s,'RestSamples',opt.seriesGA_RestSamples);   
%Window Selection parameters
s=set(s,'WS_Onset',opt.seriesGA_wsOnset);
s=set(s,'WS_Duration',opt.seriesGA_wsDuration);
s=set(s,'WS_BreakDelay',opt.seriesGA_BreakDelay);
%Resample parameters
s=set(s,'Resampled',opt.seriesGA_resampleFlag);
s=set(s,'RS_Baseline',opt.seriesGA_rsBaseline);   
s=set(s,'RS_Task',opt.seriesGA_rsTask);
s=set(s,'RS_Rest',opt.seriesGA_rsRest);
%Average parameters 
s=set(s,'Averaged',false); %I do not want the experimentSpace to average
                           %otherwise I will be still in a double stage
                           %averaging situation
%Normalization parameters
s=set(s,'Normalized',opt.seriesGA_normalizationFlag);
s=set(s,'NormalizationScope',opt.seriesGA_nScope); %'BlockIndividual'
                                                   %'Individual'
                                                   %'Collective'
s=set(s,'NormalizationDimension',opt.seriesGA_nDimension); %'Channel'
                                                   %'Signal'
                                                   %'Combined'
s=set(s,'NormalizationMethod',opt.seriesGA_nMethod); %'Normal'
                                                   %'Range'
s=set(s,'NormalizationMean',opt.seriesGA_nMean);    
s=set(s,'NormalizationVar',opt.seriesGA_nVar);    
s=set(s,'NormalizationMin',opt.seriesGA_nMin);    
s=set(s,'NormalizationMax',opt.seriesGA_nMax);    

%Now compute
s=compute(s,E);


%Filter the subset of interest
subsetDefinition{1}.dimension = experimentSpace.DIM_SUBJECT;
subsetDefinition{1}.values = opt.whichSubjects;
subsetDefinition{2}.dimension = experimentSpace.DIM_SESSION;
subsetDefinition{2}.values = opt.whichSessions;
subsetDefinition{3}.dimension = experimentSpace.DIM_DATASOURCE;
subsetDefinition{3}.values = opt.whichDataSources;
[I2,Fvectors]=getSubset(s,subsetDefinition);


%Get probe mode from first item
tmpSubjId = I2(1,experimentSpace.DIM_SUBJECT);
tmpSessId = I2(1,experimentSpace.DIM_SESSION);
tmpDsId = I2(1,experimentSpace.DIM_DATASOURCE);
ee = find(I(:,COL.SUBJECT) == tmpSubjId ...
               & I(:,COL.SESSION) == tmpSessId ...
               & I(:,COL.DATASOURCE) == tmpDsId);
sd = F{ee};
clm = get(sd,'ChannelLocationMap');
t = get(sd,'Timeline'); %Currently I am counting on this one
                        %to contain all stimulus
                        %so I can retrieve all condition tags

%I need to produce a figure per stimulus
stimulus=unique(I2(:,experimentSpace.DIM_STIMULUS))';
nChannels=max(I2(:,experimentSpace.DIM_CHANNEL))';

opt.lineWidth=1.5;
opt.fontSize=8;
for st=stimulus
    condTag=getConditionTag(t,st);
    figure
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
        location=getAxesPosition(ch,clm);
        
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
        onset = -get(s,'WS_Onset');
        endingMark = onset+get(s,'RS_Task');
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
        xBreakDelay = -get(s,'WS_Onset') + get(s,'WS_BreakDelay');
        if (get(s,'WS_BreakDelay')~=0)
            line('XData',[xBreakDelay xBreakDelay],...
                'YData',[getY(3) getY(4)],...
                'LineStyle','--','LineWidth',opt.lineWidth,...
                'Color','k')
        end
        
        set(gca,'XLim',[1 nSamples]);
        
        
        ylim=axis;
        hText=text(0.85*ylim(2),0.85*ylim(4),num2str(ch));
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
function [h]=plotAllChannels(sd)
%Plots all channels at the same time
%
% sd - A NIRS_neuroimage data
%

clm = get(sd,'ChannelLocationMap');
    
figure;

opt.lineWidth=1.5;
opt.fontSize=8;
nChannels=get(sd,'NChannels');
for ch=1:nChannels
    channelData=getChannel(sd,ch);
    nSamples=size(channelData,1);
    
    %location=getLocation(ch,get(sd,'ProbeMode')); %DEPRECATED CODE
    location=getAxesPosition(ch,clm);
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
    shadeTimeline(gca,get(sd,'Timeline'));
    set(gca,'XLim',[1 nSamples]);
    
    
    ylim=axis;
    hText=text(0.85*ylim(2),0.85*ylim(4),num2str(ch));
    set(hText,'FontSize',opt.fontSize,...
            'FontWeight','bold',...
            'BackgroundColor','y');
end
end


function [h]=plotAllChannelsAvg(sd,condTag)
%Plots all channels at the same time (block averaged).
%
% sd - A NIRS_neuroimage data
%
% condTag - A stimulus to average across
%
clm = get(sd,'ChannelLocationMap');

figure,

opt.lineWidth=1.5;
opt.fontSize=8;
nChannels=get(sd,'NChannels');

%integrity=get(sd,'Integrity');
for ch=1:nChannels
%    if isClean(integrity,ch)
        %location=getLocation(ch,get(sd,'ProbeMode')); %DEPRECATED CODE
        location=getAxesPosition(ch,clm);
        h(ch)=axes('OuterPosition',location);
        opt.axesHandle=h(ch);
        opt.blockAveraging=true;
        opt.blockCondTag=condTag;
        opt.blockBaseline=10;
        opt.blockMaxRest=20;
        opt.blockResampling=true;
        opt.blockResamplingBaseline=15;
        opt.blockResamplingTask=30;
        opt.blockResamplingRest=20;
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
        hText=text(0.85*ylim(2),0.85*ylim(4),num2str(ch));
        set(hText,'FontSize',opt.fontSize,...
            'FontWeight','bold',...
            'BackgroundColor','y');
%    end
end
end


function pos=getAxesPosition(ch,clm)
%Return an (outer) position vector to place the channel axes
%
% The distribution of channel axes will allocate room within the
%figure for every channel in the dataset.
% Thus, the axes position depends on the channel topological
%arragement within the optode array, but also on the number of
%optode arrays in the channelLocationMap. Also channels not
%associated to a particular optode array will be assigned a
%default position as if they were in a separate optode array.
%
% ch - Channel number
% clm - A channelLocationMap

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
        %Note that this is conservative
    r=min(pdist(oaInfo.chTopoArrangement));
    %...and correct the topological arrangement to accout for this needed
    %space (in all dimensions)
    tmp=repmat(max(oaInfo.chTopoArrangement+r),size(oaInfo.chTopoArrangement,1),1);
    oaInfo.chTopoArrangement = oaInfo.chTopoArrangement./tmp;

    %Finally, get the abstract location...
    thisChannelIdxWithinTheOptodeArray = find(ismember(oaChannels,ch));
    tmpAbstractArrangement = ...
        oaInfo.chTopoArrangement(thisChannelIdxWithinTheOptodeArray,:);
    %and translate this location to an axes position
    left = oa_HorzOffset + tmpAbstractArrangement(1)*(1/nCols);
    bottom = oa_VertOffset + tmpAbstractArrangement(2)*(1/nRows);
    width  = r/(2*tmp(1,1));
    height  = r/(2*tmp(1,2));
        
end
pos = [left bottom width height];
end

%%%DEPRECATED CODE
% %function pos=getLocation(ch,mode) 
% %Return an position vector to place the channel axes
% %
% % ch - Channel number
% % mode - Optode array mode, i.e. '3x3' (default)
% if ~exist('mode','var')
%     mode='3x3';
% end
% 
% switch (mode)
%     case '3x3'
%         nChannels = 24;
%                 %Each row is a channel.
%         tmpChannelPositions = ...
%             [0.09 0.78 0.136 0.17; ...
%         	0.296 0.78 0.136 0.17; ...
%         	0.03 0.59 0.136 0.17; ...
%         	0.186 0.59 0.136 0.17; ...
%         	0.342 0.59 0.136 0.17; ...
%         	0.09 0.4 0.136 0.17; ...
%         	0.296 0.4 0.136 0.17; ...
%         	0.03 0.21 0.136 0.17; ...
%         	0.186 0.21 0.136 0.17; ...
%         	0.342 0.21 0.136 0.17; ...
%         	0.09 0.02 0.136 0.17; ...
%         	0.296 0.02 0.136 0.17; ...
%         	0.572 0.78 0.136 0.17; ...
%         	0.778 0.78 0.136 0.17; ...
%         	0.518 0.59 0.136 0.17; ...
%         	0.674 0.59 0.136 0.17; ...
%         	0.83 0.59 0.136 0.17; ...
%         	0.572 0.4 0.136 0.17; ...
%         	0.778 0.4 0.136 0.17; ...
%         	0.518 0.21 0.136 0.17; ...
%         	0.674 0.21 0.136 0.17; ...
%         	0.83 0.21 0.136 0.17; ...
%         	0.572 0.02 0.136 0.17; ...
%         	0.778 0.02 0.136 0.17];
%         
%     case '4x4'
%         nChannels = 24;
%                 %Each row is a channel.
%         tmpChannelPositions = ...
%             [0.16 0.821 0.21 0.12; ...
%              0.395 0.821 0.21 0.12; ...
%              0.63 0.821 0.21 0.12; ...
%              0.05 0.6925 0.21 0.12; ...
%              0.285 0.6925 0.21 0.12; ...
%              0.52 0.6925 0.21 0.12; ...
%              0.755 0.6925 0.21 0.12; ...
%              0.16 0.564 0.21 0.12; ...
%              0.395 0.564 0.21 0.12; ...
%              0.63 0.564 0.21 0.12; ...
%              0.05 0.4355 0.21 0.12; ...
%              0.285 0.4355 0.21 0.12; ...
%              0.52 0.4355 0.21 0.12; ...
%              0.755 0.4355 0.21 0.12; ...
%              0.16 0.307 0.21 0.12; ...
%              0.395 0.307 0.21 0.12; ...
%              0.63 0.307 0.21 0.12; ...
%              0.05 0.1785 0.21 0.12; ...
%              0.285 0.1785 0.21 0.12; ...
%              0.52 0.1785 0.21 0.12; ...
%              0.755 0.1785 0.21 0.12; ...
%              0.16 0.05 0.21 0.12; ...
%              0.395 0.05 0.21 0.12; ...
%              0.63 0.05 0.21 0.12];
%     case '3x5'
%         nChannels = 25;
%                 %Each row is a channel.
%         tmpChannelPositions = ...
%             [0.085 0.78 0.17 0.17; ...
%              0.285 0.78 0.17 0.17; ...
%              0.465 0.78 0.17 0.17; ...
%              0.645 0.78 0.17 0.17; ...
%              0.02 0.59 0.17 0.17; ...
%              0.20 0.59 0.17 0.17; ...
%              0.38 0.59 0.17 0.17; ...
%              0.56 0.59 0.17 0.17; ...
%              0.74 0.59 0.17 0.17; ...
%              0.085 0.4 0.17 0.17; ...
%              0.285 0.4 0.17 0.17; ...
%              0.465 0.4 0.17 0.17; ...
%              0.645 0.4 0.17 0.17; ...
%              0.02 0.21 0.17 0.17; ...
%              0.20 0.21 0.17 0.17; ...
%              0.38 0.21 0.17 0.17; ...
%              0.56 0.21 0.17 0.17; ...
%              0.74 0.21 0.17 0.17; ...
%              0.085 0.02 0.17 0.17; ...
%              0.285 0.02 0.17 0.17; ...
%              0.465 0.02 0.17 0.17; ...
%              0.645 0.02 0.17 0.17];
%              
%     otherwise
%         error('Mode not yet ready or not recognised.');
% end
% 
% pos=[0.1 0.1 0.9 0.9];
% if ch>=1 && ch<=nChannels
%     pos=tmpChannelPositions(ch,:);
% end
% 
% end
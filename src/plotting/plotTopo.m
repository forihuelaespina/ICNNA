function [hOxy,hDeoxy,hTotal,hDiff]=plotTopo(sd,stim,mode,options)
%Topographic representation of signals in a nirs_neuroimage
%
% [hOxy,hDeoxy,hTotal,hDiff]=plotTopo(sd,stim,mode)
%   Display the spatial distribution of
%   signals in a nirs_neuroimage, either at a certain instant
%   (sample), averaged across blocks or without block averaging.
%
% [hOxy,hDeoxy,hTotal,hDiff]=plotTopo(sd,stim,mode,options)
%   Display the spatial distribution
%   of signals in a nirs_neuroimage, either at a certain instant
%   (sample), averaged across blocks or without block averaging.
%   See options below
%
%
%% Parameters
%
%   sd - A nirs_neuroimage object
%
%   stim - An stimulus tag or ID, present in the timeline. If mode
%       is numeric, then this parameter will be ignored.
%
%   mode - Either a string or a number/vector.
%       If a string then:
%           + 'AVG' - Block (task only data) averaged mean values
%               are presented.
%           + 'NBA' - Non averaged block (task only data) mean values
%               are presented, leading to 1 figure per block
%       If numeric
%           + a number represents a particular sample (global to
%               the whole timecourse).
%           + a vector represents a set of samples (global to
%               the whole timecourse), of which the mean value
%               is presented.
%
% options - An struct of options
%   .fontSize - Font size to be used in the figure series
%   .destFolder - Destination folder. Default value is
%       './images/'
%   .save - True if you want your figures to be saved. False (default)
%       otherwise. Figures are saved in MATLAB .fig format and in
%       .tif format non-compressed at 300dpi.      
%   .whichBlocks - Evaluate only selected blocks, e.g [2 4] evaluates
%       only blocks [2 and 4].
%       This option is only valid when mode is either 'avg' or 'nba'.
%       Set this field empty, to evaluate all blocks (default).
%   .taskOnly - True (default) if the plot is to represent data
%       from the task alone, or false if the plot is to represent
%       differential data of task-baseline.
%       This option is only valid when mode is either 'avg' or 'nba'.
%   .baselineLength - Number of samples to be taken from the baseline.
%       By default is set to 5. If there are not enough samples in
%       the baseline, the maximum number of available samples in the
%       baseline are taken. Set it to -1 to use all available baseline
%       samples. This option is only taken into account
%       if the option .taskOnly is set to false.
%       This option is only valid when mode is either 'avg' or 'nba'.
%   .breakDelay - Number of samples to delay the window of data
%       to be used from the stimulus onset. By default is set
%       to 0 (no break delay).
%       If the break delay is large enough to cause the data window
%       exceeds available samples, only as many samples as remaining
%       will be used.
%       Note: A negative value shifts the window prior to the onset.
%       This option is only valid when mode is either 'avg' or 'nba'.
%
%% Output
%
% hOxy,hDeoxy,hTotal,hDiff - Figure handles for the oxy, deoxy
%   totalHb and HbDiff respectively. Since the 'NBA' mode can lead
%   to several figures, each of these may be an array of handles
%   hOxy(i) is the Oxy topographic map for block i-th.
%       NOTE that if option whichBlocks is used and some blocks
%       are not assessed then hOxy(j) = 0 where j is an unused
%       block.
%
%
% Copyright 2010-2013
% @date: 26-Jul-2010
% @author: Felipe Orihuela-Espina
% @modified: 27-Dic-2013
%
% See also nirs_neuroimage, timeline, structuredData.getBlock,
%   topoOnHead, topoOptodeArray, batchBasicVisualization
%


%% Log
%
% 27-Dec-2013 (FOE): Ammended bugs by which:
%       1) "old" function channelLocationMap.getOptodeArrays was
%       still being called. This has been updated by current method
%       channelLocationMap.getChannelOptodeArrays
%       2) Calls to field oaInfo.topoArrangement has been updated to
%       oaInfo.chTopoArrangement
%

if ~isa(sd,'nirs_neuroimage')
    error('ICNA:plotTopo:InvalidInputParameter',...
          'nirs_neuroimage object not found.');
end

hOxy=[];
hDeoxy=[];
hTotal=[];
hDiff=[];


%% Deal with options
opt.save=false;
opt.destinationFolder='./images/';
%opt.mainTitle='';
opt.fontSize=13;
opt.whichBlocks=[];
opt.taskOnly=true;
opt.baselineLength=5; %only valid if taskOnly is false.
opt.breakDelay=0;
if exist('options','var')
    if isfield(options,'save')
        opt.save=options.save;
    end
    if isfield(options,'destinationFolder')
        opt.destinationFolder=options.destinationFolder;
    end
    if isfield(options,'fontSize')
        opt.fontSize=options.fontSize;
    end
    if isfield(options,'whichBlocks')
        opt.whichBlocks=options.whichBlocks;
    end
    if isfield(options,'taskOnly')
        opt.taskOnly=options.taskOnly;
    end
    if isfield(options,'baselineLength')
        opt.baselineLength=options.baselineLength;
    end
    if isfield(options,'breakDelay')
        opt.breakDelay=options.breakDelay;
    end
end





%% Preparations

t=get(sd,'Timeline');
nChannels = get(sd,'NChannels');

%% Extract information about the optode arrays
clm = get(sd,'ChannelLocationMap');
oas = getChannelOptodeArrays(clm);
oaInfo = getOptodeArraysInfo(clm);

if any(isnan(oas))
    oaList = unique(oas(~isnan(oas)));
    oaList = [oaList NaN]; %count NaNs only once as if equal
    oaInfo(end+1).mode = 'NaN';
    nNaNChannels = length(isnan(oas));
    oaInfo(end).chTopoArrangement = [[1:nNaNChannels]' zeros(nNaNChannels,2)];
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


%% Data extraction according to stim and mode
if ischar(mode)

    if ~ischar(stim)
        stim=getConditionTag(t,stim);
        %If the condition does not exist this will get an empty string
        %but we can continue...
    end
    %Check that the stimulus exist
    cevents=getConditionEvents(t,stim);
    %If the condition does not exist this will get an empty matrix

    if isempty(cevents)
        warning('ICNA:plotTopo:NoEventsFound',...
                ['No events found for the selected stimulus. ' ...
                'Stimulus is either missing or does not have ' ...
                'associated events. No plots will be generated.']);
        return;
    end
    
    nBlocks = size(cevents,1);
    blocks = 1:nBlocks;
    if ~isempty(opt.whichBlocks)
    	blocks=opt.whichBlocks;
    end
                
    switch (lower(mode))
        case 'avg'
            blockStr = 'Block = AVG';
            for bb = blocks
                block=getBlock(sd,stim,bb);
                %extract task and baseline data
                        %%%NOTE: The baseline data is computed all the way
                        %%%even if it is not to be used. Only at the time
                        %%%of plotting is either used or discarded.
                tmpt = get(block,'Timeline');
                cevents=getConditionEvents(tmpt,stim);
                    %there should be only one block, i.e. only one event
                tempData = get(block,'Data');
                if (opt.baselineLength == -1)
                    tempBaseline = tempData(1:cevents(1),:,:);
                else
                    tempBaseline = tempData(...
                                max(1,cevents(1)-opt.baselineLength) ...
                                :cevents(1),:,:);
                end    
                tempData = tempData(opt.breakDelay+cevents(1)...
                                    :max(opt.breakDelay+cevents(1)+cevents(2),...
                                         size(tempData,1)),...
                                    :,:);
                
                tmpBaseline(:,:,bb) = squeeze(nanmean(tempBaseline));
                tmpData(:,:,bb) = squeeze(nanmean(tempData));
                %not averaged ACROSS blocks; but still
                %averaged within blocks.
                %Rows are channels, Columns are signals
            end
            baseline= nanmean(tmpBaseline,3);
            data= nanmean(tmpData,3);
            
            %%Here is the trick for using or discarding the baseline
            if ~opt.taskOnly
                data=data-baseline;
            end
            
            
            nBlocks = 1;
            blocks = 1;
                %Note that this is how the averaging would be done
                %should I have started from a database, since the
                %average across blocks is computed from the
                %intra-block pre-averaged rows.
            
            idx = find(imag(data));
            data(idx)=NaN;
            
            
        case 'nba'
            blockStr = '';
            for bb = blocks
                block=getBlock(sd,stim,bb);
                %extract task and baseline data
                        %%%NOTE: The baseline data is computed all the way
                        %%%even if it is not to be used. Only at the time
                        %%%of plotting is either sued or discarded.
                tmpt = get(block,'Timeline');
                cevents=getConditionEvents(tmpt,stim);
                    %there should be only one block, i.e. only one event
                tempData = get(block,'Data');
                if (opt.baselineLength == -1)
                    tempBaseline = tempData(1:cevents(1),:,:);
                else
                    tempBaseline = tempData(...
                                max(1,cevents(1)-opt.baselineLength) ...
                                :cevents(1),:,:);
                end    
                tempData = tempData(opt.breakDelay+cevents(1)...
                                    :max(opt.breakDelay+cevents(1)+cevents(2),...
                                         size(tempData,1)),...
                                    :,:);

                baseline = squeeze(nanmean(tempBaseline));
                data = squeeze(nanmean(tempData));
                
                %%Here is the trick for using or discarding the baseline
                if ~opt.taskOnly
                    data=data-baseline;
                end
            
                
                %not averaged ACROSS blocks; but still
                %averaged within blocks.
                %Rows are channels, Columns are signals
                idx = find(imag(data));
                data(idx)=NaN;
            end
            
        otherwise
            error('ICNA:plotTopo:InvalidInputParameter',...
                'Unexpected mode.');
    end
    
else %mode is numeric
    l=get(t,'Length');
    if (mode >= l)
        error('ICNA:plotTopo:InvalidInputParameter',...
            ['Mode, when numeric, must be lower or equal than ' ...
            'the nirs_neuroimage length in samples.']);
    end
    
    nBlocks = 1;
    blocks=1;
    if isscalar(mode)
        blockStr = ['Sample = ' num2str(mode)];
        data = getSample(sd,mode); %Rows are channels, Columns are signals
    else %vector
        blockStr = ['Samples = [' num2str(mode(1)) ...
                                  num2str(mode(2:end),',%d') ']'];
        data = get(sd,'Data');
        data = data(mode,:,:);
        data = squeeze(nanmean(data)); %Rows are channels, Columns are signals
    end
        

    idx = find(imag(data));
    data(idx)=NaN;
    
end



%% Create the figures (Oxy, deoxy, totalHb and HbDiff)
for bb=blocks
    
    if strcmp(mode,'nba')
        blockStr=['Block = ' num2str(bb)];
    else
        blockStr='Block = AVG';
    end
    
    %Plot Oxy
    hOxy(bb)=figure;
    for oa=1:nOptodeArrays
        subplot(nRows,nCols,oa);
        oaChannels = find(oas==oa); %All channels in this optode array
        dataVector = data(oaChannels,nirs_neuroimage.OXY);
        tmpOptions.scale=[min(dataVector) max(dataVector)];
        if all(isnan(tmpOptions.scale))
            tmpOptions.scale=[0 0+2*eps];
        elseif isnan(tmpOptions.scale(1))
            tmpOptions.scale(1)=tmpOptions.scale(1)-2*eps;
        elseif isnan(tmpOptions.scale(2))
            tmpOptions.scale(2)=tmpOptions.scale(2)+2*eps;
        end
        tmpOptions.labels=oaChannels;
        [axisHandle]=topoOptodeArray(gca,dataVector,oaInfo(oa),tmpOptions);
        
    end
    %[ax,h3]=suplabel([get(sd,'Description') '; ' ...
    %                    blockStr '; HbO_2'],'t');
         %For some reason suplabel doesn't want to work
         %so replicate here what suplabel does.
    ax=axes('Units','Normal','OuterPosition',[0 0 1 1],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    title([get(sd,'Description') '; ' blockStr '; HbO_2'],...
            'FontSize',opt.fontSize);
    clear tmpOptions
    
    if (opt.save)
        outputFilename=['seriesTopo_Oxy'];
        saveas(gcf,[opt.destinationFolder outputFilename '.fig'],'fig');
        print(['-f' num2str(gcf)],'-dtiff','-r300',...
            [opt.destinationFolder outputFilename '_300dpi.tif']);
        
        close gcf
    end
    
    %Plot Deoxy
    hDeoxy(bb)=figure;
    for oa=1:nOptodeArrays
        subplot(nRows,nCols,oa);
        oaChannels = find(oas==oa); %All channels in this optode array
        dataVector = data(oaChannels,nirs_neuroimage.DEOXY);
        tmpOptions.scale=[min(dataVector) max(dataVector)];
        if all(isnan(tmpOptions.scale))
            tmpOptions.scale=[0 0+2*eps];
        elseif isnan(tmpOptions.scale(1))
            tmpOptions.scale(1)=tmpOptions.scale(1)-2*eps;
        elseif isnan(tmpOptions.scale(2))
            tmpOptions.scale(2)=tmpOptions.scale(2)+2*eps;
        end
        tmpOptions.labels=oaChannels;
        [axisHandle]=topoOptodeArray(gca,dataVector,oaInfo(oa),tmpOptions);
        
    end
    %[ax,h3]=suplabel([get(sd,'Description') '; ' ...
    %                    blockStr '; HHb'],'t');
         %For some reason suplabel doesn't want to work
         %so replicate here what suplabel does.
    ax=axes('Units','Normal','OuterPosition',[0 0 1 1],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    title([get(sd,'Description') '; ' blockStr '; HHb'],...
            'FontSize',opt.fontSize);
    clear tmpOptions
    
    if (opt.save)
        outputFilename=['seriesTopo_Deoxy'];
        saveas(gcf,[opt.destinationFolder outputFilename '.fig'],'fig');
        print(['-f' num2str(gcf)],'-dtiff','-r300',...
            [opt.destinationFolder outputFilename '_300dpi.tif']);
        
        close gcf
    end
    
    
    
    %Plot HbT
    hTotal(bb)=figure;
    for oa=1:nOptodeArrays
        subplot(nRows,nCols,oa);
        oaChannels = find(oas==oa); %All channels in this optode array
        dataVector = data(oaChannels,nirs_neuroimage.OXY) ...
                   + data(oaChannels,nirs_neuroimage.DEOXY);
        tmpOptions.scale=[min(dataVector) max(dataVector)];
        if all(isnan(tmpOptions.scale))
            tmpOptions.scale=[0 0+2*eps];
        elseif isnan(tmpOptions.scale(1))
            tmpOptions.scale(1)=tmpOptions.scale(1)-2*eps;
        elseif isnan(tmpOptions.scale(2))
            tmpOptions.scale(2)=tmpOptions.scale(2)+2*eps;
        end
        tmpOptions.labels=oaChannels;
        [axisHandle]=topoOptodeArray(gca,dataVector,oaInfo(oa),tmpOptions);
        
    end
    %[ax,h3]=suplabel([get(sd,'Description') '; ' ...
    %                    blockStr '; HbT'],'t');
         %For some reason suplabel doesn't want to work
         %so replicate here what suplabel does.
    ax=axes('Units','Normal','OuterPosition',[0 0 1 1],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    title([get(sd,'Description') '; ' blockStr '; HbT'],...
            'FontSize',opt.fontSize);
    clear tmpOptions
    
    if (opt.save)
        outputFilename=['seriesTopo_HbT'];
        saveas(gcf,[opt.destinationFolder outputFilename '.fig'],'fig');
        print(['-f' num2str(gcf)],'-dtiff','-r300',...
            [opt.destinationFolder outputFilename '_300dpi.tif']);
        
        close gcf
    end
    
    
    %Plot HbDiff
    hDiff(bb)=figure;
    for oa=1:nOptodeArrays
        subplot(nRows,nCols,oa);
        oaChannels = find(oas==oa); %All channels in this optode array
        dataVector = data(oaChannels,nirs_neuroimage.OXY) ...
                   - data(oaChannels,nirs_neuroimage.DEOXY);
        tmpOptions.scale=[min(dataVector) max(dataVector)];
        if all(isnan(tmpOptions.scale))
            tmpOptions.scale=[0 0+2*eps];
        elseif isnan(tmpOptions.scale(1))
            tmpOptions.scale(1)=tmpOptions.scale(1)-2*eps;
        elseif isnan(tmpOptions.scale(2))
            tmpOptions.scale(2)=tmpOptions.scale(2)+2*eps;
        end
        tmpOptions.labels=oaChannels;
        [axisHandle]=topoOptodeArray(gca,dataVector,oaInfo(oa),tmpOptions);
        
    end
    %[ax,h3]=suplabel([get(sd,'Description') '; ' ...
    %                    blockStr '; HbDiff'],'t');
         %For some reason suplabel doesn't want to work
         %so replicate here what suplabel does.
    ax=axes('Units','Normal','OuterPosition',[0 0 1 1],'Visible','off');
    set(get(ax,'Title'),'Visible','on')
    title([get(sd,'Description') '; ' blockStr '; HbDiff'],...
            'FontSize',opt.fontSize);
    clear tmpOptions
    
    if (opt.save)
        outputFilename=['seriesTopo_HbDiff'];
        saveas(gcf,[opt.destinationFolder outputFilename '.fig'],'fig');
        print(['-f' num2str(gcf)],'-dtiff','-r300',...
            [opt.destinationFolder outputFilename '_300dpi.tif']);
        
        close gcf
    end
    
end


end
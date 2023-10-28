function averaged=blocksTemporalAverage(blocks)
%Average signals temporally across the different tasks blocks
%
%
% averaged=blocksTemporalAverage(blocks) Average signals
%       temporally across the different tasks blocks.
%       The blocks is a cell array of structuredData
%       which are assumed to have block structure
%       (see structuredData.getBlock)
%
%Blocks do not neccessarily ought to have the same length. They
%will be aligned to the onset of the task, and then cropped
%to the length of the shortest block being averaged.
%If the user requires that the blocks have the same length
%then refer to function resampleBlock.
%
%   +=============================================+
%   | In case of self pace tasks, it is STRONGLY  |
%   | RECOMMENDED that resampling is executed upon|
%   | the blocks BEFORE averaging! This is to     |
%   | ensure that each chunk information is mainly|
%   | from the original chunk of interest.        |
%   +=============================================+
%
%
%The resulting averaged block has a number of signals equal
%to the maximum number of signals, a number of channels
%equal to the maximum number of channels among all the blocks.
%
%----------------------------
% REMARKS
%----------------------------
%
%If any of the block has not got a block condition a error
%is issued ('ICNNA:blocksTemporalAverage:NotABlockStructure').
%
% Signals and channels are averaged in the same order that
%they are arranged within the blocks, i.e. channel 1 is averaged
%with channel 1, and similarly for signals.
% 
%Signals and channels are respected to the maximum number of them.
%This means that if some of the blocks has less of signals
%or channels, those particular channels or signals will be
%averaged, only among the avaiable values.
%
%
%The blocks are expected not only to have block structure
%(see structuredData.getBlock), but also that their conditions
%are the same (they have the same tags). Therefore upon finding
%different condition tags, a warning is issued
%('ICNNA:blocksTemporalAverage:DifferentConditions'), but the
%averaging will still be done as if they were the same condition.
%
%In reconstructing the timeline, the duration of the single
%episode is averaged across all durations.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experimentSpace, analysis, structuredData.getBlock
%   blockResample, blockWindowSelection
%


%% LOG
%
% File created: 4-Jul-2008
% File last modified (before creation of this log): N/A This method has not
%   been updated since creation until the creation of the log.
%
% 6-May-2019: FOE
%   + Substituted deprecated call getNConditions for get(obj,'nConditions')
%
% 27-May-2023: FOE
%   + Got rid of old label @date.
%   + Updated some of the calls to get attributes using the struct like syntax
%   Bug fixing
%   + In some cases, averaged durations (calculated as duration/nBlocks)
%   may exceed the length of the block (depending on cropping). This
%   case was not being taken into account. Now, events exceeding the
%   length of the timeline are crop in their durations.
%



averaged=[];
nBlocks=length(blocks);
if nBlocks==0
    return
end

%Initialize the average
averaged=blocks{1};
if nBlocks==1
    return
end

%Get some initial values
t = averaged.timeline;
condTag = getConditionTag(t,1); %Remember that I'm assuming block structure
events  = getConditionEvents(t,condTag);
if ((t.nConditions ~= 1) ...
     || (size(events,1)~=1))
    error('ICNNA:blocksTemporalAverage:NotABlockStructure',...
        'Found data without block structure.');
end
onset = events(1);
duration = events(2);
data = averaged.data;
[nSamples,nChannels,nSignals]=size(data);
nValues = ones(nSamples,nChannels,nSignals);

%Incremental calculation
for ii=2:nBlocks
    tmpBlock = blocks{ii};
    tmpData  = tmpBlock.data;
    tmpT     = tmpBlock.timeline;
    tmpCondTag=getConditionTag(tmpT,1);
    tmpEvents = getConditionEvents(tmpT,condTag);
    tmpOnset = events(1);
    duration = duration + events(2);
    [tmpNSamples,tmpNChannels,tmpNSignals]=size(tmpData);

    if ~(strcmp(condTag,tmpCondTag))
        warning('ICNNA:blocksTemporalAverage:DifferentConditions',...
                'Different conditions found');
    end
    if ((tmpT.nConditions ~= 1) ...
            || (size(tmpEvents,1)~=1))
        error('ICNNA:blocksTemporalAverage:NotABlockStructure',...
            'Found data without block structure.');
    end

   
    %Adjust sizes...
    if tmpNChannels > nChannels
        data(:,end+1:tmpNChannels,:)=...
            tmpData(nSamples,nChannels+1:end,nSignals);
        nValues(:,end+1:tmpNChannels,:)=...
            ones(nSamples,tmpNChannels-nChannels,nSignals);
        nChannels=tmpNChannels;
    elseif tmpNChannels < nChannels
        tmpData(:,end+1:nChannels,:)=...
            data(nSamples,tmpNChannels+1:end,nSignals);
    end
    
    if tmpNSignals > nSignals
        data(:,:,end+1:tmpNSignals)=...
            tmpData(nSamples,nChannels,nSignals+1:end);
        nValues(:,:,end+1:tmpNSignals)=...
            ones(nSamples,nChannels,tmpNSignals-nSignals);
        nSignals=tmpNSignals;
    elseif tmpNSignals < nSignals
        tmpData(:,:,end+1:nSignals)=...
            data(nSamples,nChannels,tmpNSignals+1:end);
    end
    
    %Align to the task onset (cropping the longest)
    if tmpOnset > onset
        tmpData(1:tmpOnset-onset,:,:)=[];
        tmpNSamples=size(tmpData,1);
    elseif tmpOnset < onset
        data(1:onset-tmpOnset,:,:)=[];
        nValues(1:onset-tmpOnset,:,:)=[];
        onset=tmpOnset;
        nSamples=size(data,1);
    end
    
    nSamples=min(nSamples,tmpNSamples);
    
    %Now that they are aligned, crop the longer one
    data(nSamples+1:end,:,:)=[];
    nValues(nSamples+1:end,:,:)=[];
    tmpData(nSamples+1:end,:,:)=[];
    
    %Now that they have exactly the same size and have
    %been aligned, they can be added up...
    data = data+tmpData;
    nValues = nValues+1;

end

%Finally average
data=data./nValues;

duration = round(duration/nBlocks);
%Big fixing: 27-May-2023; crop duration if event lasts beyond the length
duration = min(duration,nSamples-onset);

events=[onset duration];
t = timeline(nSamples,condTag,events);
s = warning('off', 'ICNNA:timeline:set:Length:EventsCropped');
averaged.data = data;
averaged.timeline = t;
warning(s);



end

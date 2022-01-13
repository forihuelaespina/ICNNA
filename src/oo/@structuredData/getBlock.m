function obj=getBlock(obj,condTag,eventNum,varargin)
%STRUCTUREDDATA/GETBLOCK Extract a single block or trial
%
% block=getBlock(obj,conditionTag,eventNum) Extract the single
%   block or trial from a
%   structuredData corresponding to the indicated condition or stimulus
%   and event instance. Length of baseline prior to task is set
%   to 15 samples.
%
% block=getBlock(...,'NBaselineSamples',baselineSamples) allow
%	indication of the length of the baseline prior to task.
%	Default value is 15 samples.
%
% block=getBlock(...,'NRestSamples',restSamples) allow
%	indication of the maximum number of samples to be taken
%   for the rest subperiod. By default the rest subperiod will
%   last until the next event onset (of the same condition)
%   or the end of the timecourse.
%
%
% If the condition or the event instance have not been defined
%in the timeline, then an empty value is returned.
%
%
%% Blocks or Trials
%
% A block or Trial is a temporal segregation of the
%experiment time course into pieces with a common well
%defined structure.
% A normal block/trial structure has three parts:
%
%
%             This block                        Next block
%               onset                             onset
%                 |                                 |
%    |  Baseline  | Stimulus (Task) | Rest          | 
%  --+------------+-----------------+---------------+----
%    |<- Fixed -> |                 |<- Fixed or -> |
%        length                      variable length
%
%
%This structure has some implications:
%
%   1) The block is independent of other existing conditions
%   in the timeline.
%   2) The baseline of one block is also part of the previous
%   block rest, and also perhaps even part of the previous
%   block task!!. It is the user responsability to account
%   for this!
%   3) Blocks may have different length.
%   4) If there are not enough samples at the beginning of the
%   timecourse, the baseline is completed/padded with 0s (inserted
%   by the beginning).
%   5) By default, the Rest period last until the end
%   of the timecourse or the next event onset (of the same
%   condition). In addition, a maximum number of samples can be
%   specified for the rest period. Importantly, for the last
%   event of a condition if the selected number of samples
%   for the rest goes beyond the length of the timeline, no
%   zero padding is added!!
%   6) Rest may last for 0 seconds.
%
%% Output
%
% The block returned is in fact another structuredData, which
%is cropped from this. It also has some particularities.
%
%The timeline of the block is adjusted so that it only has
%one single condition (the one of interest) and that condition
%has only one episode or event or epoch. All other existing
%conditions are eliminated from the block timeline.
%
%Note that the onset of the single event will be placed at
%baselineSamples+1.
%
%The length of the block is variable and depends on the
%duration of the event and the rest (i.e. distance to the
%next event onset).
%
%The block ID, description and integrity status for
%every spatial element are kept as in the original.
%
% 
%% Remarks: Averaging across blocks in fOSA and self pace tasks
%
%The algorithm implemented in here is inspired in the original
%averaging algorithm in fOSA v1.0
%
%In fOSA averaging across block is as simple
%as calculating the mean of the samples. But exactly,
%what samples? The key is "always" use the same
%number of samples which in the case of fOSA is:
%
% - A fix number of samples (fitrest) for the baseline (as
%from fOSA v2.1)
%
% - The average time for the task chunk of the block,
%calculated as the mean number of samples across all blocks
%
% - and, The average rest time for the rest chunk,
%calculated as the mean number of samples of the rests
%periods.
%
%   +======================================================+
%   | In fOSA v1.0 the avg rest time was also used for the |
%   | average baseline time. Also in fOSA v1.0, the average|
%   | rest time was calculated only from in-between task   |
%   | rest periods ignoring the "last" rest after the last |
%   | task chunk. Both of these issues have been fixed in  |
%   | fOSA v2.1                                            |
%   +======================================================+
%
%Once the average time for each chunk of the block has been
%estimated, the block is constructed as follows
%
%             This block
%               onset
%                 |     Average     | Average    |
%    |  Baseline  | Stimulus Time   | Rest       | 
%  --+------------+-----------------+------------+----
%    |<- Fixed -> |
%        length
%
%
%This is completely ignoring the original "second" mark of
%the epoch, indicating the end of the task chunk.
%
%This may be a nice way of getting rid of extra samples
%during fix length task (extra samples may arise because
%sampling rate is high and after downsampling the marks
%are reaccomodates as best as possible) and ensuring
%that when it comes to calculating the mean, all blocks
%have the same number of samples.
%
%HOWEVER applying this averaging for self pace tasks
%is definitively NOT a good idea because the average
%task time is not meaningful.
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
%
%
% Copyright 2008-12
% @date: 27-Sep-2008
% @author: Felipe Orihuela-Espina
% @modified: 10-Jul-2012
%
% See also structuredData, dataSource, analysis
%


baselineSamples=15;

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case 'NBaselineSamples'
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                    && floor(val)==val && val>=0)
                baselineSamples=val;
            else
                error('ICNA:structuredData:getBlock', ...
                 '''NBaselineSamples'' value must be a positive integer.');
            end

       case 'NRestSamples' %Maximum number of rest samples to be taken
           if (isscalar(val) && isreal(val) && ~ischar(val) ...
                   && floor(val)==val && val>=0)
               restSamples=val;
           else
               error('ICNA:structuredData:getBlock', ...
                 '''NRestSamples'' value must be a positive integer.');
           end


        otherwise
            error('ICNA:structuredData:getBlock', ...
                 ['Option ''' prop ''' not recognised.'])
    end
end



%check that the condition exist
cond=getCondition(obj.timeline,condTag);
if isempty(cond)
    obj=[];
    return
end

%check that the event instance exist
if ((eventNum>getNEvents(obj.timeline,condTag)) ...
        || (eventNum<1))
    obj=[];
    return
end

%If the function has reach here, then the condition and event
%instance do exist, so proceed to extract the block (i.e.
%cropping the data of interest.
events=getConditionEvents(obj.timeline,condTag);
onset=events(eventNum,1);
duration=events(eventNum,2);
%Crop everything beyond the blockEnd
if eventNum==getNEvents(obj.timeline,condTag)
    blockEnd=get(obj.timeline,'Length');
else
    %blockEnd=events(eventNum+1,1)-1; %i.e. one sample before the next onset
    blockEnd=events(eventNum+1,1); %i.e. up until the next onset
        % Before, I use to crop 1 sample before the next onset.
        %There was one issue with this approach:
        % Blocks for which onset+duration last right until the next
        %block onset (that is, two events together without in-between
        %rest) -which are valid- could not be accomodated.
end
if exist('restSamples','var')
    tmpBlockEnd=onset+duration+restSamples;
    blockEnd=min(blockEnd,tmpBlockEnd);
end
obj.data(blockEnd+1:end,:,:)=[];


%Crop everything before the blockStart
blockStart=(onset-1)-baselineSamples; %blockStart may be negative
                %at this point if there is not enough samples
                %to fill the baseline
if blockStart<=0
    %Pad with zeros
    [temp,nChannels,nSignals]=size(obj.data);
    tempData=zeros(temp+(-1*blockStart),nChannels,nSignals);
    pad=zeros(-1*blockStart,nChannels);
    for ss=1:nSignals
        tempData(:,:,ss)=[pad; obj.data(:,:,ss)];
    end
    obj.data=tempData;
end
obj.data(1:blockStart,:,:)=[];

%Finally replace the timeline
obj.timeline=timeline(blockEnd-blockStart,condTag,[baselineSamples+1 duration]);

%...and just to play on the safe side
assertInvariants(obj);

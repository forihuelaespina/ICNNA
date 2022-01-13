function obj=getBlock(obj,condTag,eventNum,varargin)
%ECG/GETBLOCK Extract a single block or trial
%
% block=getBlock(obj,conditionTag,eventNum) Extract the single
%   block or trial from an ecg
%   corresponding to the indicated condition or stimulus
%   and event instance. Length of baseline prior to task is set
%   to 5 samples.
%
% block=getBlock(...,'NBaselineSamples',baselineSamples) allow
%	indication of the length of the baseline prior to task.
%	Default value is 5 samples.
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
%             This block                     Next block
%               onset                          onset
%                 |                              |
%    |  Baseline  | Stimulus (Task) | Rest       | 
%  --+------------+-----------------+------------+----
%    |<- Fixed -> |
%        length
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
%   timecourse, the baseline is completed with 0s (inserted by
%   the beginning).
%   5) Rest may last for 0 seconds.
%
%% Output
%
% The block returned is in fact another ecg, which
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
% Copyright 2009
% Author: Felipe Orihuela-Espina
% Date: 6-Mar-2009
%
% See also ecg, dataSource, analysis
%


currRPeaks = get(obj,'RPeaks');
try

	%%%Basically extracting a block is like a cropping operation
	%%% in which the init sample and the end sample are not given
	%%%explicitly but immplicitly. so I need to extract them
	%%%from the timeline before proceed.
	%check that the condition exist
	t=get(obj,'Timeline');
	cond=getCondition(t,condTag);
	if isempty(cond)
    	    obj=[];
    	    return
	end

	%check that the event instance exist
	if ((eventNum>getNEvents(t,condTag)) ...
        	|| (eventNum<1))
    		obj=[];
    		return
	end

	events=getConditionEvents(t,condTag);
	onset=events(eventNum,1);
	duration=events(eventNum,2);
	winInit=onset;
	winEnd=onset+duration;



	obj=getBlock@structuredData(obj,condTag,eventNum,varargin);
        %The data must be set before calling getRR, otherwise
        %we will be operating on old data
	switch(get(obj,'RPeaksMode'))
	    case 'manual'
		%Remove those peaks in the cut interval and
		%shift those beyond the winEnd
		idxPeaksToCrop=find(currRR>=winInit && currRR<=winEnd);
		currRPeaks=currRPeaks(idxPeaksToCrop);
		%and now shift them
		currRPeaks=currRPeaks-winInit;
		obj=set(obj,'RPeaks',currRPeaks); %Clear existing ones
		
	    case 'auto'
            obj.rPeaks=ecg.getRPeaks(get(obj,'Data')); %Automatic update
	    otherwise
		error('ICAF:ecg:getBlock',...
			'Unexpected R Peaks Maintenance Mode.');
	end
catch ME
	%Rethrow the error
        rethrow(ME);
end

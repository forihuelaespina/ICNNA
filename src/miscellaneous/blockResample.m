function [block]=blockResample(block,nSamples,varargin)
% Resample a block (structuredData) to a fixed length
%
% [resampled]=blockResample(block,nSamples) takes a block
%   (structuredData) and resamples it to a new fixed length.
%
% [resampled]=blockResample(...,'ReconcileEdges','on')
% [resampled]=blockResample(...,'ReconcileEdges','off') Enable
%    or disable	edge reconciliation between chunks in case of
%    resampling each chunk separately. By default is 'on'
%
%This function assume that timeline will have only one condition
%with a single event composed of three chunks: baseline, task, and rest
%Hence, it only works in structuredData which have a block structure.
%
% You can have two variants of fixed length:
%   1) Across the whole signal
%   2) Across each chunk separately
%
% The first variant assures you that the signal won't be distorted as new
% samples will be taken at equally spaced steps along the abcisa axe, and
% also, assures you that discontinuities will not be found between the
% block chunks. Beware though that if you are applying this
% function systematically to more than one data, it is almost certain
% that the resulting chunks across the data will have different lengths.
%
% The second variant, which is possibly more useful, might introduce some
% discontinuities on the transition between chunks because of the resample
% function behaviour (see MATLAB's resample function) and also will distort
% the signal as the chunks will need to be stretched. However it has the
% advantage of producing fixed length for the three chunks consistently.
% While there is not too much that can be done about the stretching/
% distortion, the function provides an option to decide whether you
% want the chunk edges to be reconcile (See 'ReconcileEdges').
%
%
%% Parameters:
%
% block - A structuredData.
%
% nSamples - Either a single value indicating the number of samples or
%   a row vector with three positions holding the fixed number of
%   samples for the baseline, the task time and the
%   rest time respectively. The choice will determine the variant of
%   resampling chosen (see above)
%
%        Example: nSamples = [20, 37, 25];
%            Meaning that you will get a signal with 20 samples for the
%            baseline, 37 samples for the task, and 25 samples for the
%            rest. It is recommended to set 'ReconcileEdges' to 'on'.
%
%               nSamples = 70
%            Meaning that you will get a new fixed length signal with a
%            total of 70 points.
%
%   If you specified a vector with three positions holding
%   the fixed number of samples for the baseline, the task
%   and the post-task rest, then you can use a value 0 to indicate
%   that you do not want any samples to be included from that chunk.
%
%
%
%
%% Output:
%
% resampled - A fixed length resampled structuredData
%
%
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also experimentSpace, analysis, structuredData,
% structuredData.getBlock, resample, blocksTemporalAverage
%




%% Log
%
% File created: 27-Jun-2008
% File last modified (before creation of this log): 4-Jan-2013
%
% 27-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%





%Check which variant of resampling (see above) is wanted by checking the
%length of the nSamples input Parameter
if (length(nSamples)==1) %Variant 1> Fixed length across the whole signal
    algorithmVariant=1;
elseif (length(nSamples)==3)  %Variant 2> Fixed length across the chunks
    algorithmVariant=2;
else
    error('ICNNA:miscalleneous:blockResample',...
          'Inappropriate value for parameter nSamples.');
end


%% Deal with options
reconcileEdges=true;

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case 'ReconcileEdges'
            if ischar(val)
                if strcmpi(val,'on')
                    reconcileEdges=true;
                elseif strcmpi(val,'off')
                    reconcileEdges=false;
                else
                    error('ICNNA:miscalleneous:blockResample',...
                        '''ReconcileEdges'' value must be either ''on'' or ''off''.');
                end
            else
                error('ICNNA:miscalleneous:blockResample',...
                    '''ReconcileEdges'' value must be either ''on'' or ''off''.');
            end


        otherwise
            error('ICNNA:miscalleneous:blockResample',...
		  ['Option ''' prop ''' not recognised.'])
    end
end



%% Some initialization

nChannels = block.nChannels;
nSignals  = block.nSignals;
t = block.timeline;
nOriginalSamples = t.length;

%% Find the time marks
%A single condition and single event is assumed.
if (t.nConditions ~= 1)
    error('ICNNA:miscalleneous:blockResample',...
          ['Unexpected number of conditions. '...
           'Data is possibly not a single block.']);
end
condTag=getConditionTag(t,1);
if (getNEvents(t,condTag)~=1)
    error('ICNNA:miscalleneous:blockResample',...
          ['Unexpected number of events/epochs. '...
           'Data is possibly not a single block.']);
end
marks=getConditionEvents(t,condTag);

%Allocate memory
data = block.data;

%%Resample algorithm
switch algorithmVariant
    case 1
    %% Variant 1> Fixed length across the whole signal
        resampled=zeros(nSamples,nChannels,nSignals);
        for cc=1:nChannels
            for ss=1:nSignals
                resampled(:,cc,ss) = resample(data(:,cc,ss),...
                                nSamples, length(data(:,cc,ss)));
            end
        end
        %Calculate the time marks positions manually
        newOnset=round((marks(1)*nSamples)/nOriginalSamples);
        oldEnd=marks(1)+marks(2);
        newEnd=round((oldEnd*nSamples)/nOriginalSamples);
        newDuration=newEnd-newOnset;
        newMarks=[newOnset newDuration];
        %newLength=nSamples;
        newLength=size(resampled,1);
        
    case 2
    %% Variant 2> Fixed length across the chunks
        resampled=zeros(sum(nSamples),nChannels,nSignals);
        if (reconcileEdges)
            %Temporarily borrow the neighbour (or limits) samples...
            baselineChunk=data(1:marks(1),:,:);
            baselineChunk=[data(1,:,:); baselineChunk];
            taskChunk=data(marks(1)-1:min(nOriginalSamples, ...
                                          marks(1)+marks(2)+1),:,:);
            restChunk=data(marks(1)+marks(2):end,:,:);
            restChunk=[restChunk; data(end,:,:)];
        else
            baselineChunk=data(1:marks(1)-1,:,:);
            taskChunk=data(marks(1):marks(1)+marks(2),:,:);
            restChunk=data(marks(1)+marks(2)+1:end,:,:);
        end


        for cc=1:nChannels
          for ss=1:nSignals
            if (nSamples(1)==0)
                baselineResampled = [];
            elseif (reconcileEdges)
                baselineResampled = ...
                    resample (baselineChunk (:,cc,ss), ...
                        nSamples(1)+2, length(baselineChunk(:,cc,ss)));
                %Drop borrowed samples
                baselineResampled(1)=[];
                baselineResampled(end)=[];
            else
                baselineResampled = ...
                    resample (baselineChunk (:,cc,ss), ...
                        nSamples(1), length(baselineChunk(:,cc,ss)));
                
            end
            if (nSamples(2)==0)
                taskResampled = [];
            elseif (reconcileEdges)
                taskResampled = ...
                    resample (taskChunk (:,cc,ss), ...
                        nSamples(2)+2, length(taskChunk(:,cc,ss)));
                %Drop borrowed samples
                taskResampled(1)=[];
                taskResampled(end)=[];
            else
                taskResampled = ...
                    resample (taskChunk (:,cc,ss), ...
                        nSamples(2), length(taskChunk(:,cc,ss)));
            end
            if (nSamples(3)==0)
                restResampled = [];
            elseif (reconcileEdges)
                restResampled = ...
                    resample (restChunk (:,cc,ss), ...
                        nSamples(3)+2, length(restChunk(:,cc,ss)));
                %Drop borrowed samples
                restResampled(1)=[];
                restResampled(end)=[];
            else
                restResampled = ...
                    resample (restChunk (:,cc,ss), ...
                        nSamples(3), length(restChunk(:,cc,ss)));
            end
        
            resampled(:,cc,ss) = [baselineResampled'; ...
                taskResampled'; ...
                restResampled'];
            clear baselineResampled taskResampled postrestResampled
          end
          %Insert the time marks manually (trying to resampling the timeline,
          %newMarks=[nSamples(1)+1 nSamples(1)+nSamples(2)];
          newMarks=[nSamples(1)+1 nSamples(2)];
          %newLength=sum(nSamples);
          newLength=size(resampled,1);
        end
    otherwise
        error('ICNNA:miscalleneous:blockResample',...
             ['Inappropriate value for parameter nSamples.']);
end

assert(newLength==sum(nSamples), ...
        ['ICNNA:miscalleneous:blockResample:'...
        'Unexpected length after resampling']);

s = warning('off', 'ICNNA:timeline:set:EventsCropped');
block.data = resampled;
%% re-establish the new timeline
t=timeline(newLength,condTag,newMarks);
block.timeline = t;
warning(s);


end

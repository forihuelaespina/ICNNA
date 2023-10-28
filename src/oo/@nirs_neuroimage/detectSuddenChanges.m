function [idx,reconstructed,alpha,gamma,allIdx]=detectSuddenChanges(signals,thresholdPC,options)
%Detects where sudden changes are happening and corrects the signal
%
% [idx,reconstructed,alpha,gamma,allIdx]=detectSuddenChanges(signal,thresholdPC,options)
%
%=============================================
%18-Jun-2007: Felipe Orihuela-Espina
%   Extension to more than one signal at a time
%20-Jun-2007: Felipe Orihuela-Espina
%   Now includes the "double checking", but not in use
% sice it does not "clearly" improve results. If
% anything, the results with double testing seems
% to be somehow worst.
%=============================================
%
% Detects where sudden changes (both raise or drops) are happening.
% and corrects the signal if required
%
%If only one signal is provided then the algorithm will find the
%changes in the signal which are larger than the threshold.
%Please, note that changes are not compare to the previous
%sample value, but with the prediction given by a double
%exponential smoothing time series fitting.
%If more than 1 signal (e.g. channel data) is provided as input,
%the algorithm will only report those sudden changes which
%are present in all signals at the same time. Further more,
%this changes must have the same sign, in order to be considered
%as a sudden change.
%
%A threshold set by the user in percentage terms is translated to
%absolute terms by calculating the range of the signal values
%(max-min), and then multiplying by the threshold (and dividing
%by 100). I need to think whether a normalized [0 1] range to
%express the threshold might be better.
%
%The changes are evaluated against a prediction made using time
%series analysis, rather than simply using the last value.
%A double exponential smoothing is used for the prediction, with
%alpha=0.9 and gamma=0.7. Currently these parameters are fixed,
%but I might change this later.
%
%At every sample, a prediction is made base on all the previous
%samples. Once a prediction is made, the forecast at the i-th sample
%is substracted from the i-th sample value of the signal in order
%to calculate the change. Note that by using a prediction rather than
%simply the last value, an attempt is made to allow the signal to have
%large variations which are really part of the signal and not due to
%a sudden drop or raise, in the sense that the forecast should at least
%catch part of this change.
%
%The difference between the signal and the prediction is compared with
%the threshold to decide whether there's a sudden change.
%
%
%
%% Parameters:
%
% signals - The signals. It can be a single signal (a column vector)
%   or a set of signals, a matrix where each column represent
%   a signal.
% thresholdPC - The threshold in percentage (i.e. 5 means 5%).
%
% options - An struct with several fields indicating some options.
%   Following is a list of the available options (fieds of the struct)
%
%   .optimize: Decide whether model parameters values (0<=alpha<=1)
%       and gamma should be optimized. True by default.
%       Optimizing the model
%       parameters slows down the algorithm. Default values when
%       not optimized are alpha=0.9 and gamma=0.7. These values
%       can be overridden using the corresponding options.
%
%   .alpha: Model parameter alpha value (0<=alpha<=1). Default 0.9
%       This options wil only be active if .optimize=false;
%       otherwise it will be ignored
%   
%   .gamma: Model parameter gamma value (0<=gamma<=1). Default 0.7
%       This options wil only be active if .optimize=false;
%       otherwise it will be ignored
%   
%   .visualize: Plot the results. False by default.
%
%   .correct: Set it to true if you want the signal to be
%       corrected. False by defualt.
%
%% Output:
%
% idx - The indexes of the samples at which a sudden drop or raise has
%   been detected for all signals.
%
% reconstructed - The signals either original or reconstructed
%depending on the value of options.correct
%
% 
% Copyright 2007-23
% @author: Felipe Orihuela-Espina
%
% See also nirs_neuroimage
%




%% Log
%
%
% File created: 17-May-2007
% File last modified (before creation of this log): 20-Jun-2007
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%





%Deal with some options
opt.optimize=true;
opt.alpha=0.9;
opt.gamma=0.7;
opt.visualize=false;
opt.correct=false;
if(nargin>2)
    if(isfield(options,'optimize'))
        opt.optimize=options.optimize;
    end
    if(isfield(options,'alpha'))
        opt.alpha=options.alpha;
    end
    if(isfield(options,'gamma'))
        opt.gamma=options.gamma;
    end
    if(isfield(options,'visualize'))
        opt.visualize=options.visualize;
    end
    if(isfield(options,'correct'))
        opt.correct=options.correct;
    end
end

[nSamples,nSignals]=size(signals);

for ss=1:nSignals
    if (opt.optimize)
        [alpha,gamma]=nirs_neuroimage.optimizeDESWeights(signals(:,ss));
    else
        alpha=opt.alpha;
        gamma=opt.gamma;
    end
    [model,b,f]=nirs_neuroimage.doubleES(signals(:,ss)',alpha,gamma);
    forecasts(:,ss)=f'; %forecasts
    firstDiff(:,ss)=signals(2:end,ss)-signals(1:end-1,ss); %First differences
end
%Note that forecasts will have 1 sample more (t+1) than the signal
%Simply ignore that last one...
forecasts(end,:)=[];
%The first differences will have 1 sample less, so insert a zero
%for first sample
firstDiff=[zeros(1,nSignals); firstDiff];

err=abs(signals-forecasts); %For easy comparison with threshold
errSgn=signals-forecasts; %To know whether is a raise or a drop

%Threshold express in percentage. Translate to absolute value.
threshold=(max(signals)-min(signals))*thresholdPC/100;
%Use the line below for an example of adaptive thresholding...
%%Remember: This has an important drawback!. It will always find a
%%threshold which detect at least 1 sudden change, as the histogram is
%%splitted in two parts. Thus ALL signal will always be considered noisy!
%threshold=getThresholdPoint(signal);

%Initially, there might be potential changes anywhere.
%This list of location will be trimmed by the subsequent
%intersection operations with the idx where changes are
%detected for each signal. Ultimately, only those indexes
%where changes have been found for all signals will remain.
idx=[1:1:nSamples];
%Finally mark the places where changes larger than the threshold
%are detected for all signals
for ss=1:nSignals
    %Get the location of sudden changes (i.e. where the error is larger
    %than the threshold)
    tempIdx=find(err(:,ss)>threshold(ss)); 
    %%The double checking
    %tempIdx=find((err(:,ss)>threshold(ss)) | (firstDiff(:,ss)>threshold(ss))); 
    idx = intersect(idx,tempIdx);
    clear tempIdx
end
%At this point, only idx where changes are present in all signals
%remains

%Merge "too close" detections
%%NOTE: I have notice that a very common pattern of detection is two idx
%%which are not consecutive but the step is only of 1 or 2 idx. This makes
%%the algorithm to appear extremely sensitive. So an option is to "merge"
%%changes when they are very close together...say 1 or 2 idx apart. This is
%%equivalent to "fill" those spaces. This is necessary as well so that
%%the reconstruction algorithm works properly.
for ii=length(idx)-1:-1:1
    if(idx(ii+1)==idx(ii)+2)
        idx=[idx(1:ii) idx(ii)+1 idx(ii+1:end)]; %Insert the missing "mark"
                                %so that both sudden changes get merged
    end
end


allIdx=idx; %for the reconstruction

%Remove consecutive idx...
%This is equivalent to leave the forecast, time to recover
for ii=length(idx)-1:-1:1
    if(idx(ii+1)==idx(ii)+1)
        idx(ii+1)=[];
    end
end

%Finally check the sign, and remove those locations
%where changes haven't got the same sign for all signal
signs=errSgn(idx,1); %Just for initialisation purposes
for ss=2:nSignals
    signs=signs.*errSgn(idx,ss);
    %If same sign, then the multiplication will give a
    %positive value
    idx(find(signs<=0))=[]; %Remove those locations
        %where the change hasn't got the same sign
        %for all signals...
end


%=========================
%Correction
%=========================
%To reconstruct the signal, I need to calculate the
%absolute magnitude of the change (i.e. the offset introduced
%by the sudden change). Unfortunately it is not enough
%to simply substract the sample t from t-1, as the sudden change
%can expand a few samples...
%You cannot even try to look for the value a certain fixed number
%of samples ahead, because we do not know how long will take
%the signal to stabilise after a sudden change.
%In this situation, the only thing we can do, is actually look
%for the first location where the signal has already stabilised,
%and calculate the offset induced by the sudden change
%as the difference between the prediction where the sudden change
%occur and the value of the signal, where it stabilises.
%Note that we cannot try to take a few values and do some
%averaging as other sudden changes might follow.

if(opt.correct)
%First we find those idx where the signal has stabilised...
%This can be done by starting in the "changes" indexes, and
%follow consecutive indexes until the next idx is not
%consecutive
stabilizationIdx=[]; %to store the corresponding index
                %at which the signal stabilizes
for ii=1:length(idx)
    changeIdx=idx(ii);
    [temp,pos]=find(allIdx==changeIdx);
    while (pos+1<=length(allIdx))
        if(~(allIdx(pos)+1==allIdx(pos+1)))
            break
        end
        pos=pos+1;
    end
    
    if(pos+1<=length(allIdx))
        stabilizationIdx=[stabilizationIdx allIdx(pos)+1];
    else
        %The last change did never stabilised, so simply
        %take the last idx
        stabilizationIdx=[stabilizationIdx allIdx(end)];
    end
end
% idx
% allIdx
% stabilizationIdx

%Now calculate the offset between the signal before the
%change was detected (to make it more stable I took 3 values)
%and the signal after the change once stabilised
for ss=1:nSignals
    if (idx>3)
        a=[signals(idx-3,ss) ...
                signals(idx-1,ss) ...
                signals(idx-2,ss)];
    else
        a=signals(idx-1,ss);
    end

%     a=[forecasts(idx,ss) ...
%     forecasts(idx-1,ss) ...
%     forecasts(idx-2,ss)];
    
    %offsets(ss,:)=(forecasts(idx,ss)-signals(stabilizationIdx,ss))';
    offsets(ss,:)=(mean(a,2)-signals(stabilizationIdx,ss))';
    
    %and correct for the offset...
    reconstructed(:,ss)=signals(:,ss);
    for ii=1:length(idx)
        reconstructed(idx(ii):end,ss)=...
            reconstructed(idx(ii):end,ss)+offsets(ss,ii);
                %Note how the offsets are accumulated...
        %Smooth the intervals where the signal if not stable...
        reconstructed(idx(ii):stabilizationIdx(ii)-1,ss)=...
            reconstructed(stabilizationIdx(ii),ss);
    end
    %Finally detrend the signal again...
    %reconstructed=detrend(reconstructed);
    
end


else %Do not correct
    reconstructed=signals;
end



%=========================
%Plot if required
%=========================
if(opt.visualize)
    
    lineWidth=1.5;
    colors='rbygmk';
    
    %figure,
    hold on
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    legendTags={};
    for ss=1:nSignals
        h(ss)=plot(signals(:,ss),[colors(ss) '-'],'LineWidth',lineWidth);
        legendTags{end+1} = ['Signal ' num2str(ss)];
        if(opt.correct)
            hR(ss)=plot(reconstructed(:,ss),[colors(ss+3) '--'],'LineWidth',lineWidth);
            legendTags{end+1} = ['Reconstructed ' num2str(ss)];
        end
        %herr(ss)=plot(err(:,ss),[colors(ss) '--'],'LineWidth',lineWidth);
        %%plot(firstDiff(:,ss),[colors(ss+2) '--'],'LineWidth',lineWidth);
        %legendTags{end+1} = '|Signal-forecasts|';
        %plot(temp,[colors(ss) '.'],'LineWidth',lineWidth)
        %hthresh(ss)=plot([0 length(signals(:,ss))],[threshold(ss) threshold(ss)],...
        %    [colors(ss) ':'],'LineWidth',lineWidth);
        %legendTags{end+1} = ['Threshold ' num2str(thresholdPC) '%'];
    end
    
    set(gca,'XLim',[0 nSamples]);

    getY=axis;
    for ii=1:length(idx)
        %%%In order to be considered a sudden change,
        %%%the change mustt show the same sign in in all
        %%%signals, so it does not matter too much which
        %%%signals is looked at to mark the sign :)
        if (errSgn(idx(ii))>0) %Raise
            plot([idx(ii) idx(ii)],[getY(3) getY(4)],'k--','LineWidth',lineWidth)
        else %Drop
            %...Note that it will not be 0 in any case,
            %as these are the points above the threshold...
            plot([idx(ii) idx(ii)],[getY(3) getY(4)],'k--','LineWidth',lineWidth)
        end
        
    end
    box on, grid on
%     legend('Original Signal','|Signal-forecasts|',...
%         '|Signal_t-signal_{(t-1)}|', ...
%         ['Threshold ' num2str(thresholdPC) '%'])
    %legend([h; hR; herr; hthresh],legendTags)
    if (opt.correct)
        legend(reshape([h;hR],1,numel([h;hR])),legendTags)
    else
        legend(h,legendTags)
    end
    fontSize=13;
    set(gca,'FontSize',fontSize)
    xlabel('Time (samples)','FontSize',fontSize)
    ylabel('\Delta Hb','FontSize',fontSize)
    %title('Optode movement detection algorithm','FontSize',fontSize)
    
end
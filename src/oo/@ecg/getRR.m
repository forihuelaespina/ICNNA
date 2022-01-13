function [rr]=getRR(obj)
%ECG/GETRR Extracts R to R intervals from the raw ECG data
%
% [rr]=getRR(obj) Extracts R to R intervals from the raw ECG data
%
%
%% R to R intervals
%
% Interbeat intervals represent the time intervals between
%consecutive heart beats. Interbeat intervals can be measure
%in the electrocardiogram
%either from the beginning of one QRS complex to the beginning of
%the next WRS complex (usually referred to as Q to Q intervals).
%Alternatively they can be measure using the R-wave peak as
%the reference point, and in that case the it is referered to as
%the R to R intervals.
%
%It has been argued (http://www.physionet.org/tutorials/hrv/)
%that using the R to R is more reliable than the Q to Q, as the
%R peaks are more easily found/determined.
%
%
%% Remarks
%
% This function COMPUTES the R to R intervals from current data. For
%a quick access to pre-computed R to R intervals, please use get(obj,'RR')
%
%% Parameter
%
% obj - The ECG (electrocardiogram) object.
%
%% Output
%
% rr - The R to R intervals (per sec).
%
%
% Copyright 2009
% Author: Felipe Orihuela-Espina
% Date: 19-Jan-2009
%
% See also ecg, getRPeaks, sdnn, sdann, rmssd
%


%% Log:
%
% 29-May-2019: FOE:
%   + Log started
%   + Substituted the main loop for array operations, for faster operation
%



%% Deal with some options
opt.visualize=false;
if(nargin>1)
    if(isfield(options,'visualize'))
        opt.visualize=options.visualize;
    end
end

timestamps=get(obj,'Timestamps');
nSamples=length(timestamps);


%HRsignal=get(obj,'Data');
%rPeaks=ecg.getRPeaks(HRsignal);
rPeaks=get(obj,'RPeaks');

%Pre-find last 2 peaks
peaksbool = zeros(nSamples,1);
peaksbool(rPeaks)=1; %Convert rPeaks to a "logical" array
peaksbefore=cumsum(peaksbool); %Index to last peaks 
peaksbefore(peaksbefore<=0)=NaN; %Ignore samples before the first peak
OnePeakBeforeIdx = ones(size(peaksbefore));
OnePeakBeforeIdx(~isnan(peaksbefore)) = rPeaks(peaksbefore(~isnan(peaksbefore)));
TwoPeakBeforeIdx = ones(size(peaksbefore));
TwoPeakBeforeIdx(~isnan(peaksbefore) & (peaksbefore>1)) = rPeaks(peaksbefore(~isnan(peaksbefore) & (peaksbefore>1))-1);
    %Convert peaks indexes to peaks (Yeah, I know double indirection aren't the most clear coding!)
Last2Peaks = [OnePeakBeforeIdx TwoPeakBeforeIdx];

%Calculate RR intervals
tmpTimesAtPeaks=timestamps(Last2Peaks);
rr=(tmpTimesAtPeaks(:,1)-tmpTimesAtPeaks(:,2))/1000; %in sec

% %Convert the peaks into the R to R intervals (per sec)
% rr=zeros(nSamples,1);
% for ii=1:nSamples
%     %find the two last beats
%     tmpIdx=find(rPeaks<=ii,2,'last'); %Note that rPeaks are already indexes!
%     %and calculate the time interval
%     if (length(tmpIdx)<2) || (any(tmpIdx)==0)
%         tInterval=NaN;
%     else
%         beatIdx=rPeaks(tmpIdx);
%         tmpTimesAtPeaks=timestamps(beatIdx);
%         tInterval=(tmpTimesAtPeaks(2)-tmpTimesAtPeaks(1))/1000; %in sec
%     end
%     rr(ii)=tInterval;
% end


%% Visualization =========================================
if (opt.visualize)
    lineWidth=1.5;
    fontSize=13;
    
    %R to R intervals (per sec)
    figure
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    
    plot(rr,'k-','LineWidth',lineWidth);
    %set(gca,'YLim',[0.5 1.2]);
    box on, grid on  
    ylabel('RR (sec)','FontSize',fontSize);
    xlabel('Time (samples)','FontSize',fontSize);
    title('Interbeat R to R intervals','FontSize',fontSize);
    set(gca,'FontSize',fontSize);


end

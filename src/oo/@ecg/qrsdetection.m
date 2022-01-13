function [rPeaks]=qrsdetection(ecgdata,options)
%Detect R peaks
%
% [QRSfiducials]=qrsdetection(ecgdata,options)
% 
% Uses algorithm in Ref [1] (just slightly tweak for the fact that this is
% not streamed data). This is a sophisticated alternative to my getRPeaks.
% getRpeaks is faster, but this have much better tolerance to noise in the
% ecg data.
%
%% Parameter
%
% ecgdata - Raw ECG (electrocardiogram) data series
%
% options - A struct with options
%     maskhalfsize - Half-width of the enhancement mask in [samples].
%           By default is set to 2.
%     searchingrange - Search window size in [s]. Recommended
%           values:
%               * For adults = 0.3;
%               * For babies = 0.1;
%     samplingrate - Sampling rate in [Hz]. Necessary to translate samples
%            to secs. By default is set to 50 Hz.
%     qrsminimumamplitude - A threshold used for triggering the QRS
%            search over a normalized range [-1 1]. By default is set to
%            0.5Hz
%     thresholdcrest - A threshold used for detecting crests. Recommended
%           values:
%               * For adults = 0.22;
%               * For babies = 0.4;
%     thresholdcrest - A threshold used for detecting trough. Recommended
%           values:
%               * For adults = -0.2;
%               * For babies = -0.4;
%     QRSlateny - Latency between two QRS in [s]. Recommended
%           values:
%               * For adults = 0.12;
%               * For babies = 0.06;
%           Smaller values may be good for detcting arryhtmias.
%     nboundarysamples - Controls alleviation of boundary effects in number
%           of samples around the edge that are ignored. By default is set
%           to 5.
%   
%
%
%% Reference:
% [1] Chieh-Li Chen 1 and Chun-Te Chuang
% "A QRS Detection and R Point Recognition Method for Wearable Single-Lead ECG Devices"
% Sensors (2017) 17:1969, doi:10.3390/s17091969
%
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5621148/pdf/sensors-17-01969.pdf
%
%
% See also pipePreemies0103_Pilot_HRanalysis
%



%% Log:
%
%
% @copyright 2019
% @author: Felipe Orihuela-Espina
% 
% 16-May-2019: FOE:
%   + File creation
%


opt.maskhalfsize = 2; %Half-width of the enhancement mask in [samples]
%opt.searchingrange = 0.3; %in [s]. For adults
opt.searchingrange = 0.1; %in [s]. For children
opt.samplingrate = 50; %[Hz] Necessary to translate samples to secs
%opt.samplingrate = 200; %[Hz] Necessary to translate samples to secs
opt.qrsminimumamplitude = 0.5; %in [mV]. Used for triggering the QRS search.
    %FOE> Not really in [mV], because of normalization, but that is what the paper says!
    %This value MUST be strictly bigger than opt.thresholdcrest
opt.thresholdcrest = 0.22;
%opt.thresholdcrest = 0.4;
opt.thresholdtrough = -0.2;
%opt.thresholdtrough = -0.4;
opt.QRSlateny=0.12; %In [s]. Latency between two QRS. For adults
%opt.QRSlateny=0.06; %In [s]. Latency between two QRS. For child
%opt.QRSlateny=0.03; %In [s]. Latency between two QRS. For child plus allow arrythmias
opt.nboundarysamples = 5; %Controls alleviation of boundary effects


assert(opt.qrsminimumamplitude>opt.thresholdcrest,...
    'opt.qrsminimumamplitude must be bigger than opt.thresholdcrest')

% 1) Band pass EKG Filter [0.5 17]
Hd = design(fdesign.bandpass('N,Fc1,Fc2',4,0.5,17,opt.samplingrate)); %design an order 4 bandpass FIR filter
fecgdata = filtfilt(Hd.Numerator,1,ecgdata); %Apply zero-phase filter. Since the filter is FIR, its denominator coefficient is simply 1.
fecgdata = fecgdata +(mean(ecgdata)-mean(fecgdata)); %Eliminate filter gain
%clear ecgdata

%1b) Alleviate boundary effects and remove ultra massive peaks before continue
%FOE: This is not in the original algorithm. I'm adding this step
%becuase if some massive peaks have survived, or if the filterings had some
%boundary misbehave it will completely distort the
%normalization
fecgdata = alleviateBoundaryEffects(fecgdata,opt.nboundarysamples);
fecgdata = capOutliers(fecgdata);


% 2) Enhancement mask
M = [-ones(1,opt.maskhalfsize) 2*opt.maskhalfsize -ones(1,opt.maskhalfsize)];
secgdata = conv(fecgdata,M,'same');

%Lap of Gaussian not working very well here
% M=[1 3 -7 -24 -7 3 1];
% normFactor=1/sum(M);
% secgdata=normFactor*conv(fecgdata,M,'same');


secgdata = alleviateBoundaryEffects(secgdata,opt.nboundarysamples);
secgdata = capOutliers(secgdata);
secgdata = secgdata +(mean(fecgdata)-mean(secgdata)); %Eliminate conv gain
%clear fecgdata

% 3) Normalization to eliminate person to person variability
%(See Ref [1, pg 4. Last paragraph])
mecgdata = myrescale(secgdata,-1,1); %Rescale to [-1 1]
%clear secgdata


% 4) QRS Fiducial Point Detection
eventsIdx= find(mecgdata>opt.qrsminimumamplitude); %Trigger detection of QRS fiducials
nEvents = length(eventsIdx);
Crests=[];
Troughs=[];
QRSStarts = nan(nEvents,1);
QRSfiducials = [];
iEvent=0;
while ~isempty(eventsIdx)
    iEvent=iEvent+1;
    
    currentEventWindow = eventsIdx(1)-floor(opt.searchingrange*opt.samplingrate):eventsIdx(1);
    QRSStarts(iEvent) = currentEventWindow(1); %Starting point of the QRS window. It shouldn't be empty since the QRS search has been triggered.
    %For early peaks, the window may expand BEFORE the start of the signal.
    %For late peaks, the window may expand AFTER the start of the signal.
    %Crop the window accordigly
    outIdx=find(currentEventWindow<=0 | currentEventWindow>length(mecgdata));
    currentEventWindow(outIdx) =[];
    
    
    idxOtherEvents  = eventsIdx(2:end)-eventsIdx(1); %Indexes are local to window
    idxCrests  = find(mecgdata(currentEventWindow)>opt.thresholdcrest); %Indexes are local to window
    idxTroughs = find(mecgdata(currentEventWindow)<opt.thresholdtrough); %Indexes are local to window
    
    
    %Consume current event
    eventsIdx(1) = [];
    
    
    %Clean the detection of peaks and troughs by merging together those
    %inmediately 
    %FOE: This is not in the original algorithm. But since both, my crests
    %and troguhs last for longer than 1 sample, the cases below fail to
    %detect anything.
    %contIdx=find(idxCrests(2:end)==idxCrests(1:end-1)+1);
    contIdx=find(idxCrests(2:end)==idxCrests(1:end-1)+1);
    idxCrests(contIdx)=[];
    contIdx=find(idxTroughs(2:end)==idxTroughs(1:end-1)+1);
    idxTroughs(contIdx)=[];


    
    Crests = [Crests; idxCrests+QRSStarts(iEvent)]; %Indexes are global to signal
    Troughs = [Troughs; idxTroughs+QRSStarts(iEvent)]; %Indexes are global to signal
    
    %Case I:
    %If only one crest and only one trough exist within the specified searching range, the instance
    %corresponding to the crest is defined as the QRS fiducial point and search for the next starting
    %point after the detected trough.
    if (length(idxCrests)==1 & length(idxTroughs)==1)
        QRSfiducials(end+1)=idxCrests(1)+QRSStarts(iEvent);
        %Latency. Remove any event between the crest and the through
        eventsWithinLatencyPeriod = length(find(idxOtherEvents<idxTroughs));
        eventsIdx(1:eventsWithinLatencyPeriod) = [];
        
    %Case II:
    %If two crests are within the searching range and one trough exists between the crests, then the
    %trough is defined as the QRS fiducial point and search for the next starting point from 0.12 s after
    %the detected trough is for. It is noted that a normal QRS waveform has a duration of 0.12 s.
    elseif (length(idxCrests)==2 & length(idxTroughs)==1)
        QRSfiducials(end+1)=idxTroughs(1)+QRSStarts(iEvent);
        %Latency. Remove any event between the crest and the through
        eventsWithinLatencyPeriod = length(find(idxOtherEvents<opt.QRSlateny*opt.samplingrate));
        eventsIdx(1:eventsWithinLatencyPeriod) = [];

    %Case III:
    %If there is only one crest with a value higher than another threshold of 0.52 within the searching
    %range, then the crest is defined as the QRS fiducial point and search for the next starting point
    %from 0.12 s after the detected crest. This case is a special case which can be referred to the MIT-BIH
    %arrhythmia database Record 104 and 107.
        %%%%THIS IS A SPECIAL CASE AND HENCE NOT ATTENDED

    %Case IV (Case otherwise):
    %If it is not case I, case II, or case III, then search for the next starting point corresponding to the
    %next crest
    else
    end
end

rPeaks = QRSfiducials;

% figure
% hold on
% plot(ecgdata,'r-')
% % plot(fecgdata,'g-')
% % plot(secgdata,'b-')
% % % plot(repmat(mean(secgdata),[1 length(secgdata)]),'b--','LineWidth',2)
% % % plot( 3*mean(secgdata)+repmat(mean(secgdata),[1 length(secgdata)]),'b:','LineWidth',2)
% % % plot(-3*mean(secgdata)+repmat(mean(secgdata),[1 length(secgdata)]),'b:','LineWidth',2)
% % %plot(secgdata2,'b-','LineWidth',2)
% % %set(gca,'YLim',[0.03 0.04])
% plot(QRSfiducials,mean(secgdata)*ones(length(QRSfiducials),1),'ko','LineWidth',2)
% %yyaxis right
% %hold on
% % plot(mecgdata,'m-','LineWidth',2)
% % plot(Crests,ones(length(Crests),1),'bs','LineWidth',2)
% % plot(Troughs,ones(length(Troughs),1),'gd','LineWidth',2)
% %plot(QRSfiducials,ones(length(QRSfiducials),1),'ko','LineWidth',2)
% 
% 
% tmp=ecg.getRPeaks(ecgdata);
% plot(tmp,mean(secgdata)*ones(length(tmp),1)+0.05,'gd','LineWidth',2)
% 

end



%% Auxiliary function
function B=myrescale(A,l,u)
%This coincides with MATLAB's Data Import and Aalsysis Toolbox function
%rescale.
B= l + [(A-min(A))./(max(A)-min(A))].*(u-l); %Rescale to [-1 1]
end

function B=capOutliers(A)
%Cap values beyond 3 std
nstd = 3;
tmpMean = mean(A);
B = A - tmpMean;
idx= abs(B) > nstd*std(B);
B(idx) = nstd*std(B)*sign(B(idx));
B = B + tmpMean;
end

function A=alleviateBoundaryEffects(A,nBoundarySamples)
tmp=mean(A(nBoundarySamples:end-nBoundarySamples));
A([1:nBoundarySamples end-nBoundarySamples:end])=tmp;
%A(end-nBoundarySamples:end)=tmp;
end
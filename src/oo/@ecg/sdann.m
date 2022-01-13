function s=sdann(obj,periodDuration)
%ECG/SDANN Standard deviation of the average NN interval over a period
%
% s=sdann(obj) Standard deviation of the average NN interval over a short
% period in ms. By default the period will be 5 min (300000 miliseconds).
%
% s=sdann(obj,periodDuration) Standard deviation of the
% average NN interval over a certain period (expressed in miliseconds).
%
%
%% NN intervals
%
% NN intervals (normal to normal) are intervals between adjacent QRS
% complexes in the ECG signal. The NN serie can be characterized by
% the R to R intervals (see getRR function).
%
%   +=======================================+
%   | NN intervals when characterized by RR |
%   | intervals are usually reported in     |
%   | seconds, whereas SDNN is commonly     |
%   | reported in ms [1].                   |
%   +=======================================+
%
%% SDANN
%
% Standard deviation of the average NN interval
%over a short period (SDANN) splits the full time
%course of the NN intervals into episodes or periods
%of a fixed duration and computes the SDNN for each
%of this periods.
%
% Normal range for a nominal 24h recording is 127+/-35 ms [1].
%
% Note that the last period may be shorter than the indicated
%period duration of there is not enough data to complete it.
%
%
%
%% Parameters
%
% ecg -  The ECG object
%
%
%% Reference
%
% [1] - Heart rate variability: standards of measurement, physiological
% interpretation and clinical use. Task Force of the European Society
% of Cardiology and the North American Society of Pacing and
% Electrophysiology. Malik et al (1996) European Heart Journal 17:354-381
%
%
%
% Copyright 2009
% Author: Felipe Orihuela-Espina
% Date: 19-Jan-2009
%
% See also ecg, getRR, sdnn, rmssd
%


pDuration=300000; %in ms; By default is 5 min
if exist('periodDuration','var')
    pDuration=periodDuration;
end

timestamps=get(obj,'Timestamps');
nn=get(obj,'RR');
nSamples=size(nn,1);

endIntervalIdx=0;
pos=1;
while endIntervalIdx < nSamples
    startIntervalIdx=endIntervalIdx+1;
    currTime=timestamps(startIntervalIdx);
    endTime=currTime+pDuration;
    endIntervalIdx=find(timestamps < endTime,1,'last');
    s(pos)=nanstd(nn(startIntervalIdx:endIntervalIdx));
    pos=pos+1;
end
%Since the NN intervals units are in seconds, but the sdann is usually
%reported in miliseconds, I need to convert from secs ti milisecs
s=s*1000;

function s=rmssd(obj)
%ECG/RMSSD Square root of the mean squared differences of successive NN intervals
%
% s=rmssd(obj) Square root of the mean squared differences of
%   successive NN intervals, in miliseconds.
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
%   | seconds, whereas RMSSD is commonly    |
%   | reported in ms.                       |
%   +=======================================+
%
%% RMSSD
%
% Let $NN_i$ be the i-th NN interval.
%
%
% $$ RMDSD(NN)=\sqrt{\overbar{(NN_i-NN_{i-1})^2}} $$
%
%where $\overbar{(NN_i-NN_{i-1})$ represent the mean of
%successive NN intervals. The result is experessed in miliseconds.
%
% Normal range for a nominal 24h recording is 27+/-12 ms [1].
%
%% Parameters
%
% obj - The ECG object
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
% See also ecg, getRR, sdnn, sdann, nn50, pnn50
%

nnIntervals=get(obj,'RR');
intervalDiff=nnIntervals(2:end)-nnIntervals(1:end-1);
%Since the NN intervals units are in seconds, but the rmssd is usually
%reported in miliseconds, I need to convert from secs ti milisecs
intervalDiff=intervalDiff*1000;
intervalDiff(intervalDiff==0)=[]; %Catch only the samples at which there
                                %is a new NN interval
intervalDiff(isnan(intervalDiff))=[];
s=sqrt(nanmean(intervalDiff.^2));


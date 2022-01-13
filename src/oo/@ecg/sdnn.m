function s=sdnn(obj)
%ECG/SDNN Standard deviation of all NN intervals
%
% s=sdnn(obj) Standard deviation of all NN intervals in ms
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
%% SDNN
%
% Standard deviation of the NN interval (SDNN) is the simplest
% characterization of the HRV in the time domain.
%
% Normal range for a nominal 24h recording is 141+/-39 ms [1].
%
%   +=========================================+
%   | SDNN is dependent on the length of the  |
%   | recording, hence, it is inappropriate   |
%   | to compare SDNN obtained from recordings|
%   | of different durations [1].             |
%   +=========================================+
%
%% Parameters
%
% obj - The ECG object
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
% See also ecg, getRR, sdann, rmssd
%

nn=get(obj,'RR');
s=nanstd(nn)*1000;
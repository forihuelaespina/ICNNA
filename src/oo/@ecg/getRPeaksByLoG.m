function [rPeaks,threshold]=getRPeaksByLoG(HRsignal,thresh)
%
% [rPeaks,threshold]=getRPeaksByLoG(HRsignal) finds the indexes of
% samples at which the QRS complexes wave peaks, or R peaks
% using an automatic statistically optimal threshold (See
% section Algorithm).
%
% rPeaks=getRPeaksByLoG(HRsignal,thresh) finds the indexes of samples
% at which the QRS complexes wave peaks, or R peaks using the
% specified threshold.
%
%% Algorithm
%
% It uses a Laplacian of a Gaussian over the raw ecg signal to detect
%discontinuities. Then it applies a threshold to the LoG and finally groups
%continuous groups peaks (thinning). The threshold can be computed
%automatically using Calvard and Riddler optimal threhsolding algorithm,
%or manually selected (parameter thresh).
%
%
% Laplacian of the Gaussian
%
% LoG 1D Masks: [-2 0 2]
% Laplacian of the Gaussian a.k.a. Mexican hat (*)
% * Combination of low and high pass filter
% * A Laplacian smoothed by a Gaussian
% * Mask (7x7):
%    0  0 -1 -1 -1  0  0
%    0 -1 -3 -3 -3 -1  0
%   -1 -3  0  7  0 -3 -1
%   -1 -3  7 24  7 -3 -1
%   -1 -3  0  7  0 -3 -1
%    0 -1 -3 -3 -3 -1  0
%    0  0 -1 -1 -1  0  0
%
%Masks of different sizes:
%LoG=[1 -2 1];
%LoG=[4 -8 4];
%LoG=[1 -8 1];
%LoG=[1 2 -16 2 1];
%LoG=[1 3 -7 -24 -7 3 1]; <- This is the one currently used
%
%
%% Parameter
%
% HRsignal - Raw ECG (electrocardiogram) data series
%
% thresh - Optional. A threshold established manually.
%
%% Output
%
% A column vector of samples indexes to the R peaks
%
%
% Copyright 2009
% Author: Felipe Orihuela-Espina
% Date: 19-Jan-2009
%
% See also ecg, getRR, getBPM
%

%% Log:
%
% 29-May-2019: FOE:
%   + Log started
%   + Code separated from getRPeaks
%

LoG=[1 3 -7 -24 -7 3 1];
normFactor=1/sum(LoG);

tmp1=normFactor*conv(HRsignal,LoG);
tmp1(1:floor(length(LoG)/2))=[];
tmp1(end-floor(length(LoG)/2)+1:end)=[];
tmp1=-1*(HRsignal-tmp1);

if exist('thresh','var')
    threshold=thresh;
else
    threshold=ecg.optimalThreshold(abs(tmp1));
end
rPeaks=find(tmp1>threshold)'; %Indexes to R peaks

%Group together
tmpIdx=find(rPeaks(2:end)==rPeaks(1:end-1)+1);
rPeaks(tmpIdx)=[];

%Manually discard the boundaries; which obviously are always detected
rPeaks(end)=[];
rPeaks(1)=[];


end
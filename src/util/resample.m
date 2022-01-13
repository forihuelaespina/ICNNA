function  [y, h] = resample( x, p, q, N, beta )
%Substitue for MATLAB's resample function
%
% See MATLAB's resample function!! I have borrowed some comments
%
%Change the sampling rate of a signal.
%   Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times
%   the original sample rate using a polyphase implementation.  Y is P/Q 
%   times the length of X (or the ceiling of this if P/Q is not an
%   integer).  
%
%   RESAMPLE applies an anti-aliasing (lowpass) FIR filter to X during the 
%   resampling process, and compensates for the filter's delay.
%   In its filtering process, RESAMPLE assumes the samples at times before
%   and after the given samples in X are equal to zero. Thus large
%   deviations from zero at the end points of the sequence X can cause
%   inaccuracies in Y at its end points.
%
%   [Y,h] = RESAMPLE(X,P,Q,...) returns in h the coefficients of the
%   filter applied to X during the resampling process (after upsampling).
%
%% REMARKS
%
% This function is limited with respect to the original
%MATLAB function as it is not capable of resampling matrix.
%
% The anti-alias filter is desiged using windowedFIR rather
%than MATLAB's firls.
%
% Differently from MATLAB, N=0 is not accepted...
%
%% PARAMETERS
%
% x - The discrete digital signal signal to be resampled
% p - Interpolation coefficient. Must be a positive integer
% q - Decimation coefficient. Must be a positive integer
% n - Optional.(Proportional) Length of the anti-aliasing
%       FIR filter. Default value is 10 similar to MATLAB's
% beta - Optional. The beta parameter for the Kaiser window.
%       Default value is 5 similar to MATLAB's
%
% @Copyright 2008-9
% Some comments are property of Mathworks!!
% This is still property of Mathworks!!
%
% Author: Felipe Orihuela-Espina
% Date: 10-Jun-2008
%
% See also windowedFIR, createFIRWindow, upfirdn



if (~exist('N','var'))
    N = 10; %Proportional to the length of the filter
end
if (~exist('beta','var'))
    beta = 5; %beta parameter for the Kaiser window
end
if (abs(round(p))~=p || p==0)
    error('P must be a positive integer.');
end
if (abs(round(q))~=q || q==0)
    error('Q must be a positive integer.');
end


%Generate the compensation filter for upfirdn.
pqmax = max(p,q);
L = 2*N*pqmax + 1;
fc = 1/2/pqmax;
myhalfWindow = createFIRWindow(L,'kaiser',beta);
mywindow=[myhalfWindow(end:-1:1) myhalfWindow];
h = p*windowedFIR(L,(1/2)*(2*fc),'low',mywindow);


%%========================================================
%%This is similar to MATLAB original but
%%Importantly it uses my upfirdn rather than MATLAB's
%%========================================================
halfL = (L-1)/2;
Lx = length(x);

% Need to delay output so that downsampling by q hits center tap of filter.
nPadSamples = floor(q-mod(halfL,q));
pad = zeros(1,nPadSamples);
h = [pad h(:).'];  % ensure that h is a row vector.
halfL = halfL + nPadSamples;

% Number of samples removed from beginning of output sequence 
% to compensate for delay of linear phase filter:
delay = floor(ceil(halfL)/q);

% Need to zero-pad so output length is exactly ceil(Lx*p/q).
nPadSamples1 = 0;
while ceil( ((Lx-1)*p+length(h)+nPadSamples1 )/q ) - delay < ceil(Lx*p/q)
    nPadSamples1 = nPadSamples1+1;
end
h = [h zeros(1,nPadSamples1)];

y = upfirdn(x,h,p,q); %Uses my upfirdn

% Get rid of trailing and leading data so input and output
%  signals line up temporally:
Ly = ceil(Lx*p/q);  % output length
y(1:delay) = [];
y(Ly+1:end) = [];

%Get rid of leading and trailing zeros
h([1:nPadSamples (end-nPadSamples1+1):end]) = [];
%%========================================================


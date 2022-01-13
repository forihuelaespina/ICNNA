function obj=filter(obj, varargin)
%SIGNAL/FILTER Apply a filter to the signal.
%
% obj=filter(obj) Apply a filter to the signal. The default
%       filter is a 30 samples wide, low pass (fc=0.3),
%       filter (based on a rectangular window).
%
% obj=filter(obj,filterLength) Apply a filter to the signal
%       using a time window of the indicated length (in samples).
%       The filter is a low pass (fc=0.3)
%       filter (based on a rectangular window).
%
% obj=filter(obj,filterLength,fc) Apply a filter to the signal
%       using a time window of the indicated length (in samples)
%       and a normalized cut off frequency (0<=fc<=0.5).
%       The filter is a low pass (based on a rectangular window).
%
% obj=filter(obj,filterLength,fc,ftype) Apply a filter to the signal
%       using a time window of the indicated length (in samples)
%       and a normalized cut off frequency.
%       Filter type is 'low' pass (default), 'high' pass,
%       'bandpass' or 'bandstop'.
%
% obj=filter(obj,filterLength,fc,ftype,wtype) Apply a filter
%       to the signal. Window type is 'rect'angular (default),
%       'triangular', 'Hamming', 'gHamming' (generalized), 'Hanning',
%       'Chebyshev' or 'Kaiser'.
%
% First, a FIR digital filter is designed i.e. computes
%the filter coefficients, using the window method. Then
%the filter is applyed to the signal.
%
%% Remarks
%
%This method is capable of designing lowpass, bandpass,
%bandstop and highpass filters for both even and odd
%values of the impulse response duration (in samples),
%using a variety of windows.
%
%This method is basically a wrap for fir1
%
%
% Copyright 2008
% @date: 29-May-2008
% @author Felipe Orihuela-Espina
%
% See also decimate, fir1
%


%Deal with arguments
filterLength=30;
fc=0.3;
fType='low';
wType='rect';
if ~isempty(varargin)
	filterLength=varargin{1};
end
if (length(varargin)>1)
	fc=varargin{2};
end
if (length(varargin)>2)
	fType=varargin{3};
end
if (length(varargin)>3)
	wType=varargin{4};
end

%1) Design a low pass FIR filter with cutoff frequency 1/r
G=windowedFIR(filterLength,fc,fType,wType);
%2) Apply the filter to the input vector in one direction
x=double(obj);
obj=signal(conv(x,G));
function obj=decimate(obj,r)
%SIGNAL/DECIMATE Decrease sampling rate
%
%   obj2 = decimate(obj,r) reduces the sample rate by a factor r.
%The decimated vector obj2 is r times shorter in length than the
%input signal obj. It uses an order 30 samples long FIR filter.
%
%% Remarks
%
%This method is basically a wrap for decimate
%
% @Copyright 2008
% Author: Felipe Orihuela-Espina
% Date: 29-May-2008
%
% See also fir1, decimate
%
%

x=double(obj);
obj=signal(decimate(x,r));
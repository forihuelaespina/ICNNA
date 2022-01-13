function y=decimate(x,r)
%Substitue for MATLAB's decimate function
%
% See MATLAB's decimate function!! I have borrowed some comments
%
%Decimation reduces the original sampling rate for a sequence
%to a lower rate, the opposite of interpolation. The decimation
%process filters the input data with a lowpass filter and then
%resamples the resulting smoothed signal at a lower rate.
%
%   y = decimate(x,r) reduces the sample rate of x by a factor r.
%The decimated vector y is r times shorter in length than the
%input vector x. It uses an order 30 samples long FIR filter,
%which means that this is similar to calling MATLAB's
%
%       y = decimate(x,r,'fir')
%
%. Here decimate filters the input sequence in only one direction.
%
% @Copyright 2008
%Some comments are property of Mathworks!
% Author: Felipe Orihuela-Espina
% Date: 20-May-2008
%
% See also windowedFIR, createFIRWindow
%
%

example=false;
if (example)
%Example
t=0:.00025:1;
x=sin(2*pi*30*t)+sin(2*pi*60*t);
r=4;
end

%A) Design a low pass FIR filter with cutoff frequency 1/r
G=windowedFIR(30,(1/2)*1/r,'low','cheby');
    %%The 1/2 factor is neccessary to normalize the frequency to 0.5Hz
    %%See windowedFIR for more information
    
%B) Apply the filter to the input vector in one direction
tempX=conv(x,G);
%Remove zero-padding added by conv
tempX(1:floor(length(G)/2)+1)=[];
tempX(end-floor(length(G)/2)+1:end)=[];

%C) Resample the filtered data by selecting every r-th point
y=tempX(1:r:end);


if (example)
    fontSize=13;
    maxSample=240; %Show only the first maxSamples...
    figure
    subplot(1,2,1)
    stem(x(1:maxSample),'r-');
    grid on, box on
    set(gca,'XLim',[1 maxSample]);
    set(gca,'FontSize',fontSize);
    title('Original Signal','FontSize',fontSize);
    subplot(1,2,2)
    stem(y(1:maxSample/r),'b-');
    grid on, box on
    set(gca,'FontSize',fontSize);
    title(['Decimated Signal - Downsampling rate (r): ' num2str(r)],...
            'FontSize',fontSize);
end

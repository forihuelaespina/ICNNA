function G=windowedFIR(N,fc,ftype,wtype,normalization)
%FIR windowed filter design
%Substitute for MATLAB's fir1 function
%
% The main motive for creating this function was that
%I do not have the MATLAB Signal Processing Toolbox.
%
%
% G=windowedFIR(N,fc,ftype,wtype,normalization)
%
% Based on:
% [1] "Programs for Digital Signal Processing" Edited by IEEE
%   Digital Signal Processing Committee; IEEE Acoustics, Speech,
%   and Signal Processing Society. Chapter 5, Section 5.2
%
%Designs a FIR digital filter using the window method, i.e. computes
%the filter coefficients.
%The program is capable of designing lowpass, bandpass,
%bandstop and highpass filters for both even and odd
%values of the impulse response duration (in samples),
%using either a variety of windows.
%
%
%% Method
%
%Let N be the  Impulse response duration in samples or
%filter length and let's define its response
%w as a window of N samples of duration. Let w(n) be the
%the N-point windows for 0<=n<=N-1 centered at n. Let h(n) be
%the ideal digital impulse response filter obtained as the
%inverse Fourier transform of the ideal frequency response
%of the filter with -inf < n < inf. Then, the windowed digital 
%filter is given by:
%
%           | w(n)h(n)  if 0<=n<=N-1
%   h'(n)= <
%           | 0         otherwise
%
% In this discussion it is assumed that h(n) incorporates an
%ideal delay of (N-1)/2 samples, and that w(n) is symmetric
%around the point (N-1)/2.
%
%% Remarks
%
%IMPORTANT: My cut-off frequency parameter is normalized
%from 0 to 0.5Hz, whereas MATLAB normalization goes from 0 to 1Hz.
%To get MATLAB's behaviour the cut-off frequency parameter
%must be multiplied by 1/2 with respect to the value that you would
%have passed to MATLAB's fir1 function.
%
%A difference with MATLAB's fir1 is that this function
%only works for single band filters, whereas MATLAB's fir1
%can compute mutiband filters!
%
%
%% Parameters
%
% N - Impulse response duration or filter length in samples. Must be
%   higher or equal than 3. For high pass or bandpass it must be odd.
% fc - Normalized cut off frequencies to the range 0<=fc<=0.5.
%   For low or high pass is a single scalar. For bandpass or bandstop
%   it is a row vector of two values [fcLow fcHigh] with fcLow<fcHigh.
%
%IMPORTANT: See Remark about my cut-off frequency parameter.
%
% ftype -  Filter type: 'low' pass (default), 'high' pass,
%   'bandpass' or 'bandstop'
% wtype/window - Window type; Specified by a string identifier (in which
%   case, some default values may be used);
%   'rect'angular, 'triangular',
%   'Hamming', 'gHamming' (generalized), 'Hanning' (default),
%   'Chebyshev' or 'Kaiser'.
%     or as in fir1 function, the window coefficients (in which case
%   the window specified in column vector window for the design.
%   The vector window must be N+1 elements long.
%   
%
%
% @Copyright 2008-9
% Author: Felipe Orihuela-Espina
% Date: 20-May-2008
%
% See also createFIRwindow
%

if (~exist('ftype','var'))
    ftype='low';
else
    ftype=lower(ftype);
end
if (~exist('wtype','var'))
    wtype='hanning';
else
    if (ischar(wtype))
        wtype=lower(wtype);
    else
        half=floor(length(wtype)/2);
        window=wtype(half+1:end); %Take only the last half window
    end
end
if (~exist('normalization','var'))
    normalization='scale';
else
    normalization=lower(ftype);
end

oddNSamples=mod(N,2); %Whether the number of samples is even or odd


%% Check input parameters
if (N<3)
    error('Filter window duration less than 3 samples');
end
switch(ftype)
    case 'low'
        assert(isscalar(fc) & fc>=0 & fc<=0.5,'Invalid cut off frequency');
    case 'high'
        assert(isscalar(fc) & fc>=0 & fc<=0.5,'Invalid cut off frequency');
        if (~oddNSamples)
            error('N must be odd for high pass or bandstop filters.');
        end
    case 'bandpass'
        assert(length(fc)==2,'Invalid cut off frequency');
        fcLow=fc(1);
        fcHigh=fc(2);
        assert( fcLow<fcHigh,'Invalid cut off frequency');
    case 'bandstop'
        assert(length(fc)==2,'Invalid cut off frequency');
        fcLow=fc(1);
        fcHigh=fc(2);
        assert(fcLow<fcHigh,'Invalid cut off frequency');
        assert(~oddNSamples,'N must be odd for high pass or bandstop filters.');
    otherwise
        error('Filter type not recognised');
end

%% Some initialization
halfN=floor((N+1)/2);
%w=zeros(1,halfN);%Holds half of the window.
     %The second half is obtained by symmetry.
G=zeros(1,halfN);%Holds half of the filter coefficients.
     %The second half is obtained by symmetry.

%% Compute the ideal (unwindowed) impulse response for filter
if ((strcmp(ftype,'bandpass')) || (strcmp(ftype,'bandstop')))
    c1=fcHigh-fcLow;
else
    c1=fc;
end

if (oddNSamples)
    G(1)=2*c1;
end

iiStart=oddNSamples+1;

xn=[iiStart:halfN]-1; %%Added by FOE to eliminate the loop
%for ii=iiStart:halfN
%    xn=ii-1;
    if (~oddNSamples)
        xn=xn+0.5;
    end
    c=pi*xn;
    c3=c*c1;
    if (strcmp(ftype,'low') || strcmp(ftype,'high'))
        c3=2*c3;
    end
    %Added  by FOE to eliminate the loop
    G(iiStart:halfN)=sin(c3)./c;
    if (strcmp(ftype,'bandpass') || strcmp(ftype,'bandstop'))
        G(iiStart:halfN)=G(iiStart:halfN).*2.*cos(c*(fcLow+fcHigh));
    end
%     G(ii)=sin(c3)/c;
%     if (strcmp(ftype,'bandpass') || strcmp(ftype,'bandstop'))
%         G(ii)=G(ii)*2*cos(c*(fcLow+fcHigh));
%     end
%end



%El meollo del asunto...that is; the key stuff!
if (ischar(wtype))
    w=createFIRWindow(N,wtype);
else
    w=window;
end
G=G.*w;
if (~((strcmp(ftype,'low')) || (strcmp(ftype,'bandpass'))))
    G=-G;
    G(1)=1-G(1);
end


%Now obtaining the other half of the filter by symmetry
if (oddNSamples)
    G=[G(end:-1:1) G(2:end)];
else
    G=[G(end:-1:1) G];
end


if (strcmp(normalization,'scale'))
    G=G/sum(G);%Gain Normalization
elseif (strcmp(normalization,'noscale'))
    %do nothing
else
    warning('Normalization not valid. Returning unnormalized filter.');
end


%% Display results
displayResults=false;
if (displayResults)
highRes(N,fc,ftype,wtype,G);


k=N/4; %for presentation purposes it is nice to return an oversampled response
if (oddNSamples)
    range=[-(N-1)/2:(N-1)/2];
    fullWindow=[w(end:-1:1) w(2:end)];
    fullFilter=G;%[G(end:-1:1) G(2:end)];
else
    range=[-(N/2):(N/2-1)];
    fullWindow=[w(end:-1:1) w];
    fullFilter=G;%[G(end:-1:1) G];
end

NFFT = 2^nextpow2(N*k); % Next power of 2 from length of signal

XW = fft(fullWindow,NFFT)/(N/k);
XF = 2*fft(fullFilter,NFFT)/(N/k);
Fs = 1; % Sampling frequency
f = Fs/2*linspace(0,1,NFFT/2);


nCols=3;
nextPlot=1;
subplot(2,nCols,nextPlot);
plot(range,fullWindow)
box on, grid on
title(['Temporal Window response (type ' wtype ')']);
nextPlot=nextPlot+2;

% subplot(2,nCols,nextPlot);
% plot(f,2*abs(X(1:NFFT/2)),'r-') 
% box on, grid on
% title(['Normalized Frequency Window response (type ' wtype ')']);
% nextPlot=nextPlot+1;

subplot(2,nCols,nextPlot);
windowFreqResp=2*abs(XW(1:NFFT/2));
ffrindb=20*log10(windowFreqResp); %Filter Frequency Response in dB
plot(f,ffrindb,'r-') 
box on, grid on
title(['Window frequency response in dB']);
nextPlot=nextPlot+1;



subplot(2,nCols,nextPlot);
plot(range,fullFilter)
box on, grid on
title(['(' ftype ' pass) Filter Impulse response (filter coefficients)']);
nextPlot=nextPlot+1;

subplot(2,nCols,nextPlot);
plot(f,2*abs(XF(1:NFFT/2)),'r-') 
box on, grid on
title(['Normalized Frequency Filter response (type ' ftype ')']);
nextPlot=nextPlot+1;

subplot(2,nCols,nextPlot);
filterFreqResp=2*abs(XF(1:NFFT/2));
ffrindb=20*log10(filterFreqResp); %Filter Frequency Response in dB
plot(f,ffrindb,'r-') 
box on, grid on
title(['Filter Frequency Response in dB']);

end %display results

end %function


%=========
%AUXILIAR FUNCTIONS
%=========
%
% Standard basic MATLAB package provides the following functions:
%   fft, ifft - Discrete Fourier Transform (DFT) and the inverse
%       discrete Fourier transform computed with an FFT algorithm.
%
%   cos, acos - Compute the cosine and its inverse (arccosine)
%
%   cosh, acosh - Compute the hyperbolic cosine and its inverse
%       cosh^{-1}
%


function resp=highRes(N,fc,ftype,wtype,G)
%Computes a high resolution response of the resulting filter
%using a DFT (e.g. fft) algorithm to determine filter
%characteristics. For all window designs
%(except the triangular windows for which no ripple or
%band-edge are readily obtained), each ideal filter band
%is searched for the peak riddle and the band-edge.
%The band-edge is defined as the point where the frequency
%response crosses the ripple bound. A more precise estimate
%of the band-edge is determined by linear interpolation of
%the frequency response of the filter in the vicinity of the
%band-edge. Finally the ripple (i.e. peak deviation from
%the ideal response) is determined as
%
%   Ripple = 20 log(1+d) [deciBels] for passbands
%   Ripple = 20 log(d) [deciBels] for stopbands
%

oddNSamples=mod(N,2);  
halfN=floor((N+1)/2);
NR=8*N; %Size in samples of the response
resp=zeros(1,NR);
if (~(strcmp(wtype,'triangular'))) %Not for triangular window
    xnr=NR;
    twn=pi/xnr;
    sumi=-G(1)/2;
    if (~oddNSamples)
        sumi=0;
    end
    for ii=1:NR
        xi=ii-1;
        twni=twn*xi;
        totalSum=sumi;
        for jj=1:halfN
            xj=jj-1;
            if (~oddNSamples)
                xj=xj+0.5;
            end
            totalSum=totalSum + G(jj)*cos(xj*twni);
        end
        resp(ii)=2*totalSum;
    end
    
    switch(ftype)
        case 'low'
            [cfLow,cfHigh,dev]=ripple(NR,1,0,fc,resp);
%             disp(['Passband cutoff: '  num2str(cfHigh) ...
%                   '; Ripple: ' num2str(dev)]);
            [cfLow,cfHigh,dev]=ripple(NR,0,fc,0.5,resp);
%             disp(['Stopband cutoff: '  num2str(cfLow) ...
%                   '; Ripple: ' num2str(dev)]);
        case 'high'
            [cfLow,cfHigh,dev]=ripple(NR,0,0,fc,resp);
%             disp(['Stopband cutoff: '  num2str(cfHigh) ...
%                   '; Ripple: ' num2str(dev)]);
            [cfLow,cfHigh,dev]=ripple(NR,1,fc,0.5,resp);
%             disp(['Passband cutoff: '  num2str(cfLow) ...
%                   '; Ripple: ' num2str(dev)]);
        case 'bandpass'
            fLow=fc(1);
            fHigh=fc(2);
            [cfLow,cfHigh,dev]=ripple(NR,0,0,fLow,resp);
%             disp(['Stopband cutoff: '  num2str(cfHigh) ...
%                   '; Ripple: ' num2str(dev)]);
            [cfLow,cfHigh,dev]=ripple(NR,1,fLow,fHigh,resp);
%             disp(['BandPass cutoffs: '  num2str(cfLow) ...
%                   '; Ripple: ' num2str(dev)]);
            [cfLow,cfHigh,dev]=ripple(NR,0,fHigh,0.5,resp);
%             disp(['Stopband cutoff: '  num2str(cfLow) ...
%                   '; Ripple: ' num2str(dev)]);
        case 'bandstop'
            fLow=fc(1);
            fHigh=fc(2);
            [cfLow,cfHigh,dev]=ripple(NR,1,0,fLow,resp);
%             disp(['Passband cutoff: '  num2str(cfHigh) ...
%                   '; Ripple: ' num2str(dev)]);
            [cfLow,cfHigh,dev]=ripple(NR,0,fLow,fHigh,resp);
%             disp(['StopPass cutoffs: '  num2str(cfLow) ...
%                   '; Ripple: ' num2str(dev)]);
            [cfLow,cfHigh,dev]=ripple(NR,1,fHigh,0.5,resp);
%             disp(['Passband cutoff: '  num2str(cfLow) ...
%                   '; Ripple: ' num2str(dev)]);
        otherwise
            error('Filter type not recognised')
    end
end

end %function

function [cfLow,cfHigh,dev]=ripple(NR,rIdeal,fLow,fHigh,resp)
%Determines the filter ripples (i.e. peak deviation from
%the ideal response) and band-edges from the
%filter parameters.
%Finds the largest ripple in band and locates the band
%edges based on the point where the transition region
%crosses the measured ripple bound.
%
% NR - Size of the (high definition) response
% rIdeal - Ideal frequency response
% fLow - Low edge of the ideal band
% fHigh - High edge of the ideal band
% resp - Frequency response of size NR
%
% cfLow - Computed lower band edge
% cfHigh - Computed upper band edge
% dev - Deviation from ideal response in DB (decibels)


xnr=NR;

%Indexes of the Band limits
idx_fLow=round(2*xnr*fLow+1.5);
idx_fHigh=round(2*xnr*fHigh+1.5);
if (idx_fLow==0)
    idx_fLow =1;
end
if (idx_fHigh>=NR)
    idx_fHigh =NR-1;
end

    
%find max and min peaks in band
rMin=rIdeal;
rMax=rIdeal;
for ii=idx_fLow:idx_fHigh
    if (~((resp(ii)<=rMax) || (resp(ii)<resp(ii-1)) || ...
            (resp(ii)<resp(ii+1))))
        rMax=resp(ii);
    end
    if (~((resp(ii)>=rMin) || (resp(ii)>resp(ii-1)) || ...
            (resp(ii)>resp(ii+1))))
        rMax=resp(ii);
    end 
end

%Peak deviation from ideal
ripl = max(rMax-rIdeal,rIdeal-rMin);
%Search for lower band edge
cfLow = fLow;
if (~(fLow==0))

    pos=idx_fHigh;
    for ii=idx_fLow:idx_fHigh
        if (abs(resp(ii)-rIdeal)<=ripl)
            pos=ii;
            break
        end
    end
    xi=pos-1;
    %Linear interpolation of band edge frequency to improve accuracy
    x1=0.5*xi/xnr;
    x0=0.5*(xi-1)/xnr;
    y1=abs(resp(pos)-rIdeal);
    y0=abs(resp(pos-1)-rIdeal);
    cfLow = (x1-x0)/(y1-y0)*(ripl-y0) + x0;

end

%Search for upper band edge
cfHigh = fHigh;
if (~(fHigh==0.5))

    pos=idx_fLow;
    for ii=idx_fLow:idx_fHigh
        jj=idx_fHigh+idx_fLow-ii;
        if (abs(resp(jj)-rIdeal)<=ripl)
            pos=jj;
            break
        end
    end
    xi=pos-1;
    %Linear interpolation of band edge frequency to improve accuracy
    x1=0.5*xi/xnr;
    x0=0.5*(xi+1)/xnr;
    y1=abs(resp(pos)-rIdeal);
    y0=abs(resp(pos+1)-rIdeal);
    cfLow = x0+(x1-x0)/(y1-y0)*(ripl-y0) + x0;

end

%finally calculate the deviation in decibels
dev=20*log10(ripl+rIdeal);

end %function


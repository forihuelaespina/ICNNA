function w=createFIRWindow(N,wtype,varargin)
%Creates a (half) window of a certain type to generate a filter
%Return the window coefficients for half the window of a filter
%
% Based on:
% [1] "Programs for Digital Signal Processing" Edited by IEEE
%   Digital Signal Processing Committee; IEEE Acoustics, Speech,
%   and Signal Processing Society. Chapter 5, Section 5.2
%
%
% The main motive for creating this function was that
%I do not have the MATLAB Signal Processing Toolbox.
%
%% FORMS OF THE WINDOWS
%
%       Odd number of samples
%
%         +-----+-----+-...-+-...-+-----+-----+
%     -(N-1)/2              n              (N-1)/2
%               Example: N=5 goes from -2 to 2 => [-2, -1, 0, 1, 2]
%
%       Even number of samples
%
%         +-----+-----+-...-+-...-+-----+-----+
%       -N/2                n               N/2-1
%               Example: N=6 goes from -3 to 2 => [-3, -2, -1, 0, 1, 2]
%
%
%
% Rectangular ('rect')
%   For N odd   =>    w(n)=1      if -(N-1)/2 <= n <= (N-1)/2
%   For N even  =>    w(n)=1      if    -N/2  <= n <= (N/2-1)
%
% Triangular ('triangular')
%   For N odd   =>    w(n)=1-|2n|/(N+1)
%                                 if -(N-1)/2 <= n <= (N-1)/2
%   For N even  =>    w(n)=1-|2n+1|/N
%                                 if    -N/2  <= n <= (N/2-1)
%
% Hamming ('hamming')
%   For N odd   =>    w(n)=0.54+0.46cos[2*pi*n/(N-1)]
%                                 if -(N-1)/2 <= n <= (N-1)/2
%   For N even  =>    w(n)=0.54+0.46cos[2*pi*(2n+1)/(2(N-1))]
%                                 if    -N/2  <= n <= (N/2-1)
%
% Hanning ('hanning')
%   For N odd   =>    w(n)=0.5+0.5cos[2*pi*n/(N+1)]
%                                 if -(N-1)/2 <= n <= (N-1)/2
%   For N even  =>    w(n)=0.5+0.5cos[2*pi*(2n+1)/(2(N+1))]
%                                 if    -N/2  <= n <= (N/2-1)
%
% Generalized Hamming ('ghamming')
%   For N odd   =>    w(n)=a+(1-a)cos[2*pi*n/(N-1)]
%                                 if -(N-1)/2 <= n <= (N-1)/2
%   For N even  =>    w(n)=a+(1-a)cos[2*pi*(2n+1)/(2(N-1))]
%                                 if    -N/2  <= n <= (N/2-1)
%
%           where 'a' is a variable parameter
%
% Kaiser I_0-sinh ('kaiser')
%   For N odd   =>    w(n)=(I0*[b*sqrt(1-[(4n^2)/((N-1)^2)])])/I0(b)
%                                 if -(N-1)/2 <= n <= (N-1)/2
%   For N even  =>    w(n)=(I0*[b*sqrt(1-[(4(n+1/2)^2)/((N-1)^2)])])/I0(b)
%                                 if    -N/2  <= n <= (N/2-1)
%
%           where 'b' is a window parameter related to the
%       minimum stopband attenuation.
%
%
% Chebyshev ('chebyshev')
%
%   w(n) is obtained as the inverse DFT of the Chebyshev polynomial
%evaluated at N equally spaced frequencies around the unit circle.
%The parameters of the Chebyshev window are the ripple, d, the
%filter length, N, and the normalized transition width, DF. Only
%two of these three parameters can be independently specified.
%   - If d and DF are specified then
%       N >= 1+[cosh^{-1}((1+d)/d) / cosh^{-1}(1/(cos(pi*DF)))]
% 
%   - If d and N are specified then
%       DF = (1/pi)*cos^{-1}[1/(cosh(cosh^{-1}((1+d)/d)/(N-1))]
% 
%   - If DF and N are specified then
%       d = 1/[cosh[(N-1)cosh^{-1}(1/(cos(pi*DF)))]-1]
% 
%   
%% PARAMETERS
%
% N - Impulse response duration or filter length in samples. Must be
%   higher or equal than 3. For high pass or bandpass it must be odd.
%
% wtype - Window type; 'rect'angular (default), 'triangular',
%   'Hamming', 'gHamming' (generalized), 'Hanning',
%   'Chebyshev' or 'Kaiser'.
%
% varargin - Varies depending on the window type:
%   For window type:
%       Kaiser: beta(=1 default)%Minimum Stopband Attenuation
%       Chebyshev: dplog (=60dB default); %Filter ripple in dB
%
%
%% KNOWN BUGS
%
% The Hanning window is not working properly as it returns
%a window vector which is 1 sample longer than it should.
%
%
% @Copyright 2008-9
% Author: Felipe Orihuela-Espina
% Date: 20-May-2008
%
% See also windowedFIR
%

oddNSamples=mod(N,2);
halfN=floor((N+1)/2);
w=ones(1,halfN); %Initialize the window to a Rectangular window
switch(wtype)
    case 'triangular'
        numerator=halfN;
%         for ii=1:halfN
%             xi=ii-1;
%             if (~oddNSamples)
%                 xi=xi+0.5;
%             end
%             w(ii)=1-(xi/numerator);
%         end
        xi=0:halfN-1;
        if (~oddNSamples)
                xi=xi+0.5;
        end
        w=1-(xi/numerator);
            
    case 'rect'
        w(1:end)=1;
    case 'hamming'
        alpha=0.54;%Constant of window. Between 0 and 1
        beta=1-alpha; %Constant of window. Generally 1-alpha
        numerator=N-1;
%         for ii=1:halfN
%             xi=ii-1;
%             if (~oddNSamples)
%                 xi=xi+0.5;
%             end
%             w(ii)=alpha+beta*cos(2*pi*xi/numerator);
%         end
        xi=0:halfN-1;
        if (~oddNSamples)
                xi=xi+0.5;
        end
        w=alpha+beta*cos(2*pi*xi/numerator);
        
    case 'hanning'
        %Increase N by2 and update halfN for hanning
        %so zero endpoints are not part of window
        N=N+2; %Not necessary in this case...
        halfN=halfN+1;
        alpha=0.5;%Constant of window. Between 0 and 1
        beta=1-alpha; %Constant of window. Generally 1-alpha
        numerator=N-1;
%         for ii=1:halfN
%             xi=ii-1;
%             if (~oddNSamples)
%                 xi=xi+0.5;
%             end
%             w(ii)=alpha+beta*cos(2*pi*xi/numerator);
%         end
        xi=0:halfN-1;
        if (~oddNSamples)
                xi=xi+0.5;
        end
        w=alpha+beta*cos(2*pi*xi/numerator);
        
    case 'ghamming'
        alpha=0.5;%Constant of window. Between 0 and 1
        beta=1-alpha; %Constant of window. Generally 1-alpha
        numerator=N-1;
%         for ii=1:halfN
%             xi=ii-1;
%             if (~oddNSamples)
%                 xi=xi+0.5;
%             end
%             w(ii)=alpha+beta*cos(2*pi*xi/numerator);
%         end
        xi=0:halfN-1;
        if (~oddNSamples)
                xi=xi+0.5;
        end
        w=alpha+beta*cos(2*pi*xi/numerator);
        
    case 'kaiser'
        beta=1;%Parameter of the kaiser window. Minimum Stopband Attenuation
        if (length(varargin)>=1)
            beta=varargin{1};
        end
        res=ino(beta);
        xind=(N-1)^2;
        for ii=1:halfN
            xi=ii-1;
            if (~oddNSamples)
                xi=xi+0.5;
            end
            xi=4*xi^2;
            w(ii)=ino(beta*sqrt(1-xi/xind));
            w(ii)=w(ii)/res;
        end
        
    case 'cheby'
        dplog=60;%chebyshev filter ripple in dB (minimum attenuation ???)
        if (length(varargin)>=1)
            dplog=varargin{1};
        end
        DP=10^(-dplog/20); %Filter ripple in absolute scale
        DF=0;%Normalized transition width. Not specified
        [N,DP,DF]=chebyc(N,DP,DF);
        x0=(3-cos(2*pi*DF))/(1+cos(2*pi*DF)); %chebishev window constant
        w=cheby(N,DP,DF,x0);
    otherwise
        error('Window type not recognised');
end


%% Display Results
dispRes=false;
if (dispRes)
    displayResults(N,w,wtype);
end

end %function



%%==============================================
%% Auxiliar Functions

function res=ino(x)
%Evaluates I0(x). Bessel function for Kaiser window
y=x/2;
t=1e-8;
e=1;
de=1;
for ii=1:25
    xi=ii;
    de=de*y/xi;
    sde=de*de;
    e=e+sde;
    if (~(e*t-sde))
        res=e;
        return
    end
end
res=e;
end %function

function [N,DP,DF]=chebyc(N,DP,DF)
%computes the unspecified parameter of a Chebyshev window
if (N==0) %DP, DF specified, determine N
    c1=acosh((1+DP)/DP);
    c0=cos(pi*DF);
    x=1+c1/acosh(1/c0);
    %%Increment by 1 to give N which meets or exceeds
    %%specs on DP and DF
    N=x+1;
    %halfN=floor((N+1)/2);
    %xn=N-1;
elseif (DF==0) %DP, N specified, determine DF
    xn=N-1;
    c1=acosh((1+DP)/DP);
    c2=cosh(c1/xn);
    DF=acos(1/c2)/pi;
else %DF, N specified, determine DP
    xn=N-1;
    c0=cos(pi*DF);
    c1=xn*acosh(1/c0);
    DP=1/(cosh(c1)-1);
end
end


function w=cheby(N,DP,DF,x0)
%computes the Chebyshev window
oddNSamples=mod(N,2);
halfN=floor((N+1)/2);
w=zeros(1,halfN);
PRE=zeros(1,N); %Holds the real part of the DFT;
PIM=zeros(1,N); %Holds the imaginary part of the DFT;
    
       xn=N-1;
       fnf=N;
       alpha=(x0+1)/2;
       beta=(x0-1)/2;
       c2=xn/2;
       for ii=1:N
           xi=ii-1;
           f=xi/fnf;
           x=alpha*cos(2*pi*f)+beta;
           if (abs(x)-1)
               p=DP*cos(c2*acos(x));
           else
               p=DP*cosh(c2*acosh(x));
           end
           
           PIM(ii)=0;
           PRE(ii)=p;
           %For even length filters use a one half sample delay
           %Also the frequency response is antisymmetric in frequency
           if (~(oddNSamples))
               PRE(ii)=p*cos(pi*f);
               PIM(ii)=-p*sin(pi*f);
               if (ii>(N/2+1))
                   PRE(ii)=-PRE(ii);
                   PIM(ii)=-PIM(ii);
               end
           end
       end
       %Use DFT to give window
       twn=2*pi/fnf;
       for ii=1:halfN
           xi=ii-1;
           totalSum=0;
           for jj=1:N
               xj=jj-1;
               totalSum=totalSum+PRE(jj)*cos(twn*xj*xi) ...
                                +PIM(jj)*sin(twn*xj*xi);
           end
           w(ii)=totalSum;
       end
       c1=w(1);
       for ii=1:halfN
           w(ii)=w(ii)/c1;
       end

end %function


function displayResults(N,w,wtype)
%Display the results
figure
%Set Figure screen size
set(gcf,'Units','normalized');
set(gcf,'Position',[0.02, 0.4, 0.92, 0.45]);
set(gcf,'Units','pixels'); %Return to default

    oddNSamples=mod(N,2); %Whether the number of samples is even or odd
    %... and display results
    if (oddNSamples)
        range=-(N-1)/2:(N-1)/2;
        fullWindow=[w(end:-1:2) w(1:end)];
    else
        range=-(N/2):(N/2-1);
        fullWindow=[w(end:-1:1) w(1:end)];
    end
    range=1:N;
    
    nCols=2;
    nextPlot=1;
    subplot(1,nCols,nextPlot);
    plot(range,fullWindow)
    set(gca,'XLim',[1 length(range)]);
    box on, grid on
    title(['Temporal Window response (type ' wtype ')']);
    nextPlot=nextPlot+1;


    NFFT = 2^nextpow2(N);
    X = fft(fullWindow,NFFT)/(N); %This is the real response
    %For normalized presentation only, it is interesting to
    %present the results oversampled - high res - and with
    %gain 0dB at f=0 Hz.
    k=N/2; %For presentation purposes is nice to produce
        %an oversampled output
    NFFT = 2^nextpow2(N*k); % Next power of 2 from 
                            %length of signal
    X = fft(fullWindow,NFFT)/(N/k); %Gain at fc approx 0dB 
    
    Fs = 1; % Sampling frequency %Use this to plot like the original book
                                 %with normalized freq. between 0 and 0.5
    %Fs = 2; % Sampling frequency %Use this to plot like the MATLAB
    %                             %with normalized freq. between 0 and 1
    f = (Fs/2)*linspace(0,1,NFFT/2);
    windowNormFrqRes=2*abs(X(1:NFFT/2));

%     X = fft(fullWindow);
%     halfN=floor((N+1)/2);
%     f = (Fs/2)*linspace(0,1,halfN); %For normalized representation
%     windowNormFrqRes=2*abs(X(1:halfN));
    
    if (nCols>2)
        subplot(1,nCols,nextPlot);
        plot(f,windowNormFrqRes,'r-')
        box on, grid on
        title(['Normalized Frequency Window response (type ' wtype ')']);
        nextPlot=nextPlot+1;
    end

    subplot(1,nCols,nextPlot);
    ffrindb=20*log10(windowNormFrqRes); %window Frequency Response in dB
    plot(f,ffrindb,'r-')
    box on, grid on
    title('Window frequency response in dB');
end
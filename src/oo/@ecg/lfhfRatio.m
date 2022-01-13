function [res,hf,lf,vlf,ulf]=lfhfRatio(obj,options)
%ECG/LFHFRATIO Computes the LF/HF ratio measure of heart rate variability
%
% [res,hf,lf,vlf,ulf]=lfhfRatio(obj) Computes the LF/HF ratio
%
% [res,hf,lf,vlf,ulf]=lfhfRatio(obj,options) Computes the LF/HF ratio.
%   See parameter options below.
%
% Frequency bands for heart rate variability calculations are
%defined as [Ref. 1]:
%
% * HF (high frequency) -  0.15-0.4 Hz
% * LF (low frequency) -  0.04-0.15 Hz
% * VLF (very low frequency) -  0.003-0.04 Hz
% * ULF (ultra low frequency) -  0.0001-0.003 Hz
%
% Components in the ULF band are only available for long recordings
%(e.g. 24h) - see option longTerm. Component in the VLF band may
%not be reliable for short measurements.
%
%Uses the Fast Fourier Transform (FFT) to compute the ratio
%between low frequency and high frequency components.
%
%% Power Spectrum ===================================
%From: http://zone.ni.com/reference/en-XX/help/371361B-01/lvanlsconcepts/power_spect/
%
%The DFT or FFT of a real signal is a complex number,
%having a real and an imaginary part. You can obtain
%the power in each frequency component represented by
%the DFT or FFT by squaring the magnitude of that
%frequency component. Thus, the power in the kth frequency
%component - that is, the kth element of the DFT or FFT -
%is given by the following equation.
%
%         power = |X[k]|^2,                       (1)
%
%where |X[k]| is the magnitude of the frequency component.
%
%The power spectrum returns an array that contains the
%two-sided power spectrum of a time-domain signal and
%that shows the power in each of the frequency components.
%You can use Equation (2) to compute the two-sided power
%spectrum from the FFT.
%
%                                FFT(A).FFT*(A)
%    Power Spectrum S_{AA}(f) = ----------------   (2)
%                                    N^2
%
%where FFT*(A) denotes the complex conjugate of FFT(A).
%The complex conjugate of FFT(A) results from negating
%the imaginary part of FFT(A).
%
%The values of the elements in the power spectrum array
%are proportional to the magnitude squared of each
%frequency component making up the time-domain signal.
%Because the DFT or FFT of a real signal is symmetric,
%the power at a positive frequency of k?f is the same as
%the power at the corresponding negative frequency of -k?f,
%excluding DC and Nyquist components. The total power in
%the DC component is |X[0]|^2. The total power in the Nyquist
%component is |X[N/2]|^2.
%
%
%% Converting a Two-Sided Power Spectrum to a Single-Sided Power Spectrum?
%From: http://zone.ni.com/reference/en-XX/help/371361B-01/lvanlsconcepts/power_spect/
%
%Most frequency analysis instruments display only the
%positive half of the frequency spectrum because the
%spectrum of a real-world signal is symmetrical around DC.
%Thus, the negative frequency information is redundant.
%The two-sided results from the analysis functions include
%the positive half of the spectrum followed by the negative
%half of the spectrum.
%
%A two-sided power spectrum displays half the energy at
%the positive frequency and half the energy at the negative
%frequency. Therefore, to convert a two-sided spectrum to a
%single-sided spectrum, you discard the second half of the
%array and multiply every point except for DC by two.
%
%The units of a power spectrum are often quantity squared
%rms (root mean squared - a special case of the power mean
%with the exponent p = 2), where
%quantity is the unit of the time-domain signal.
%Hence if the original signal is in ms, the output is in ms^2.
%
%
%% Loss of Phase Information
%
%Because the power is obtained by squaring the magnitude
%of the DFT or FFT, the power spectrum is always real.
%The disadvantage of obtaining the power by squaring the
%magnitude of the DFT or FFT is that the phase information
%is lost. If you want phase information, you must use the
%DFT or FFT, which gives you a complex output.
%
%% Computing phase and spectrum
%From: http://zone.ni.com/reference/en-XX/help/371361B-01/lvanlsconcepts/compute_amp_phase_spectrums/
%
%The power spectrum shows power as the mean squared
%amplitude at each frequency line but includes no phase
%information. Because the power spectrum loses phase
%information, you might want to use the FFT to view both
%the frequency and the phase information of a signal.
%The phase information the FFT provides is the phase
%relative to the start of the time-domain signal.
%Therefore, you must trigger from the same point in
%the signal to obtain consistent phase readings.
%Usually, the primary area of interest for analysis
%applications is either the relative phases between
%components or the phase difference between two signals
%acquired simultaneously.
%
%The FFT produces a two-sided spectrum in complex form
%with real and imaginary parts. You must scale and convert
%the two-sided spectrum to polar form to obtain magnitude
%and phase. The frequency axis of the polar form is identical
%to the frequency axis of the two-sided power spectrum. The
%amplitude of the FFT is related to the number of points
%in the time-domain signal. Use the following equations
%to compute the amplitude and phase versus frequency from the FFT.
%
%% Parameter
%
% ecg - Raw ECG (electrocardiogram) data series with 2 columns,
%   The first column are relative timestamps in <b>miliseconds</b>.
%   The second column are the ECG raw data values.
%
% options - (Optional). A struct for options
%   .fontSize - Font size for the figure (see option .visualize).
%       By default is set to 13 points
%   .lineWidth - Line width for the figure (see option .visualize).
%       By default is set to 1.5
%   .longTerm - The ECG is a long term recording, and has a ULF
%       component. False by default, i.e. recording is short term
%   .visualize - Display the (single sides) power spectrum of the RR
%       intervals.
%
%% Output
%
% res - The LF/HF ratio (dimensionless)
% hf - Power on the HF band in ms^2
% lf - Power on the LF band in ms^2
% vlf - Power on the VLF band in ms^2
% ulf - Power on the ULF band in ms^2, or 0 if recording is short term.
%
%
%% References:
%
% [1] Malik (1996) "Heart rate variability: Standards of measurement,
%   physiological interpretation, and clinical usage." Task force
%   of the European Society of Cardiology and the North American
%   Society of Pacing and Electrophysiology. European Heart Journal
%   Vol 17, pg 354-381
%
%
%
% Copyright 2008
% Author: Felipe Orihuela-Espina
% Date: 25-Nov-2008
%
% See also importECGFromZephyr, getRR, sdnn, sdann, rmssd
%


%% Deal with options
opt.fontSize=13;
opt.lineWidth=1.5;
opt.longTerm=false;
opt.visualize=false;
if exist('options','var')
    if isfield(options,'fontSize')
        opt.fontSize=options.fontSize;
    end
    if isfield(options,'lineWidth')
        opt.lineWidth=options.lineWidth;
    end
    if isfield(options,'longTerm')
        opt.longTerm=options.longTerm;
    end
    if isfield(options,'visualize')
        opt.visualize=options.visualize;
    end
end


%% Compute RR-intervals
rr=get(obj,'RR');
signal=rr;
signal(isnan(signal))=nanmean(signal);

%Fs = 250;                     % Sampling frequency
Fs = get(obj,'SamplingRate'); % Sampling frequency
T = 1/Fs;                     % Sample time
L = length(signal);           % Length of signal
%t = (0:L-1)*T;               % Time vector
t = get(obj,'Timestamps');    % Time vector
% plot(t/1000,signal)
% title('Signal')
% xlabel('time (seconds)')

NFFT = 2^nextpow2(L); % Next power of 2 from length of signal
f = Fs/2*linspace(0,1,NFFT/2);
Y = fft(signal,NFFT)/L; %Remember fft yields a complex result!
%Convert to single-sided power spectrum (See comments above)
psd_ss=2*abs(Y(1:NFFT/2)); %Single sided power spectrum

% * HF (high frequency) -  0.15-0.4 Hz
% * LF (low frequency) -  0.04-0.15 Hz
% * VLF (very low frequency) -  0.003-0.04 Hz
% * ULF (ultra low frequency) -  0.0001-0.003 Hz
idx=find(f<=0.4 & f>=0.15);
hf=sum(psd_ss(idx));
idx=find(f<=0.15 & f>=0.04);
lf=sum(psd_ss(idx));
idx=find(f<=0.04 & f>=0.003);
vlf=sum(psd_ss(idx));
ulf=0; %Not available for short period recordings
if opt.longTerm
    idx=find(f<=0.003 & f>=0.0001);
    ulf=sum(psd_ss(idx));
end
res=lf/hf;


%% Plot single-sided amplitude spectrum.
if (opt.visualize)
    figure('Units','normalized','Position',[0 0 1 1]);
    %plot(f,psd_ss)
    %semilogy(f,psd_ss)
    loglog(f,psd_ss,'LineWidth',opt.lineWidth);
    %Frequency bands separators
   ylim=axis;
    line('XData',[0.4 0.4],...
         'YData',[ylim(3) ylim(4)],...
         'Color','r',...
         'LineStyle','-','LineWidth',opt.lineWidth);
    text(0.2,ylim(3)+((ylim(4)-ylim(3))/10),...
         'HF','Color','r','FontWeight','bold',...
         'FontSize',opt.fontSize);
    line('XData',[0.15 0.15],...
         'YData',[ylim(3) ylim(4)],...
         'Color','r',...
         'LineStyle','-','LineWidth',opt.lineWidth);
    text(0.06,ylim(3)+((ylim(4)-ylim(3))/10),...
         'LF','Color','r','FontWeight','bold',...
         'FontSize',opt.fontSize);
    line('XData',[0.04 0.04],...
         'YData',[ylim(3) ylim(4)],...
         'Color','r',...
         'LineStyle','-','LineWidth',opt.lineWidth);
    text(0.009,ylim(3)+((ylim(4)-ylim(3))/10),...
         'VLF','Color','r','FontWeight','bold',...
         'FontSize',opt.fontSize);
    line('XData',[0.003 0.003],...
         'YData',[ylim(3) ylim(4)],...
         'Color','r',...
         'LineStyle','-','LineWidth',opt.lineWidth);
     if (opt.longTerm)
       text(0.001,ylim(3)+((ylim(4)-ylim(3))/10),...
         'ULF','Color','r','FontWeight','bold',...
         'FontSize',opt.fontSize);
       line('XData',[0.0001 0.0001],...
         'YData',[ylim(3) ylim(4)],...
         'Color','r',...
         'LineStyle','-','LineWidth',opt.lineWidth);
     end
     
    %title('Single-Sided Amplitude Spectrum of y(t)')
    title('Single-Sided Amplitude Spectrum of RR intervals',...
            'FontSize',opt.fontSize)
    xlabel('Frequency (Hz)','FontSize',opt.fontSize)
    %ylabel('|Y(f)|')
    %ylabel('Power (ms^2)','FontSize',opt.fontSize);
    ylabel('Power (s^2/Hz)','FontSize',opt.fontSize);
    set(gca,'XLim',[0 1]);
    set(gca,'FontSize',opt.fontSize);
    
    grid on
end
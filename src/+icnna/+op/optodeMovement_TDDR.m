function [nimg] = optodeMovement_TDDR(nimg,options)
%Apply the TDDR algorithm for optode movement correction to a nirs_neuroimage
%
%   [nimg] = iccna.op.optodeMovement_TDDR(nimg) - Apply the TDDR 
%       algorithm for optode movement correction to a nirs_neuroimage.
%
%   [nimg] = iccna.op.optodeMovement_TDDR(nimg,options) - Apply the TDDR 
%       algorithm for optode movement correction to a nirs_neuroimage
%       with the given options.
%
%
%% Temporal derivative distribution repair (TDDR)
%
% Temporal derivative distribution repair (TDDR) [Fishburn, 2018] is an
% optode movement (detection and) correction algorithm for both baseline
% shifts and spike artefacts types of movements.
%
%   Assumptions:
%   * Non-motion related signal fluctuations are approximately normally
%   distributed.
%   * Noise in the fNIRS signals is composed of;
%       + instrumental noise assumed negligible,
%       + physiological noise assumed narrow band and quasi-stationary, and
%       + optode movement noise assumed infrequent (as compared to other
%       fluctuations of the signals) and hence residing in the tails of
%       the distribution of fluctuations of the signal.
%   * Signal fluctuations from optode movement have more energy i.e.
%   greater amplitude, than non-motion related signal fluctuations.
%
%
%
%  The algorithm in a nutshell;
%
% The signal typical "magnitude-based" representation is replaced by its
%   differential (referred here to as temporal derivative) representation.
%   and reconstruct the "magnitude-based" format from a weighted version
%   of this differential representation, where he weights are (iteratively)
%   estimated from the distribution of residuals in the distribution of
%   differentials.
%
%   The algorithm refers to the differentials as "fluctuations" and the
%   regular magnitudes as "observations".
%
% 1) Compute the differential representation i.e. the fluctuations or
%   temporal derivative of the signal.
% 2) Initialize weights (to 1).
% 3) Iteratively estimate the weights (until convergence)
%   3.1) Estimate the weighted mean of the fluctuations
%   3.2) Compute the (absolute) residuals of the estimate
%   3.3) Compute the (robust) estimate of the std of the residuals
%       (assuming normal distribution)
%   3.4) Compute the scaled deviations of each observation
%   3.5) Update the weights using Tukey's biweight function
% 4) Repair the fluctuations
% 5) Integrate back to the "magnitude-based" representation of the signal.
%
%
% TDDR is dependent on the sampling rate of the signal. In addition,
% the presence of high frequency components (of nature different than
% optode movement) inflates the variance, hence reducing TDDR efficacy.
% To prevent the potential decay in performance associated with these
% issues;
%
%   * If the sampling rate is >1Hz, the signal is;
%       A) split into low and high frequency components by low
%           pass filtering (0.5Hz cutoff).
%       B) TDDR is applied to the low frequency component of the
%           signal
%       C) The high frequency component of the signal is added back
%           to the TDDR corrected low component
% 
%
%
%% References
%
%   [Fishburn, 2018] Fishburn FA, Ludlum RS, Vaidya CJ, Medvedev AV (2018)
%       "Temporal derivative distribution repair (TDDR): A motion
%       correction method for fNIRS" Neuroimage, 184, pp.171-179
%
%
%
%% Parameters
%
% nimg - An @nirs_neuroimage to be processed.
% options - A struct of options
%   .tolerance - double [AU]. By default is set to 10^-8.
%       Tolerance for controlling the convergence of the error of
%       the weights.
%
%% Output
% nimg - An @nirs_neuroimage to which the TDDR optode movement correction
%       has been applied.
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%



%% Log
%
% 16-May-2025: FOE
%   + File created.
%
% 18-May-2025: FOE
%   + Initial testing and debugging.
%


%% Deal with options
opt.tolerance = 10^-8;
if exist('options','var') && isstruct(options)
    if isfield(options,'tolerance')
        opt.tolerance = options.tolerance;
    end
end




%% Preliminaries
%Unfold the "signal" dimensions so that all measurements can be computed
%in one shot
nMeasurements = nimg.nChannels*nimg.nSignals;
tmpData = reshape(nimg.data,nimg.nSamples,nMeasurements);



%% A) Split into low and high frequency components by low pass filtering (0.5Hz cutoff).
lowComponent  = tmpData;
highComponent = zeros(size(nimg.data));

fs = nimg.timeline.samplingRate; % Sampling frequency (Hz)
if fs > 1
    % Design Butterworth filters
    fc = 0.5; % Cutoff frequency (Hz)
    [b_low,  a_low]  = butter(4, fc/(fs/2), 'low'); % Low-pass filter
    [b_high, a_high] = butter(4, fc/(fs/2), 'high'); % High-pass filter
    
    % Apply filters to the signal
    lowComponent  = filtfilt(b_low,  a_low,  tmpData); % Low-frequency component
    highComponent = filtfilt(b_high, a_high, tmpData); % High-frequency component
end





%% B) TDDR is applied to the low frequency component of the signal
% 1) Compute the differential representation i.e. the fluctuations or
%   temporal derivative of the signal.
Y = diff(lowComponent);

% figure(1)
% subplot(4,1,1);
% plot(tmpData)
% title('Data');
% subplot(4,1,2);
% plot(lowComponent)
% title('Low component');
% subplot(4,1,3);
% plot(highComponent)
% title('High component');
% subplot(4,1,4);
% plot(Y)
% title('Differentials');



% 2) Initialize weights (to 1).
W = ones(nimg.nSamples-1, nMeasurements);

% 3) Iteratively estimate the weights (until convergence)
mu(1,1:nMeasurements)          = Inf;
iIter = 0;
theError = [];
while true
%   3.1) Estimate the weighted mean of the fluctuations
    mu_previous = mu;
    mu = (1./sum(W)).*sum(W.*Y);

%   3.2) Compute the (absolute) residuals of the estimate
    R = abs(Y-repmat(mu,size(Y,1),1));

%   3.3) Compute the (robust) estimate of the std of the residuals
%       (assuming normal distribution)
    S = 1.4826 * median(R,'omitnan');

%   3.4) Compute the scaled deviations of each observation
    tmpS = repmat(4.685*S,size(Y,1),1);
    D = R./tmpS;

%   3.5) Update the weights using Tukey's biweight function
    tmpIdx     = find(abs(D)<1);
    W(tmpIdx)  = (1-D(tmpIdx).^2).^2;
    W(~tmpIdx) = 0;


    iIter = iIter + 1;
    theError(iIter) = sum(abs(mu - mu_previous));


    % figure(iIter+1)
    % subplot(2,2,1);
    % imagesc(log(D))
    % colormap('hot')
    % title('Deviations');
    % subplot(2,2,2);
    % imagesc(W)
    % colormap('hot')
    % title('Weights');
    % subplot(2,2,3:4);
    % plot(theError)
    % xlabel('Iterations');
    % ylabel('Sum of Errors');


    % Condition check at the end of the loop
    if all(abs(mu - mu_previous) < opt.tolerance)
        break;
    end
end

% 4) Repair the fluctuations
Y = W.*(Y-repmat(mu,size(Y,1),1));


% 5) Integrate back to the "magnitude-based" representation of the signal.
lowComponent(2:end,:,:) = lowComponent(1,:) + cumsum(Y);

% figure(iIter+2)
% subplot(4,1,1);
% plot(tmpData)
% title('Data');
% subplot(4,1,2);
% plot(lowComponent)
% title('Low component');
% subplot(4,1,3);
% plot(highComponent)
% title('Repaired component');
% subplot(4,1,4);
% plot(Y)
% title('Integrated');




%% C) The high frequency component of the signal is added back to the TDDR corrected low component
tmpData = lowComponent + highComponent;

%Put it back into the nimd folded by signals
nimg.data = reshape(tmpData,nimg.nSamples,nimg.nChannels,nimg.nSignals);

end
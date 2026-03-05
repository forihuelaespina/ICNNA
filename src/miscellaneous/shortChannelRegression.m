function [nimg,XX] = shortChannelRegression(nimg,options)
%Apply a short channel regression to a nirs_neuroimage
%
%   [nimg,X] = shortChannelRegression(nimg) - 
%   [nimg,X] = shortChannelRegression(nimg,options) 
%
% Apply a short channel regression to a @nirs_neuroimage for
% the alleviation of systemic extracranial noise.
%
%
%% Short channel regression
%
% In principle, a naive implementation of the short channel
% regression will use the model in Eq. 1:
%
%   y_{longMeasured} = \beta_{task} * x_{task}
%               + \beta_{short} * x_{short}         (Eq. 1)
%               + \beta_{drift} * t^k
%               + \varepsilon
%
%   with (k=0: \beta_{0} * t^0 = \beta_{0} * 1) accounting
% for the interception term and x_{short} the regressor
% generated from short channels measurements.
%
% From Eq. 1 it follows that:
%
%   y_{longCorrected} = \beta_{task}* x_{task} + \varepsilon 
%               = y_{longMeasured} 
%                 - \beta_{short} * x_{short}         (Eq. 2)
%                 [- \beta_{drift} * t^k]
%
%
%   The above has the virtue of estimating all beta coefficients
% simultaneously (hence leading to a cleaner partitioned of
% shared variance), BUT it makes assumptions about the task
% e.g., it necessitates a prior estimation of x_{task}.
%
% The prior estimation of x_{task} can be obtained perhaps
% using the common convolution of the some HRF e.g. double
% gamma, and the stimulus boxcar. But of course, this has all
% sort of short commings e.g. for event-related designs
% there may be some accumulation effects;
%
%   x_{task}​(t)= [\sum_k \delt(t−tk​)]∗HRF(t)
% 
% or for resting state designs, there shouldn't be such
% x_{task} in the first place.
%
% Alternatively, one can try to simply tackle the problem
% of removing the physiological noise without worring about
% the assumed x_{task} using (Eq. 3):
%
%   y_{longMeasured} = \beta_{short} * x_{short}         (Eq. 3)
%               + \beta_{drift} * t^k
%               + \varepsilon
%
% and then reconstructing as per Eq. 4:
%
%   y_{longCorrected} = \varepsilon 
%               = y_{longMeasured} 
%                 - \beta_{short} * x_{short}         (Eq. 4)
%                 [- \beta_{drift} * t^k]
%
% Eq. 3 is a nuisance-only regression. Sequential regression
% is NOT equivalent to joint GLM estimation unless regressors
% are orthogonal.
%
% This makes no assumption about x_{task}, it is design
% agnostic e.g. can support event related designs and can
% work well for resting state measurements. Indeed, this
% is the solution used by HomEr 3.
% 
% HOWEVER, it is NOT immediate than Eq. 3 is a better choice
% than Eq. 1. Residualizing the short channel first as per Eq. 3
% (and somewhere later dopwn the line in the pipeline 
% solving for the GLM) means that some task-related
% variance will be removed here (as one has to assume that
% Cov(x_{task},x_{short})=0), and therefore; 1) your GLM betas
% downstream will be biased, and 2) the statistical power will
% be reduced (sequential regression is NOT equal to joint
% regression unless regressors are orthogonal).
%
% In consequence, unfortunately, there is no universal way
% of applying the short channel regression. Some common variations
% include:
%
%   * Not using the interception term in the regression
%   (specially if strong filtering is used) OR not "subtracting" 
%   its contribution.
%   * Use ridge regression with multiple shorts separating the
%   contributions of different short channels
%   rather than using a single "mean" regressor for the
%   short channels (the averaged regressor assumes homogeneous
%   superficial physiology), e.g. Eq. 1 would rather be:
%
%   y_{long} = \beta_{task} * y_{task}
%               + \sum_k \beta_{short,k} * y_{short,k}  (Eq. 3)
%               + \beta_{0} * 1
%
%   * Using the first principal component of short channels
%   used as y_{short} regressor instead of the mean.
%   * Assuming that \varepsilon has some structure, e.g.
%   MNE-NIRS assume that \varepsilon = AR(p), and hence
%   using a different adjustment. At present (v1.4.0), this function
%   assumes no temporal autocorrelation modeling i.e.
%   
%       \varepsilon \sim \mathcal{N}(0,\sigma^2*I)  (Eq. 4)
%
%   which may be not the optimal choice for fNIRS for which
%   the noise is expected to be strongly autocorrelated. However,
%   direct application of AR(p) may lead to the appearance
%   of transients at the beginning of the signal if NOT corrected.
%
% It goes without saying that each of the above have different
% pros and cons. 
% 
%   +==================================================+
%   | IMPORTANT: This function operates on Eq. 3 by    |
%   | default, but it offers a few options to customize|
%   | its behaviour.                                   |
%   +==================================================+
%
%
%% Remarks
%
%   By default, interoptode distances are calculated over the 3D locations
% of the sources and detectors. Only if 3D locations are not available, 
% the 2D locations will be used.
%
%   Interoptode distances are approximated using Euclidean distances.
%
%
%% Parameters
%
% nimg - An @nirs_neuroimage to be processed.
% options - A struct of options
%   .arOrder - int. Default is 0 (No prewhitening)
%       Consider temporal autocorrelation in the uncertainty
%       term. For fNIRS, AR(1) or AR(2) is usually enough.
%       Beware! Although using AR(p) accounts for potential temporal
%       autocorrelations in the uncertainty term BUT this introduces
%       transients at the beginning of the signal. At present
%       (v.1.4.0), ICNNA does NOT correct for these transients.
%   .driftOrder - int. Default is 0 (only interception term).
%       Order of the drift regressors (polynomial).
%       Use -1 if you do NOT want to use drift terms.
%   .kShorts - int. Default is 1.
%       The number of short channels to be used to generate
%     the regressor. By default only the closest short channel is
%     used (kShorts = 1) but you can use average several closest
%     channels by using a higher value of kShorts with the maximum
%     being the total number of short channels present in the
%     neuroimage. To use all short channels either indicate the
%     exact number or set kShorts to -1.
%   .ridgeLambda - double. Default is 0 (no regularization / OLS)
%       Ridge regularization parameter.
%       Ridge regression is a special case of Tikhonov regularization
%       where Tikhonov matrix is the identity, i.e, \Gamma = I.
%       0 equals ordinary least squares (OLS).
%       This function does not support Tikhonov's full regularization
%       at present because Ridge regularization is often ok 
%       during the short channel regression. Note that there may be
%       further regularization when converting deltaOD to
%       deltaConcentrations.
%   .shortRegressorType - char[]. Default is 'average'
%       Method to generate the regressor(s) associated with the
%     short channels. Valid options are:
%       'average' - Uses the man of all k closest short channels.
%           This assumes homogeneous superficial physiology and
%           discards any spatial structure.
%       'separate' - Use separate regressors for each of the k closest 
%           short channels.
%       'pca' - Uses the first principal component of all k closest 
%           short channels.
%
%   +==================================================+
%   | Although, currently only the 'average' regressor |
%   | is supported, but this option is included here   |
%   | as a placeholder for future developments.        |
%   +==================================================+
%
%   .subtractDrift - Bool. Default is false.
%       Whether to subtract the drift terms when reconstructing
%       the long channels response.
%       Only considered if option .driftOrder >= 0.
%   .thresholdIOD - Int [mm]. By default is set to 12mm.
%       The threshold over the interoptode distance indicating under
%     which distance a channel is considered short channel.
%   .visualize - Bool. Default is false.
%       Visualize the results.
%
%   +==================================================+
%   | Watch out! For neuroimages with many channels    |
%   | this option may generate a large number of       |
%   | images.                                          |
%   +==================================================+
%
%% Output
% nimg - @nirs_neuroimage
%       An @nirs_neuroimage to which the short channel
%       regression for the alleviation of systemic
%       extracranial noise has been applied.
%       
% X - cell[nChannels,nSignals]
%       where [~,nChannels,nSignals] == size(nimg.data)
%       Each cell includes the regression matrix X.
%
%   ONLY long channels are regressed out, but the regressors
%   are calculated for ALL channels, whether short or long. Note
%   that for option .kShorts > 1, the regressors for the short
%   channels (regardless of the fact that they are "unused")
%   will not match the channel recording.
%
%
%
%
% Copyright 2025-26
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%



%% Log
%
% 14-Apr-2025: FOE
%   + File created.
%
%
% -- v1.4.0
%
% 18-Feb-2026: FOE
%   + Now accounts for the fact that @channelLocationMap does not
%   store the spatial units and hence the IOD may not be in [cm]
%   by default.
%   + Added output SSregressors
%   + Improved comments/documentation
%   + Added options .dirftOrder and substractDirft to control the
%   use of drift terms including the interception term.
%   + Added options .shortRegressorType.
%


%% Deal with options
opt.arOrder        = 0; % 0 = no prewhitening
opt.driftOrder     = 0; %Use only the interception term.
opt.kShorts        = 1;
opt.ridgeLambda    = 0; %OLS
opt.shortRegressorType = 'average';
opt.subtractDrift  = false;
opt.thresholdIOD   = 12;
opt.visualize      = false;
if exist('options','var') && isstruct(options)
    if isfield(options,'arOrder')
        opt.arOrder = options.arOrder;
    end
    if isfield(options,'driftOrder')
        opt.driftOrder = options.driftOrder;
    end
    if isfield(options,'kShorts')
        opt.kShorts = options.kShorts;
    end
    if isfield(options,'ridgeLambda')
        opt.ridgeLambda = options.ridgeLambda;
    end
    if isfield(options,'shortRegressorType')
        opt.shortRegressorType = lower(options.shortRegressorType);
    end
    if isfield(options,'subtractDrift')
        opt.subtractDrift = options.subtractDrift;
    end
    if isfield(options,'thresholdIOD')
        opt.thresholdIOD = options.thresholdIOD;
    end
    if isfield(options,'visualize')
        opt.visualize = options.visualize;
    end
end

assert(opt.thresholdIOD >= 0,...
    ['Interoptode distance threshold to mark the short channels ' ...
     'needs to be larger than 0.']);



%% Retrieve interoptode distances and inter-channels distances
clm          = nimg.chLocationMap;
chLocations  = clm.chLocations;
chIOD        = icnna.util.autoscaleIOD2mm(clm.getIOD());


chPairwiseDistance = squareform(pdist(chLocations,'euclidean'));
maskShortChannels  = chIOD <= opt.thresholdIOD;

nShortChannels = sum(maskShortChannels);
if (opt.kShorts == -1)
    opt.kShorts = 1:nShortChannels;
end
if (opt.kShorts > nShortChannels)
    warning('icnna:miscellaneous:shortChannelRegression:InvalidParameterValue',...
            ['Number of short channels (option.kShorts) is larger ' ...
            'than available total number of short channels. Setting ' ...
            'option.kShorts to total number of short channels.']);
    opt.kShorts = nShortChannels;
end

shortChannelIdx = find(maskShortChannels); %Indices of the short channels

%% Form the short channel regressors for each channel
shortChannelNeighbours = nan(clm.nChannels, opt.kShorts);
regressors = cell(clm.nChannels,nimg.nSignals);

%disp('Short Channel Pairings:')
for iCh = 1:clm.nChannels

    [~,tmpIdx]  = mink(chPairwiseDistance(iCh,maskShortChannels),opt.kShorts);
        %Retrieve the k closest short channels but beware as the index
        %is "only" over the subset of short channels. I need to "decode"
        %what is the channel index of these short channels.
    shortChannelNeighbours(iCh,:) = shortChannelIdx(tmpIdx);

    % if ismember(iCh,shortChannelIdx)
    %     disp([' Short: ' num2str(iCh) ' => Short: ' mat2str(shortChannelNeighbours(iCh,:))])
    % else
    %     disp([' Long: ' num2str(iCh) ' => Short: ' mat2str(shortChannelNeighbours(iCh,:))])
    % end

    for iSig = 1:nimg.nSignals
        shortData = nimg.data(:,shortChannelNeighbours(iCh,:),iSig);

        switch opt.shortRegressorType
            case 'average'
                R = mean(shortData,2,'omitnan');

            case 'separate'
                R = shortData;

            case 'pca'
                shortData = shortData - mean(shortData,1,'omitnan');
                [U,~,~] = svd(shortData,'econ');
                R = U(:,1); %Use only the first PC

            otherwise
                error('Invalid shortRegressorType.');
        end

        regressors{iCh,iSig} = R;
    end
end



%% Drift regressors (polynomial)
if opt.driftOrder > -1
    t = linspace(-1,1,nimg.nSamples)';
    Xdrift = [];
    for k = 0:opt.driftOrder
        Xdrift = [Xdrift t.^k];
    end
else
    Xdrift = [];
end



%% Regress out

% Note that I could in principle merge this loop below with the one above,
% but this is kept separate for code readability
XX = cell(clm.nChannels,nimg.nSignals);
for iCh = 1:clm.nChannels 
    %Only regress out long-channels
    if ~ismember(iCh,shortChannelIdx)
        for iSig = 1:nimg.nSignals
            Yorig = nimg.data(:,iCh,iSig);
            Y = Yorig;

            %Build the regression matrix
            X = regressors{iCh,iSig};
            nShortCols = size(X,2);
            if ~isempty(Xdrift)
                %Concatenate drift regressors
                X = [X Xdrift];
            end
            



            %Optional AR(p) prewhitening
            %Estimating: 
            % \hat{\beta}_{\mathrm{GLS}} = (X^{T}\Sigma^{-1}X)^{-1} X^{T}\Sigma^{-1}Y
            %Watch out! Filtering introduces transients
            % at the beginning of the signal
            Xorig = X;
            if opt.arOrder > 0
                %Estimate AR model on Y using Yule-Walker equations
                arCoeff = myARYuleWalker(Y, opt.arOrder);
                        %See auxiliary function below
                
                %Filter Y
                Y = filter(arCoeff,1,Y);
                
                %Filter each column of X
                for kCol = 1:size(X,2)
                    X(:,kCol) = filter(arCoeff,1,X(:,kCol));
                end
            end


            XX(iCh,iSig) = {X};

            %Solve the regression using the AR(p) adjusted X and Y
            if opt.ridgeLambda > 0
                beta = pinv(X'*X + opt.ridgeLambda*eye(size(X,2))) * (X'*Y);
            else
                beta = pinv(X)*Y;
            end

            %Compute fitted nuisance (exclude drift if desired)
            %Note that this is done in the ORIGINAL space
            if (~isempty(Xdrift) && opt.subtractDrift) 
                Yhat = Xorig*beta;
            else %Do not subtract the drift terms
                Yhat = Xorig(:,1:nShortCols)*beta(1:nShortCols);
            end


            %Reconstruct the observation
            nimg.data(:,iCh,iSig) = Yorig - Yhat;


            if opt.visualize
                tmpSignalName = 'oxy';
                if iSig == 2
                    tmpSignalName = 'deoxy';
                end
                
                figure('Name',['SSR - Ch. ' num2str(iCh)]);
                subplot(3,1,1);
                plot(Yorig);
                title([tmpSignalName ' - Before SSR']);
                subplot(3,1,2);
                plot(X);
                title('Short Regressor(s)');
                subplot(3,1,3);
                plot(nimg.data(:,iCh,iSig));
                title('After SSR');
            end

        end
    end
end






end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AUXILIARY FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function arCoeff = myARYuleWalker(Y, p)
% Estimate AR(p) coefficients using Yule-Walker equations
%
% arCoeff = myARYuleWalker(Y, p)
%
%% Remark
% Matlab provides function aryule(Y, p) but it is in the
% Signal Processing Toolbox. This is a reimplementation using only
% basic standard MATLAB.
%
%% Input Parameters:
%   Y - double[nSamples x 1]
%       Observations
%   p - int. (integer >= 0)
%       AR order 
%
%% Output:
%   arCoeff - double[1 x p+1] vector
%       AR coefficients including leading 1
%       i.e., arCoeff = [1, -phi1, -phi2, ..., -phi_p]
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also 
%


%% Log
%
% -- v1.4.0
%
% 18-Feb-2026: FOE
%   + Function created.
%

Y = Y(:); % ensure column vector
nSamples = length(Y);

if p == 0
    arCoeff = 1;
    return;
end

% Compute biased autocorrelation
r = zeros(p+1,1);
for k = 0:p
    r(k+1) = (Y(1:nSamples-k)' * Y(1+k:nSamples)) / nSamples;
end

% Solve Yule-Walker equations
R = toeplitz(r(1:p));  % autocorrelation matrix
rhs = r(2:p+1);        % right-hand side
phi = R \ rhs;          % solve for AR coefficients

arCoeff = [1; -phi];    % aryule convention: leading 1, negated phi
arCoeff = arCoeff(:).'; % row vector
end
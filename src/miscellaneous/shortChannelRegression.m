function [nimg] = shortChannelRegression(nimg,options)
%Apply a short channel regression to a nirs_neuroimage
%
%   [nimg] = shortChannelRegression(nimg) - Apply a short channel
%       regression to a nirs_neuroimage for the alleviation of systemic
%       extracranial noise.
%
%   [nimg] = shortChannelRegression(nimg,options) - Apply a short channel
%       regression to a nirs_neuroimage for the alleviation of systemic
%       extracranial noise with the given options.
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
%   .kShorts - Int. By default is 1.
%       The number of short channels to be averaged to generate
%     the regressor. By default only the closest short channel is
%     used (kShorts = 1) but you can use average several closest
%     channels by using a higher value of kShorts with the maximum
%     being the total number of short channels present in the
%     neuroimage. To use all short channels either indicate the
%     exact number or set kShorts to -1.
%   .thresholdIOD - Int [mm]. By default is set to 12mm.
%       The threshold over the interoptode distance indicating under
%     which distance a channel is considered short channel.
%   .visualize - Bool. Default is false.
%       Visualize the results.
%
%% Output
% nimg - An @nirs_neuroimage to which the short channel
%       regression for the alleviation of systemic
%       extracranial noise has been applied.
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%



%% Log
%
% 14-Apr-2025: FOE
%   + File created.
%

%% Deal with options
opt.kShorts = 1;
opt.thresholdIOD = 12;
opt.visualize = false;
if exist('options','var') && isstruct(options)
    if isfield(options,'kShorts')
        opt.kShorts = options.kShorts;
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



%% Retrieve interoptode distances and inter-channel distances
clm          = nimg.chLocationMap;
srcIdx       = clm.pairings(:,1);
detIdx       = clm.pairings(:,2);
srcLocations = clm.optodesLocations(srcIdx,1);
detLocations = clm.optodesLocations(detIdx,2);
chLocations  = clm.chLocations;
chIOD        = clm.getIOD();


chPairwiseDistance = squareform(pdist(chLocations,'euclidean'));
maskShortChannels  = chIOD <= opt.thresholdIOD;

nShortChannels = sum(maskShortChannels);
if opt.kShorts == -1,
    opt.kShorts = 1:nShortChannels;
end
assert(opt.kShorts <= nShortChannels,...
    'Invalid number of short channels (option.kShorts).');


%% Form the short channel regressors for each channel

shortChannelIdx = find(maskShortChannels); %Indices of the short channels
shortChannelNeighbours = nan(clm.nChannels, opt.kShorts);
regressors = nan(size(nimg.data));
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
        regressors(:,iCh,iSig) = mean(nimg.data(:,shortChannelNeighbours(iCh,:),iSig),2,'omitnan');
    end
end



%% Regress out

% Note that I could in principle merge this loop below with the one above,
% but this is kept separate for code readability
for iCh = 1:clm.nChannels 
    %Only regress out long-channels
    if ~ismember(iCh,shortChannelIdx)
        for iSig = 1:nimg.nSignals
            Y = nimg.data(:,iCh,iSig);
            X = [regressors(:,iCh,iSig) ones(nimg.nSamples,1)];
            beta = pinv(X)*Y;
            nimg.data(:,iCh,iSig) = Y-beta(1)*X(:,1);


            if opt.visualize
                tmpSignalName = 'oxy';
                if iSig == 2
                    tmpSignalName = 'deoxy';
                end
                
                figure
                subplot(3,1,1)
                plot(Y)
                title([tmpSignalName ' - Before SSR'])
                subplot(3,1,2)
                plot(X(:,1))
                title('Short Channel')
                subplot(3,1,3)
                plot(nimg.data(:,iCh,iSig))
                title('After SSR')
            end

        end
    end
end

end

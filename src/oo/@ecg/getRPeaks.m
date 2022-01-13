function [rPeaks,threshold]=getRPeaks(HRsignal,options)
%ECG/GETRPEAKS Indexes of samples at which the QRS complexes wave peaks
%
% [rPeaks,threshold]=getRPeaks(HRsignal) finds the indexes of
% samples at which the QRS complexes wave peaks, or R peaks
% using an automatic statistically optimal threshold (See
% section Algorithm).
%
% rPeaks=getRPeaks(HRsignal,options) finds the indexes of samples
% at which the QRS complexes wave peaks, or R peaks using the
% specified options.
%
% See also qrsdetection which is a sophisticated alternative to this getRPeaks.
% getRpeaks is faster, but qrsdetection have much better tolerance to noise in the
% ecg data.
%

%
%% Remarks
%
% This function updates the property threshold.
%
%
%% Parameter
%
% HRsignal - Raw ECG (electrocardiogram) data series
%
% thresh - DEPRECATED. Threshold for the LoG algorithm. See
%   option .logthreshold
%
% options - Optional.
%   algo - Algorithm used to detect R peaks. Possible values
%       are:
%       'LoG' - (Default) Laplacian of a Gaussian.
%       'Chen2017' - See qrsdetection method
%   logthreshold - Threshold for the LoG algorithm.
%   visualization - True if a figure is to be rendered. False (default)
%   otherwise.
% == For the Laplacian of Gaussian (LoG) algorithm
%   thresh - A threshold established manually.
% == For the Chen2017 algorithm
%   See method qrsdetection
%
%% Output
%
% A column vector of samples indexes to the R peaks
%
%
% Copyright 2009
% Author: Felipe Orihuela-Espina
% Date: 19-Jan-2009
%
% See also ecg, getRR, getBPM
%


%% Log
%
% 29-May-2019: FOE
%   + Log started.
%   + Provided support for the new R peak detection algorithm; 'Chen2017'
%   + Deprecated direct use of parameter thresh
%


%% Deal with some options
opt.visualize=false;
opt.algo = 'LoG';
opt.logthreshold = []; %Threshold for the LoG algorithm
if exist('options','var')
    if ~isstruct(options)
        %Backward compatibility.
        opt.logthreshold = options;
        warning(['DEPRECATED use of parameter ''thresh'': ' ...
                 'Please pass the threshold using option .logthreshold']);
    else
        if(isfield(options,'algo'))
            opt.algo=options.algo;
        end
        if(isfield(options,'logthreshold'))
            opt.logthreshold=options.logthreshold;
        end
        if(isfield(options,'visualize'))
            opt.visualize=options.visualize;
        end
    end
end


%Set default outputs
rPeaks = [];
threshold = opt.logthreshold;
if ~isempty(HRsignal)
    switch lower(opt.algo)
        case 'log' %Laplacian of Gaussian
            if isempty(opt.logthreshold)
                [rPeaks,threshold] = ecg.getRPeaksByLoG(HRsignal);
            else
                [rPeaks,threshold] = ecg.getRPeaksByLoG(HRsignal,opt.logthreshold);
            end
        case 'chen2017'
            if exist('options','var')
                [rPeaks] = ecg.qrsdetection(HRsignal,options);
            else
                [rPeaks] = ecg.qrsdetection(HRsignal);
            end
            
        otherwise
            error('ICAF:ecg:getRPeaks',...
                'Unexpected R Peaks detection algorithm.');
    end

end




%% Visualization =========================================
if (opt.visualize)
    lineWidth=1.5;
    fontSize=13;
    
    %R peaks detection
    figure
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    
    hold on
    plot(HRsignal,'b-','LineWidth',lineWidth);
    plot(tmp1,'r-','LineWidth',lineWidth);
    getY=axis;
    for ii=1:length(rPeaks)
        plot([rPeaks(ii) rPeaks(ii)],[getY(3) getY(4)],'k--', ...
                'LineWidth',lineWidth)
    end
    title(['LoG 1D Mask: ' mat2str(LoG) '; Thrsh: ' num2str(threshold)])
    box on, grid on

end

end



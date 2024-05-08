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
% rPeaks - A column vector of samples indexes to the R peaks
%
%
% Copyright 2009-24
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
% 12-Apr-2024: FOE
%   + Enabled some options for controlling Chen's algorithm
%
%

        if(isfield(options,'samplingrate'))
            opt.samplingrate=options.samplingrate;
        end
%% Deal with some options
opt.visualize=false;
opt.algo = 'LoG';
opt.logthreshold = []; %Threshold for the LoG algorithm

%Chen 2017 related options
opt.maskhalfsize = 2; %Half-width of the enhancement mask in [samples]
opt.searchingrange = 0.3; %in [s]. For adults
%opt.searchingrange = 0.1; %in [s]. For children
opt.samplingrate = 50; %[Hz]
opt.qrsminimumamplitude = 0.5; %in [mV]. Used for triggering the QRS search.
opt.thresholdcrest = 0.22;
%opt.thresholdcrest = 0.4;
opt.thresholdtrough = -0.2;
%opt.thresholdtrough = -0.4;
opt.QRSlateny=0.12; %In [s]. Latency between two QRS. For adults
%opt.QRSlateny=0.06; %In [s]. Latency between two QRS. For child
%opt.QRSlateny=0.03; %In [s]. Latency between two QRS. For child plus allow arrythmias
opt.nboundarysamples = 5; %Controls alleviation of boundary effects



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


        %Chen 2017's algorithm options

        if(isfield(options,'maskhalfsize'))
            opt.maskhalfsize=options.maskhalfsize;
        end
        if(isfield(options,'searchingrange'))
            opt.searchingrange=options.searchingrange;
        end
        if(isfield(options,'samplingrate'))
            opt.samplingrate=options.samplingrate;
        end
        if(isfield(options,'qrsminimumamplitude'))
            opt.qrsminimumamplitude=options.qrsminimumamplitude;
        end
        if(isfield(options,'thresholdcrest'))
            opt.thresholdcrest=options.thresholdcrest;
        end
        if(isfield(options,'thresholdtrough'))
            opt.thresholdtrough=options.thresholdtrough;
        end
        if(isfield(options,'QRSlateny'))
            opt.QRSlateny=options.QRSlateny;
        end
         if(isfield(options,'nboundarysamples'))
            opt.nboundarysamples=options.nboundarysamples;
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



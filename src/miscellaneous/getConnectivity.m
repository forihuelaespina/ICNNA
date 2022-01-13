function [C,P]=getConnectivity(sd,options)
%Computes the connectivity matrix between channels (overall or by stimulus)
%
% [C,P]=getConnectivity(sd) Computes the connectivity
%	matrix between channels (overall)
%
% [C,P]=getConnectivity(sd,options) Computes the connectivity
%	matrix between channels (overall or by stimulus) with the
%   indicated options.
%
%
%Currently applies the crosscorrelation2D as metric of
%connectivity (functional). Use 1-C to convert them to
%distances.
%
%% Remarks
%
% This function requires MATLAB's Signal Processing Toolbox.
%
%% Parameters
%
% sd - A structuredData. Connectivity among its channels.
%
% options - A struct of options
%       .outputType - Selects whether the connectivity is calculated
%           overall or by stimulus. Valid values are:
%               + 'overall' - Default. Uses the whole timecourse to
%                       establish the connectivity
%               + 'stim' - Segments the timecourse by stimulus (i.e.
%                       conditions in the timeline) before
%                       calculating the connectivity. See the option
%                       .experimentSpace to parameterize the processing.
%       .experimentSpace - An experiment space object. This option
%           is only taken into account if the outputType is 'stim'.
%           Use this option to indicate how the structuredData is to
%           be processed. If not indicated a default experimentSpace
%           will be used (refer to class experimentSpace). Data will be
%           processed similarly to function experimentSpace.compute
%
%
%
%% Output
%
% C - The connectivity matrix.
%        If the options.outputType is 'overall' then this is
%           a <nChannelsxnChannels> matrix. 
%        If the options.outputType is 'stim' then this is
%           a <nChannelsxnChannelsxnStim> matrix. 
% P - The significance (p-value) of the connectivity matrix
%        If the options.outputType is 'overall' then this is
%           a <nChannelsxnChannels> matrix. 
%        If the options.outputType is 'stim' then this is
%           a <nChannelsxnChannelsxnStim> matrix. 
%
%
%
%
% Copyright 2010-13
% @date: 12-Jan-2010
% @author: Felipe Orihuela-Espina
% @modified: 10-Apr-2013
%
% See also structuredData, toPajek, tpvalue, experimentSpace
%


%=====================================================%
% A nice description of the relation between the
% cross-correlation function and the correlation
% coefficient value can be found in:
% http://www.biomedical-engineering-online.com/content/3/1/26
%=====================================================%
%%Computation of p-values of the cross-correlation
%
%Computing the p-value of the cross-correlation function
%is everything but trivial [SimpsonMD2001]. Not in vain
%Matlab does not provide the p-value of the cross-correlation
%neither for xcorr nor for xcorr2.
%
% [SimpsonMD2001] Simpson, M. D.; Infantosi, A. F. C. and
%Botero Rosas, D. A.  (2001) "Estimation and significance
%testing of cross-correlation between cerebral blood flow
%velocity and background electro-encephalograph activity
%in signals with missing samples" Medical and Biological
%Engineering and Computing 39:428-433
%=====================================================%






%% Deal with options
opt.outputType='overall';
opt.experimentSpace=experimentSpace;
if exist('options','var')
    if isfield(options,'outputType')
        opt.outputType=options.outputType;
    end
    if isfield(options,'experimentSpace')
        opt.experimentSpace=options.experimentSpace;
    end
end


nChannels = get(sd,'NChannels');


switch lower(opt.outputType)
%% Connectivity: Overall
    case 'overall'
        
C=zeros(nChannels);
for ch1=1:nChannels
    tmpCh1 = getChannel(sd,ch1);
    for ch2=1:nChannels
        tmpCh2 = getChannel(sd,ch2);
	tmpc = xcorr2(tmpCh1,tmpCh2); %Watch out! No scaling/normalization
    %For normalization of the 2D cross-correlation
    %value, please refer to MATLAB's function reference
    %help xcorr2 (literally; the last 3 lines).
    
    %I'm only interested in the full aligment of the signals
    %i.e. HbO2 with HbO2 and HHb with HHb, so I can focus
    %on the center column
    nCols = size(tmpc,2);
    tmpc = tmpc(:,ceil(nCols/2));
    
    %Since normalization is "difficult" at a lag different
    %than zero, I will stick to lag zero by now...
    tmpc_lag0 = tmpc(ceil(length(tmpc)/2));
    %...and normalize
    I1p = tmpCh1;
    I2 = tmpCh2;
    n_tmpc_lag0 = tmpc_lag0 / sqrt(sum(dot(I1p,I1p))*sum(dot(I2,I2)));
        %%%NOTE that this normalization is only valid at lag 0.
        %%%At different lags, a "window" of the size of the
        %%%shorter signal (I2), must be cropped from the longer
        %%%signal (I1) to get I1p...
    C(ch1,ch2) = n_tmpc_lag0;

    %IMPORTANT: See [AchardS2007, pg 175] for a discussion
    %on the choice of the threshold!.



    %%Compute p-values
    
    %%%Comment from MATLAB's corrcoef function
%   The p-value is computed by transforming the correlation to create a t
%   statistic having N-2 degrees of freedom, where N is the number of rows
%   of X.
    N = min(size(tmpCh1,1),size(tmpCh2,1)); %Sample size
    Tstat = C(ch1,ch2) .* sqrt((N-2) ./ (1 - C(ch1,ch2).^2));
                                            %convert the cross-correlation
                                            %value to a t-distribution.
    % "...(N - 2)1/2 r/(l - r2)1/2 has a t-distribution with N - 2
    %degrees of freedom..."
    % [CliffordP1989] Clifford, Peter; Richardson, Sylvia; Hemon, Denis
    %(1989) "Assessing the Significance of the Correlation between
    %Two Spatial Processes" Biometrics, Vol. 45, No. 1
    %(Mar., 1989), pp. 123-134
    %
    
        %Note 1: The above formulation to compute Tstat is ready
        %for dealing with the whole matrix C in one shot. But since
        %N may change at for each pair of channels, then I cannot
        %take all this bit of computing the p-value out from the
        %loops.
        %Note 2: Tstat may take complex values (SURE OF THIS),
        %thus -abs is required (NOT SURE OF THIS, BUT THIS IS HOW
        %MATLAB'S CORRCOEF DEALS WITH IT).
    p = tpvalue(-abs(Tstat),N-2);
    P(ch1,ch2) = p;

    end
end



%% Connectivity: By stimulus
    case 'stim'
        
        expSpace = opt.experimentSpace;
        
        t=get(sd,'Timeline');
        integrityCodes=get(sd,'Integrity');
        %%TO DO: Still need to check whether timelines are compatible
        nSignals=get(sd,'NSignals');
        nStim=get(t,'NConditions');
                
        C=zeros(nChannels,nChannels,nStim);
        
        for stim=1:nStim
            stimTag=getConditionTag(t,stim);
            
            %% Stage 1: Block Splitting
            nBlocks=getNEvents(t,stimTag);
            %Temporarily collect the blocks for this condition
            tmpBlocks=cell(nBlocks,1);
            bSamples=get(expSpace,'BaselineSamples');
            rSamples=get(expSpace,'RestSamples');
            for bl=1:nBlocks
                if (rSamples < 0)
                    tmpBlocks(bl)=...
                        {getBlock(sd,stimTag,bl,...
                        'NBaselineSamples',bSamples)};
                else
                    tmpBlocks(bl)=...
                        {getBlock(sd,stimTag,bl,...
                        'NBaselineSamples',bSamples,...
                        'NRestSamples',rSamples)};
                end
            end
            
            %% Stage 2: Resampling
            if (get(expSpace,'Resampled'))
                nRSSamples=[get(expSpace,'RS_Baseline') ...
                    get(expSpace,'RS_Task') ...
                    get(expSpace,'RS_Rest')];
                for bl=1:nBlocks
                    s=warning('query','ICNA:timeline:set:EventsCropped');
                    warning('off','ICNA:timeline:set:EventsCropped');
                    tmpBlocks(bl)={blockResample(tmpBlocks{bl},nRSSamples)};
                    warning(s.state,'ICNA:timeline:set:EventsCropped');
                    %Leave the warning state as it was
                end
            end
            
            %% Stage 3: Block Averaging
            if (get(expSpace,'Averaged'))
                nBlocks=1;
                avgBlock=blocksTemporalAverage(tmpBlocks);
                clear tmpBlocks
                tmpBlocks={avgBlock};
                clear avgBlock
            end
            
            %% Stage XX: Normalization
            %See below
            
            %% Stage 4: Window Selection
            %if (get(obj,'Windowed'))
            for bl=1:nBlocks
                t2=get(tmpBlocks{bl},'Timeline');
                
                s=warning('query','ICNA:timeline:set:EventsCropped');
                warning('off','ICNA:timeline:set:EventsCropped');
                tmpBlocks(bl)={windowSelection(tmpBlocks{bl},...
                    getConditionTag(t2,1),1,...
                    get(expSpace,'WS_Onset'),...
                    get(expSpace,'WS_Duration'))};
                warning(s.state,'ICNA:timeline:set:EventsCropped');
                %Leave the warning state as it was
            end
            %end
            
            
            
            %% Stage X: Concatenate each block timecourse into a single timecourse
            tmpData = nan(0,nChannels,nSignals);
            for bl=1:nBlocks
                for chID=1:nChannels
                    %if (getStatus(integrityCodes,chID)==integrityStatus.FINE)
                        channelData=getChannel(tmpBlocks{bl},chID);
                        tmpSamples=size(channelData);
                        for signID=1:nSignals
                            if bl==1 && chID==1 && signID==1
                                tmpData(end+1:end+tmpSamples,chID,signID)=...
                                            channelData(:,signID);
                            else
                                tmpData(end-tmpSamples+1:end,chID,signID)=...
                                            channelData(:,signID);
                            end
                        end %of signals
                        
                    %end %if clean channel
                end %of channels
            end %of blocks
        
for ch1=1:nChannels
    tmpCh1 = squeeze(tmpData(:,ch1,:));
    for ch2=1:nChannels
        tmpCh2 = squeeze(tmpData(:,ch2,:));
	tmpc = xcorr2(tmpCh1,tmpCh2); %Watch out! No scaling/normalization
    %For normalization of the 2D cross-correlation
    %value, please refer to MATLAB's function reference
    %help xcorr2 (literally; the last 3 lines).
        
    
    %I'm only interested in the full aligment of the signals
    %i.e. HbO2 with HbO2 and HHb with HHb, so I can focus
    %on the center column
    nCols = size(tmpc,2);
    tmpc = tmpc(:,ceil(nCols/2));
    
    %Since normalization is "difficult" at a lag different
    %than zero, I will stick to lag zero by now...
    tmpc_lag0 = tmpc(ceil(length(tmpc)/2));
    %...and normalize
    I1p = tmpCh1;
    I2 = tmpCh2;
    n_tmpc_lag0 = tmpc_lag0 / sqrt(sum(dot(I1p,I1p))*sum(dot(I2,I2)));
        %%%NOTE that this normalization is only valid at lag 0.
        %%%At different lags, a "window" of the size of the
        %%%shorter signal (I2), must be cropped from the longer
        %%%signal (I1) to get I1p...
    C(ch1,ch2,stim) = n_tmpc_lag0;

    %IMPORTANT: See [AchardS2007, pg 175] for a discussion
    %on the choice of the threshold!.



    %%Compute p-values
   
    %%%Comment from MATLAB's corrcoef function
%   The p-value is computed by transforming the correlation to create a t
%   statistic having N-2 degrees of freedom, where N is the number of rows
%   of X.
    N = min(size(tmpCh1,1),size(tmpCh2,1)); %Sample size
    Tstat = C(ch1,ch2,stim) .* sqrt((N-2) ./ (1 - C(ch1,ch2,stim).^2));
                                            %convert the cross-correlation
                                            %value to a t-distribution.
    % "...(N - 2)1/2 r/(l - r2)1/2 has a t-distribution with N - 2
    %degrees of freedom..."
    % [CliffordP1989] Clifford, Peter; Richardson, Sylvia; Hemon, Denis
    %(1989) "Assessing the Significance of the Correlation between
    %Two Spatial Processes" Biometrics, Vol. 45, No. 1
    %(Mar., 1989), pp. 123-134
    %
    
        %Note 1: The above formulation to compute Tstat is ready
        %for dealing with the whole matrix C in one shot. But since
        %N may change at for each pair of channels, then I cannot
        %take all this bit of computing the p-value out from the
        %loops.
        %Note 2: Tstat may take complex values (SURE OF THIS),
        %thus -abs is required (NOT SURE OF THIS, BUT THIS IS HOW
        %MATLAB'S CORRCOEF DEALS WITH IT).
    p = tpvalue(-abs(Tstat),N-2);
    P(ch1,ch2,stim) = p;

    end
end

        
        end %of stimulus
        
        
        

    otherwise
        error('ICNA:getConnectivity',...
              ['Unexpected value ''' opt.outputType ...
                  '''for option outputType. ' ...
               'Current accepted values are ''overall'' and ''stim''.']);


end %Switch outputType


end %function



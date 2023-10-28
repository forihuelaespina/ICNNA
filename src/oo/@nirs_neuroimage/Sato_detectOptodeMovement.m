function [idx,reconstructed,idxPeaks]=Sato_detectOptodeMovement(signal,options)
%Sato's wavelength based algorithm for the detection of optode movement artefacts
%
% function [idx,reconstructed]=Sato_detectOptodeMovement(signal)
%
%Sato's wavelength based algorithm for the detection of
%optode movement artefacts (see [Sato et al, 2006b]).
%
%
%% Parameters:
%
%
% signal - The signal time serie. Please note that Sato operates on the
%   totalHb
%
%
% options - An struct with several fields indicating some options.
%   Following is a list of the available options (fieds of the struct)
%
%   .visualize: Plot the results. False by default.
%
%
%
%
% 
% Copyright 2007-23
% @author: Felipe Orihuela-Espina
%
% See also nirs_neuroimage
%




%% Log
%
% File created: 19-Jul-2007
% File last modified (before creation of this log): N/A. This method
%   had not been modified since creation.
%
% 20-May-2023: FOE
%   + Added this log. This method is so old it didn't even had the
%       labels @date and @modified, instead there was just the creation
%       date!!
%





%Deal with some options
opt.visualize=false;
if(nargin>=2)
    if(isfield(options,'visualize'))
        opt.visualize=options.visualize;
    end
end

nSamples=length(signal);
nScales=1:30;

%Haar family wavelet coefficient
coeff=cwt(signal,nScales,'haar');
%coeff=cwt(signal,nScales,'haar','plot');
%Normalized wavelet coefficients
%%This helps to standardize the parameters for most OT data.
scMedian=median(coeff.^2,2);
for ii=nScales
    scMedian(ii,1:nSamples)=scMedian(ii,1);
end
normCoeff=(coeff.^2)./scMedian;

%%Plot normalized coefficients at some sample scales (same as in the paper)...
% subplot(3,1,1);
% plot(normCoeff(3,:))
% subplot(3,1,2);
% plot(normCoeff(9,:))
% subplot(3,1,3);
% plot(normCoeff(20,:))

%Mean optimal parameters as found by Sato
sc=9;
threshold=43;

%Find the sudden changes
idx=find(normCoeff(sc,:)>43);
%Remove consecutive idx...
%This is equivalent to leave the wavelet, time to recover
for ii=length(idx)-1:-1:1
    if(idx(ii+1)==idx(ii)+1)
        idx(ii+1)=[];
    end
end

%%Note that for Sato's approach, it might be more accurate
%%to look for the local maxima in each "group" of idx when looking
%%for the accurate location of the change
idx2=find(normCoeff(sc,:)>43);
idxPeaks=[];
for ii=idx2
    if (ii==1)
        if (normCoeff(sc,ii)>normCoeff(sc,ii+1))
            idxPeaks=[idxPeaks ii];
        end
    elseif (ii==nSamples)
        if (normCoeff(sc,ii)>normCoeff(sc,ii-1))
            idxPeaks=[idxPeaks ii];
        end
    else    
        if ((normCoeff(sc,ii)>normCoeff(sc,ii+1)) ...
                & (normCoeff(sc,ii)>normCoeff(sc,ii-1)))
            idxPeaks=[idxPeaks ii];
        end
    end
end


%%%Reconstruction (Not working properly at the moment)
idx3=find(normCoeff>43);
coeff(idx3)=0;
reconstructed=idwt(coeff(30:-1:16),coeff(15:-1:1),'haar');

%% Visualization =========================================
if (opt.visualize)
    lineWidth=1.5;
    
    figure
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    subplot(2,1,1), hold on
    plot(signal,'b-','LineWidth',lineWidth)
    %plot(reconstructed,'r-','LineWidth',lineWidth)
    getY=axis;
    % for ii=1:length(idx)
    %     plot([idx(ii) idx(ii)],[getY(3) getY(4)],'k--','LineWidth',lineWidth)
    % end
    for ii=1:length(idxPeaks)
        plot([idxPeaks(ii) idxPeaks(ii)],[getY(3) getY(4)],'m--','LineWidth',lineWidth)
    end
    box on, grid on
    subplot(2,1,2)
    hold on
    plot(normCoeff(sc,:))
    hthresh=plot([0 nSamples],[threshold threshold],'k:','LineWidth',lineWidth);
    box on, grid on
    
end

end
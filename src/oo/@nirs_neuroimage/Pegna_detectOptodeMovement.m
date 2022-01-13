function [idx,reconstructed]=Pegna_detectOptodeMovement(signal,options)
%Peña's differences based algorithm for the detection of optode movement artefacts
%%
%%Date: 19-Jul-2007
%%Author: Felipe Orihuela-Espina
%%
%
% function [idx,reconstructed]=Pegna_detectOptodeMovement(signal)
%
%Peña's differences based algorithm for the detection of
%optode movement artefacts (see [Pegna et al, 2003]).
%
%
%Parameters:
%-----------
%
% signal - The signal time serie. Please note that Pegna operates on the
%   totalHb
%
%
% options - An struct with several fields indicating some options.
%   Following is a list of the available options (fieds of the struct)
%
%   .visualize: Plot the results. False by default.
%
%


%Deal with some options
opt.visualize=false;
if(nargin>2)
    if(isfield(options,'visualize'))
        opt.visualize=options.visualize;
    end
end

nSamples=length(signal);
threshold=10;%0.1 mmol/mm used by pegna

firstDifferences=abs(signal(2:end)-signal(1:end-1));
tempIdx=find(firstDifferences>threshold);
%Since we need two consecutive samples going above the threshold
%we therefore ignore isolated idx...
idx=[];
for ii=tempIdx
    nextIdx=ii+1;
    if(any(ismember(tempIdx,nextIdx)))
        idx=[idx ii];
    end
end


%% Visualization =========================================
if (opt.visualize)
    lineWidth=1.5;
    figure
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    hold on
    plot(signal,'b-','LineWidth',lineWidth)
    getY=axis;
    for ii=1:length(idx)
        plot([idx(ii) idx(ii)],[getY(3) getY(4)],'k--','LineWidth',lineWidth)
    end
    box on, grid on
end
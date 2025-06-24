function [idx,reconstructed]=Pegna_detectOptodeMovement(signal,options)
%Peña's differences based algorithm for the detection of optode movement artefacts
%
% function [idx,reconstructed]=Pegna_detectOptodeMovement(signal)
%
%Peña's differences based algorithm for the detection of
%optode movement artefacts (see [Pegna et al, 2003]).
%
%
%% Remarks
%
% Since version 1.3.0 this algorithms has been slightly reinterpreted;
%
%Rather than ignoring large jumps that only show in one sample, I now
%believe Pegna's spirit meant that the "cumulative"
%change over the two samples is bigger than the threshold so to capture
%both quick baselines shift as well as spikes.
%
% The "old" strict interpretation is still offered for backwards
% compatibility, but requires explicit use of options .version
%
%
%% Parameters:
%
%
% signal - The signal time serie. Please note that Pegna operates on the
%   totalHb
%
%
% options - An struct with several fields indicating some options.
%   Following is a list of the available options (fieds of the struct)
%
%   .threshold: Double. Default is 10.
%       Pegna used 0.1 mmol/mm
%       Threshold for the signal baselie shift. Suggested value
%       is 0.25*(max(signal)-min(signal)), i.e. make it dependent
%       on the signal's range.
%   .version: Char array. Default is '1.3.0'.
%       Choose the "version" of the algorithm being run. Original
%       implementation (up to v1.2.2) implements strict adherence
%       to Pegna's original algorithm (letter of the law). From
%       version (v1.3.0), the algorithm has been reimplemented to
%       represent the "cumulative" change over the two samples is
%       bigger than the threshold so to capture issues sufficiently
%       large but lasting only one sample (spirit of the law).
%   .visualize: Bool. False by default.
%       Plot the results. 
%
%
%
%
% 
% Copyright 2007-25
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
% 18-May-2025: FOE
%   + Bug fixed: I was NOT returning the reconstructed signal yet offering
%   it as a parameter. I have now added a naive reconstruction.
%   + Threshold is now offered as a option.
%   + Algorithm has been reinterpreted. See remarks.
%



%Deal with some options
opt.threshold = 10; %0.1 mmol/mm used by pegna
opt.version   = '1.3.0';
opt.visualize = false;
if(exist('options','var'))
    if(isfield(options,'threshold'))
        opt.threshold=options.threshold;
    end
    if(isfield(options,'version'))
        opt.version=options.version;
    end
    if(isfield(options,'visualize'))
        opt.visualize=options.visualize;
    end
end

nSamples=length(signal);


if version_IsHigherOrEqual(opt.version,'1.3.0')
    %18-May-2025: FOE
    % Reinterpretation of Pegna: Rather than ignoring large jumps that
    %only show in one sample, I now believe Pegna meant that the "cumulative"
    %change over the two samples is bigger than the threshold so to capture
    %both quick baselines shift as well as spikes. Note however, that this
    %new "cumulative" reinterpretation means that the threshold is doubled.
    firstDifferences=[0 abs(diff(signal))' 0];
    cumDifferences  =firstDifferences(1:end-1)+firstDifferences(2:end);
    idx = find(cumDifferences > 2*opt.threshold);

else %older versions
    firstDifferences=abs(signal(2:end)-signal(1:end-1));
    tempIdx=find(firstDifferences>opt.threshold);
    %Since we need two consecutive samples going above the threshold
    %we therefore ignore isolated idx...
    idx=[];
    for ii=tempIdx
        nextIdx=ii+1;
        if(any(ismember(tempIdx,nextIdx)))
            idx=[idx ii];
        end
    end

end

[reconstructed] = correctMotion(signal,idx);


%% Visualization =========================================
if (opt.visualize)
    lineWidth=1.5;
    figure
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    hold on
    plot(signal,'b-','LineWidth',lineWidth)
    plot(reconstructed,'m-','LineWidth',lineWidth)
    getY=axis;
    for ii=1:length(idx)
        plot([idx(ii) idx(ii)],[getY(3) getY(4)],'k--','LineWidth',lineWidth)
    end
    box on, grid on
end





end


function [reconstructed] = correctMotion(signal,idx)
%A naive signal correction that shifts signals where an optode movement
%has been found.
%
% signal - A vector of values representing a time series
% idx - Locations where an optode movement has been detected e.g. using
%   Sato's algorithm.
%
% reconstructed - A vector of the same length as signal The signal corrected.
%

windowSize = 10;
uncertaintyOffset = 2;
%Ignore movements detected at the boundaries
idx(idx<windowSize+uncertaintyOffset) = [];
idx(idx>length(signal)-windowSize-uncertaintyOffset) = [];

for iMovement = 1:length(idx)
    movementLocation = idx(iMovement);
    %offset = signal(movementLocation-1) - signal(movementLocation);
    
    LeftLowerBoundary  = max(1,movementLocation-windowSize-uncertaintyOffset);
    LeftUpperBoundary  = max(1,movementLocation-uncertaintyOffset);
    RightLowerBoundary = min(length(signal),movementLocation+uncertaintyOffset);
    RightUpperBoundary = min(length(signal),movementLocation+windowSize+uncertaintyOffset);
    
    offset = mean(signal(LeftLowerBoundary:LeftUpperBoundary)) ...
            - mean(signal(RightLowerBoundary:RightUpperBoundary));

    signal(movementLocation:end) = signal(movementLocation:end) + offset;
end
reconstructed = signal;
end


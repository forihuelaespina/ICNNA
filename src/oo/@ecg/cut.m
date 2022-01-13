function obj=cut(obj,winInit,winEnd)
%ECG/CUT Cut a temporal window
%
% obj=cut(obj,winInit,winEnd) Cut a temporal window from an
%   ecg. winInit and winEnd determines the starting
%   and ending sample indexes location of the window to be
%   eliminated. Samples at both, winInit and winEnd, are part
%   of the eliminated temporal segment.
%
%% Remarks
%
% winInit must be larger or equal than 1 and smaller or equal than winEnd.
%
% winEnd must be larger or equal than winInit and smaller or equal to
%the number of samples in the structuredData.
%
%Timeline will be shifted/corrected accordingly for ALL existing
%conditions and events. At the end of the window selection
%the timeline will still contains all the conditions but
%the events definition may have changed with some events
%being removed or even disappearing.
%
% The R Peaks are also shifted/corrected as appropriate.
%
%
%
%
%
% Copyright 2009
% @date: 6-Mar-2009
% @author Felipe Orihuela-Espina
%
% See also structuredData, crop, windowSelection, getBlock,
% experimentSpace, analysis, blockResample, blocksTemporalAverage
%

currRPeaks = get(obj,'RPeaks');
try
	obj=cut@structuredData(obj,winInit,winEnd);
        %The data must be set before calling getRR, otherwise
        %we will be operating on old data
	switch(get(obj,'RPeaksMode'))
	    case 'manual'
		%Remove those peaks in the cut interval and
		%shift those beyond the winEnd
		idxPeaksToCut=find(currRPeaks>=winInit && currRPeaks<=winEnd);
		currRPeaks(idxPeaksToCut)=[];
		idxPeaksToShift=find(currRPeaks>winEnd);
		currRPeaks(idxPeaksToShift)=currRPeaks(idxPeaksToShift)-(winEnd-winInit);
		obj=set(obj,'RPeaks',currRR); %Clear existing ones
		
	    case 'auto'
            obj.rPeaks=ecg.getRPeaks(get(obj,'Data')); %Automatic update
        otherwise
            error('ICAF:ecg:cut',...
                'Unexpected R Peaks Maintenance Mode.');
	end
catch ME
	%Rethrow the error
        rethrow(ME);
end


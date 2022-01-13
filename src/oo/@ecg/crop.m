function obj=crop(obj,winInit,winEnd)
%ECG/CROP Crop a temporal window
%
% obj=crop(obj,winInit,winEnd) Crop a temporal window from an
%   ecg. winInit and winEnd determines the starting
%   and ending sample indexes location of the cropped window.
%   Samples at both, winInit and winEnd, will still be part
%   of the cropped window. The rest will be discarded.
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
%being cropped or even disappearing.
%
% The R Peaks intervals are also shifted/corrected as appropriate.
%
%
%
%
% Copyright 2009-10
% @date: 6-Mar-2009
% @author Felipe Orihuela-Espina
% @modified: 28-Nov-2010
%
% See also structuredData, cut, windowSelection, getBlock,
% experimentSpace, analysis, blockResample, blocksTemporalAverage
%

currRPeaks = get(obj,'RPeaks');
try
    %Compute the new start time BEFORE cropping
    tmpST=computeNewStartTime; %nested function
    
    obj=crop@structuredData(obj,winInit,winEnd);
    
    obj=set(obj,'StartTime',tmpST);
    
    %The data must be set before calling getRR, otherwise
    %we will be operating on old data
    switch(get(obj,'RPeaksMode'))
        case 'manual'
            %Remove those peaks in the cut interval and
            %shift those beyond the winEnd
            idxPeaksToCrop=find(currRPeaks>=winInit & currRPeaks<=winEnd);
            currRPeaks=currRPeaks(idxPeaksToCrop);
            %and now shift them
            currRPeaks=currRPeaks-winInit;
            obj=set(obj,'RPeaks',currRPeaks); %Update existing ones

        case 'auto'
            obj.rPeaks=ecg.getRPeaks(get(obj,'Data')); %Automatic update
        otherwise
            error('ICAF:ecg:crop',...
                'Unexpected R Peaks Maintenance Mode.');
    end
catch ME
	%Rethrow the error
        rethrow(ME);
end


    function newST=computeNewStartTime
        timestamps = get(obj,'Timestamps'); %In milliseconds
        initTimestamp = timestamps(winInit);
        initTimestamp = initTimestamp/1000; %to secs
            %Convert from secs to datevec
            tmpTime = zeros(6,1);
            tmpTime(3,:) = floor(initTimestamp/(24*3600)); %days
            initTimestamp = initTimestamp - tmpTime(3,:)*(24*3600);
            tmpTime(4,:) = floor(initTimestamp/(3600)); %hours
            initTimestamp = initTimestamp - tmpTime(4,:)*(3600);
            tmpTime(5,:) = floor(initTimestamp/(60)); %mins
            initTimestamp = initTimestamp - tmpTime(5,:)*(60);
            tmpTime(6,:) = initTimestamp; %secs

        currST = datenum(get(obj,'StartTime'));
        newST = currST + datenum(tmpTime');
        newST = datevec(newST);
    
    end

end
    


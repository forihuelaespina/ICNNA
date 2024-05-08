function e=cropECG(e,initTime,endTime)
%Crop the ecg object between the initTime and endTime
%
% e=cropECG(e,initTime,endTime) Crop the ecg object between the initTime
%       and endTime
%
%
%% Parameters:
%
% e - An ecg object
% initTime and endTime - Start and final times expressed as datenum
%
%% Output:
%
% e - The ecg cropped
%
%
%
% Copyright 2010
% @date: 21-Jul-2010 (Extracted from guiSplitECG on 27-Nov-2010=
% @author Felipe Orihuela-Espina
% @modified: 28-Nov-2010
%
% See also rawData_BioHarnessECG, ecg, dataSource, rawData_ETG4000,
%   guiSplitECG
%
ecgST = datenum(get(e,'StartTime'));
timestamps = get(e,'Timestamps')'/1000; %In seconds
tmpTimes=sec2datevec(timestamps);
%To datenum    
tmpTimes= datenum(tmpTimes')' + ecgST;
%tmpTimes2=datevec(tmpTimes)';

initIdx= find(tmpTimes <= initTime,1,'last');
if isempty(initIdx)
    initIdx=1;
end
endIdx= find(tmpTimes >= endTime,1,'first');
if isempty(endIdx)
    endIdx=length(timestamps);
end

e=crop(e,initIdx,endIdx);

end



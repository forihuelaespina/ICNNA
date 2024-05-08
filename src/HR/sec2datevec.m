function tmpTimes=sec2datevec(timestamps)
%Convert a vector of timestamps from secs to datevec
%
% tmpTimes=sec2datevec(timestamps) Convert a vector of timestamps expressed
%       in secs to datevec
%
%
%  Limited to days! No months or years
%
%% Parameters:
%
% timestamps - A vector of timestamps expressed in secs
%
%
%% Output:
%
% tmpTimes - A vector of timestamps expressed as datevec
%
%
% Copyright 2010
% @date: 21-Jul-2010 (Extracted from guiSplitECG on 27-Nov-2010=
% @author Felipe Orihuela-Espina
% @modified: 27-Nov-2010
%
% See also rawData_BioHarnessECG, ecg, dataSource, rawData_ETG4000,
%   guiSplitECG
%
tmpTimes = zeros(6,length(timestamps));
tmpTimes(3,:) = floor(timestamps/(24*3600)); %days
timestamps = timestamps - tmpTimes(3,:)*(24*3600);
tmpTimes(4,:) = floor(timestamps/(3600)); %hours
timestamps = timestamps - tmpTimes(4,:)*(3600);
tmpTimes(5,:) = floor(timestamps/(60)); %mins
timestamps = timestamps - tmpTimes(5,:)*(60);
tmpTimes(6,:) = timestamps; %secs
end

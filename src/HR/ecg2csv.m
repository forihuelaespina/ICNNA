function ecg2csv(e,filename)
%Save the ecg object to a text file (.csv) using BioHarness output format
%
% ecg2csv(e,filename) Save the ecg object to a text (.csv) file
%   using BioHarness output format
%
%% Remarks
%
% The function is not particularly efficient. :(
%
%% Parameters
%
% e - An ecg object
% filename - Output filename
%
%% Output
%
% Write (overwrites if already exists) the file
%
% Copyright 2010
% @date: 21-Jul-2010
% @author Felipe Orihuela-Espina
% @modified: 21-Jul-2010
%
% See also rawData_BioHarnessECG, ecg, dataSource, rawData_ETG4000
%
fid = fopen(filename,'w');
if fid==-1
    error('ICAF:guiSplitECG:FileNotFound',...
          ['Unable to open output file ' filename]);
    return;
end

%Header
fprintf(fid,'\nTimestamp,ECG - Raw Data,\n');
%Data
timestamps = get(e,'Timestamps')'/1000; %In seconds
tmpTimes=sec2datevec(timestamps);

ecgST = datenum(get(e,'StartTime'));
%Add the start time  
tmpTimes= datenum(tmpTimes')' + ecgST;

data = get(e,'Data');
nSamples = length(timestamps);

ssss=datestr(tmpTimes,'yyyy/mm/dd HH:MM:SS');
dddd=num2str(data,',%5d,');
ssss=[ssss dddd];

x=0;
h=waitbar(x,'Writing ECG output file. Please wait...');
step=1/nSamples;
for ii=1:nSamples
    waitbar(x,h);
    x=x+step;
%    fprintf(fid,'%s,%d,\n',...
%              datestr(tmpTimes(ii),'yyyy/mm/dd HH:MM:SS'),...
%              data(ii));
    fprintf(fid,'%s\n',ssss(ii,:));
end
fclose(fid);
close(h);

end



%% AUXILIAR FUNCTION
function tmpTimes=sec2datevec(timestamps)
%Convert a vector of timestamps expressed in from secs to datevec
%
%Limited to days! No months or years
tmpTimes = zeros(6,length(timestamps));
tmpTimes(3,:) = floor(timestamps/(24*3600)); %days
timestamps = timestamps - tmpTimes(3,:)*(24*3600);
tmpTimes(4,:) = floor(timestamps/(3600)); %hours
timestamps = timestamps - tmpTimes(4,:)*(3600);
tmpTimes(5,:) = floor(timestamps/(60)); %mins
timestamps = timestamps - tmpTimes(5,:)*(60);
tmpTimes(6,:) = timestamps; %secs
end


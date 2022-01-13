function avg_sd=getAverageSD(SD)
%Averages a set of structuredData objects
%
% sd=getAverageSD(SD) Averages a set of structuredData objects
%
%
%% Remarks
%
% All structuredData must be of the same type e.g. nirs_neuroimage.
%They may contain a different number of channels, but channels will be
%averaged in order. They may contain a different number of signals, but
%signals will be averaged in order (no attempt is made to check the
%signal tags).
%
% If for some structuredData some channels are not clean or not checked
%but others structuredData contain checked and valid information, only this
%information will be averaged and the integrity code set to FINE.
%
%
% Signal tags will be extracted from the arguments. If they differ, the
%first one to appear will be selected.
%
%If the provided structuredData are a subclass of structuredData, the
%remaining fields will be taken from the first object.
%
% Timeline will be taken from the first object but length will be set
%to the maximum of valid samples.
%
%% Parameters
%
% SD - A cell array of structuredData objects
%
%% Output
%
% sd - A new structuredData object with data averaged from SD
%   The new structuredData ID will be set 1
%   The new structuredData description will be set 'Averaged SD'
%   If SD is empty sd is a new structuredData
%
%
%
%
% Copyright 2011
% @date: 20-Jun-2011
% @author: Felipe Orihuela-Espina
% @modified: 20-Jun-2011
%
% See also 
%



avg_sd = structuredData;
if isempty(SD)
    return
else
    avg_sd = SD{1}; %Capturing subclass if necessary
end
avg_sd = set(avg_sd,'ID',1);
avg_sd = set(avg_sd,'Description','Averaged SD');
data=nan(0,0,0,0); %The fourth dimension is the element dimension along which I will average
    
SD = reshape(SD,numel(SD),1);
nElements = length(SD);
for ee=1:nElements
    assert(strcmp(class(avg_sd),class(SD{ee})), ...
        'Unable to generate averaged structuredData. Invalid class');
%     timelines(ee) = {get(SD{ee},'Timeline')};
%     conditions(ee) = getNConditions(timelines{ee});
%     maxSamples = get(timelines{ee},'Length');
    
    tmpData = get(SD{ee},'Data');
    [nSamples,nChannels,nSignals]=size(tmpData);
    integrity(ee,1:nChannels)=double(get(SD{ee},'Integrity'));
    idxNotFine = find(integrity(ee,:)~=integrityStatus.FINE);
    tmpData(:,idxNotFine,:)=NaN;
    data(1:nSamples,1:nChannels,1:nSignals,ee)=tmpData;
end
data = nanmean(data,4);
avg_sd = set(avg_sd,'Data',data);

nChannels = size(integrity,2);
assert(nChannels==size(data,2),...
    'Unable to reconstruct integrity status');
vals(1:nChannels)=integrityStatus.UNCHECK;
for ch=1:nChannels
    if any(integrity(:,ch)==integrityStatus.FINE)
        vals(ch)=integrityStatus.FINE;
    elseif all(integrity(:,ch)==integrityStatus.UNCHECK)
        vals(ch)=integrityStatus.UNCHECK;
    else
        vals(ch)=integrityStatus.OTHER;
    end
end
is = integrityStatus(nChannels);
is=setStatus(is,1:nChannels,vals);
avg_sd = set(avg_sd,'Integrity',is);
t = get(avg_sd,'Timeline');
t = set(t,'Length',size(data,1));
avg_sd = set(avg_sd,'Timeline',t);



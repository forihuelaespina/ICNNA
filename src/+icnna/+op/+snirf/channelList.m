function [srcDetPairs,theChannels,theSignals] = channelList(theSnirf,options)
%Retrieves the channel list for the i-th nirs dataset and j-th data block
%
%	[srcDetPairs,theChannels,theSignals] = channelList(theSnirf)
%	[srcDetPairs,theChannels,theSignals] = channelList(theSnirf,options)
%
%
% An snirf data block do not hold channels directly, but instead if stores
%the information as individual measurements.
%	This is a convenience function to "fold" the measurements into channels.
%
%% Remarks
%
% This function makes no distinction on whether channels are
%short or long distance.
%
%% Error handling
%
%	Yields an error if the data block is not found.
%
%% Input parameters
%
% theSnirf - icnna.data.snirf.snirf | icnna.data.snirf.nirsDataset | icnna.data.snirf.dataBlock
%	The (snirf formatted) data for which to retrieve the list of channels
%
% options - Struct
%	A struct of options
%		.datablock - Int. Default is 1.
%			The j-th data block.
%			This option is only considered if theSnirf is either
%			 an icnna.data.snirf.snirf or an icnna.data.snirf.nirsDataset
% 		.nirsDataset - Int. Default is 1.
%			The i-th dataset.
%			This option is only considered if theSnirf is an icnna.data.snirf.snirf
%
%
%% Output
%
% srcDetPairs - Int[nChannels,3]
%		List of channel source-detector pairings. Channels are indexed
%   in the same order as they first appear in the measurements list.
%
%   +========================================================+
%   | Watch out! This indexing may NOT coincide with other   |
%   | channel indexing ocurring in other parts of ICNNA. For |
%   | instance, it may not be the same ordering ocurring     |
%   | subsequent to conversion to an @icnna.data.structuredData |
%   +========================================================+
%
%	 + The first column is a channel index or identifier.
%	 + The second column is the source index.
%	 + The third column is the detector index.
%
% theChannels - Int[nMeasurements]
%		List of channel indexes (see srcDetPairs) of each
%   measurement.
%
% theSignals - Int[nMeasurements]
%		List of signal indexes of each measurement.
%       IF theSnirf is unprocessed data, then
%           the signals correspond to different wavelengths
%       ELSE 
%           the signals correspond to different physiological parameters
%       END
%
%
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also 
%


%% Log
%
% 9-Feb-2026: FOE
%   File created.
%



%% Deal with options
opt.datablock   = 1;
opt.nirsDataset = 1;
if exist('options','var')
	if isfield(options,'datablock')
		opt.datablock = options.datablock;
	end
	if isfield(options,'nirsDataset')
		opt.nirsDataset = options.nirsDataset;
	end
end




%% Navigate to the measurement list
try
	if isa(theSnirf,'icnna.data.snirf.snirf')
		msList = theSnirf.nirs(opt.nirsDataset).data(opt.datablock).measurementsList;
    elseif isa(theSnirf,'icnna.data.snirf.nirsDataset')
		msList = theSnirf.data(opt.datablock).measurementsList;
	else  %isa(theSnirf,'icnna.data.snirf.dataBlock')
		msList = theSnirf.measurementList;
	end
catch ME
	error('icnna:op:snirf:channelList:InvalidDatablock',...
			'Unable to retrive the requested data block.');
end





%% Allocate memory
srcs   = [msList(:).sourceIndex]';
dets   = [msList(:).detectorIndex]';
nMeasurements = numel(msList);

nChannels = size(unique([srcs dets],'rows'),1);
	%Note that the order yield by function unique is not the order appearance.
	
srcDetPairs = [(1:nChannels)' nan(nChannels,2)];
theChannels = nan(nMeasurements,1);
theSignals  = nan(nMeasurements,1);

%% Iterate over the measurementLists to retrieve the channelList
chIdx = 0;
for iMeas = 1:nMeasurements
	tmpNewChannel = [srcs(iMeas) dets(iMeas)];
    [flagMember,posMember] = ismember(tmpNewChannel, srcDetPairs(1:chIdx,2:3), 'rows');
	if ~flagMember
		chIdx = chIdx + 1;
		srcDetPairs(chIdx,2:3) = tmpNewChannel;
        theChannels(iMeas) = chIdx;
    else
        theChannels(iMeas) = posMember;
    end

    if msList(iMeas).dataType ~= 99999 %i.e. not processed
        theSignals(iMeas) = msList(iMeas).wavelengthIndex;
    else
        theSignals(iMeas) = msList(iMeas).dataTypeIndex;
    end
end


end
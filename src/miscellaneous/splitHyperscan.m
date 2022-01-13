function [N]=splitHyperscan(nimg,varargin)
%Splits a neuroimage into "sub-"neuroimages corresponding to a hyperscan session
%
% [N]=splitHyperscan(nimg,'NImages',n) Splits a neuroimage into
%       n "sub-"neuroimages corresponding to a hyperscan session
%
% During a hyperscanning session, several people are scanned at once
%with the same device. From the point of view of the neuroimaging device
%this corresponds to only one neuroimage, but actually it corresponds
%to as many neuroimages as people were scanned together.
%
% This function naively splits a single neuroimage assumed to correspond to
%a hyperscanning session into several individual neuroimages. In the
%simplest case, the splitting simply assumes the channels are somehow
%"sorted" sequentially according to the succesive neuroimages.
%
%
%
%
%% Parameters
%
% Available options
%   'NImages',n - Number of concomitant neuroimages. The splitting
%       assumes the channels are somehow "sorted" sequentially according
%       to the succesive neuroimages.
%
%
%% Output
%
% N - A cell array of nirs_neuroimage objects
%
%
% 
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
%
% See also nirs_neuroimage
%


%% Log
%
% 
%



%% Deal with options
opt.nImages=1; %Number of hyperscanned images
opt.chDistribution=cell(1,0); %Channel distribution. Empty if naive splitting.
    %The naieve splitting
    %assumes the channels are "sorted" sequentially according
    %to the succesive neuroimages.
while ~isempty(varargin)
    optName=varargin{1};
    varargin(1)=[];
    if strcmpi(optName,'nimages')
        opt.nImages = varargin{1};
        varargin(1)=[];
        assert(isscalar(opt.nImages),...
                'Number of hyperscanned images must be an integer value.');
    end
end



%Some initialization
totalNChannels=get(nimg,'NChannels');
N=cell(opt.nImages,1); %Initialize the output variable
channelDistribution=cell(opt.nImages,1);
if isempty(opt.chDistribution)
    %Naive partition
    nChannelsPerImage=totalNChannels/opt.nImages;
    assert(mod(totalNChannels,opt.nImages)==0,...
        ['Number of channels cannot be naively split equally among ' ...
            'hyperscanned neuroimages. Please, provide a channel ' ...
            'distribution.']);
    
    for ii=1:opt.nImages
        channelDistribution(ii)={[1:nChannelsPerImage]+(ii-1)*nChannelsPerImage};
    end
else
    channelDistribution=opt.chDistribution;      
end

assert(length(channelDistribution)==opt.nImages && size(channelDistribution,2)==1,...
        'Unexpected channel distribution among hyperscanned images.');


%Extract data and channel location map
data =get(nimg,'Data');
clm =get(nimg,'ChannelLocationMap');
        

%...go on, and extract the sub-neuroimages
for ii=1:opt.nImages
    theNimg =nimg; %Uses the copy constructor
    
    theChannels = channelDistribution{ii};
    %Set the data corresponding to this sub-neuroimage alone
    theData = data(:,theChannels,:);
    theNimg=set(theNimg,'Data',theData);
    %fix the channel location map
    theCLM=extractSubCLM(clm,theChannels);
    theNimg=set(theNimg,'ChannelLocationMap',theCLM);
    %Note that the timeline does not need fixing
    
    N(ii)={theNimg};
end



end

%% AUXILIAR FUNCTIONS
function [theCLM]=extractSubCLM(clm,theChannels)
%Extracts the sub-channel location map

nChannels = length(theChannels);

theCLM = clm; %Use copy contructor
theCLM = set(theCLM,'nChannels',nChannels);

%Remove unnecesary channel information
tmp = getChannel3DLocations(clm,theChannels);
theCLM = setChannel3DLocations(theCLM,1:nChannels,tmp);
tmp = getChannelSurfacePositions(clm,theChannels);
theCLM = setChannelSurfacePositions(theCLM,1:nChannels,tmp);
tmp = getChannelStereotacticPositions(clm,theChannels);
theCLM = setChannelStereotacticPositions(theCLM,1:nChannels,tmp);
tmp = getChannelOptodeArrays(clm,theChannels);
theCLM = setChannelOptodeArrays(theCLM,1:nChannels,tmp);
tmp = getChannelProbeSets(clm,theChannels);
theCLM = setChannelProbeSets(theCLM,1:nChannels,tmp);

end



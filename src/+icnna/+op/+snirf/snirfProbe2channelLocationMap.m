function clm = snirfProbe2channelLocationMap(obj,options)
%SNIRFPROBE2CHANNELLOCATIONMAP Convert SNIRF probe to channelLocationMap
%
% clm = icnna.op.snirf.snirfProbe2channelLocationMap(obj)
%
% Converts the probe definition stored in a SNIRF object into an
% ICNNA @channelLocationMap object.
%
% SNIRF represents probe geometry by storing sources and detectors
% separately. Channels are defined implicitly via the measurementList
% objects stored in the SNIRF dataset.
%
% This function reconstructs the equivalent ICNNA probe representation.
%
% Behaviour depends on the type of object passed as input.
%
% @li If the input is an icnna.data.snirf.nirsDataset object, both optodes and
%     channels are reconstructed.
% @li If the input is an icnna.data.snirf.probe object, only optodes are
%     reconstructed since channel pairings are not available.
%
%
%% Remarks
%
% + Channel (nominal) locations are estimated as the midpoint between the
%   corresponding source and detector positions.
%
% + SNIRF does not explicitly store probe sets or optode arrays.
%   Default values are therefore assigned.
%
% + When only a probe object is provided, the returned
%   @channelLocationMap will not contain channel definitions.
%
% + Sources and detector locations favour the 3D positions when available
%   but use the 2D positions otherwise.
%
%% Error handling
%
% + An error is thrown if input obj is not an @icnna.data.snirf.nirs or
%   @icnna.data.snirf.probe.
%
%% Input parameters
%
% obj - One of the following SNIRF objects:
%
%   @icnna.data.snirf.nirsDataset
%       A full SNIRF dataset containing probe and measurementList.
%
%   @icnna.data.snirf.probe
%       Probe definition only. Channel pairings are not available.
%
% options - struct. Reserved for future use.
%   A list of options.
%
%
%% Output parameters
%
% clm - A channelLocationMap object describing the probe geometry.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also channelLocationMap, icnna.data.snirf.probe, icnna.data.snirf.nirs
%


%% Log
%
% -- ICNNA v1.4.1
%
% 5-Mar-2026: FOE
%   + File created.
%


%% Deal with options
%N/A. Reserved for future use.
if nargin < 2
    options = struct();
end


%% Determine input type
if isa(obj,'icnna.data.snirf.nirsDataset')
    snirfProbe = obj.probe;
    measurementList = obj.data.measurementList;

elseif isa(obj,'icnna.data.snirf.probe')
    snirfProbe = obj;
    measurementList = [];

else
    error('icnna:op:snirfProbe2channelLocationMap:InvalidInput', ...
        ['Input must be an icnna.data.snirf.nirs or ' ...
         'icnna.data.snirf.probe object.']);
end


%% Sources and detectors
if ~isempty(snirfProbe.sourcePos3D)
    sourcePos = snirfProbe.sourcePos3D;
elseif ~isempty(snirfProbe.sourcePos2D)
    sourcePos = snirfProbe.sourcePos2D;
else
    error('icnna:op:snirfProbe2channelLocationMap:MissingSourcePositions',...
          'Probe does not contain source positions.');
end

if ~isempty(snirfProbe.detectorPos3D)
    detectorPos = snirfProbe.detectorPos3D;
elseif ~isempty(snirfProbe.detectorPos2D)
    detectorPos = snirfProbe.detectorPos2D;
else
    error('icnna:op:snirfProbe2channelLocationMap:MissingDetectorPositions',...
          'Probe does not contain detector positions.');
end

nSources   = size(sourcePos,1);
nDetectors = size(detectorPos,1);


%% Create CLM

clm                  = channelLocationMap;
clm.nOptodes         = nSources + nDetectors;
clm.optodesLocations = [sourcePos; detectorPos];


%% Define optode types

clm = clm.setOptodeTypes( ...
        1:nSources, ...
        clm.OPTODE_TYPE_EMISOR*ones(nSources,1));

clm = clm.setOptodeTypes( ...
        nSources+(1:nDetectors), ...
        clm.OPTODE_TYPE_DETECTOR*ones(nDetectors,1));


%% Default probe sets

clm = clm.setOptodeProbeSets( ...
        1:clm.nOptodes, ...
        ones(clm.nOptodes,1));


%% If measurement list is available create channels
if ~isempty(measurementList)

    nMeasurements = numel(measurementList);

    src = zeros(nMeasurements,1);
    det = zeros(nMeasurements,1);

    for i=1:nMeasurements
        src(i) = measurementList(i).sourceIndex;
        det(i) = measurementList(i).detectorIndex;
    end

    channelList = unique([src det],'rows');

    nChannels = size(channelList,1);

    clm.nChannels = nChannels;

    clm = clm.setPairings( ...
            1:nChannels, ...
            [channelList(:,1) nSources+channelList(:,2)]);


    %% Channel nominal locations (midpoint)
    channelLocations3D = ...
        (sourcePos(channelList(:,1),:) + ...
         detectorPos(channelList(:,2),:))/2;

    clm = clm.setChannel3DLocations(1:nChannels,channelLocations3D);

    clm = clm.setChannelProbeSets( ...
            1:nChannels, ...
            ones(nChannels,1));

end

end

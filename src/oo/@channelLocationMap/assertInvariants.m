function assertInvariants(obj)
%CHANNELLOCATIONMAP/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%=======
%INVARIANTS
%=======
%
%   Invariant: The number of channels is always positive or 0
%       obj.nChannels>=0
%
%   Invariant: The number of optodes is always positive or 0
%       obj.nOptodes>=0
%
%   Invariant: The number of channels 3D locations match the number
%       of channels
%       size(obj.chLocations,1)==obj.nChannels
%
%   Invariant: The number of optodes 3D locations match the number
%       of optodes
%       size(obj.optodesLocations,1)==obj.nOptodes
%
%   Invariant: Optodes types are either unknown, emisor or detector
%       all(ismember(obj.optodesTypes,[obj.OPTODE_TYPE_UNKNOWN ...
%                                      obj.OPTODE_TYPE_EMISOR ...
%                                      obj.OPTODE_TYPE_DETECTOR ]))
%
%   Invariant: The number of surface positions match the number of channels
%       length(obj.chSurfacePositions)==obj.nChannels
%
%   Invariant: The number of surface positions match the number of optodes
%       length(obj.optodesSurfacePositions)==obj.nOptodes
%
%   Invariant: The number of stereotactic positions match the number of
%       channels
%       size(obj.chStereotacticPositions,1)==obj.nChannels
%
%   Invariant: The number of associated optode arrays match the number
%       of channels
%       size(obj.chOptodeArrays,1)==obj.nChannels
%
%   Invariant: The number of associated optode arrays match the number
%       of optodes
%       size(obj.optodesOptodeArrays,1)==obj.nOptodes
%
%   Invariant: The number of associated probe sets match the number of
%       channels
%       size(obj.chProbeSets,1)==obj.nChannels
%
%   Invariant: The number of associated probe sets match the number of
%       optodes
%       size(obj.optodesProbeSets,1)==obj.nOptodes
%
%   Invariant: All optode arrays have associated information
%       max(obj.chOptodeArrays)<=length(obj.optodeArrays)
%
%   Invariant: Channel surface positions are always valid within
%       the current surface positioning system
%       all(isValidSurfacePosition(obj.chSurfacePositions,...
%                              obj.surfacePositioningSystem));
%
%   Invariant: Optodes surface positions are always valid within
%       the current surface positioning system
%       all(isValidSurfacePosition(obj.optodesSurfacePositions,...
%                              obj.surfacePositioningSystem));
%
%   Invariant: Number of pairings matches the number of channels
%       size(obj.pairings,1)==obj.nChannels
%
%   Invariant: Each pairing is always between an emisor (1st col) and
%       and a detector (2nd col). Any of these might also be of an
%       unknown type.
%       all(obj.pairings(:,1) is either emisor or unknown)
%       all(obj.pairings(:,2) is either detector or unknown)
%
%
% Copyright 2012-13
% @date: 26-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also channelLocationMap
%

%% Log
%
% 10-Sep-2013: Bug fixed. Invariant checking for all pairings second
%       element to be a detector was checking for emisors instead.
%
% 8-Sep-2013: Several new invariants related to optodes information and
%       pairings have been added.
%



assert(obj.nChannels>=0 & floor(obj.nChannels)==obj.nChannels, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of channels cannot be negative.']);
assert(obj.nOptodes>=0 & floor(obj.nOptodes)==obj.nOptodes, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of optodes cannot be negative.']);
assert(size(obj.chLocations,1)==obj.nChannels, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of channels 3D locations mismatches the number of channels.']);
assert(size(obj.optodesLocations,1)==obj.nOptodes, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of optodes 3D locations mismatches the number of channels.']);


     

tmp=ismember(obj.optodesTypes,[obj.OPTODE_TYPE_UNKNOWN; ...
                                     obj.OPTODE_TYPE_EMISOR; ...
                                     obj.OPTODE_TYPE_DETECTOR ]);
tmp=reshape(tmp,numel(tmp),1);
    %ismember will do its best to return a row vector, but
    %all requires a column vector...
assert(all(tmp), ...
        ['channelLocationMap.assertInvariants: ' ...
         'Optodes types must be either unknown, emisor or detector.']);
     
     
assert(length(obj.chSurfacePositions)==obj.nChannels, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of surface positions mismatches the number of channels.']);
assert(length(obj.optodesSurfacePositions)==obj.nOptodes, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of surface positions mismatches the number of optodes.']);
assert(size(obj.chStereotacticPositions,1)==obj.nChannels, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of stereotactic positions mismatches the number of channels.']);

assert(size(obj.chOptodeArrays,1)==obj.nChannels, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of associated optode arrays mismatches the number of channels.']);
assert(size(obj.optodesOptodeArrays,1)==obj.nOptodes, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of associated optode arrays mismatches the number of optodes.']);
assert(size(obj.chProbeSets,1)==obj.nChannels, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of associated probe sets mismatches the number of channels.']);
assert(size(obj.optodesProbeSets,1)==obj.nOptodes, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of associated probe sets mismatches the number of optodes.']);

assert(max([obj.chOptodeArrays;0])<=length(obj.optodeArrays), ...
        ['channelLocationMap.assertInvariants: ' ...
         'Information for one or more optode arrays is missing.']);
     %NOTE: The addition of a 0 at the end of obj.chOptodeArrays
     %avoids that the max function yields an empty matrix when
     %nChannels is 0 i.e. length(obj.chOptodeArrays)==0, leading
     %to an error in the assert condition.

     
assert(all(channelLocationMap.isValidSurfacePosition(...
                                    obj.chSurfacePositions,...
                                    obj.surfacePositioningSystem)),...
        ['channelLocationMap.assertInvariants: ' ...
         'Invalid surface position found for channels.']);
assert(all(channelLocationMap.isValidSurfacePosition(...
                                    obj.optodesSurfacePositions,...
                                    obj.surfacePositioningSystem)),...
        ['channelLocationMap.assertInvariants: ' ...
         'Invalid surface position found for optodes.']);

     
assert(size(obj.pairings,1)==obj.nChannels, ...
        ['channelLocationMap.assertInvariants: ' ...
         'Number of pairings mismatches the number of channels.']);
%check pairings
unknownIdx=find(obj.optodesTypes==obj.OPTODE_TYPE_UNKNOWN);
emisorIdx=find(obj.optodesTypes==obj.OPTODE_TYPE_EMISOR);
detectorIdx=find(obj.optodesTypes==obj.OPTODE_TYPE_DETECTOR);

tmp=ismember(obj.pairings(:,1),[unknownIdx emisorIdx]) | isnan(obj.pairings(:,1));
tmp=reshape(tmp,numel(tmp),1);
    %ismember will do its best to return a row vector, but
    %all requires a column vector...
assert(all(tmp), ...
        ['channelLocationMap.assertInvariants: ' ...
         'Pairings first element must be a light source (emisor) or unknown.']);
tmp=ismember(obj.pairings(:,2),[unknownIdx detectorIdx]) | isnan(obj.pairings(:,2));
tmp=reshape(tmp,numel(tmp),1);
assert(all(tmp), ...
        ['channelLocationMap.assertInvariants: ' ...
         'Pairings second element must be a light detector or unknown.']);

     

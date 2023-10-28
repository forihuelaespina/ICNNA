function assertInvariants(obj)
%CHANNELLOCATIONMAP/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Remarks
%
%   +=====================================================+
%   | WATCH OUT!!! Because of the limitations of Matlab's |
%   | support with the struct like syntax correct (e.g.   |
%   | for these specific get/set methods, Matlab does not |
%   | support overriding), maintenance of interdependent  |
%   | properties becomes more difficult. This is because  |
%   | it is now not possible to transiently violate       |
%   | postconditions  invariants. Although, there may be  |
%   | ah-doc solutions for some specific invariants which |
%   | have been implemented, but we have not been able to |
%   | solve the problem in general. Hence, from version   |
%   | 1.2, some of ICNNA's traditional hard class         |
%   | invariants have been relaxed and changed from       |
%	| errors into warnings, or simply removed.            |
%   +=====================================================+
% 
%% Invariants
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
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also channelLocationMap
%

%% Log
%
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 10-Sep-2013: Bug fixed. Invariant checking for all pairings second
%       element to be a detector was checking for emisors instead.
%   + Added this log.
%
% 8-Sep-2013: Several new invariants related to optodes information and
%       pairings have been added.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%
% 21-May-2023: FOE
%   + Some class invariants have been relaxed to warnings or removed.
%   + Added missing error codes.
%   + Improved some comments.
%



assert(obj.nChannels>=0 & floor(obj.nChannels)==obj.nChannels, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of channels cannot be negative.']);
assert(obj.nOptodes>=0 & floor(obj.nOptodes)==obj.nOptodes, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of optodes cannot be negative.']);
% assert(size(obj.chLocations,1)==obj.nChannels, ...
%         ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
%          'Number of channels 3D locations mismatches the number of channels.']);
% assert(size(obj.optodesLocations,1)==obj.nOptodes, ...
%         ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
%          'Number of optodes 3D locations mismatches the number of channels.']);


     

tmp=ismember(obj.optodesTypes,[obj.OPTODE_TYPE_UNKNOWN; ...
                                     obj.OPTODE_TYPE_EMISOR; ...
                                     obj.OPTODE_TYPE_DETECTOR ]);
tmp=reshape(tmp,numel(tmp),1);
    %ismember will do its best to return a row vector, but
    %all requires a column vector...
assert(all(tmp), ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Optodes types must be either unknown, emisor or detector.']);
     
     
assert(length(obj.chSurfacePositions)==obj.nChannels, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of surface positions mismatches the number of channels.']);
assert(length(obj.optodesSurfacePositions)==obj.nOptodes, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of surface positions mismatches the number of optodes.']);
assert(size(obj.chStereotacticPositions,1)==obj.nChannels, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of stereotactic positions mismatches the number of channels.']);

assert(size(obj.chOptodeArrays,1)==obj.nChannels, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of associated optode arrays mismatches the number of channels.']);
assert(size(obj.optodesOptodeArrays,1)==obj.nOptodes, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of associated optode arrays mismatches the number of optodes.']);
assert(size(obj.chProbeSets,1)==obj.nChannels, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of associated probe sets mismatches the number of channels.']);
assert(size(obj.optodesProbeSets,1)==obj.nOptodes, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Number of associated probe sets mismatches the number of optodes.']);

assert(max([obj.chOptodeArrays;0])<=length(obj.optodeArrays), ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Information for one or more optode arrays is missing.']);
     %NOTE: The addition of a 0 at the end of obj.chOptodeArrays
     %avoids that the max function yields an empty matrix when
     %nChannels is 0 i.e. length(obj.chOptodeArrays)==0, leading
     %to an error in the assert condition.

     
assert(all(channelLocationMap.isValidSurfacePosition(...
                                    obj.chSurfacePositions,...
                                    obj.surfacePositioningSystem)),...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Invalid surface position found for channels.']);
assert(all(channelLocationMap.isValidSurfacePosition(...
                                    obj.optodesSurfacePositions,...
                                    obj.surfacePositioningSystem)),...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Invalid surface position found for optodes.']);

     
assert(size(obj.pairings,1)==obj.nChannels, ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
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
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Pairings first element must be a light source (emisor) or unknown.']);
tmp=ismember(obj.pairings(:,2),[unknownIdx detectorIdx]) | isnan(obj.pairings(:,2));
tmp=reshape(tmp,numel(tmp),1);
assert(all(tmp), ...
        ['ICNNA:channelLocationMap:assertInvariants:InvariantViolation ' ...
         'Pairings second element must be a light detector or unknown.']);

     
end
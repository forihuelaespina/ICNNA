function assertInvariants(obj)
%RAWDATA_ETG4000/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: The size of the raw data (along the 3rd dimension)
%       matches number of probes (length of .probesetInfo).
%           size(obj.lightRawData,3)==length(obj.probesetInfo)
%
%   Invariant: The size of stimulus marks (along the 2nd dimension)
%       matches number of probes (length of .probesetInfo).
%           size(obj.marks,2)==length(obj.probesetInfo)
%
%   Invariant: The size of timestamps (along the 2nd dimension)
%       matches number of probes (length of .probesetInfo).
%           size(obj.timestamps,2)==length(obj.probesetInfo)
%
%   Invariant: The size of body movement marks (along the 2nd dimension)
%       matches number of probes (length of .probesetInfo).
%           size(obj.bodyMovement,2)==length(obj.probesetInfo)
%
%   Invariant: The size of removal marks (along the 2nd dimension)
%       matches number of probes (length of .probesetInfo).
%           size(obj.removalMarks,2)==length(obj.probesetInfo)
%
%   Invariant: The size of preScan stamps (along the 2nd dimension)
%       matches number of probes (length of .probesetInfo).
%           size(obj.preScan,2)==length(obj.probesetInfo)
%
%
%
%
%
% Copyright 2012-2016
% @date: 26-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 14-Jan-2016
%
% See also rawData_ETG4000
%



%assertInvariants@rawData(obj);

assert(size(obj.lightRawData,3)==length(obj.probesetInfo),...
	  'Size of raw data mismatches existing number of probe sets.');

assert(size(obj.marks,2)==length(obj.probesetInfo),...
	  'Size of stimulus marks mismatches existing number of probe sets.');

assert(size(obj.timestamps,2)==length(obj.probesetInfo),...
	  'Size of timestamps mismatches existing number of probe sets.');

assert(size(obj.bodyMovement,2)==length(obj.probesetInfo),...
	  'Size of body movement marks mismatches existing number of probe sets.');

assert(size(obj.removalMarks,2)==length(obj.probesetInfo),...
	  'Size of removal marks mismatches existing number of probe sets.');

assert(size(obj.preScan,2)==length(obj.probesetInfo),...
	  'Size of preScan marks mismatches existing number of probe sets.');

end
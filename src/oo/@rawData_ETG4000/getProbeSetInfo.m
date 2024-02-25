function [pInfo]=getProbeSetInfo(obj,idx)
%RAWDATA_ETG4000/GETPROBESETINFO Get the information associated to the probs sets
%
% [pInfo]=getProbeSetInfo(obj) Gets the information associated
%   for all probe sets. The struct may be empty if the
%   number of probes sets is 0.
%
% [pInfo]=getProbeSetInfo(obj,idx) Gets the information associated
%   for selected probe set. If any of the indexes to probe sets
%   is beyond the number of probe sets, it will be ignored. The struct
%   may be empty if the number of probes sets is 0, or none of the
%   indexes are valid.
%
% Please refer to rawData_ETG4000 class documentation for the
%information fields.
%
%
% Copyright 2012-2016
% @date: 26-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 14-Jan-2016
%
% See also setProbeSetInfo, addProbeSetInfo
%


%% Log
%
% 14-Jan-2016 (FOE): Added method addProbeSetInfo to the "see also" section.
%


pInfo=obj.probesetInfo;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>length(obj.probesetInfo))=[];
    pInfo=pInfo(idx);
end

end
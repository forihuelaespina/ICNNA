function tag=getSignalTag(obj,i)
%STRUCTUREDDATA/GETSIGNALTAG Gets an individual signal tag
%
% tag=getSignalTag(obj,i) Gets the tag of the i-th signal of
%	the structuredData. If i is larger than the number of existing
%   signals (or minor than 1), then and empty matrix is returned.
%
%
% Alternatively use get(obj,'SignalTags') to access all tags at once.
%
%% Remarks
%
% i>=1 && i<=get(obj,'NSignals')
%
%
% Copyright 2008
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also setSignalTag, get, set
%

tag=[];
if ((i>=1) && (i<=get(obj,'NSignals')))
    tag=obj.signalTags{i};
end

function obj=setSignalTag(obj,i,tag)
%STRUCTUREDDATA/SETSIGNALTAG Sets an individual signal tag
%
% obj=setSignalTag(obj,i,tag) Sets the tag of the i-th signal of
%	the structuredData. If i is larger than the number of existing
%   signals (or minor than 1), then nothing is done.
%
%
%% Remarks
%
% i>=1 && i<=get(obj,'NSignals')
% tag must be a string (i.e. ischar(tag)==1)
%
%
% Copyright 2008
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getSignalTag, get, set
%

if ((i>=1) && (i<=get(obj,'NSignals')) && ischar(tag))
    obj.signalTags(i)={tag};
end

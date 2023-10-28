function tag=getSignalTag(obj,i)
%STRUCTUREDDATA/GETSIGNALTAG Gets an individual signal tag
%
% tag=getSignalTag(obj,i) Gets the tag of the i-th signal of
%	the structuredData. If i is larger than the number of existing
%   signals (or minor than 1), then and empty matrix is returned.
%
%
% Alternatively use obj.signalTags to access all tags at once.
%
%% Remarks
%
% i>=1 && i<=obj.nSignals
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also setSignalTag, get, set
%




%% Log
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): N/A This method has not
%   been updated since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%



tag=[];
if ((i>=1) && (i<=obj.nSignals))
    tag=obj.signalTags{i};
end

end

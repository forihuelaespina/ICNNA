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
% i>=1 && i<=obj.nSignals
% tag must be a string (i.e. ischar(tag)==1)
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getSignalTag, get, set
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



if ((i>=1) && (i<=obj.nSignals) && ischar(tag))
    obj.signalTags(i)={tag};
end


end
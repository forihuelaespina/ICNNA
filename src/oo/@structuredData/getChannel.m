function im=getChannel(obj,i)
%STRUCTUREDDATA/GETCHANNEL Gets the i-th channel
%
% im=getChannel(obj,i) Gets the data at the i-th location of
%	the structuredData or an empty matrix if the i-th spatial element does
%	not exist. The i-th spatial element includes all time samples
%	and all signals.
%
%It returns a 2D matrix where
%
%         +----------------> NSignals
%         |
% Time    |
% Sample  |
%(Temporal|
% Element)|
%         |
%         v
%% Remarks
%
% i>=1 && i<=get(obj,'NChannels')
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getSignal, getSample
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


im=[];
if ((i>=1) && (i<=obj.nChannels))
    im=squeeze(obj.data(:,i,:));
end

end
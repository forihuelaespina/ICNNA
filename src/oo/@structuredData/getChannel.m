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
% Copyright 2008
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getSignal, getSample
%

im=[];
if ((i>=1) && (i<=get(obj,'NChannels')))
    im=squeeze(obj.data(:,i,:));
end

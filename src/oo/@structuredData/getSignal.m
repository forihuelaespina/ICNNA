function im=getSignal(obj,i)
%STRUCTUREDDATA/GETSIGNAL Gets the i-th signal of the structured data
%
% im=getSignal(obj,i) Gets the data of the i-th signal of
%	the structuredData or an empty matrix if the signal has not been
%	defined. The i-th signal includes all time samples
%	and all channels.
%
%It returns a 2D matrix where
%
%         +----------------> Channel (Spatial Element)
%         |
% Time    |
% Sample  |
%(Temporal|
% Element)|
%         |
%         v
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
% See also getChannel, getSample
%

im=[];
if ((i>=1) && (i<=get(obj,'NSignals')))
    im=obj.data(:,:,i);
end

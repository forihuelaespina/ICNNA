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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getChannel, getSample
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
if ((i>=1) && (i<=obj.nSignals))
    im=obj.data(:,:,i);
end

end

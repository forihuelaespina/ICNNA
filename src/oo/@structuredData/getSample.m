function im=getSample(obj,i)
%STRUCTUREDDATA/GETSAMPLE Gets the i-th time sample of the structured data
%
% im=getSample(obj,i) Gets the data at the i-th time sample of
%	the structuredData or an empty matrix if the i-th time sample does
%	not exist. The i-th sample is a static sub-image at all
%	locations including all signals.
%
%It returns a 2D matrix where
%
%         +----------------> NSignals
%         |
% Channel |
%(Spatial |
% Element)|
%         |
%         |
%         v
%
%% Remarks
%
% i>=1 && i<=get(obj,'NSamples')
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getChannel, getSignal
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
if ((i>=1) && (i<=obj.nSamples))
    im=squeeze(obj.data(i,:,:));
end

end

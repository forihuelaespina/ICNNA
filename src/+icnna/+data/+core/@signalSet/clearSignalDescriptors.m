function obj = clearSignalDescriptors(obj)
% Clears all existing signal descriptors.
%
%   obj = clearSignalDescriptors(obj)
%   obj = obj.clearSignalDescriptors()
%
%
% Behavior:
%
%   + Removes all @icnna.data.core.signalDescriptor objects from this
%   @icnna.data.core.signalSet.
%
%   + No warning or error is issued if no @icnna.data.core.signalDescriptor
%   exist.
%
%   + After execution:
%         obj.nSignals == 0
%
%   + This method does NOT affect any associated structuredData.
%     Consistency validation with the data tensor must be handled
%     externally e.g. by @icnna.data.core.structuredData.
%
%
%% Output:
%
% obj - @icnna.data.core.signalSet
%   Updated object with no signal descriptors defined.
%
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.signalSet,
%   icnna.data.core.signalDescriptor,
%   addSignalDescriptors,
%   removeSignalDescriptor,
%   findSignalDescriptors
%


%% Log
%
% -- ICNNA v1.4.0
%
% 4-Mar-2026: FOE
%   + File created.
%

obj.descriptors = icnna.data.core.signalDescriptor.empty;

end
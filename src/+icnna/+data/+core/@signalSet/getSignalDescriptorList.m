function [ids,names] = getSignalDescriptorList(obj)
% List stored @icnna.data.core.signalDescriptor objects.
%
%   [ids,names] = getSignalDescriptorList(obj)
%
%   Returns the |id| and |name| of all stored
%   @icnna.data.core.signalDescriptor.
%
%
%% Output:
%
% ids - int[nSignals]
%   Numerical identifiers of the signal descriptors.
%   This may be empty if no descriptor is currently defined in obj.
%
% names - cell array[nSignals] of char
%   Names of the signal descriptors.
%   The returned names correspond to the internal property:
%       desc.name
%   This may be empty if no descriptor is currently defined in obj.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also:
%   icnna.data.core.signalSet,
%   icnna.data.core.signalDescriptor,
%   addSignalDescriptors,
%   getSignalDescriptors,
%   removeSignalDescriptor
%


%% Log
%
% -- ICNNA v1.4.0
%
% 4-Mar-2026: FOE
%   + File created.
%

ids = [obj.descriptors.id];
if nargout > 1
    names = {obj.descriptors.name};
end
end
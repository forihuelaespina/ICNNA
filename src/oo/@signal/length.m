function nSamples=length(obj)
%SIGNAL/LENGTH Overload of the length function.
%
% nSamples=length(obj)  return the number of samples in the signal.
%
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also size

nSamples=length(double(obj));

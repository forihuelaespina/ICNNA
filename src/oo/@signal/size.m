function c=size(obj)
%SIGNAL/SIZE Overload of the size function.
%
% c=size(obj)  return the size of the signal [nSamples x 1].
%
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also length

c=size(double(obj));

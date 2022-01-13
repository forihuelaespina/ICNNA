function r=uminus(p)
%SIGNAL/UMINUS Implement -p for signal.
%
% r=-p Inverts signals p.
%
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also plus, minus, mtimes, mrdivide

%Ensure that argument is a signal
p=double(signal(p));

r=-p;
r=signal(r);
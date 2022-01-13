function r=minus(p,q)
%SIGNAL/MINUS Implement p-q for signal.
%
% r=p-q Subtraction of signals p-q by substracting individual samples.
%
% Both signals must have the same length in number of samples.
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also uminus, plus, mtimes, mrdivide

%Ensure that both arguments are signals
p=double(signal(p));
q=double(signal(q));

r=p-q;
r=signal(r);
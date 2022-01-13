function r=mtimes(p,q)
%SIGNAL/MRDIVIDE Implement p*q for signal.
%
% r=p*q Divide signals p*q by dividing individual samples.
%
% Both signals must have the same length in number of samples.
%
%REMARKS:
%
% A more MATLAB like notation would have been p.*s, but
%it make no sense for two signals to be multiplied in a matrix
%like way.
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also uminus, plus, minus, mrdivide, ctranspose

%Ensure that both arguments are signals
p=double(signal(p));
q=double(signal(q));

r=p.*q;
r=signal(r);
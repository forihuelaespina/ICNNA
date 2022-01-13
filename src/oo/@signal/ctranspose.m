function r=ctranspose(p)
%SIGNAL/CTRANSPOSE Implement p' for signal.
%
% r=p Transposes signals p.
%
%REMARKS:
%
% A more MATLAB like notation would have been p.', but
%it make no sense for a signals to be complex transposed in a matrix
%like way.
%
% The output is no longer a signal, but an double vector, as an object
%signal has been defined to be a column vector.
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also uminus, plus, minus, mtimes, mrdivide

%Ensure that argument is a signal
p=double(signal(p));

r=p.';
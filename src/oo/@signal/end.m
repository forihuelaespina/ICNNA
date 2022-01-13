function e=end(obj,k,n)
%SIGNAL/END Provides an end object indexing expression for class signal.
%
%The end method has the calling sequence
%
%   end(obj,k,n)
%
%where obj is the user object, k is
%the index in the expression where the end syntax is used,
%and n is the total number of indices in the expression.
%
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subsref, subsasgn

e=length(obj.samples);
% for k = 1:n
% 	if a(k) == 0
% 		a(k) = a(k) + 2;
%     end
% end
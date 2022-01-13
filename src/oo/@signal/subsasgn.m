function obj=subsasgn(obj,s,B)
%SIGNAL/SUBSASGN for indexed assignment of samples.
%
% obj=subsasgn(obj,s,B)  assigns B values to the samples in the signal
%       by their indexed position.
%
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subsref

switch s.type
    case '()'
        obj.samples(s.subs{:})=B;
    otherwise
        error('Indexed access is by means of the ''()'' operator.');
end

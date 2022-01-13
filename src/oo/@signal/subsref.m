function b=subsref(obj,s)
%SIGNAL/SUBSREF for indexed access to the samples.
%
% b=subsref(obj,s)  access samples in the signal by their indexed position.
%
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subsasgn

switch s.type
    case '()'
        b=obj.samples(s.subs{:});
    otherwise
        error('Indexed access is by means of the ''()'' operator.');
end

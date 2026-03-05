function [ver] = classVersion(obj)
%Returns the current classVersion
%
% [ver] = obj.classVersion()
%
%% Remarks
%
% For subclasses with their own (private) property |classVersion| this
%should return the value at the subclass. Matlab does not
%permit accessing child classes private attributes, therefore, for this
%to work properly, this method ought to be replicated in each subclass.
%
%% Output parameters
%
% ver - Char array.
%   Class version of the current object.
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
% 
% See also 
%

%% Log
%
%
% -- ICNNA v1.4.0
%
% 3-Mar-2026: FOE. 
%   + File created
%

ver = obj.classVersion; 

end
function [ver] = classVersion(obj)
%Returns the current classVersion
%
% [ver] = obj.classVersion()
% [ver] = classVersion(obj)
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
% Copyright 2025
% @author Felipe Orihuela-Espina
% 
% See also 
%

%% Log
%
%
% File created: 9-Jul-2025
%
% -- ICNNA v1.3.1
%
% 9-Jul-2025: FOE. 
%   + File created
%

ver = obj.classVersion; 

end
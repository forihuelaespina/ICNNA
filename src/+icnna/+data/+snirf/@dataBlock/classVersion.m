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
% Copyright 2026
% @author Felipe Orihuela-Espina
% 
% See also 
%

%% Log
%
% -- ICNNA v1.4.2.1
%
% 9-Jul-2026: FOE
%   + File created. Adds the classVersion accessor these snirf classes were
%     missing, so classVersion (now an immutable, serialized instance
%     property) can be read via classVersion(obj) like other ICNNA classes.
%

ver = obj.classVersion; 

end

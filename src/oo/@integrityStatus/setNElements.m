function obj=setNElements(obj,nelem)
%INTEGRITYSTATUS/SETNELEMENTS Set the number of tracked elements
%
% obj=setNElements(obj,nelem) Set the number of tracked elements
%
%The number of elements to track must be a positive integer,
%otherwise a warning message is delivered and nelem is simply
%ignored.
%
% If the new number of elements is larger than the existing
%number of elements, a list of elements are added labelled as
%UNCHECK.
% 
% If the new number of elements is smaller than the existing
%number of elements then the last n elements are discarded.
%
% Copyright 2008
% date: 14-May-2008
% Author: Felipe Orihuela-Espina
%
% See also getNElements
%

if ((isscalar(nelem)) && (nelem==floor(nelem)) && (nelem>=1))
    if (nelem < getNElements(obj))
        obj.elements(nelem+1:end)=[];
    else
        obj.elements(end+1:nelem)=obj.UNCHECK;
    end
else
    warndlg('Invalid number of elements',...
        'integrityStatus');
end

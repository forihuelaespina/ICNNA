function display(obj)
%SIGNAL/DISPLAY Command window display of a signal
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also signal
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
if (isempty(obj.samples))
    disp('   []');
else
    disp(obj.samples);
end
disp(' ');

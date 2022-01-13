function display(obj)
%SESSION/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also session
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp('   Definition: ');
definition=obj.definition;
display(definition);
disp(['   date: ' obj.date]);
disp(['   Data Sources: ' num2str(getNDataSources(obj)) ' sources']);
disp(' ');

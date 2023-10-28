function display(obj)
%SESSION/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also session
%


%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Now also displays new attribute classVersion
%




disp(' ');
disp([inputname(1),'= ']);
disp(' ');
try
    disp(['   Class version: ' num2str(obj.classVersion)]);
catch
    disp('   Class version: N/A');
end
disp('   Definition: ');
display(obj.definition);
disp(['   date: ' obj.date]);
disp(['   Data Sources: ' num2str(obj.nDataSources) ' sources']);
disp(' ');



end
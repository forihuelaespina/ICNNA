function display(obj)
%SESSIONDEFINITION/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition, get, set
%


%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
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
disp(['   ID: ' num2str(obj.id)]);
disp(['   name: ' obj.name]);
disp(['   description: ' obj.description]);
disp(['   Sources of data: ' num2str(obj.nDataSources) ' sources']);
nElements=length(obj.sources);
for ii=1:nElements
    tmp = obj.sources{ii};
    disp(['        [ID, Type, Device Number]: [' ...
            num2str(tmp.id) ',''' tmp.type ...
            ''', ' num2str(tmp.deviceNumber) ']']);
end
disp(' ');


end

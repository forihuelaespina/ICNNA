function display(obj)
%SESSIONDEFINITION/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   name: ' obj.name]);
disp(['   description: ' obj.description]);
disp(['   Sources of data: ' num2str(getNSources(obj)) ' sources']);
nElements=length(obj.sources);
for ii=1:nElements
    disp(['        [ID, Type, Device Number]: [' ...
            num2str(get(obj.sources{ii},'ID')) ...
            ',''' get(obj.sources{ii},'Type') ...
            ''', ' num2str(get(obj.sources{ii},'DeviceNumber')) ']']);
end
disp(' ');

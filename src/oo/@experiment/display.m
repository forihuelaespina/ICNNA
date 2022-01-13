function display(obj)
%EXPERIMENT/DISPLAY Command window display of an experiment
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   name: ' obj.name]);
disp(['   description: ' obj.description]);
disp(['   version: ' obj.version]);
disp(['   date: ' obj.date]);
disp(['   data source Definitions: ' num2str(getNDataSourceDefinitions(obj)) ...
            ' definitions.']);
idList=getDataSourceDefinitionList(obj);
for ii=idList
    ssd = getDataSourceDefinition(obj,ii);
    type = get(ssd,'Type');
    devNum = get(ssd,'DeviceNumber');
    disp(['      *' num2str(ii) ': ''' type ...
          ''' (' num2str(devNum) ')']);
end
disp(['   session Definitions: ' num2str(getNSessionDefinitions(obj)) ...
            ' definitions.']);
idList=getSessionDefinitionList(obj);
for ii=idList
    ssd = getSessionDefinition(obj,ii);
    name = get(ssd,'Name');
    disp(['      *' num2str(ii) ': ' name]);
end
disp(['   Num. Subjects: ' num2str(getNSubjects(obj)) ' Subjects']);
%disp(obj.subjects);

disp(' ');
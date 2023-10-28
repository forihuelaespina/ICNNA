function display(obj)
%EXPERIMENT/DISPLAY Command window display of an experiment
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @author Felipe Orihuela-Espina
%


%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Now also displays new attribute classVersion
%   + Deprecated property date now change to studyDate
%   + Deprecated property version now hidden.
%



disp(' ');
disp([inputname(1),'= ']);
disp(' ');
try
    disp(['   Class version: ' num2str(obj.classVersion)]);
catch
    disp(['   Class version: N/A']);
end
disp(['   name: ' obj.name]);
disp(['   description: ' obj.description]);
%disp(['   version: ' obj.version]);
disp(['   studyDate: ' datestr(obj.studyDate)]);
disp(['   data source Definitions: ' num2str(obj.nDataSourceDefinitions) ...
            ' definitions.']);
idList=getDataSourceDefinitionList(obj);
for ii=idList
    ssd = getDataSourceDefinition(obj,ii);
    type = get(ssd,'Type');
    devNum = get(ssd,'DeviceNumber');
    disp(['      *' num2str(ii) ': ''' type ...
          ''' (' num2str(devNum) ')']);
end
disp(['   session Definitions: ' num2str(obj.nSessionDefinitions) ...
            ' definitions.']);
idList=getSessionDefinitionList(obj);
for ii=idList
    ssd = getSessionDefinition(obj,ii);
    name = get(ssd,'Name');
    disp(['      *' num2str(ii) ': ' name]);
end
disp(['   Num. Subjects: ' num2str(obj.nSubjects)]);
%disp(obj.subjects);

disp(' ');


end
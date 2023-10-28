function display(obj)
%ANALYSIS/DISPLAY Command window display of a analysis
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%


%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): N/A. This method
%   had not been modified since creation.
%
% 7-Jun-2023: FOE
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
disp(['   distance metric: ' obj.metric]);
disp(['   embedding technique: ' obj.embedding]);
disp(['   Number of Patterns: ' num2str(obj.nPatterns)]);
disp(['   Projection dimensionality: ' ...
    num2str(obj.projectionDimensionality)]);
disp('   Subjects Included: ');
disp(mat2str(obj.subjectsIncluded));
disp('   Sessions Included: ');
disp(mat2str(obj.sessionsIncluded));
disp('   Channel grouping: ');
disp(mat2str(obj.channelGrouping));
disp('   Signal descriptors [dataSource signal]: ')
disp(mat2str(obj.signalDescriptors));
tmp = obj.F;
if tmp.runStatus
    disp('   Experiment Space: COMPUTED');
else
    disp('   Experiment Space: NOT COMPUTED');
end

if obj.runStatus
    disp('   Run Status: RUN');
else
    disp('   Run Status: NOT RUN');
end

disp('   clusters: ');
disp(obj.clusters);
disp(' ');



end
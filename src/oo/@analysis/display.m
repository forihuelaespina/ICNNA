function display(obj)
%ANALYSIS/DISPLAY Command window display of a analysis
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 23-Apr-2008
% @author Felipe Orihuela-Espina
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   name: ' get(obj,'Name')]);
disp(['   description: ' get(obj,'Description')]);
disp(['   distance metric: ' get(obj,'Metric')]);
disp(['   embedding technique: ' get(obj,'Embedding')]);
disp(['   Number of Patterns: ' num2str(size(obj.H,1))]);
disp(['   Projection dimensionality: ' ...
    num2str(obj.projectionDimensionality)]);
disp('   Subjects Included: ');
disp(mat2str(get(obj,'SubjectsIncluded')));
disp('   Sessions Included: ');
disp(mat2str(get(obj,'SessionsIncluded')));
disp('   Channel grouping: ');
disp(mat2str(obj.channelGrouping));
disp('   Signal descriptors [dataSource signal]: ')
disp(mat2str(obj.signalDescriptors));
tmpRunStatus=get(obj.F,'RunStatus');
if tmpRunStatus
    disp('   Experiment Space: COMPUTED');
else
    disp('   Experiment Space: NOT COMPUTED');
end

if get(obj,'RunStatus')
    disp('   Run Status: RUN');
else
    disp('   Run Status: NOT RUN');
end

disp('   clusters: ');
disp(obj.clusters);
disp(' ');

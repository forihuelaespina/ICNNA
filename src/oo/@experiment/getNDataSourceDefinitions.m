function n=getNDataSourceDefinitions(obj)
%EXPERIMENT/GETNDATASOURCEDEFINITIONS DEPRECATED. Gets the number of dataSource definitions
%
% n=getNDataSourceDefinitions(obj) Gets the number of dataSource
%	definitions defined in the experiment dataset.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getDataSourceDefinitionList
%


%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%


warning('ICNNA:experiment:getNDataSourceDefinitions:Deprecated',...
        ['Method DEPRECATED (v1.2). Use experiment.nDataSourceDefinitions instead.']); 
    %Maintain method by now to accept different capitalization though.


%n=length(obj.dataSourceDefinitions);
n = obj.nDataSourceDefinitions;

end

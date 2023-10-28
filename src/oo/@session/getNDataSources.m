function n=getNDataSources(obj)
%SESSION/GETNDATASOURCES DEPRECATED (v1.2). Gets the number of dataSources defined
%
% n=getNDataSources(obj) Gets the number of dataSources defined
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getDataSource, getDataSourceList, clearDataSources,
% addDataSource
%



%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to update get/set methods calls for struct like access
%   + Declare method as DEPRECATED (v1.2).
%


warning('ICNNA:session:getNDataSources:Deprecated',...
        ['Method DEPRECATED (v1.2). Use session.nDataSources instead.']); 
    %Maintain method by now to accept different capitalization though.


%n=length(obj.sources);
n = obj.nDataSources;

end

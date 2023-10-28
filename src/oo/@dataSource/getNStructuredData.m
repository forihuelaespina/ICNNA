function n=getNStructuredData(obj)
%DATASOURCE/GETNSTRUCTUREDDATA DEPRECATED (v1.2). Gets the number of structured data defined
%
% n=getNStructuredData(obj) Gets the number of structured data
%   defined in the dataSource
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also findStructuredData
%


%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%


warning('ICNNA:dataSource:getNStructuredData:Deprecated',...
        ['Method DEPRECATED (v1.2). Use dataSource.nStructuredData instead.']); 
    %Maintain method by now to accept different capitalization though.


%n=length(obj.structured);
n = obj.nStructuredData;

end
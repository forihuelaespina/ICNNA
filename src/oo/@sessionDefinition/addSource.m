function obj=addSource(obj,dsd)
% SESSIONDEFINITION/ADDSOURCE Defines a new source of data
%
% obj=addSource(obj,dataSourceDefinition) Defines a new source of data.
%
%
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also removeSource, clearSources, dataSourceDefinition
%

if ~isa(dsd,'dataSourceDefinition')
    error('ICNA:sessionDefinition:addSource:InvalidParameter',...
            'Invalid Parameter.');
end    


idx=findSource(obj,dsd.id);
if isempty(idx)
    obj.sources(end+1)={dsd};
else
    warning('ICNA:sessionDefinition:addSource:RepeatedID',...
            ['A data source definition with the same ID '...
             'has already been defined.']);
end
assertInvariants(obj);
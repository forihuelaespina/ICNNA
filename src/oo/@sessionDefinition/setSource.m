function obj=setSource(obj,id,i)
% SESSIONDEFINITION/SETSOURCE Updates a data source definition
%
% obj=setSource(obj,id,newDataSourceDefinition) Updates the
%   associated data source definition 
%   with ID==id. If the source definition has not been defined,
%   then nothing is done.
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also addSource, removeSource, clearSources, getSource,
%dataSourceDefinition
%

if (isa(i,'dataSourceDefinition'))
    error('ICNA:sessionDefinition:setSourceType:InvalidParameter',...
          ['Invalid ''type'' parameter value. ' ...
           'Value must be a dataSourceDefintion.']);
end

idx=findSource(obj,id);
if (~isempty(idx))
    obj.sources(idx)={i};
end
assertInvariants(obj);
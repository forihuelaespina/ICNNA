function idx=findSource(obj,id)
%SESSIONDEFINITION/FINDSOURCE Finds a source of data
%
% idx=findSource(obj,id) returns the index of the data source.
%   If the source of data has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition, assertInvariants

nElements=length(obj.sources);
idx=[];
for ii=1:nElements
    if (id==get(obj.sources{ii},'ID'))
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end
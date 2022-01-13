function idx=findStructuredData(obj,id)
%DATASOURCE/FINDSTRUCTUREDDATA Finds a structured data
%
% idx=findStructuredData(obj,id) returns the index of the structured data.
%   If the structured data has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008
% @date: 23-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also dataSource, assertInvariants

nElements=length(obj.structured);
idx=[];
for ii=1:nElements
    tmpID=get(obj.structured{ii},'ID');
    if (id==tmpID)
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end
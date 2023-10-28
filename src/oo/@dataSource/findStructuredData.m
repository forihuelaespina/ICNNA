function idx=findStructuredData(obj,id)
%DATASOURCE/FINDSTRUCTUREDDATA Finds a structured data
%
% idx=findStructuredData(obj,id) returns the index of the structured data.
%   If the structured data has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also dataSource, assertInvariants




%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): N/A. This method had
%   never been updated since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



nElements=length(obj.structured);
idx=[];
for ii=1:nElements
    tmpSD = obj.structured{ii};
    tmpID=tmpSD.id;
    if (id==tmpID)
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end


end
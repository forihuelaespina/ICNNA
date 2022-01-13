function idx=findDataSource(obj,id)
%SESSION/FINDDATASOURCE Finds a dataSource within the session
%
% idx=findDataSource(obj,id) returns the index of the dataSource.
%   If the dataSource has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008
% @date: 23-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also session, assertInvariants

nElements=length(obj.sources);
idx=[];
for ii=1:nElements
    tmpID=get(obj.sources{ii},'ID');
    if (id==tmpID)
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end
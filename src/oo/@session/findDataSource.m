function idx=findDataSource(obj,id)
%SESSION/FINDDATASOURCE Finds a dataSource within the session
%
% idx=findDataSource(obj,id) returns the index of the dataSource.
%   If the dataSource has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also session, assertInvariants



%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%



nElements=length(obj.sources);
idx=[];
for ii=1:nElements
    tmpDataSource = obj.sources{ii};
    tmpID=tmpDataSource.id;
    if (id==tmpID)
        idx=ii;
        % Since the id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end


end
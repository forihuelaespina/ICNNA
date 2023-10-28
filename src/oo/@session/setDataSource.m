function obj=setDataSource(obj,id,nDS)
% SESSION/SETDATASOURCE Replace a dataSource
%
% obj=setDataSource(obj,id,newDataSource) Replace dataSource whose ID==id
%   with the new dataSource. If the dataSource whose ID==id has not been
%   defined, then nothing is done.
%
%% Remarks
%
%When updating a new dataSource in a session, it must comply
%with the session's definition. The session definition must
%have a "slot" for the type of data being inserted, and
%moreover, the ID of this slot must be the same than
%the ID of the data being inserted. If this is not the case
%warnings will be issued and nothing will be inserted.
%
%It is valid however inserting a generic dataSource
%(i.e. whose Type is empty).
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also addDataSource, removeDataSource
%



%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%


idx=findDataSource(obj,id);
if (~isempty(idx))
    if (isa(nDS,'dataSource')) %Ensuring that i is a dataSource
        %Look at the session definition
        validIDList=getSourceList(obj.definition);
        if (ismember(nDS.id,validIDList))
            tmp = getSource(obj.definition,nDS.id);
            if (strcmp(nDS.type, tmp.type) || strcmp(nDS.type,''))
                %Now update
                obj.sources(idx)={nDS};
            else
                warning('ICNA:session:addDataSource:InvalidType',...
                    'Invalid Type');
            end
        else
            warning('ICNA:session:addDataSource:UndefinedInSession',...
                'The ID has not been defined in the session definition.');
        end
        
    end
end
assertInvariants(obj);


end
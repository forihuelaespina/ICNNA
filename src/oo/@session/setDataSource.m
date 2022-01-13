function obj=setDataSource(obj,id,i)
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
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also addDataSource, removeDataSource
%

idx=findDataSource(obj,id);
if (~isempty(idx))
    if (isa(i,'dataSource')) %Ensuring that i is a dataSource
        %Look at the session definition
        validIDList=getSourceList(obj.definition);
        if (ismember(get(i,'ID'),validIDList))
            if (strcmp(get(i,'Type'),...
                       get(getSource(obj.definition,get(i,'ID')),'Type')) ...
                || strcmp(get(i,'Type'),''))
                %Now update
                obj.sources(idx)={i};
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
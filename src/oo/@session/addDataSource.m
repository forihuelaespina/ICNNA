function obj=addDataSource(obj,nDS)
% SESSION/ADDDATASOURCE Add a new dataSource to the session
%
% obj=addDataSource(obj,nDS) Add a new dataSource nDS to the session. If
%   a dataSource with the same ID has already been defined within
%   the session, then a warning is issued and nothing is done.
%
%
%
%% Remarks
%
%When adding a new dataSource to a session, it must comply
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
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also removeDataSource, setDataSource, clearDataSources
%



%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%



%Ensure that i is a dataSource
if isa(nDS,'dataSource')
    idx=findDataSource(obj,nDS.id);
    if isempty(idx)
        %Look at the session definition
        validIDList=getSourceList(obj.definition);
        if (ismember(nDS.id,validIDList))
            tmpDS = getSource(obj.definition,nDS.id);
            if (strcmp(nDS.type, tmpDS.type) || strcmp(nDS.type,''))
                %Now insert
                obj.sources(end+1)={nDS};
            else
                warning('ICNA:session:addDataSource:InvalidType',...
                    'Invalid Type');
            end
        else
            warning('ICNA:session:addDataSource:UndefinedInSession',...
                'The ID has not been defined in the session definition.');
        end
    else
        warning('ICNA:session:addDataSource:RepeatedID',...
            'A dataSource with the same ID has already been defined.');
    end
else
    error([inputname(2) ' is not a dataSource']);
end
assertInvariants(obj);


end
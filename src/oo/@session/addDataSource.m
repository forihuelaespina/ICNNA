function obj=addDataSource(obj,i)
% SESSION/ADDDATASOURCE Add a new dataSource to the session
%
% obj=addDataSource(obj,i) Add a new dataSource i to the session. If
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
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also removeDataSource, setDataSource, clearDataSources
%

%Ensure that i is a dataSource
if isa(i,'dataSource')
    idx=findDataSource(obj,get(i,'ID'));
    if isempty(idx)
        %Look at the session definition
        validIDList=getSourceList(obj.definition);
        if (ismember(get(i,'ID'),validIDList))
            if (strcmp(get(i,'Type'),...
                       get(getSource(obj.definition,get(i,'ID')),'Type')) ...
                || strcmp(get(i,'Type'),''))
                %Now insert
                obj.sources(end+1)={i};
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
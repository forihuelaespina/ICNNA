function obj=addSessionDefinition(obj,newSessionDefinitions)
% EXPERIMENT/ADDSESSIONDEFINITION Add a new session definition to the experiment
%
% obj=addSessionDefinition(obj,s) Add a new session definition
%   to the experiment dataset. If
%   a definition with the same ID has already been defined within
%   the experiment, then a warning is issued
%   and nothing is done.
%
% This function can insert multiple defintions at a time, by
%using a cell array of sessionDefinitions in s.
%
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also removeSessionDefinition, setSessionDefinition
%

if (length(newSessionDefinitions)==1 ...
        && isa(newSessionDefinitions,'sessionDefinition'))
    %Insert single sessionDefinition
    s=newSessionDefinitions;

    idx=findSessionDefinition(obj,get(s,'ID'));
    if isempty(idx)
        if existDataSourceDefinitionConflicts(obj,s)
            warning('ICNA:experiment:addSessionDefinition:DataSourceDefinitionConflict',...
                ['Data source definition conflict found. ' ...
                 'Session definition not added.']);
        else
            %Collect the new data source definitions
            defs=collectDataSourceDefinitionsFromSessionDefinition(obj,s,1);
            obj=addDataSourceDefinition(obj,defs);
            obj.sessionDefinitions(end+1)={s};
        end
    else
        warning('ICNA:experiment:addSessionDefinition:RepeatedID',...
            ['A session definition with the same ID ' ...
            'has already been defined. ' ...
            'Session definition not added.']);
    end

 
elseif iscell(newSessionDefinitions) %Insert multiple sessionDefinitions
%     barProgress=0;
%     h = waitbar(barProgress,'Adding multiple sessionDefinitions - 0%');
%     step=1/(length(newSessionDefinitions)*2);

idxs=zeros(1,0);
for ii=1:numel(newSessionDefinitions)
%     waitbar(barProgress,h,['Adding multiple sessionDefinitions - Check Stage - ' ...
%                     num2str(round(barProgress*100)) '%']);
%     barProgress=barProgress+step;
    if isa(newSessionDefinitions{ii},'sessionDefinition')
        if isempty(findSessionDefinition(obj,get(newSessionDefinitions{ii},'ID')))
            %Check possible dataSourceDefinitions coflicts
            if existDataSourceDefinitionConflicts(obj,newSessionDefinitions{ii})
                warning(['ICNA:experiment:addSessionDefinition:'...
                    'DataSourceDefintionConflict'],...
                    ['Data source definition conflict found. ' ...
                    'Session defintion in position ' num2str(ii) ...
                    ' will not be added.']);
            else
                %Collect the new data sources definitions
                defs=collectDataSourceDefinitionsFromSessionDefinition(obj,...
                            newSessionDefinitions{ii},1);
                obj=addDataSourceDefinition(obj,defs);
                idxs=[idxs ii];
            end
        else
             warning('ICNA:experiment:addSessionDefinition:RepeatedID',...
                ['A sessionDefinition with ID=' ...
                     num2str(get(newSessionDefinitions{ii},'ID')) ...
                     ' has already been defined.']);
        end
    else
        warning('ICNA:experiment:addSessionDefinition:InvalidParameter',...
                ['Element in position ' num2str(ii) ...
                 ' is not a sessionDefinition.']);
    end
end
% waitbar(barProgress,h,['Adding multiple sessionDefinitions - Saving stage - ' ...
%                 num2str(round(barProgress*100)) '%']);
% barProgress=barProgress+step;
obj.sessionDefinitions(end+1:end+length(idxs))=newSessionDefinitions(idxs);
clear newSessionDefinitions

% waitbar(1,h);
% close(h);

else
    error('Invalid input sessionDefinition/s. For multiple sessionDefinitions use a cell array');
end
assertInvariants(obj);

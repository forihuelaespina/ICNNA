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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also removeSessionDefinition, setSessionDefinition
%




%% Log
%
% File created: 10-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to update get/set methods calls for struct like access
%




if (length(newSessionDefinitions)==1 ...
        && isa(newSessionDefinitions,'sessionDefinition'))
    %Insert single sessionDefinition
    s=newSessionDefinitions;

    idx=findSessionDefinition(obj,s.id);
    if isempty(idx)
        if existDataSourceDefinitionConflicts(obj,s)
            warning('ICNNA:experiment:addSessionDefinition:DataSourceDefinitionConflict',...
                ['Data source definition conflict found. ' ...
                 'Session definition not added.']);
        else
            %Collect the new data source definitions
            defs=collectDataSourceDefinitionsFromSessionDefinition(obj,s,1);
            obj=addDataSourceDefinition(obj,defs);
            obj.sessionDefinitions(end+1)={s};
        end
    else
        warning('ICNNA:experiment:addSessionDefinition:RepeatedID',...
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
    tmpSessDef = newSessionDefinitions{ii};
    if isa(tmpSessDef,'sessionDefinition')
        if isempty(findSessionDefinition(obj,tmpSessDef.id))
            %Check possible dataSourceDefinitions coflicts
            if existDataSourceDefinitionConflicts(obj,tmpSessDef)
                warning(['ICNNA:experiment:addSessionDefinition:'...
                    'DataSourceDefintionConflict'],...
                    ['Data source definition conflict found. ' ...
                    'Session defintion in position ' num2str(ii) ...
                    ' will not be added.']);
            else
                %Collect the new data sources definitions
                defs=collectDataSourceDefinitionsFromSessionDefinition(obj,...
                            tmpSessDef,1);
                obj=addDataSourceDefinition(obj,defs);
                idxs=[idxs ii];
            end
        else
             warning('ICNA:experiment:addSessionDefinition:RepeatedID',...
                ['A sessionDefinition with ID=' num2str(tmpSessDef.id) ...
                     ' has already been defined.']);
        end
    else
        warning('ICNNA:experiment:addSessionDefinition:InvalidParameter',...
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



end

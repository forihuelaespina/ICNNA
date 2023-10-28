function obj=addDataSourceDefinition(obj,newDataSourceDefinitions)
% EXPERIMENT/ADDDATASOURCEDEFINITION Add a new dataSource definition to the experiment
%
% obj=addDataSourceDefinition(obj,s) Add a new dataSource definition
%   to the experiment dataset. If a dataSource
%   definition with the same ID has already been defined within
%   the experiment, then a warning is issued
%   and nothing is done.
%
% This function can insert multiple defintions at a time, by
%using a cell array of dataSourceDefinitions in s.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also removeDataSourceDefinition, setDataSourceDefinition
%


%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%
% 24-May-2023: FOE
%   + Started to update calls to get/set methods for struct like access
%





if (length(newDataSourceDefinitions)==1 ...
        && isa(newDataSourceDefinitions,'dataSourceDefinition'))
    %Insert single dataSourceDefinition
    s=newDataSourceDefinitions;
    
    %Ensure that s is a dataSourceDefinition
    if isa(s,'dataSourceDefinition')
        idx=findDataSourceDefinition(obj,s.id);
        if isempty(idx)
            obj.dataSourceDefinitions(end+1)={s};
        else
            warning('ICNA:experiment:addDataSourceDefinition:RepeatedID',...
                ['A dataSourceDefinition with the same ID ' ...
                 'has already been defined.']);
        end
    else
        error([inputname(2) ' is not a dataSourceDefinition.']);
    end
    
 
elseif iscell(newDataSourceDefinitions) %Insert multiple dataSourceDefinitions
%     barProgress=0;
%     h = waitbar(barProgress,'Adding multiple dataSourceDefinitions - 0%');
%     step=1/(length(newDataSourceDefinitions)*2);

idxs=zeros(1,0);
for ii=1:numel(newDataSourceDefinitions)
%     waitbar(barProgress,h,['Adding multiple dataSourceDefinitions - Check Stage - ' ...
%                     num2str(round(barProgress*100)) '%']);
%     barProgress=barProgress+step;
    tmpDSdef = newDataSourceDefinitions{ii};
    if isa(tmpDSdef,'dataSourceDefinition')
        if isempty(findDataSourceDefinition(obj,tmpDSdef.id))
            idxs=[idxs ii];
        else
             warning('ICNA:experiment:addDataSourceDefinition:RepeatedID',...
                ['A dataSourceDefinition with ID=' num2str(tmpDSdef.id) ...
                     ' has already been defined.']);
        end
    else
        warning('ICNA:experiment:addDataSourceDefinition:InvalidParameter',...
                ['Element in position ' num2str(ii) ...
                 ' is not a dataSourceDefinition.']);
    end
end
% waitbar(barProgress,h,['Adding multiple dataSourceDefinitions - Saving stage - ' ...
%                 num2str(round(barProgress*100)) '%']);
% barProgress=barProgress+step;
obj.dataSourceDefinitions(end+1:end+length(idxs))=newDataSourceDefinitions(idxs);
clear newDataSourceDefinitions

% waitbar(1,h);
% close(h);

else
    error('Invalid input dataSourceDefinition/s. For multiple dataSourceDefinitions use a cell array');
end
assertInvariants(obj);



end
function defs=collectDataSourceDefinitionsFromSessionDefinition(obj,s,mode)
%EXPERIMENT/COLLECTDATASOURCEDEFINTIONSFROMSESSIONDEFINITION
%Collect dataSource definitions from sessionDefinition
%
% defs=collectDataSourceDefinitionsFromSessionDefinition(obj,s) 
%   Collect the dataSource definitions for all the dataSources
%   defined in the sessionDefinition s. May return an empty matrix
%   if no sessionDefinition has been defined with the same
%   id as s, or if the sessionDefinition contains no dataSources.
%
% defs=collectDataSourceDefinitionsFromSessionDefinition(obj,s,mode) 
%   Collect dataSource definitions from dataSources
%   defined in the sessionDefinition s. May return an empty matrix
%   if no sessionDefinition has been defined with the same
%   id as s, or if the sessionDefinition contains no dataSources.
%       + If mode equals 0, then all data sources definition
%       declared in the sessionDefinition are collected.
%       + If mode equals 1, then only data source definitions
%       which do not already exist in the experiment 
%       are collected (those with IDs not defined).
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experiment, sessionDefinition, dataSourceDefinition, assertInvariants





%% Log
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%



if ~isa(s,'sessionDefinition')
    error('Invalid sessionDefinition parameter.');
end

m=0;
if (exist('mode','var'))
    if (mode==0) || (mode==1)
        m=mode;
    else
        warning(['ICNNA:experiment:private:' ...
            'collectDataSourceDefinitionsFromSessionDefinition:InvalidMode'],...
            'Invalid mode. Setting mode equals to 0.');
    end
end

if m
    expDefIDs=getDataSourceDefinitionList(obj);
end

srcIDs=getSourceList(s);
defs=cell(1,0);
if ~m
    defs=cell(1,s.nDataSources);
end
pos=1;
for src=srcIDs
    if m %Collect only new ones
        tmpDef=getSource(s,src);
        if (~ismember(tmpDef.id,expDefIDs))
            defs(pos)={tmpDef};
            pos=pos+1;
        end
    else %Collect all
        defs(pos)={getSource(s,src)};
        pos=pos+1;
    end
end



end

function [I,F,COL]=unfoldExperiment(E)
%Extract active structuredData across the experiment
%
% [I,F,COL]=unfoldExperiment(E) Extract active structuredData across the
%       experiment
%
%This function unfolds the object oriented data structure
%of an experiment into 2 matrixes/cell-arrays to ease navigation
%across the experiment:
%
%   + I: An index matrix with the following columns
%       <Subject, Session, DataSource>
%   + F: Active StructuredData
%
%Each row is a case, and these matrixes share the same number of rows.
%
%% Remarks
%
% This functions does not perform any kind of block splitting
%nor any averaging nor integrity checking.
%
%% Parameters
%
% E - An experiment
%
%% Output
%
% I - An index matrix with the following columns
%       <Subject, Session, DataSource>
% F - A cell array of structuredData.
%       Note that it may actually be a subclass of structuredData such as
%       nirs_neuroimage.
% COL - Column index constants. A struct with the constants
%   to the columns of the index matrix I including
%           .SUBJECT
%           .SESSION
%           .DATASOURCE
%
%
%
%
% Copyright 2010-23
% @author: Felipe Orihuela-Espina
%
% See also experimentSpace, structuredData, batchBasicVisualization,
%   plotChannel, guiBasicVisualization
%




%% Log
%
% File created: 3-Jul-2010
% File last modified (before creation of this log): 17-Aug-2012
%
% 27-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%





%Declare the constants
COL.SUBJECT = 1;
COL.SESSION = 2;
COL.DATASOURCE = 3;

%Pre-allocate memory
I = zeros(0,length(fieldnames(COL)));
F = cell(0,1);

subjectList=getSubjectList(E);
%subjectList=[2];
for subjID=subjectList
    s=getSubject(E,subjID);
    sessionList=getSessionList(s);
    for sessID=sessionList
        ss=getSession(s,sessID);
        dataSourceList=getDataSourceList(ss);
        for dataSourceID=dataSourceList
            ds=getDataSource(ss,dataSourceID);
            activeDataID=ds.activeStructured;
            I(end+1,:)=[subjID sessID dataSourceID];
            F(end+1,1)={getStructuredData(ds,activeDataID)};
            
        end %dataSource
        clear ss        
    end %sessions
    clear s
end %subjects

end


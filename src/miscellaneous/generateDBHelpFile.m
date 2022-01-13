function generateDBHelpFile(expSpace,ver,filename,options)
%Automatically generates the output help file for a database
%
% generateDBHelpFile(expSpace,ver,outputFilename)
%   Automatically generates the output help file for a database
%
% generateDBHelpFile(expSpace,ver,outputFilename,options)
%   Automatically generates the output help file for a database
%       with some options
%
%
%% Parameters:
%
% expSpace - An experiment space that yielded the database
%
% ver - A version of the database
%
% filename - The database help file filename.
%
% options - A struct of options
%   .removeOutliers - Indicate whether outliers channels were removed
%       from the database. See option .removeOutliers in method
%       generateDB_withBreak.m
%
%
%
%
% Copyright 2008-2014
% @date: 28-Nov-2008
% @author: Felipe Orihuela-Espina
% @modified: 15-May-2014
%
% See also experimentSpace, generateDB, getDBConstants
%


%% Log
%
% 15-May-2014: Added parameter options, and the option to indicate
%       whether DB otulier removal has been used. Also improved some
%       comments.
%


%% Deal with options
opt.removeOutliers=false;
if exist('options','var')
    if isfield(options,'removeOutliers')
        opt.removeOutliers=options.removeOutliers;
    end
end




% Open the file for writing
fidr = fopen(filename, 'w');
if fidr == -1
    error('Unable to open %s\n', filename);
end


fprintf(fidr,'%s\n\n','//Database help file');
fprintf(fidr,'%s\n', ...
        '--------------------------------------------------------------');
fprintf(fidr,'%s\n', ...
        '- Experiment Space:');
fprintf(fidr,'%s\n\n', ...
        '--------------------------------------------------------------');
fprintf(fidr,'%s\n\n', ...
        [get(expSpace,'Name') ' - ' get(expSpace,'Description')]);

    
fprintf(fidr,'%s\n',['   Block splitting [baseline, Max. Rest Samples]: ' ...
    mat2str([get(expSpace,'BaselineSamples') ...
             get(expSpace,'RestSamples') ])]);
    
    
if (get(expSpace,'Averaged'))
    fprintf(fidr,'%s\n','   Averaged across blocks: TRUE');
end 
if (get(expSpace,'Resampled'))
    fprintf(fidr,'%s\n',['   Resampling [Baseline, Task, Rest]: ' ...
        mat2str([get(expSpace,'RS_Baseline') ...
                 get(expSpace,'RS_Task') ...
                 get(expSpace,'RS_Rest')])]);
end


%if (get(expSpace,'Windowed'))
fprintf(fidr,'%s\n',['   Window selection [window onset, duration, break delay]: ' ...
    mat2str([get(expSpace,'WS_Onset') ...
             get(expSpace,'WS_Duration') ...
             get(expSpace,'WS_BreakDelay') ])]);
%end 

%Normalization occurs after windowing!!! See experimentSpace.compute
if (get(expSpace,'Normalized'))
  if strcmp(get(expSpace,'NormalizationMethod'),'normal')
    fprintf(fidr,'%s\n',['   Normalization [Scope, Dimension, Method (Params)]: ' ...
        '[' get(expSpace,'NormalizationScope') ',' ...
            get(expSpace,'NormalizationDimension') ',' ...
            get(expSpace,'NormalizationMethod') ...
                '(' mat2str([get(expSpace,'NormalizationMean'),...
                            get(expSpace,'NormalizationVar')]) ')]' ]);
  elseif strcmp(get(expSpace,'NormalizationMethod'),'range')
    fprintf(fidr,'%s\n',['   Normalization [Scope, Dimension, Method (Params)]: ' ...
        '[' get(expSpace,'NormalizationScope') ',' ...
            get(expSpace,'NormalizationDimension') ',' ...
            get(expSpace,'NormalizationMethod') ...
                '(' mat2str([get(expSpace,'NormalizationMin'),...
                            get(expSpace,'NormalizationMax')]) ')]' ]);
  else
    fprintf(fidr,'%s\n',['   Normalization [Scope, Dimension, Method]: ' ...
        '[' get(expSpace,'NormalizationScope') ',' ...
            get(expSpace,'NormalizationDimension') ',' ...
            get(expSpace,'NormalizationMethod') ']' ]);
  end
end 




fprintf(fidr,'%s\n\n',['   Num. Points: ' ...
                num2str(get(expSpace,'nPoints'))]);

fprintf(fidr,'%s\n\n', ...
    'Database was generated with generateDB_withBreak.m');


fprintf(fidr,'%s\n', ...
        '--------------------------------------------------------------');
fprintf(fidr,'%s\n', ...
        '- Database Processing:');
fprintf(fidr,'%s\n\n', ...
        '--------------------------------------------------------------');
if (opt.removeOutliers)
    fprintf(fidr,'%s\n','   Outlier removal after DB generation: TRUE');
    fprintf(fidr,'%s\n\n','         This may reduce the number of points.');
else
    fprintf(fidr,'%s\n\n','   Outlier removal after DB generation: FALSE');
end



fprintf(fidr,'%s\n', ...
        '--------------------------------------------------------------');
fprintf(fidr,'%s\n', ...
        '- Database Columns:');
fprintf(fidr,'%s\n\n', ...
        '--------------------------------------------------------------');

dbCons=getDBConstants(ver);
names = fieldnames(dbCons);
nIndependentVariables=dbCons.COL_LAST_INDEPENDENT;
nTotalVariables=length(names);


fprintf(fidr,'%s\n', ...
        ' Column | Independent Variables:');
fprintf(fidr,'%s\n', ...
        '--------+-----------------------');

for ii=1:nIndependentVariables
    fprintf(fidr,'%d\t| %s\n', ...
        getfield(dbCons,names{ii}),names{ii}(5:end));    
end
fprintf(fidr,'\n');

fprintf(fidr,'%s\n', ...
        ' Column | Dependent Variables:');
fprintf(fidr,'%s\n', ...
        '--------+-----------------------');

for ii=nIndependentVariables+2:nTotalVariables
    fprintf(fidr,'%d\t| %s\n', ...
        getfield(dbCons,names{ii}),names{ii}(5:end));    
end
fprintf(fidr,'\n');


fprintf(fidr,'%s\n', ...
        '--------------------------------------------------------------');
fprintf(fidr,'%s\n', ...
        '- Signal Identifiers:');
fprintf(fidr,'%s\n\n', ...
        '--------------------------------------------------------------');
fprintf(fidr,'\n');
fprintf(fidr,'%s\n','1 - OXY-HB');
fprintf(fidr,'%s\n','2 - DEOXY-HB');
fprintf(fidr,'%s\n','4 - TOTAL-HB (IF PRESENT)');
fprintf(fidr,'%s\n','5 - HB-DIFF (IF PRESENT)');
fprintf(fidr,'\n');


fclose(fidr);

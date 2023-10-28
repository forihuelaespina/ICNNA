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
% Copyright 2008-2023
% @author: Felipe Orihuela-Espina
%
% See also experimentSpace, generateDB, getDBConstants
%


%% Log
%
% File created: 28-Nov-2008
% File last modified (before creation of this log): 15-May-2014
%
% 15-May-2014: Added parameter options, and the option to indicate
%       whether DB otulier removal has been used. Also improved some
%       comments.
%
% 18-Aug-2024: 
%   + Got rid of old labels @date and @modified.
%   + Adapted calls of get/set methods for struct like access
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
fprintf(fidr,'%s\n\n', [expSpace.name ' - ' expSpace.description]);

    
fprintf(fidr,'%s\n',['   Block splitting [baseline, Max. Rest Samples]: ' ...
    mat2str([expSpace.baselineSamples expSpace.restSamples ])]);
    
    
if (expSpace.averaged)
    fprintf(fidr,'%s\n','   Averaged across blocks: TRUE');
end 
if (expSpace.resampled)
    fprintf(fidr,'%s\n',['   Resampling [Baseline, Task, Rest]: ' ...
        mat2str([expSpace.rs_baseline ...
                 expSpace.rs_task ...
                 expSpace.rs_rest])]);
end


%if (get(expSpace,'Windowed'))
fprintf(fidr,'%s\n',['   Window selection [window onset, duration, break delay]: ' ...
    mat2str([expSpace.ws_onset ...
             expSpace.ws_duration ...
             expSpace.ws_breakDelay ])]);
%end 

%Normalization occurs after windowing!!! See experimentSpace.compute
if (expSpace.normalized)
  if strcmp(expSpace.normalizationMethod,'normal')
    fprintf(fidr,'%s\n',['   Normalization [Scope, Dimension, Method (Params)]: ' ...
        '[' expSpace.normalizationScope ',' ...
            expSpace.normalizationDimension ',' ...
            expSpace.normalizationMethod ...
                '(' mat2str([expSpace.normalizationMean,...
                            expSpace.normalizationVar]) ')]' ]);
  elseif strcmp(expSpace.normalizationMethod,'range')
    fprintf(fidr,'%s\n',['   Normalization [Scope, Dimension, Method (Params)]: ' ...
        '[' expSpace.normalizationScope ',' ...
            expSpace.normalizationDimension ',' ...
            expSpace.normalizationMethod ...
                '(' mat2str([expSpace.normalizationMin,...
                            expSpace.normalizationMax]) ')]' ]);
  else
    fprintf(fidr,'%s\n',['   Normalization [Scope, Dimension, Method]: ' ...
        '[' expSpace.normalizationScope ',' ...
            expSpace.normalizationDimension ',' ...
            expSpace.normalizationMethod ']' ]);
  end
end 




fprintf(fidr,'%s\n\n',['   Num. Points: ' ...
                num2str(expSpace.nPoints)]);

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

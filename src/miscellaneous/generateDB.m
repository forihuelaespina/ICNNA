function [db]=generateDB(expSpace,options)
%DEPRECATED. Use generateDB_withBreak. Generates a database for further data analysis
%
% [db]=generateDB(expSpace)
%
%
%Allows the creation of a database for further analysis.
%
%% Remarks
%
%   The term "database" here is used in the
%   terms of a social science (barely a table) and not a
%   computer science fully ER 3rd normal form DB.
%
%
% Blocks of data in the experiment space are now only considered
% of having a baseline (perhaps of 0 samples!!) and the rest is
% considered to be task related information. If you do not wish
% to include any rest information into your database, run the
% experiment space so that it does not hold the information, either
% by resampling rest periods to 0 samples, or by windowing the
% block only to include task info.
%
%% Parameters:
%
% expSpace - An experiment space
%
% options - A struct of options
%   .outputFilename - Output filename for the database. Database will
%       be saved to a file if this option is provided. Output format is
%       .csv
%   .helpFilename - Output filename of the help file. Database help
%       will be saved to a file if this option is provided. Output
%       format is .txt
%
%% Output
%
% Current version of the database produces the following
%columns:
%
% Column | Independent variables:
% -------+-----------------------
%    1   | Subject
%    2   | Session
%    3   | Data Source
%    4   | Structured Data
%    5   | Channel
%    6   | Signal
%    7   | Stimulus
%    8   | Block (always 1 if experiment space is averaged across blocks)
%
%
% Column | Dependent variables:
% -------+-----------------------
%    9   | Signal/block baseline average 
%   10   | Signal/block baseline standard deviation 
%   11   | Signal/block task(+rest) average
%   12   | Signal/block task(+rest) standard deviation
%   13   | Signal/block task(+rest) average minus baseline average
%   14*  | Signal/block task(+rest) area under curve
%   15   | Time to Peak (in samples)
%   16   | Time to Nadir (in samples)
%
%
% * The area under the curve is computed with the trapezoidal approach
% (see MATLAB's trapz function)
%
%
% Copyright 2008
% date: 28-Nov-2008
% Author: Felipe Orihuela-Espina
%
% See also experimentSpace, getDBConstants, generateDBHelpFile
%

assert(get(expSpace,'RunStatus'),...
    'Experiment Space has not been run yet.');


%% Deal with options
opt.save=false;
opt.outputFilename=['./data/' get(expSpace,'Name') '_DB.csv'];
opt.saveHelp=false;
opt.helpFilename=['./data/' get(expSpace,'Name') '_DB_Help.txt'];
if exist('options','var')
    if isfield(options,'outputFilename')
        opt.save=true;
        opt.outputFilename=options.outputFilename;
    end
    if isfield(options,'helpFilename')
        opt.saveHelp=true;
        opt.helpFilename=options.helpFilename;
    end
end


[dbCons,ver]=getDBConstants;
[Findex,Fvectors]=getSubset(expSpace,[]);



%Calculate the number of samples that belong to each chunk
%of the block (baseline and task only, as rest is also
%considered to b part of the task!)

%nBaselineSamples=get(expSpace,'BaselineSamples');
%if get(expSpace,'Resampled')
%    nBaselineSamples=get(expSpace,'RS_Baseline');
%end
%if get(expSpace,'Windowed')
nBaselineSamples=0;
if (get(expSpace,'WS_Onset')<0)
    nBaselineSamples=-1*get(expSpace,'WS_Onset');
end
%end

x=0;
hbar = waitbar(x,'Generating database. Please wait...');

%Note that the Fvectors are not guaranteed to have the same
%length.
nPoints=size(Findex,1);
step=1/nPoints;
db=zeros(nPoints,size(Findex,2)+8); %Indep + Dep
for ii=1:nPoints
   x=x+step;
   waitbar(x,hbar);

   fvector=Fvectors{ii};
   nTotalSamples=length(fvector);

   %Split Fvector as appropiate
    if (nBaselineSamples==0)
        baseChunk=0;
    else
        baseChunk=fvector(1:nBaselineSamples);
    end

    assert(nTotalSamples>=nBaselineSamples,...
        'Corrupt Experiment Space.');
    if (nTotalSamples-nBaselineSamples==0)
        taskChunk=0;
    else
        taskChunk=fvector(nBaselineSamples+1:end,:);
    end

    baseVal=mean(baseChunk);
    baseStd=std(baseChunk);
    taskVal=mean(taskChunk);
    taskStd=std(taskChunk);
    areaUnderCurve=trapz(taskChunk);
    [tmpRubbish,timeToPeak]=max(taskChunk);
    timeToPeak=timeToPeak(1);
    [tmpRubbish,timeToNadir]=min(taskChunk);
    timeToNadir=timeToNadir(1);

    db(ii,:)=[Findex(ii,:) ...
        baseVal baseStd ...
        taskVal taskStd ...
        taskVal-baseVal ...
        areaUnderCurve ...
        timeToPeak timeToNadir];
end
waitbar(1,hbar);

if (opt.save)
    waitbar(0,hbar,'Saving database file.');
    csvwrite(opt.outputFilename,db);
    waitbar(1,hbar,'Saving database file.');
end
if (opt.saveHelp)
    waitbar(0,hbar,'Saving database help file.');
    generateDBHelpFile(expSpace,ver,opt.helpFilename);
    waitbar(1,hbar,'Saving database help file.');
end

close(hbar);

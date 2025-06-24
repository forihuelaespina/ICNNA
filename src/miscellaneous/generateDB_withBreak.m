function [db]=generateDB_withBreak(expSpace,options)
%%%
%%% AD HOC solution to allow a break between baseline data and task data
%%%(see option breakSamples)
%%%
%Generates a database for further data analysis
%
% [db]=generateDB_withBreak(expSpace)
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
%   .breakSamples - DEPRECATED. Set this value to get(expSpace,'WS_BreakDelay').
%       Number of samples of break between the end of the baseline
%       and the beggining of the task block. Previously it was defaulted
%       to 0. Now it is default to get(expSpace,'WS_BreakDelay').
%   .includeHbT - Include total Hb data. Data is assumed to origin from
%       a NIRS neuroimage, and with the first signal being the OxyHb
%       and the second signal begin the DeoxyHb. HbT data is marked
%       as signal nirs_neuroimage.TOTALHB. Default false.
%   .includeHbDiff - Include total Hb data. Data is assumed to origin from
%       a NIRS neuroimage, and with the first signal being the OxyHb
%       and the second signal begin the DeoxyHb. HbDiff data is marked
%       as signal nirs_neuroimage.HBDIFF. Default false.
%   .removeOutliers - Eliminate outlier channels from the database. An
%       outlier channel is defined as a channel for which its task HbO2 or
%       HHb lays beyond 3 standard deviations from the mean task HbO2 or
%       HHb of the rest of layers. This can be regarded as an additional
%       quality control measure. Default false.
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
%   15   | Signal/block time to peak
%   16   | Signal/block time to nadir
%
%
% * The area under the curve is computed with the trapezoidal approach
% (see MATLAB's trapz function)
%
%
% Copyright 2008-2023
% @author: Felipe Orihuela-Espina
%
% See also experimentSpace, getDBConstants, generateDBHelpFile
%


%% Log
%
% File created: 28-Nov-2008
% File last modified (before creation of this log): 15-May-2014
%
% 15-May-2014:
%   + Added this log.
%   + Added option to remove outliers.
%
% 20-Jun-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Adapted calls of get/set methods for struct like access
%
% 23-Feb-2024: FOE
%   + Bug fixed. Improved treatment of empty blocks.
%
% 14-Feb-2024: FOE
%   + Behaviour change:
%       BEFORE: Assert on whether an fvector was shorter than the
%       Baseline+BreakSamples
%       NOW: Assert switched for warning and set that fvector chunkSize to 0.
%

assert(expSpace.runStatus,'Experiment Space has not been run yet.');

%% Deal with options
opt.save=false;
opt.outputFilename=['.' filesep 'data' filesep expSpace.name '_DB.csv'];
opt.saveHelp=false;
opt.helpFilename=['.' filesep 'data' filesep expSpace.name '_DB_Help.txt'];
%opt.breakSamples=0;
opt.breakSamples= expSpace.ws_breakDelay;
opt.includeHbT=false;
opt.includeHbDiff=false;
opt.removeOutliers=false;
if exist('options','var')
    if isfield(options,'outputFilename')
        opt.save=true;
        opt.outputFilename=options.outputFilename;
    end
    if isfield(options,'helpFilename')
        opt.saveHelp=true;
        opt.helpFilename=options.helpFilename;
    end
    if isfield(options,'breakSamples')
        opt.breakSamples=options.breakSamples;
    end
    if isfield(options,'includeHbT')
        opt.includeHbT=options.includeHbT;
    end
    if isfield(options,'includeHbDiff')
        opt.includeHbDiff=options.includeHbDiff;
    end
    if isfield(options,'removeOutliers')
        opt.removeOutliers=options.removeOutliers;
    end
end


[dbCons,ver]=getDBConstants;
[Findex,Fvectors]=getSubset(expSpace,[]);



%Calculate the number of samples that belong to each chunk
%of the block (baseline and task only, as rest is also
%considered to b part of the task!)

% nBaselineSamples=get(expSpace,'BaselineSamples');
% if get(expSpace,'Resampled')
%     nBaselineSamples=get(expSpace,'RS_Baseline');
% end
% if get(expSpace,'Windowed')
nBaselineSamples=0;
if (expSpace.ws_onset < 0)
    nBaselineSamples=-1*expSpace.ws_onset;
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
   if ~isempty(fvector)
       if (nBaselineSamples==0)
           baseChunk=0;
       else
           baseChunk=fvector(1:nBaselineSamples);
       end

       %%The following lines have been modified to allow for a break
       %14-Feb-2025: FOE
       %    Change of behvaiour. Assert substituted by warning.
       %
       %assert(nTotalSamples>=(nBaselineSamples+opt.breakSamples),...
       %    'Corrupt Experiment Space.');
       if (nTotalSamples<(nBaselineSamples+opt.breakSamples))
           warning('ICNNA:generateDB_withBreak:UnexpectedSize',...
                   ['Number of total samples is lower than expected ' ...
                    'for experimentSpace vector ' num2str(ii) '.'])
           taskChunk=0;
       elseif (nTotalSamples-(nBaselineSamples+opt.breakSamples)==0)
           taskChunk=0;
       else
           taskChunk=fvector((nBaselineSamples+opt.breakSamples)+1:end,:);
       end
   else
       baseChunk=0;
       taskChunk=0;
   end

    baseVal=mean(baseChunk);
    baseStd=std(baseChunk);
    taskVal=mean(taskChunk);
    taskStd=std(taskChunk);
    areaUnderCurve=trapz(taskChunk);
    [~,timeToPeak]=max(taskChunk);
    timeToPeak=timeToPeak(1);
    [~,timeToNadir]=min(taskChunk);
    timeToNadir=timeToNadir(1);

    db(ii,:)=[Findex(ii,:) ...
        baseVal baseStd ...
        taskVal taskStd ...
        taskVal-baseVal ...
        areaUnderCurve ...
        timeToPeak timeToNadir];
end
waitbar(1,hbar);



%%%%%%%%%%%%%%
%% Outlier removal if requested
if opt.removeOutliers
    idxOxy=find(db(:,dbCons.COL_SIGNAL)==nirs_neuroimage.OXY);
    idxDeoxy=find(db(:,dbCons.COL_SIGNAL)==nirs_neuroimage.DEOXY);
    
    %Calculate mean and std
    oxyMean   = nanmean(db(idxOxy,dbCons.COL_MEAN_TASK));
    deoxyMean = nanmean(db(idxDeoxy,dbCons.COL_MEAN_TASK));
    oxyStd    = nanstd(db(idxOxy,dbCons.COL_MEAN_TASK));
    deoxyStd  = nanstd(db(idxDeoxy,dbCons.COL_MEAN_TASK));
    
    %Identify outliers
    tmpIdx = find(db(idxOxy,dbCons.COL_MEAN_TASK)<(oxyMean-3*oxyStd));
    idxOutliersOxy_Lower = idxOxy(tmpIdx);
    tmpIdx = find(db(idxOxy,dbCons.COL_MEAN_TASK)>(oxyMean+3*oxyStd));
    idxOutliersOxy_Upper = idxOxy(tmpIdx);
    tmpIdx = find(db(idxDeoxy,dbCons.COL_MEAN_TASK)<(deoxyMean-3*deoxyStd));
    idxOutliersDeoxy_Lower = idxDeoxy(tmpIdx);
    tmpIdx = find(db(idxDeoxy,dbCons.COL_MEAN_TASK)>(deoxyMean+3*deoxyStd));
    idxOutliersDeoxy_Upper = idxDeoxy(tmpIdx);
	idxOutliers = union(union(union(idxOutliersOxy_Lower,idxOutliersOxy_Upper),...
                            idxOutliersDeoxy_Lower),idxOutliersDeoxy_Upper);
    
    %Eliminate outliers
    db(idxOutliers,:)    =[];
    Findex(idxOutliers,:)=[];
    Fvectors(idxOutliers)=[];
    
end

%%%%%%%%%%%%%%
%Add HbT and HbDiff if neccessary

if (opt.includeHbT || opt.includeHbDiff)
assert(length(unique(Findex(:,[experimentSpace.DIM_DATASOURCE])))==1,...
    ['More than one source found. Currently unable to mix databases with ' ...
    'more than one data source.']);
assert(all(unique(Findex(:,[experimentSpace.DIM_SIGNAL]))==[1; 2]),...
    ['Unexpected signals found. This tool can currently only mix ' ...
    'fNIRS databases, i.e. expected signals should be OXY-HB (1) ' ...
    'and DEOXY-HB (2).']);
    

%signals=find(unique(independentVars(:,[dbCons.COL_DATASOURCE dbCons.COL_SIGNAL]), 'rows');
signals=[1 2];
idxOxy=find(Findex(:,dbCons.COL_SIGNAL)==signals(1));
idxDeoxy=find(Findex(:,dbCons.COL_SIGNAL)==signals(2));

tmpIndVarHbT=Findex(idxOxy,:);
tmpIndVarHbT(:,dbCons.COL_SIGNAL)=nirs_neuroimage.TOTALHB;
tmpIndVarHbDiff=Findex(idxOxy,:);
tmpIndVarHbDiff(:,dbCons.COL_SIGNAL)=nirs_neuroimage.HBDIFF;

nBaselineSamplesHbT=nBaselineSamples;
nBaselineSamplesHbDiff=nBaselineSamples;


x=0;
waitbar(x,hbar,'Adding derived Hb (HbT / HbDiff). Please wait...');


nPoints=size(tmpIndVarHbT,1);
step=1/nPoints;
db_HbT=zeros(nPoints,size(Findex,2)+8); %Indep + Dep
db_HbDiff=zeros(nPoints,size(Findex,2)+8); %Indep + Dep
for ii=1:nPoints
   x=x+step;
   waitbar(x,hbar);

   fvectorOxy=Fvectors{idxOxy(ii)};
   fvectorDeoxy=Fvectors{idxDeoxy(ii)};
   fvectorHbT=fvectorOxy+fvectorDeoxy;
   fvectorHbDiff=fvectorOxy-fvectorDeoxy;
   
   nTotalSamplesHbT=length(fvectorHbT);
   nTotalSamplesHbDiff=length(fvectorHbDiff);

   %Split Fvector as appropiate
    if (nBaselineSamplesHbT==0)
        baseChunkHbT=0;
    else
        baseChunkHbT=fvectorHbT(1:nBaselineSamplesHbT);
    end
    if (nBaselineSamplesHbDiff==0)
        baseChunkHbDiff=0;
    else
        baseChunkHbDiff=fvectorHbDiff(1:nBaselineSamplesHbDiff);
    end

    %%The following lines have been modified to allow for a break
    assert(nTotalSamplesHbT>=(nBaselineSamplesHbT+opt.breakSamples),...
        'Corrupt Experiment Space.');
    if (nTotalSamplesHbT-(nBaselineSamplesHbT+opt.breakSamples)==0)
        taskChunkHbT=0;
    else
        taskChunkHbT=...
            fvectorHbT((nBaselineSamplesHbT+opt.breakSamples)+1:end,:);
    end
    assert(nTotalSamplesHbDiff>=(nBaselineSamplesHbDiff+opt.breakSamples),...
        'Corrupt Experiment Space.');
    if (nTotalSamplesHbDiff-(nBaselineSamplesHbDiff+opt.breakSamples)==0)
        taskChunkHbDiff=0;
    else
        taskChunkHbDiff=...
            fvectorHbDiff((nBaselineSamplesHbDiff+opt.breakSamples)+1:end,:);
    end

    baseValHbT=mean(baseChunkHbT);
    baseStdHbT=std(baseChunkHbT);
    taskValHbT=mean(taskChunkHbT);
    taskStdHbT=std(taskChunkHbT);
    areaUnderCurveHbT=trapz(taskChunkHbT);
    [~,timeToPeakHbT]=max(taskChunkHbT);
    timeToPeak=timeToPeakHbT(1);
    [~,timeToNadirHbT]=min(taskChunkHbT);
    timeToNadir=timeToNadirHbT(1);
    baseValHbDiff=mean(baseChunkHbDiff);
    baseStdHbDiff=std(baseChunkHbDiff);
    taskValHbDiff=mean(taskChunkHbDiff);
    taskStdHbDiff=std(taskChunkHbDiff);
    areaUnderCurveHbDiff=trapz(taskChunkHbDiff);
    [~,timeToPeakHbDiff]=max(taskChunkHbDiff);
    timeToPeakDiff=timeToPeakHbDiff(1);
    [~,timeToNadirHbDiff]=min(taskChunkHbDiff);
    timeToNadirDiff=timeToNadirHbDiff(1);

    db_HbT(ii,:)=[tmpIndVarHbT(ii,:) ...
        baseValHbT baseStdHbT ...
        taskValHbT taskStdHbT ...
        taskValHbT-baseValHbT ...
        areaUnderCurveHbT ...
        timeToPeakHbT timeToNadirHbT];
    db_HbDiff(ii,:)=[tmpIndVarHbDiff(ii,:) ...
        baseValHbDiff baseStdHbDiff ...
        taskValHbDiff taskStdHbDiff ...
        taskValHbDiff-baseValHbDiff ...
        areaUnderCurveHbDiff ...
        timeToPeakHbDiff timeToNadirHbDiff];

end


if (opt.includeHbT)
    db=[db; db_HbT];
end
if (opt.includeHbDiff)
    db=[db; db_HbDiff];
end
waitbar(1,hbar);

end
%%%%%%%%%%%%%%

if (opt.save)
    waitbar(0,hbar,'Saving database file.');
    csvwrite(opt.outputFilename,db);
    waitbar(1,hbar,'Saving database file.');
end
if (opt.saveHelp)
    waitbar(0,hbar,'Saving database help file.');
    tmpOpt.removeOutliers=opt.removeOutliers;
    generateDBHelpFile(expSpace,ver,opt.helpFilename,tmpOpt);
    waitbar(1,hbar,'Saving database help file.');
end

close(hbar);




end

function [baseECG,blocksECGs,lastECG]=...
                    splitECGbyRawNIRS(elem,rawNIRSfilename)
%Split an ECG recording into chunks corresponding to blocks matching
%experimental stimulus
%
% [baseECG,blocksECGs,lastECG]=...
%                    splitECGbyRawNIRS(elem,rawNIRSfilename)
%       Split an ECG recording into chunks corresponding to 
%       blocks matching experimental stimulus
%
%% Parameters:
%
% elem - An ECG object
%
% rawNIRSfilename - The filename of the raw nirs neuroimage file (HITACHI
%       ETG-4000) to guide the splitting. Note that it is expected
%       that the ECG object timestamps match the timings of the NIRS
%       data acquisition.
%
%% Output:
%
% baseECG - An ECG object corresponding to the first 20 seconds
%   of the experimental session
%
% blocksECGs - An array of struct containing the ECG objects
%   corresponding to the stimulus periods for each expeirmental trial.
%   Each struct has the following fields:
%       .stim - Stimulus Tag
%       .block - Block numner within the stimulus
%       .taskecg - The ECG object during the trial
%
% lastECG - An ECG object corresponding to the last 20 seconds
%   of the experimental session
%
%
%
%
% Copyright 2010
% @date: 21-Jul-2010 (Extracted from guiSplitECG on 27-Nov-2010)
% @author Felipe Orihuela-Espina
% @modified: 28-Nov-2010
%
% See also rawData_BioHarnessECG, ecg, dataSource, rawData_ETG4000,
%   guiSplitECG
%

r = rawData_ETG4000;
    try
        %Read the fNIRS file
        r = import(r,rawNIRSfilename);
        %r = import(r,'./data/LGCMC0002a_MES_Probe1.csv'); %for testing only
    catch ME
        warndlg([ME.identifier ': ' ME.message ...
            'Unable to read ETG-4000 fNIRS file.'],'ICAF:guiSplitECG');
        return;
    end
    
    startTime = datenum(get(r,'Date'));
    timestamps = get(r,'Timestamps');
    tmpTimes=sec2datevec(timestamps);    
    
    %Step 1: Crop the ECG data corresponding to the fNIRS session time
    initTime = startTime + datenum(tmpTimes(:,1)');
    endTime = startTime + datenum(tmpTimes(:,end)');
    cropped_elem = cropECG(elem,initTime,endTime);
    
    %Step 2: Save cropped ECG data to a .csv file
    %ecg2csv(cropped_elem,[directory_name filename '_ECG_cropped.csv']);
    %rawData = rawData_BioHarnessECG;
    %rawData=import(rawData,[directory_name filename '_ECG_cropped.csv']);

    %Step 3: Extract "pre" block (very first 20 seconds)
    sr=get(cropped_elem,'SamplingRate');
    intervalSamples = 20 * sr;
    tmp_elem = crop(cropped_elem,1,intervalSamples);
    theData = dataSource;
    if exist('rawData','var')
        theData = setRawData(theData,rawData);
    else
        theData = unlock(theData);
    end
    baseECG = addStructuredData(theData,tmp_elem);
    clear theData

    %Step 4: Extract block timings
    %(assumes block design - no event related design)
    blocksECGs=struct('stim',{},'block',{},'taskecg',{});
    marks = get(r,'Marks');
    nStim = max(marks);
    for ss=1:nStim
        idx = find(marks == ss);
        partition = reshape(idx,2,numel(idx)/2)';
        nBlocks = size(partition,1);
        
        for bb=1:nBlocks
            initTime = startTime + datenum(tmpTimes(:,partition(bb,1))');
            endTime = startTime + datenum(tmpTimes(:,partition(bb,2))');
            
            tmp_elem = cropECG(cropped_elem,initTime,endTime);
            
            theData = dataSource;
            if exist('rawData','var')
                theData = setRawData(theData,rawData);
            else
                theData = unlock(theData);
            end
            blocksECGs(end+1).stim = char(ss+64);
            blocksECGs(end).block = bb;
            blocksECGs(end).taskecg = addStructuredData(theData,tmp_elem);
            clear theData
%%%%%ONLY FOR TESTING
%             if bb==1
%             ecg2csv(tmp_elem,[directory_name filename ...
%                     '_ECG_cropped_Stim' char(ss+64) ...
%                     '_Block' num2str(bb) '.csv']);
%             end
%%%%%%%%%%%%%%%%%%%%%%%%%%
        end %Blocks
    end %Stim
    
    %Step 5: Extract "post" block (very last 20 seconds)
    totalSamples=get(cropped_elem,'NSamples');
    tmp_elem = crop(cropped_elem,...
                    totalSamples-intervalSamples,totalSamples);
    theData = dataSource;
    if exist('rawData','var')
        theData = setRawData(theData,rawData);
    else
        theData = unlock(theData);
    end
    lastECG = addStructuredData(theData,tmp_elem);
    clear theData
    
    
end

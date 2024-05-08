function splitECGByBlock()
%Break a raw ECG file into several ECG structured files
%
% splitECGByBlock() break a raw ECG file into several ECG
%structured files according to a certain partition.
%
% 
%
% Copyright 2009
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also rawData_BioHarnessECG, ecg, dataSource
%
%


srcDir='../BioHarness/experimentalData/NN_CroppedHRdata/';
destDir=srcDir;


partition=[3750, 8749; ...
    8750, 13749; ...
    26250, 31249; ...
    43750, 48749; ...
    61250, 66249; ...
    78750, 83749]; %First row represents rest!
nBlocks=size(partition,1);

files = dir([srcDir 'NN*_RawECG.csv']);

nFiles=length(files);
%Subject 25 is failing
for ff=22:nFiles
    FileName=files(ff).name;
    disp([datestr(now,13) ': ' FileName])
    
    rawData=rawData_BioHarnessECG;
    rawData=import(rawData,[srcDir, FileName]);
    structuredD=convert(rawData);
    structuredD=set(structuredD,'Description','Raw_Block');

%     for bb=1:nBlocks
%         %Crop the block of interest
%         initIdx=partition(bb,1);
%         endIdx=partition(bb,2);
%         sd=crop(structuredD,initIdx,endIdx);
%         
%         dsHR=dataSource;
%         dsHR=setRawData(dsHR,rawData);
%         dsHR=addStructuredData(dsHR,sd);
%         
%         suffix=['_' num2str(bb-1)];
%         if bb==1
%             suffix='_r';
%         end
%         save([destDir FileName(1:end-4) suffix '.mat'],'dsHR');
%     end

    %and post rest using the last 20 secs
    %%%Note that for this block I do not know in advance the
    %%%sample bounding the partition, but I must catch it
    %%%on the fly.
    initIdx=get(structuredD,'NSamples')...
            -20*get(structuredD,'SamplingRate');
    endIdx=get(structuredD,'NSamples');
    sd=crop(structuredD,initIdx,endIdx);
    
    dsHR=dataSource;
    dsHR=setRawData(dsHR,rawData);
    dsHR=addStructuredData(dsHR,sd);
    
    suffix=['_p'];
    save([destDir FileName(1:end-4) suffix '.mat'],'dsHR');
    
end
disp([datestr(now,13) ': Done.'])
        
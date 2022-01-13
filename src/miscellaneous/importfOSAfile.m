function obj=importfOSAfile(obj,filename)
%IMPORTFOSAFILE Import an fOSA file 
%
% obj=importfOSAfile(obj,filename) Import data from an fOSA file
%   to the object obj. All the file contents is considered to be
%   data belonging to a certain experimental session.
%       * If the obj is an experiment:
%           It will add a new subject to the experiment, and
%           a new session to the subject. 
%       * If the obj is an subject:
%           It will add a new session to the subject. The name
%           of the subject will be update to the value stored
%           at fOSA_info.subjname
%       * If the obj is an session:
%           Existing obj data will be deleted and substited
%           with the imported data. However the ID will still
%           be maintained.
%       * If the obj is an dataSource:
%           The object is overwritten with the information
%           imported from the fOSA file.
%
%
%--------------------
% About fOSA
%--------------------
%
% fOSA (functional Optical Signal Analysis) is an application
%developed by Peck Hui Koh from the Dept. of Medical
%Physics at UCL (University College London).
%
% It is a MATLAB based software for applying standard processing
%to fNIRS data. It has been widely used by our group. And thus
%this method.
%
%fOSA stores its data in a '.mat' file in MATLAB format. As per
%fOSA version 2.1, this file contains the following variables
%
% Variable name | Size                          | Description
% --------------+-------------------------------+--------------
% fOSA_info     | struct                        | Some parameters
% format_data   |<nSamples x nChannelsx2+1 x 4> | Raw light intensity data
% hb_data       |<nSamples x nChannels+1 x 4>   | Converted unprocessed data
% filter_data   |<nSamples x nChannels+1 x 4>   | Filtered data
% detrend_data  |<nSamples x nChannels+1 x 4>   | Filtered + Detrended data
% average_data  |<nSamples x nChannels+1 x 4>   | Filtered + Detrended + Averaged across blocks data
%
%
% * 4 is the number of signals stored (HbO2, HHb, HbT, HbDiff)
% * Timeline is the extra column in the second dimension
% * fOSA does not make any integrity check
%
%=======
% REMARKS:
%=======
%
% No effort is currently made in checking whether the file is
% an original fOSA data file. This is simply assumed
% to be true.
%
%=======
%PARAMETERS:
%=======
% filename - The fOSA data file to import
%
% 
% Copyright 2008
% date: 13-Jun-2008
% Author: Felipe Orihuela-Espina
%
% See also experiment, subject, session, dataSource, setRawData
%

if (nargin==1)
    obj=dataSource;
end

if ~(isa(obj,'experiment') || isa(obj,'subject') ...
        || isa(obj,'session') || isa(obj,'dataSource'))
    error(['Parameter obj must be an experiment, ' ...
            'subject, session or dataSource.']);
end
    

barProgress=0;
h = waitbar(barProgress,'Importing fOSA data - 0%');

s=dataSource;

% Open the fOSA file
if (~exist(filename, 'file'))
    error('Unable to read %s\n', filename);
    return
else
    load(filename);
end

%% Import the Raw Data
%fOSA does not store the original device from which the raw
%data was recorded, so I simply asumed to be the ETG-4000
raw=format_data;
raw(:,end)=[];
marks=format_data;
marks(:,1:end-1)=[];
r=rawData_ETG4000;
r=set(r,'lightRawData',raw);
r=set(r,'marks',marks);
s=setRawData(s,r);

%% Import the images
for ii=1:4
    flag=true;
    switch(ii)
        case 1
            if (exist('hb_data','var'))
                currImg=hb_data;
                imgDescription='hb_data';
            else
                flag=false;
            end
        case 2
            if (exist('filter_data','var'))
                currImg=filter_data;
                imgDescription='filter_data';
            else
                flag=false;
            end
        case 3
            if (exist('detrend_data','var'))
                currImg=detrend_data;
                imgDescription='detrend_data';
            else
                flag=false;
            end
        case 4
            if (exist('average_data','var'))
                currImg=average_data;
                imgDescription='average_data';
            else
                flag=false;
            end
    end

    if (flag)

        %Discard timelines and signals other than HbO2 and HHb
        imageData=currImg(:,1:end-1,1:2);
        barProgress=barProgress+1/15; %5 images x 3 stages =15
        waitbar(barProgress,h,['Importing fOSA data - ' ...
            num2str(barProgress*100) '%']);

        %Timeline
        %get the timeline marks from the last column of the second dim
        marks=squeeze(currImg(:,end,1));
        theTimeline=convertToTimeline (marks);
        barProgress=barProgress+1/15;
        waitbar(barProgress,h,['Importing fOSA data - ' ...
            num2str(barProgress*100) '%']);

        %Finally generate the image
        nimg=nirs_neuroimage;
        nimg=set(nimg,'ID',ii);
        nimg=set(nimg,'Description',imgDescription);
        nimg=set(nimg,'Data',imageData);
        nimg=set(nimg,'Timeline',theTimeline);
        barProgress=barProgress+1/15;
        waitbar(barProgress,h,['Importing fOSA data - ' ...
            num2str(barProgress*100) '%']);

        %...and assign it to the dataSource
        s=addStructuredData(s,nimg);
        s=set(s,'ActiveStructured',ii);
        
    end %flag
end
%If possible, set the active image to the detrended (not averaged) data
if (exist('detrend_data','var'))
    s=set(s,'ActiveStructured',3); 
end

waitbar(1,h);
close(h);

%Finally save the results onto obj
data=dataSource(s);
if (isa(obj,'experiment'))
    %Add a new session definition to the experiment
    existingElements=getSessionDefinitionList(obj);
    if (isempty(existingElements))
        newId=1;
    else
        newId=max(existingElements)+1;
    end
    sdef=sessionDefinition(newId);
    tmpDSD=dataSourceDefinition(newId,'nirs_neuroimage');
    sdef=addSource(sdef,tmpDSD);
    obj=addSessionDefinition(obj,sdef);
    
    %Add a new dataSource to a new session with the given definition
    sess=session(sdef);
    sess=addDataSource(sess,data);
    %Add a new session to a new subject
    subj=subject();
    subj=addSession(subj,sess);
    
    %Add the new subject to the experiment
    existingElements=getSubjectList(obj);
    if (isempty(existingElements))
        newId=1;
    else
        newId=max(existingElements)+1;
    end
    subj=set(subj,'ID',newId);
    subj=set(subj,'Name',fOSA_info.subjname);
    obj=addSubject(obj,subj);

elseif (isa(obj,'subject'))
    %Add a new session to the subject
    existingElements=getSessionList(obj);
    if (isempty(existingElements))
        newId=1;
    else
        newId=max(existingElements)+1;
    end
    sdef=sessionDefinition;
    tmpDSD=dataSourceDefinition(newId,'nirs_neuroimage');
    sdef=addSource(sdef,tmpDSD);
    sess=session(sdef);
    
    %Add a new dataSource to a new session
    sess=addDataSource(sess,data);

    obj=addSession(obj,sess);
    obj=set(obj,'Name',fOSA_info.subjname);
elseif (isa(obj,'session'))
    %The session needs to permit a nirs_neuroimage dataSource
    %so when the new datasource is added, then it comply with the
    %session definition.
    def=get(obj,'Definition');
    idSources=getSourceList(def);
    doImport=true;
    if (isempty(idSources))
        warning('ICNA:importfOSAfile:NotSuitableDefinition',...
            ['Session definition is not suitable for ' ...
            'a nirs_neuroimage. Please ensure that the definition '...
            'is appropriate before importing the data.']);
        doImport=false;
    else
        found=false;
        for ss=idSources
            if (strcmp(get(getSource(def,ss),'Type'),'nirs_neuroimage'))
                dataSourceId=ss;
                found=true;
                break;
            end
        end
        if (~found)
            doImport=false;
        else
            warning('ICNA:importfOSAfile:DataOverwrite',...
                ['Session definition contains a suitable source ' ...
                'for a nirs_neuroimage. Data will be overwritten ' ...
                'for this source.']);
        end

    end

    if (doImport)
        %Add a new dataSource to the session
        data=set(data,'ID',dataSourceId);
        obj=addDataSource(obj,data);
    end

elseif (isa(obj,'dataSource'))
    tmpId=get(obj,'ID');
    obj=data;
    obj=set(obj,'ID',tmpId);
end




end

%%==================================
%% AUXILIAR FUNCTIONS
%%==================================
function theTimeline=convertToTimeline (marks)
%Take a set of marks and convert them into a timeline
nSamples=length(marks);
theTimeline=timeline(nSamples);
conds=sort(unique(marks));
conds(1)=[]; %Remove the 0;
tags='ABCDEFGHIJ'; %The ETG-4000 only admits until condition J
for cc=conds
    idx=find(marks==cc);
    onsets=idx(1:2:end);
    durations=idx(2:2:end)-onsets;
    stim=[onsets durations];
    theTimeline=addCondition(theTimeline,tags(cc),stim);
end
end
function obj=getFeatureSpace(obj)
%ANALYSIS/GETFEATURESPACE Converts the object's Experiment Space to a Feature space matrix
%
% function obj=getFeatureSpace(obj) Converts the object's 
%   Experiment Space to a Feature space matrix.
%
%Converts the object Experiment Space F into a
%Feature Space (indexes I and feature vectors H by concatenating
%points appropriately).
%
%
%----------------------
% Remarks
%----------------------
% Running this function requires that the Experiment Space
%has been computed. Otherwise an error with id
%'ICNA:analysis:getFeatureSpace:ExperimentSpaceNotComputed'
%will be generated.
%
%Running this function will overwrite attributes H and I.
%
%
%Output:
%-------
% H - The Feature Space matrix
%   Each column represents a feature or dimension in the Feature Space
%   and each row represents a point/pattern in the input space.
%   The number of dimensions or features will depend on how the
%   Experiment Space was computed and how the signals and channels
%   will be grouped together.
%
% I - The Indexes matrix
% 
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also analysis, experimentSpace, cluster, run
%




%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This method had
%   not been updated since creation.
%
% 8-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%
%
% 11-Jun-2023: FOE
%   + Method moved from folder private/ to main class folder and explictly
%   declared as private in the class definition.
%




tmp = obj.F;
if (isempty(tmp) || ~tmp.runStatus)
    error('ICNA:analysis:getFeatureSpace:ExperimentSpaceNotComputed',...
        'The Experiment Space has not been computed.')
end

if (isempty(obj.signalDescriptors) || isempty(obj.channelGrouping))
        obj.H=zeros(0,0); 
        obj.I=zeros(0,5);
        warning('ICNA:analysis:getFeatureSpace:EmptyAnalysis',...
            ['Empty analysis. Please check signal descriptors '...
             'and channel grouping.']);
        return
end



%Current version only accepts data coming from one single
%source.

theDataSource=obj.signalDescriptors(1,1);

tmpStruct.dimension=obj.F.DIM_DATASOURCE;
tmpStruct.values=theDataSource;
subsetDefinition={tmpStruct};

%Filter subjects and sessions if required
if ~isempty(obj.subjectsIncluded)
    tmpStruct.dimension=obj.F.DIM_SUBJECT;
    tmpStruct.values=obj.subjectsIncluded;
    subsetDefinition(end+1)={tmpStruct};
end
if ~isempty(obj.sessionsIncluded)
    tmpStruct.dimension=obj.F.DIM_SESSION;
    tmpStruct.values=obj.sessionsIncluded;
    subsetDefinition(end+1)={tmpStruct};
end

%% Obtain Findex and Fvectors
[Findex,Fvectors]=getSubset(obj.F,subsetDefinition);

nSubjects=length(unique(Findex(:,obj.F.DIM_SUBJECT)));
nSessions=length(unique(Findex(:,obj.F.DIM_SESSION)));
nStimulus=length(unique(Findex(:,obj.F.DIM_STIMULUS))); %Stimulus may be
        %be different across sessions...but just to allocate
        %space
nBlocks=length(unique(Findex(:,obj.F.DIM_BLOCK)));
nChannelGroups=size(obj.channelGrouping,1);

nPatterns=nSubjects*nSessions*nStimulus*nBlocks*nChannelGroups;
%Note that this is an overestimation, as not all combinations
%may be present in the Experiment Space.


%Selected signals are determined by the dataSource and the
%signal IDs (note that the structuredData can be ignored
%since only one structuredData i.e. the active structuredData
%produces entries in the experimentSpace.
nSignals=size(obj.signalDescriptors,1);
signals=obj.signalDescriptors(:,2)';
                    
nChannelsPerGroup=size(obj.channelGrouping,2); %All groups must have
    %the same number of channels.
nNecessaryFPoints=nChannelsPerGroup*nSignals; %This is the number
    %of points in the Experiment Space that yields a single pattern
    %in the Feature Space. To be able to construct the pattern,
    %all points must be available.

%Allocating spaces
obj.H=zeros(nPatterns,0); %MxN features: signal1@ch1,...,signalM@chN
obj.I=zeros(nPatterns,5); %5D: Subjects, Sessions, Stimulus, Blocks,
                        %and ChannelGroups

                        
%%Converts the matrix
%disp('Converting matrix...')
subjects=unique(Findex(:,obj.F.DIM_SUBJECT))';
pos=1;
flagFirstPoint=true; %To get the number of features on the fly...
for subj=subjects
    idxSubj=find(Findex(:,obj.F.DIM_SUBJECT)==subj);
    sessions=unique(Findex(idxSubj,obj.F.DIM_SESSION))';
    for sess=sessions
        idxSess=find(Findex(:,obj.F.DIM_SUBJECT)==subj ...
                   & Findex(:,obj.F.DIM_SESSION)==sess);
        stimulus=unique(Findex(idxSess,obj.F.DIM_STIMULUS))';
        for stim=stimulus
            idxStim=find(Findex(:,obj.F.DIM_SUBJECT)==subj ...
                       & Findex(:,obj.F.DIM_SESSION)==sess...
                       & Findex(:,obj.F.DIM_STIMULUS)==stim);
            blocks=unique(Findex(idxStim,obj.F.DIM_BLOCK))';
            for block=blocks
                idxBlock=find(Findex(:,obj.F.DIM_SUBJECT)==subj ...
                           & Findex(:,obj.F.DIM_SESSION)==sess...
                           & Findex(:,obj.F.DIM_STIMULUS)==stim...
                           & Findex(:,obj.F.DIM_BLOCK)==block);
                for chGroup=1:nChannelGroups
                    channels=obj.channelGrouping(chGroup,:);
                    idx=find(Findex(:,obj.F.DIM_SUBJECT)==subj ...
                           & Findex(:,obj.F.DIM_SESSION)==sess...
                           & Findex(:,obj.F.DIM_STIMULUS)==stim...
                           & Findex(:,obj.F.DIM_BLOCK)==block...
                           & ismember(Findex(:,obj.F.DIM_CHANNEL),channels)...
                           & ismember(Findex(:,obj.F.DIM_SIGNAL),signals))';
                      
                      if (size(Findex(idx,:),1) == nNecessaryFPoints)
                          %Insert this points
                          
                          tmpIdxVector=zeros(1,5);
                          tmpIdxVector(obj.COL_CHANNELGROUP)=chGroup;
                          tmpIdxVector(obj.COL_BLOCK)=block;
                          tmpIdxVector(obj.COL_STIMULUS)=stim;
                          tmpIdxVector(obj.COL_SESSION)=sess;
                          tmpIdxVector(obj.COL_SUBJECT)=subj;

                          try
                            tmpFeatureVector=horzcat(Fvectors{idx});
                          catch ME
                            tmpFeatureVector=vertcat(Fvectors{idx});
                          end
                          tmpFeatureVector=reshape(tmpFeatureVector,...
                                        1,numel(tmpFeatureVector));
                          if (flagFirstPoint)
                              flagFirstPoint=false;
                              nFeatures=length(tmpFeatureVector);
                              obj.H=zeros(nPatterns,nFeatures);
                          end
                          %I need all vectors to have the same number
                          %of features
                          if (length(tmpFeatureVector)==nFeatures)
                            obj.I(pos,:)=tmpIdxVector;
                            obj.H(pos,:)=tmpFeatureVector;
                            pos=pos+1;
                          else
                              error(['Unbalanced number of features ' ...
                                 'accross points. Try to either ' ...
                                 'change analysis parameters or '...
                                 'recompute the Experiment Space with '...
                                 'a different configuration.']);
                          end
                          
                      else
                          %skip this point
                          disp('Unexpected number of points. Skipping pattern.');
                          %%Do nothing
                      end
                    
                end
            end
        end
    end
end



%Remove those last unnecessary rows
obj.H(pos:end,:)=[];
obj.I(pos:end,:)=[];

%Just a check
assert(all(all(obj.I~=0)),...
    'analysis:getFeatureSpace: Unexpected index value.');


end
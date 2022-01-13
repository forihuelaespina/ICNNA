function obj=normalize(obj)
% EXPERIMENTSPACE/NORMALIZE Normalize the space with current configuration
%
% obj=normlize(obj) Normalize the space with current normalization
%   parameters.
%
%
%% Remarks
%
%Running this method will set the 'Normalized' property to true.
%
%For more information on the normalization options please refer
%to class general documentation (See experimentSpace).
%
%This function is called by method compute, and uses the generic
%function util/normalize.
%
%
%
% Copyright 2009
% @date: 5-Jun-2009
% @author Felipe Orihuela-Espina
%
% See also experimentSpace, compute, util/normalize
%


method=get(obj,'NormalizationMethod');
switch (method)
    case 'normal'
        params=[get(obj,'NormalizationMean') ...
                get(obj,'NormalizationVar')];
    case 'range'
        params=[get(obj,'NormalizationMin') ...
                get(obj,'NormalizationMax')];
    otherwise
        error('ICNA:experimentSpace:normalize:UnexpectedMethod',...
            'Unexpected normalization method.');
end

%Convert Fvectors from cell to a matrix form
%%%since window selection is now compulsory, all vectors will
%%%have the same length

nPoints=length(obj.Fvectors);
% for ii=1:nPoints
%     tmpFvectors(ii,:)=obj.Fvectors{ii};
% end
tmpFvectors=cell2mat(obj.Fvectors)';

switch (get(obj,'NormalizationScope'))
    case 'blockindividual'
        switch (get(obj,'NormalizationDimension'))
            case 'channel'
                tmpFvectors=normalize_BlockIndividual_ByChannel(obj.Findex,...
                                        tmpFvectors,method,params);
            case 'signal'
                tmpFvectors=normalize_BlockIndividual_BySignal(obj.Findex,...
                                        tmpFvectors,method,params);                
            case 'combined'
                tmpFvectors=normalize_BlockIndividual_Combined(obj.Findex,...
                                        tmpFvectors,method,params);                
            otherwise
                error('ICNA:experimentSpace:normalize:UnexpectedDimension',...
                    'Unexpected normalization direction.');
        end
    case 'individual'
        switch (get(obj,'NormalizationDimension'))
            case 'channel'
                tmpFvectors=normalize_Individual_ByChannel(obj.Findex,...
                                        tmpFvectors,method,params);
            case 'signal'
                tmpFvectors=normalize_Individual_BySignal(obj.Findex,...
                                        tmpFvectors,method,params);                
            case 'combined'
                tmpFvectors=normalize_Individual_Combined(obj.Findex,...
                                        tmpFvectors,method,params);                
            otherwise
                error('ICNA:experimentSpace:normalize:UnexpectedDimension',...
                    'Unexpected normalization direction.');
        end
    case 'collective'
        switch (get(obj,'NormalizationDimension'))
            case 'channel'
                tmpFvectors=normalize_Collective_ByChannel(obj.Findex,...
                                        tmpFvectors,method,params);
            case 'signal'
                tmpFvectors=normalize_Collective_BySignal(obj.Findex,...
                                        tmpFvectors,method,params);                
            case 'combined'
                tmpFvectors=normalize_Collective_Combined(obj.Findex,...
                                        tmpFvectors,method,params);                
            otherwise
                error('ICNA:experimentSpace:normalize:UnexpectedDimension',...
                    'Unexpected normalization direction.');
        end
        
    otherwise
        error('ICNA:experimentSpace:normalize:UnexpectedScope',...
            'Unexpected normalization scope.');
end

%Restitute Fvectors as a cell matrix
for ii=1:nPoints
    obj.Fvectors(ii)={tmpFvectors(ii,:)'};
end

obj=set(obj,'Normalized',true);
assertInvariants(obj);

end

%% AUXILIAR FUNCTIONS
%% Scope BlockIndividual; Dimension Channel
function fvectors=normalize_BlockIndividual_ByChannel(findex,...
                                    fvectors,method,params)
%Normalization of individual scope and dimension by channel

subjects = unique(findex(:,experimentSpace.DIM_SUBJECT))';
for subj=subjects
    tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj);
    sessions = unique(findex(tmpIdx,experimentSpace.DIM_SESSION))';
    for sess=sessions
        tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
             & findex(:,experimentSpace.DIM_SESSION)==sess);
        
        stimulus = unique(findex(tmpIdx,experimentSpace.DIM_STIMULUS))';
        for stim=stimulus
            tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                & findex(:,experimentSpace.DIM_SESSION)==sess ...
                & findex(:,experimentSpace.DIM_STIMULUS)==stim);
            
            %One normalization per channel
            channels=unique(findex(tmpIdx,experimentSpace.DIM_CHANNEL))';
            for ch=channels
                idx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_CHANNEL)==ch);
                    
                fvectors(idx,:)=normalize(fvectors(idx,:),1,method,params);                
            end
        end
    end
end
end

%% Scope BlockIndividual; Dimension Signal
function fvectors=normalize_BlockIndividual_BySignal(findex,...
                                    fvectors,method,params)
%Normalization of individual scope and dimension by signal

subjects = unique(findex(:,experimentSpace.DIM_SUBJECT))';
for subj=subjects
    tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj);
    sessions = unique(findex(tmpIdx,experimentSpace.DIM_SESSION))';
    for sess=sessions
        tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
            & findex(:,experimentSpace.DIM_SESSION)==sess);
        
        stimulus = unique(findex(tmpIdx,experimentSpace.DIM_STIMULUS))';
        for stim=stimulus
            tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                & findex(:,experimentSpace.DIM_SESSION)==sess ...
                & findex(:,experimentSpace.DIM_STIMULUS)==stim);
            
            %One normalization per signal (i.e. pair <source,signal>)
            dataSources=unique(findex(tmpIdx,experimentSpace.DIM_DATASOURCE))';
            for ds=dataSources
                tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds);
            signals=unique(findex(tmpIdx,experimentSpace.DIM_SIGNAL))';
            for ss=signals
                idx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
                        & findex(:,experimentSpace.DIM_SIGNAL)==ss);
                    
                fvectors(idx,:)=normalize(fvectors(idx,:),1,method,params);                
            end
            end
        end
    end
end
end

%% Scope BlockIndividual; Dimension Combined
function fvectors=normalize_BlockIndividual_Combined(findex,...
                                    fvectors,method,params)
%Normalization of individual scope and dimension combined

subjects = unique(findex(:,experimentSpace.DIM_SUBJECT))';
for subj=subjects
    tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj);
    sessions = unique(findex(tmpIdx,experimentSpace.DIM_SESSION))';
    for sess=sessions
        tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
            & findex(:,experimentSpace.DIM_SESSION)==sess);
        
        stimulus = unique(findex(tmpIdx,experimentSpace.DIM_STIMULUS))';
        for stim=stimulus
            tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                & findex(:,experimentSpace.DIM_SESSION)==sess ...
                & findex(:,experimentSpace.DIM_STIMULUS)==stim);
            
            %One normalization per signal (i.e. pair <source,signal>)
            dataSources=unique(findex(tmpIdx,experimentSpace.DIM_DATASOURCE))';
            for ds=dataSources
                tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds);
            signals=unique(findex(tmpIdx,experimentSpace.DIM_SIGNAL))';
            for ss=signals
                tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
                        & findex(:,experimentSpace.DIM_SIGNAL)==ss);
            channels=unique(findex(tmpIdx,experimentSpace.DIM_CHANNEL))';
            for ch=channels
                idx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
                        & findex(:,experimentSpace.DIM_SIGNAL)==ss ...
                        & findex(:,experimentSpace.DIM_CHANNEL)==ch);
                    
                fvectors(idx,:)=normalize(fvectors(idx,:),1,method,params);                
            end
            end
            end
        end
    end
end
end


%% Scope Individual; Dimension Channel
function fvectors=normalize_Individual_ByChannel(findex,fvectors,...
                                            method,params)
%Normalization of individual scope and dimension by channel

subjects = unique(findex(:,experimentSpace.DIM_SUBJECT))';
for subj=subjects
    tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj);
    sessions = unique(findex(tmpIdx,experimentSpace.DIM_SESSION))';
    for sess=sessions
        tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
             & findex(:,experimentSpace.DIM_SESSION)==sess);
        
        stimulus = unique(findex(tmpIdx,experimentSpace.DIM_STIMULUS))';
        for stim=stimulus
            tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                & findex(:,experimentSpace.DIM_SESSION)==sess ...
                & findex(:,experimentSpace.DIM_STIMULUS)==stim);
            
            %One normalization per channel
            channels=unique(findex(tmpIdx,experimentSpace.DIM_CHANNEL))';
            for ch=channels
                idx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_CHANNEL)==ch);
                    
                fvectors(idx,:)=normalize(fvectors(idx,:),method,params);                
            end
        end
    end
end
end

%% Scope Individual; Dimension Signal
function fvectors=normalize_Individual_BySignal(findex,fvectors,...
                                            method,params)
%Normalization of individual scope and dimension by signal

subjects = unique(findex(:,experimentSpace.DIM_SUBJECT))';
for subj=subjects
    tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj);
    sessions = unique(findex(tmpIdx,experimentSpace.DIM_SESSION))';
    for sess=sessions
        tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
            & findex(:,experimentSpace.DIM_SESSION)==sess);
        
        stimulus = unique(findex(tmpIdx,experimentSpace.DIM_STIMULUS))';
        for stim=stimulus
            tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                & findex(:,experimentSpace.DIM_SESSION)==sess ...
                & findex(:,experimentSpace.DIM_STIMULUS)==stim);
            
            %One normalization per signal (i.e. pair <source,signal>)
            dataSources=unique(findex(tmpIdx,experimentSpace.DIM_DATASOURCE))';
            for ds=dataSources
                tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds);
            signals=unique(findex(tmpIdx,experimentSpace.DIM_SIGNAL))';
            for ss=signals
                idx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
                        & findex(:,experimentSpace.DIM_SIGNAL)==ss);
                    
                fvectors(idx,:)=normalize(fvectors(idx,:),method,params);                
            end
            end
        end
    end
end
end

%% Scope Individual; Dimension Combined
function fvectors=normalize_Individual_Combined(findex,fvectors,...
                                            method,params)
%Normalization of individual scope and dimension combined

subjects = unique(findex(:,experimentSpace.DIM_SUBJECT))';
for subj=subjects
    tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj);
    sessions = unique(findex(tmpIdx,experimentSpace.DIM_SESSION))';
    for sess=sessions
        tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
            & findex(:,experimentSpace.DIM_SESSION)==sess);
        
        stimulus = unique(findex(tmpIdx,experimentSpace.DIM_STIMULUS))';
        for stim=stimulus
            tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                & findex(:,experimentSpace.DIM_SESSION)==sess ...
                & findex(:,experimentSpace.DIM_STIMULUS)==stim);
            
            %One normalization per triplet (i.e. pair <source,signal,channel>)
            dataSources=unique(findex(tmpIdx,experimentSpace.DIM_DATASOURCE))';
            for ds=dataSources
                tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds);
            signals=unique(findex(tmpIdx,experimentSpace.DIM_SIGNAL))';
            for ss=signals
                tmpIdx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
                        & findex(:,experimentSpace.DIM_SIGNAL)==ss);
            channels=unique(findex(tmpIdx,experimentSpace.DIM_CHANNEL))';
            for ch=channels
                idx=find(findex(:,experimentSpace.DIM_SUBJECT)==subj ...
                        & findex(:,experimentSpace.DIM_SESSION)==sess ...
                        & findex(:,experimentSpace.DIM_STIMULUS)==stim ...
                        & findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
                        & findex(:,experimentSpace.DIM_SIGNAL)==ss ...
                        & findex(:,experimentSpace.DIM_CHANNEL)==ch);
                    
                fvectors(idx,:)=normalize(fvectors(idx,:),method,params);                
            end
            end
            end
        end
    end
end
end

%% Scope Collective; Dimension Channel
function fvectors=normalize_Collective_ByChannel(findex,fvectors,...
                                            method,params)
%Normalization of collective scope and dimension by channel

%One normalization per channel
channels=unique(findex(:,experimentSpace.DIM_CHANNEL))';
for ch=channels
    idx=find(findex(:,experimentSpace.DIM_CHANNEL)==ch);
    fvectors(idx,:)=normalize(fvectors(idx,:),method,params);
end

end

%% Scope Collective; Dimension Signal
function fvectors=normalize_Collective_BySignal(findex,fvectors,...
                                            method,params)
%Normalization of collective scope and dimension by signal

%One normalization per signal (i.e. pair <source,signal>)
dataSources=unique(findex(:,experimentSpace.DIM_DATASOURCE))';
for ds=dataSources
    tmpIdx=find(findex(:,experimentSpace.DIM_DATASOURCE)==ds);
    signals=unique(findex(tmpIdx,experimentSpace.DIM_SIGNAL))';
    for ss=signals
        idx=find(findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
               & findex(:,experimentSpace.DIM_SIGNAL)==ss);
        fvectors(idx,:)=normalize(fvectors(idx,:),method,params);
    end
end

end

%% Scope Collective; Dimension Combined
function fvectors=normalize_Collective_Combined(findex,fvectors,...
                                            method,params)
%Normalization of collective scope and dimension combined

%One normalization per triplet (i.e. pair <source,signal,channel>)
dataSources=unique(findex(:,experimentSpace.DIM_DATASOURCE))';
for ds=dataSources
    tmpIdx=find(findex(:,experimentSpace.DIM_DATASOURCE)==ds);
    signals=unique(findex(tmpIdx,experimentSpace.DIM_SIGNAL))';
    for ss=signals
        tmpIdx=find(findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
            & findex(:,experimentSpace.DIM_SIGNAL)==ss);
        channels=unique(findex(tmpIdx,experimentSpace.DIM_CHANNEL))';
        for ch=channels
            idx=find(findex(:,experimentSpace.DIM_DATASOURCE)==ds ...
                & findex(:,experimentSpace.DIM_SIGNAL)==ss ...
                & findex(:,experimentSpace.DIM_CHANNEL)==ch);
            fvectors(idx,:)=normalize(fvectors(idx,:),method,params);
        end
    end
end
end

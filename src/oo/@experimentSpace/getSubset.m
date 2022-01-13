function [Findex,Fvectors]=getSubset(obj,s)
% EXPERIMENTSPACE/GETSUBSET Access to a subset of points in the space
%
% [Findex,Fvectors]=getSubset(obj,subsetDefinition) Access to a
%   subset of points of the Experiment Space.
%
% Parameter subsetDefinition is a cell matrix of structs.
%Each position of the cell matrix (struct) has 2 fields:
%   .dimension - Dimension for filtering
%   .values - Values
%
% It is strongly recommended that you use the constant
%dimension descriptors provided by the class e.g. DIM_SUBJECT,
%to refer to the dimension.
%
%Not every dimension of the experiment space needs to be
%defined, nor they need to be indicated in any particular order,
%but only one set of values can be indicated for each dimension of
%the Experiment Space. By not defining a particular value
%for one or more dimensions, it is possible to access to more
%than one point at a time. The limit case is when subsetDefinition
%is an empty matrix, hence the whole cloud of points in the Experiment
%Space will be returned.
%
%
%   +===========================================+
%   |   Even if subsetDefinition is empty, it   |
%   | still must be passed to the function.     |
%   +===========================================+
%
%
%
%
% Copyright 2008
% @date: 18-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also experimentSpace, compute
%

if (isempty(s))
    Findex=obj.Findex;
    Fvectors=obj.Fvectors;
    return
end

%Check the validity of the input parameter s
if ~iscell(s)
    error('ICNA:experimentSpace:getSubset:InvalidParameter',...
        'Invalid parameter subsetDefinition.')
end
dims=zeros(1,0); %dimension descriptors
for ii=1:length(s)
    tmpStruct=s{ii};
    if ~(isstruct(tmpStruct) && isfield(tmpStruct,'dimension') ...
            && isfield(tmpStruct,'values'))
        error('ICNA:experimentSpace:getSubset:InvalidParameter',...
            'Invalid parameter subsetDefinition.')
    end
    
    dims=[dims tmpStruct.dimension];
end
dims=dims';
if (any(dims<1) || any(dims>=obj.DIM_BLOCK))
     error('ICNA:experimentSpace:getSubset:UndefinedDimension',...
        'Undefined dimension within space.')
end


%Get the indexes of the subset of points
idx=[];
switch (length(dims))
    case 1
        idx=find(ismember(obj.Findex(:,dims(1)),s{1}.values));

    case 2
        idx=find(ismember(obj.Findex(:,dims(1)),s{1}.values) ...
               & ismember(obj.Findex(:,dims(2)),s{2}.values));
    case 3
        idx=find(ismember(obj.Findex(:,dims(1)),s{1}.values) ...
               & ismember(obj.Findex(:,dims(2)),s{2}.values) ...
               & ismember(obj.Findex(:,dims(3)),s{3}.values));

    case 4
        idx=find(ismember(obj.Findex(:,dims(1)),s{1}.values) ...
               & ismember(obj.Findex(:,dims(2)),s{2}.values) ...
               & ismember(obj.Findex(:,dims(3)),s{3}.values) ...
               & ismember(obj.Findex(:,dims(4)),s{4}.values));

    case 5
        idx=find(ismember(obj.Findex(:,dims(1)),s{1}.values) ...
               & ismember(obj.Findex(:,dims(2)),s{2}.values) ...
               & ismember(obj.Findex(:,dims(3)),s{3}.values) ...
               & ismember(obj.Findex(:,dims(4)),s{4}.values) ...
               & ismember(obj.Findex(:,dims(5)),s{5}.values));

    case 6
        idx=find(ismember(obj.Findex(:,dims(1)),s{1}.values) ...
               & ismember(obj.Findex(:,dims(2)),s{2}.values) ...
               & ismember(obj.Findex(:,dims(3)),s{3}.values) ...
               & ismember(obj.Findex(:,dims(4)),s{4}.values) ...
               & ismember(obj.Findex(:,dims(5)),s{5}.values) ...
               & ismember(obj.Findex(:,dims(6)),s{6}.values));

    case 7
        idx=find(ismember(obj.Findex(:,dims(1)),s{1}.values) ...
               & ismember(obj.Findex(:,dims(2)),s{2}.values) ...
               & ismember(obj.Findex(:,dims(3)),s{3}.values) ...
               & ismember(obj.Findex(:,dims(4)),s{4}.values) ...
               & ismember(obj.Findex(:,dims(5)),s{5}.values) ...
               & ismember(obj.Findex(:,dims(6)),s{6}.values) ...
               & ismember(obj.Findex(:,dims(7)),s{7}.values));

    case 8 %currently there cannot be more than 8D!
        idx=find(ismember(obj.Findex(:,dims(1)),s{1}.values) ...
               & ismember(obj.Findex(:,dims(2)),s{2}.values) ...
               & ismember(obj.Findex(:,dims(3)),s{3}.values) ...
               & ismember(obj.Findex(:,dims(4)),s{4}.values) ...
               & ismember(obj.Findex(:,dims(5)),s{5}.values) ...
               & ismember(obj.Findex(:,dims(6)),s{6}.values) ...
               & ismember(obj.Findex(:,dims(7)),s{7}.values) ...
               & ismember(obj.Findex(:,dims(8)),s{8}.values));

    otherwise
     error('ICNA:experimentSpace:getSubset:UndefinedDimension',...
        'Unexpected dimension.')
end

%Now simply pick the subset...
Findex=obj.Findex(idx,:);
Fvectors=obj.Fvectors(idx);
function Y=mena_embedding(D,options)
%Computes an embedding or projection
%
% Y=mena_embedding(D,options) Computes an embedding or projection
%   starting from a matrix of pairwise distances.
%
%
%% Options
%
%   .projectionDimensionality -  Output dimensionality (scalar)
%       Default 2.
%
%   .embedding - Embedding/projection technique
%       1) 'none' - Do not perform embedding
%       2) 'cmds' - classical MDS (Default)
%       3) 'cca' - Curvilinear Component Analysis. If option
%                   is 'cca' then the data (Feature Space H) also
%                   must be provided.
%
%   .featureSpace - The Feature Space H. Only needed if embedding
%       is 'cca'. When 'cca' is the selected embedding this Option
%       is mandatory.
%
%   .verbose - You know this one... False (shut up!) by default.
%
%
%
%% Output
%
% Y - An MxK low dimensional coordinates (K<<N). A zeros(0,2) is returned
%       if embedding is set to 'none'
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also analysis, run, getFeatureSpace, mena_metric
%




%% Log
%
% File created: 25-Jul-2008
% File last modified (before creation of this log): N/A. This method had
%   not been updated since creation.
%
% 11-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Error codes updated from ICNA to ICNNA
%   + Method moved from folder private/ to main class folder and explictly
%   declared as static in the class definition.
%




%Deal with options
opt.projDim=2; %Output dimensionality
opt.embedding='cmds';
opt.H='';
opt.verbose=false;
if (exist('options','var'))
    if(isfield(options,'projectionDimensionality'))
        pD=options.projectionDimensionality;
        if (isscalar(pD) && isreal(pD) && ~ischar(pD) ...
                && floor(pD)==pD && pD>0)
            opt.projDim=pD;
        end
    end
    if(isfield(options,'embedding'))
        opt.embedding=lower(options.embedding);
    end
    if(isfield(options,'verbose'))
        opt.verbose=options.verbose;
    end
end

if (strcmp(opt.embedding,'cca'))
    assert(isfield(options,'featureSpace'),...
        'When using ''cca'' option .featureSpace must also be provided.');
    opt.H=options.featureSpace;
end


%=======================================
if (opt.verbose)
    disp([datestr(now,13) ': Now embedding -> ' opt.embedding]);
end

switch (opt.embedding)
    case 'none'
        Y=zeros(0,opt.projDim);
    case 'cmds' %Classical MDS
        Y=cmdscale(D);
        Y=Y(:,1:opt.projDim); %Take only the first N dimensions.
    case 'cca' %Curvilinear component analysis
        epochs = 10000;
        P= opt.projDim; %Output dimensionality (scalar) or
             %projection initialization (matrix)
        Y = cca(opt.H, P, epochs, D);
%     case 'lle' %Locally Linear Embedding
%         dmax=2; %Final dimensionality
%         k=12; %Number of neighbours
%         [Y,e]=mena_generalisedLLE(H',D,k,dmax);
%         Y=Y';
    otherwise
        error('ICNNA:analysis:mena_embedding:UnrecognisedTechnique',...
            'Invalid selection of embedding technique');
end




end


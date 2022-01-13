function A=normalize(A,varargin)
%Normalizes data matrix
%
% A=normalize(A) the matrix is normalized to zero mean and unit variance
%   across all dimensions at once.
%
% A=normalize(A,dim) the matrix is subdivided in hyperplanes along dim x,
%   and each submatrix is normalized to zero mean and unit variance
%   separately.
%
% A= normalize(...,'normal',[mu var]) the matrix is normalized to 
%   have mu mean and var variance.
%
% A= normalize(...,'range',[min max]) the matrix is normalized to range
%   between min and max. Common normalizations ranges are [0 1]
%   and/or [-1 1].
%
%
%
%% Algortithm
%
% If dim=[], then the matrix is normalized across all dimensions at once.
% If dim=x, the the matrix is subdivided in hyperplanes along dim x, and
%   each submatrix is normalized separately.
%
%
% If type is omitted, then normalization is to zero mean
%   and unit variance. If 'range' is specified, then the elements
%   are mapped to the interval [min max].
%
%% Parameters
%
% A - An n-dimensional matrix
%
% dim - Optional. Dimension across which to normalised.
%
% type and normalization parameters - Optionals. Type of
%   normalization and normalization parameters. By default
%   normalization is to zero mean and unit variance.
%           +'normal' normalization maps elements of A to mean 
%               and variance [mu var] respectively.
%           +'range' normalization maps elements of A to range
%               to the interval [min max], normally [0 1] or [-1 1]
%               but any range can be specified.
%
%% Output
%
% A - The normalized matrix
%
%
%
% Copyright 2009
% Date: 24-Apr-2009
% Author: Felipe Orihuela-Espina
%
% See also 
%


%%Deal with options
d=[]; %Dimension
type='normal'; %or 'range'
interval=[0 1]; %Either [mu var] for normal, or [min max] range

if ~isempty(varargin) && ~ischar(varargin{1})
    d=varargin{1};
    varargin(1)=[];
end
if ~isempty(varargin)
    type=varargin{1};
    interval=varargin{2};
end

assert(isempty(d) || (isscalar(d) && ~ischar(d) ...
                        && floor(d)==d && numel(d)==1 ...
                        && d>0),...
        'Invalid input for parameter dimension.');
assert(ischar(type),'Invalid input for parameter normalization type.');

if isempty(d)
    %Normalize the entire matrix at once
    sizeA=size(A);
    tmpA=reshape(A,1,numel(A));
    switch(type)
        case 'normal'
            %Normalize to zero mean and unit variance (default)
            assert(numel(interval)==2 && isreal(interval) ...
                && ~ischar(interval) ...
                && interval(2)>0,...
                'Invalid input for parameter [mean variance].');
            tmpA=(tmpA-mean(tmpA))/std(tmpA);
                %Note that the division is by the std, not by the
                %variance!!
                %A small rounding error may remain!
            %...and adjust to other mu and var if necessary
            mu=interval(1);
            v=interval(2);
            tmpA=(tmpA*v)+mu;
            
        case 'range'
            assert(numel(interval)==2 && isreal(interval) && ~ischar(interval) ...
                && interval(1)<interval(2),...
                'Invalid input for range parameter [min max].');
            tmpMin=min(tmpA);
            tmpMax=max(tmpA);
            %First normalize to [0 1]
            tmpA=(tmpA-tmpMin)/(tmpMax-tmpMin);
            %and then stretch to any given interval
            tmpMin=interval(1);
            tmpMax=interval(2);
            tmpA=(tmpA*(tmpMax-tmpMin))+tmpMin;
                    %Note that the min must be added, not substracted!!
        otherwise
            error('Unexpected normalization type.');
    end
    A=reshape(tmpA,sizeA);
else
    %Simply repeat for each submatrix
    S.type='()';
    S.subs=cell(1,ndims(A));
    nSubmatrices=size(A,d);
    for ii=1:nSubmatrices
        S.subs(1:end)={':'};
        S.subs(d)={ii};
        tmpA=squeeze(subsref(A, S));
        tmpA=normalize(tmpA,type,interval);
        A = subsasgn(A, S, tmpA);
    end
end
    
    
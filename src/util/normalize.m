function A=normalize(A,varargin)
%DEPRECATED. Normalizes data matrix
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
% Copyright 2009-25
% Date: 24-Apr-2009
% Author: Felipe Orihuela-Espina
%
% See also 
%



%% Log
%
% 31-Aug-2025: FOE
%   + Added this log
%   + Function deprecated since v1.3.1. This function now hides MATLAB's
%   own normalize function, hence it should be renamed or replaced.
%   

warning('ICNNA:util:normalized:Deprecated',...
        'DEPRECATED. Please use icnna_normalize instead.'); 

A=icnna_normalize(A,varargin{:});
end
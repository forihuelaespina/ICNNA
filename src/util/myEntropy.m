function e=myEntropy(X)
%Entropy of a signal
%
% e=myEntropy(X) Entropy of a signal
%
%
%   +==========================================+
%   | Substitute for MATLAB' sImage Processing |
%   |Toolbox function entropy.                 |
%   +==========================================+
%
%Entropy is a statistical measure of randomness.
%Shannon's entropy is defined as:
%
% -sum(p.*log2(p))
%
%where p contains the histogram counts.
%
%
%% Parameters
%
% X - A 1-D real-value signal (vector).
%       For 2-D (integer) signal see imgEmptropy
%
%% Output
%
% e - Entropy expressed in bits (base 2)
%
%
% Copyright note: some lines of code have been copied
%from MATLAB's original entropy function.
%
% @date: 26-Apr-2012
% @author: Felipe Orihuela-Espina
% @modified: 26-Apr-2012
%
% See also imgEntropy
%

%Ensure X is a signal vector
[r,c]=size(X);
if ~(r==1 || c==1)
    error('X must be a 1-D signal.');
end

% calculate histogram counts
nBins=ceil(sqrt(length(X))); %Bins in the histrogram
            %I got this way of computing the number of cells from
            %the function histogram by R. Moddemeijer
            %See also: http://www.cs.rug.nl/~rudy/matlab/
p=hist(X,nBins);

%%===================================================
%%%Code imported from MATLAB's original entropy function %%%%%
% remove zero entries in p 
p(p==0) = [];
% normalize p so that sum(p) is one.
p = p ./ length(X);

e = -sum(p.*log2(p)); %in bits
%e = -sum(p.*log(p)); %in nats

%%%END: Code imported from MATLAB's original entropy function %%%%%
%%===================================================
  



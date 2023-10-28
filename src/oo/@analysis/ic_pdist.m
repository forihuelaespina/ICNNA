function Y=ic_pdist(X,s)
%Pairwise distances between observations
%
% function Y=ic_pdist(X,d)
%
% Computes the distance between each pair of points in X according to
%a certain criterion.
%
%% Parameters:
%
% X - The MxN dataset. Rows represents different M signals. Columns
%represents different N time points or samples.
%
% s - Optional. The distance criterion. Choices are:
%
%       'kl' - Kullback-Leibler divergence
%       'js' - Jensen-Shannon divergence
%       'jsm'- Default. Square root of Jensen-Shannon divergence
%               based metric
%Note that whilst the Jensen-Shannon divergence is not a metric, its square
%root its indeed a metric. See the [Fuglede, 2004]
%
%% Output:
%
% A vector Y containing the distances (according to the selected criterion)
%   between each pair of signals in the M-by-N data matrix X.  Rows of
%   X correspond to signals, columns correspond to time samples.
%   Y is an (M*(M-1)/2)-by-1 vector, corresponding to the M*(M-1)/2
%   pairs of signals in X.
%   
%   The output Y is arranged in the order of ((1,2),(1,3),..., (1,M),
%   (2,3),...(2,M),.....(M-1,M)), i.e. the upper right triangle of the full
%   M-by-M distance matrix.  To get the distance between the Ith and Jth
%   signals (I < J), either use the formula Y((I-1)*(M-I/2)+J-I), or
%   use the MATLAB helper function Z = SQUAREFORM(Y), which returns
%   an M-by-M square symmetric matrix, with the (I,J) entry equal to
%   distance between signal I and signal J.
%
%% References:
%
%   1) Fuglede, B. and Topsoe, F. "Jensen-Shannon Divergence and
%   Hilbert space embedding". ISIT 2004 pg. 30
%
%
% Copyright 2007-23
% @author: Felipe Orihuela-Espina
%
% See also squareform, kldiv, jsm
%




%% Log
%
% File created: 9-Oct-2007
% File last modified (before creation of this log): N/A. This method had
%   probably been updated at some point (because it already had the error
%   codes in the ICNA format, but I failed to keep track of those changes.
%
% 11-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Error codes updated from ICNA to ICNNA
%   + Method moved from folder private/ to main class folder and explictly
%   declared as static in the class definition.
%




%Deal with some arguments
if nargin < 2
    s = 'jsm';
end
distfun = @distcalc;
distargs = {s};

m= size(X,1);
if any(imag(X(:)))
   error('ICNNA:analysis:ic_pdist',...
         'IC_PDIST does not accept complex inputs.');
end

if m < 2
   % Degenerate case, just return an empty of the proper size.
   Y = zeros(1,0);
   return;
end

% Create (I,J) defining all pairs of points
p = (m-1):-1:2;
I = zeros(m*(m-1)/2,1);
I(cumsum([1 p])) = 1;
I = cumsum(I);
J = ones(m*(m-1)/2,1);
J(cumsum(p)+1) = 2-p;
J(1)=2;
J = cumsum(J);


% For large matrices, process blocks of rows as a group
n = length(I);
ncols = size(X,2);
blocksize = 1e4;                     % # of doubles to process as a group
M = max(1,ceil(blocksize/ncols));    % # of rows to process as a group
nrem = rem(n,M);
if nrem==0, nrem = min(M,n); end


if (n>250)
    msgTemp=[datestr(now,13) ' ic_pdist: ', ...
            'The number of pairwise distances is large ' ...
            '(n=' num2str(n) '). ', ...
            'This will take a while. Please BE PATIENT!'];
    disp(msgTemp)
end
%%Calculate the distance
Y = zeros(1,n);
ii = 1:nrem;
try
    Y(ii) = feval(distfun,X(I(ii),:),X(J(ii),:),distargs{:})';
catch
    error('ICNNA:analysis:ic_pdist',...
          ['The distance function ''%s'' generated the following ', ...
            'error:\n%s'], func2str(distfun),lasterr);
end

for j=nrem+1:M:n
    ii = j:j+M-1;
    try
        Y(ii) = feval(distfun,X(I(ii),:),X(J(ii),:),distargs{:})';
    catch
        error('ICNNA:analysis:ic_pdist',...
              ['The distance function ''%s'' generated the following', ...
                'error:\n%s'], func2str(distfun),lasterr);
    end
end


end


% ---------------------------------------------------------
%% Auxiliary functions
function d = distcalc(XI,XJ,s,arg)
%DISTCALC Perform distance calculation for PDIST.
nSignals = size(XI,1);
%Just do 1 at a time
d=[];
for ss=1:nSignals
    switch s
        case 'jsm'
            dtemp = jsm(XI(ss,:),XJ(ss,:));  % Jansen-Shannon metric
        otherwise
            error('ICNNA:analysis:ic_pdist:distcalc',...
                    'Metric distance not recognised.');
    end
    d=[d dtemp];
    clear dtemp;
end
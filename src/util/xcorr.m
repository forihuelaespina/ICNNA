function [c,lags]=xcorr(varargin)
%Cross-correlation.
%
%Substitue for MATLAB's xcorr function, although it does not work with
%matrix.
%
% See MATLAB's decimate function!! I have borrowed MATLAB's comments
%
% REFERENCE:
%   [1] Proakis, John G. and Manolakis, Dimitris G.
%       "Digital Signal Processing: Principles, Algorithms
%       and Applications" 4th Ed. Pearson-Prentice Hall
%       New Jersey (2007) ISBN 0-13-187374-1
%
%
% Syntax
%
%   c = xcorr(x,y)
%   c = xcorr(x)
%   c = xcorr(x,y,'option')
%   c = xcorr(x,'option')
%   c = xcorr(x,y,maxlags)
%   c = xcorr(x,maxlags)
%   c = xcorr(x,y,maxlags,'option')
%   c = xcorr(x,maxlags,'option')
%   [c,lags] = xcorr(...)
%
%
%Description
%
%xcorr estimates the cross-correlation sequence of a
%random process. Autocorrelation is handled as a special case.
%
%The true cross-correlation sequence is
%
%   Rxy(m)=E{x_(n+m)y*_n}=E{x_(n)y*_(n-m)}
%
%where xn and yn are jointly stationary random processes,
%-inf<n<inf, and E {·} is the expected value operator.
%xcorr must estimate the sequence because, in practice,
%only a finite segment of one realization of the infinite-length
%random process is available.
%
%c = xcorr(x,y) returns the cross-correlation sequence in a
%length 2*N-1 vector, where x and y are length N vectors (N>1).
%If x and y are not the same length, the shorter vector is
%zero-padded to the length of the longer vector.
%
%By default, xcorr computes raw correlations with no normalization.
%
%           / N-m-1
%           | SUM(x_(n+m)y*_n)      if m>=0
%           | n=0
%   R'xy(m)=<
%           |
%           | R'xy(-m)              if m<0
%           \
%
%The output vector c has elements given by
%
%   c(m) = Rxy(m-N), m=1, ..., 2N-1.
%
%In general, the correlation function requires normalization
%to produce an accurate estimate.
%
%c = xcorr(x,y,'option') specifies a normalization option
%for the cross-correlation, where 'option' is
%
%   * 'biased': Biased estimate of the cross-correlation function
%   * 'unbiased': Unbiased estimate of the cross-correlation function
%   * 'coeff': Normalizes the sequence so the autocorrelations
%           at zero lag are identically 1.0. See reference [1]
%   * 'none', to use the raw, unscaled cross-correlations
%           (default)
%
%c = xcorr(x,'option') specifies one of the above normalization
%options for the autocorrelation.
%
%c = xcorr(x,y,maxlags) returns the cross-correlation sequence
%over the lag range [-maxlags:maxlags]. Output c has length 2*maxlags+1.
%
%c = xcorr(x,maxlags) returns the autocorrelation sequence over
%the lag range [-maxlags:maxlags]. Output c has length 2*maxlags+1.
%
%c = xcorr(x,y,maxlags,'option') specifies both a maximum number
%of lags and a scaling option for the cross-correlation.
%
%c = xcorr(x,maxlags,'option') specifies both a maximum number
%of lags and a scaling option for the autocorrelation.
%
%
%In all cases, the cross-correlation or autocorrelation
%computed by xcorr has the zeroth lag in the middle of the
%sequence, at element or row maxlags+1 (element or row N if
%maxlags is not specified).
%
% @Copyright 2008
% Author: Felipe Orihuela-Espina
% Date: 22-May-2008
%
% See also decimate
%
%

%% Get the parameters
if (length(varargin)>4)
    error('Too many input parameters');
end
%Default values
x=varargin{1};
y=varargin{1};
normOption='none';
varargin(1)=[];
while (~isempty(varargin))
    if ischar(varargin{1})
        normOption=varargin{1};
    elseif isscalar(varargin{1})
        maxlags=varargin{1};
    else
        y=varargin{1};
    end
    varargin(1)=[];
end


%% Allocate memory
N=max(length(x),length(y));
assert(N>1,'Signal length must N>1');
%If x and y are not the same length, the shorter vector is zero-padded
%to the length of the longer vector
if (length(x)<N)
    x(end+1:N)=0;
end
if (length(y)<N)
    y(end+1:N)=0;
end

if (exist('maxlags','var'))
    N=maxlags+1;
else
end
c=zeros(1,2*N-1);
lags=-N+1:N-1;


%% Compute raw cross-correlation R'xy with no normalization
for m=1:length(c)
%The output vector c has elements given by
%
%   c(m) = Rxy(m-N), m=1, ..., 2N-1.
    c(m)=rawRxy(m-N,x,y);
end

%% Normalize if necessary
switch(normOption)
    case 'biased'
        c=c/N;
    case 'unbiased'
        for m=1:length(c)
            c(m)=c(m)/(N-abs(m));
        end
    case 'coeff'
        %Autocorrelation at zero lag are identically 1.0
        rxx0=sum(x.^2); %See Reference [ProakisJG,2007, pg. 119]
        ryy0=sum(y.^2);
        c=c/sqrt(rxx0*ryy0); %See Reference [ProakisJG,2007, pg. 121 Eq. 2.6.18]
    case 'none'
        %Use the raw unscaled cross-correlations
    otherwise
        error('Normalization option not recognised.');
end


end

%%=============================================
%% Auxiliar functions
function cc=rawRxy(m,x,y)
%Computes the raw correlation at m lag
N=max(length(x),length(y));
if (m<0)
    cc=rawRxy(-m,x,y);
else
    sum=0;
    for n=0:N-m-1
        nn=n+1;
        sum=sum+(x(nn+m)*y(nn));
    end
    cc=sum;
end
end
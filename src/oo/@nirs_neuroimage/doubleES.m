function [S,b,f]=doubleES(s,a,g,m)
%Double exponential smoothing (and forecast) of a time series
%
% [S,b,f]=doubleES(s,a,g,m)
%
% Let s be a sequence {s_i|i=1...p}.
% The double exponential smoothing S of the time serie is:
%
%   S_t=as_(t)+(1-a)(S_(t-1)+b_(t-1))     0<a<=1  t>=3
%   b_t=g(S_t-S_(t-1))+(1-g)b_(t-1)       0<g<=1
%
%
% The first equation adjust S_t from the trend of the previous
% period. b_(t-1), by adding it to the last smoothed value,
% S(t-1). This helps to eliminate the lag and brings S_t to the
% appropriate base of the current value. The second smoothing
% equation updates the trend.
%
% The initial values:
%   S_1 is set to s_1. And b_1 is set to s_2-s_1.
%
%
% The values of a and g (usually named alpha and gamma
%respectively) can be optimised
%with the Marquardt search algorithm. But this is out of
%the scope of this function.
%
%
%% Remarks
%
%  Using "Engineering Statistics Handbook"
%  http://www.itl.nist.gov/div898/handbook/
%
%% Parameters:
%
%   s - The sequence (time-serie). A row vector of p observations
%   a - Alpha. The smoothing constant. 0<a<=1.
%   g - Gamma. The trend constant.0<g<=1.
%   m - Optional. Forecasting period. S_(t+m) will be predicted.
%       Default value set to 1.
%
%% Output:
%
%   S - The sequence of double exponential smoothing.
%   b - The trend values
%   f - The t+m forecasts at each step
%
%
%
% Copyright 2007-23
% @author: Felipe Orihuela-Espina
%
% See also nirs_neuroimage
%




%% Log
%
% File created: 17-May-2007
% File last modified (before creation of this log): N/A.  This method
%   had not been modified since creation.
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%



if(isempty(s))
    error('Empty signal')
end

if (nargin<4)
    m=1;
end


p=length(s);
if(~((0<=a) & (a<=1)))
    error(['Smoothing constant a (alpha) incorrect: a=' num2str(a)])
end
if(~((0<=g) & (g<=1)))
    error(['Smoothing constant g (gamma) incorrect g=' num2str(g)])
end

S=zeros(1,p);%Allocate memory
b=zeros(1,p);

%Initial values
%Put a NaN in the first position of S
S(1)=s(1);
b(1)=s(2)-s(1);

%Fit the rest according to the general equation
for tt=2:p
    S(tt)=a*s(tt)+(1-a)*(S(tt-1)+b(tt-1));
    b(tt)=g*(S(tt)-S(tt-1))+(1-g)*b(tt-1);
end

%%Forecast S_(t+1)
f=[s(1) S+m*b]; %The first value is arbitrary,
                %it is just so f_(t+1)=S(t)+m*b(t)


end
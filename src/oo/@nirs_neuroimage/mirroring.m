function c=mirroring(x,y,init,ws,tolerance)
%Detects mirroring between two signals
%
% value=mirroring(x,y,init,ws)
%
% Detects mirroring between two signals starting at location
%given by sample index init and for a legnth equal to
%the window size ws.
%
%This function is the building block for the multi-scale
%windowed cross correlation mirroring detection algorithm.
%The application of this function at different locations
%and different window size constitutes the multi-scale
%approach.
%
%
%% Parameters
%
%   x and y - The signals time courses (vectors)
%
%   init - The initial sample index at which to check for
%       mirroring. It is therefore a positive integer.
%       If init is beyond the length of one of the signals,
%       then the function will return 0.
%
%   ws - Window size in number of samples. A positive integer.
%
%The length of signals x and y is expected to be longer (greater)
%or equal to (init+ws) so the full window size can be checked.
%If the length of at least one of the signal is not long enough
%they will only be checked from init untill the length of the
%shortest signal ignoring the window size.
%
%   tolerance - Optional. The tolerance to noise. A value between
%       0 and 1. Default value 0. If tolerance is different from 0,
%       thenn mirroring will be considered to be present if the value
%       of the cross correlation function at lag zero is greater or
%       equal to 1-tolerance. Since the cross-correlation function
%       is normalised by definition, the tolerance can be seen as
%       a percentage of noise accepted. Although being precise, it
%       is actually "half" of the real percentage of noise accepted
%       in the sense that cross correlation function varies from
%       -1 to 1 which is a scale "double" in length that the accepted
%       range for the tolerance.
%
%% Output
%
% 1 if the value of the cross-correlation function at zero-lag
%between the two signals if the cross-correlation function
%peaks at zero-lag and this peak value is greater or equal
%than 1-tolerance. 0 otherwise.
%
% Copyright 2007
% @date: 19-Nov-2007
% @author Felipe Orihuela-Espina
%
% See also detectMirroringv3
%

%Check that init and ws are positive
%%%I know, I'm assuming they are integers..
if (init<=0)
    error('Parameter init is not positive');
end
if (ws<=0)
    error('Parameter ws is not positive');
end

%Check whether the tolerance has been defined and
%it is within the range [0 1] and if not, assign it a value 0.
t=0;
if (exist('tolerance','var'))
    if ((tolerance>=0) && (tolerance<=1))
        t=tolerance;
    else
        warning('ICNA:nirs_neuroimage:mirroring',...
            'Tolerance out of range. A tolerance=0 is being used');
    end
end

%Check that init is "within range" of both signals
if ((init>length(x)) || (init>length(y)))
    c = 0;
else
    
    windowSize=min([length(x(init:end)), ...
        length(y(init:end)), ...
        ws]);
    
    chunkX=x(init:init+windowSize-1);
    chunkY=y(init:init+windowSize-1);
    temp=xcorr(chunkX,chunkY,'coeff'); %Windowed cross-correlation
    %Discard the "negative lags" part of the correlation function
    %so the first value in temp corresponds to lag 0.
    temp(1:windowSize-1)=[];
    %Look for the peak value
    [c,idx]=max(-1*temp); %The -1 multiplication is because
            %mirroring is always changes in opposite directions.
            

    if (c<1-t-2*eps) %The peak value is smaller than 1-tolerance,
                %so there's no mirroring
                %IMPORTANT: Please do not remove the substraction
                %of 2*eps, as MATLAB seems to be making some
                %rounding errors.
        c=0;
    else
        c=1; %correct for possible rounding errors.
    end
    if (idx(1)~=1) %The peak is not a lag=0, so there's no mirroring
        c=0;
    end
    
end %if ((init>length(x)) | (init>length(y)))

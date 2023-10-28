function [F]=sos_suddenChange(x,s)
%Sum of squares function to be minimized by the optimization algorithm
%
%   [F]=sosLM_suddenChange(signal,model)
%
%Generates a column vector of sum of squares function
%to be minimized by the optimization
%algorithm.
%
% The optimization algorithm is implemented
%in the Optimization Toolbox of MATLAB in the function
%lsqnonlin. This function requires as first parameter a function
%of sum of squares to be minimized.
%
%          | f_1(x) |
%       F= | f_2(x) |
%          | ...    |
%          | f_n(x) |
%
% where:
%
%   x=<alpha,gamma> is the vector of parameters in the model
%M(t,x) to be optimised.
%
%   f_i(x) is the residual between the model and the real value
%at the sample t=i
%
%       f_i(x)=f(t_i)=signal(t_i)-M(t_i,x)
%
%
%
%% Parameters:
%
%   x - The vector of model parameters [alpha gamma]
%
%   s - The original signal. Note that this parameter is optional.
%       It is optional not because you can simply not provide it
%       and leave happy with a default value, but because I do not
%       know how MATLAB lsqnonlin will call to this function, but
%       surely is not passing this parameter. You will still need
%       to provide the signal the first time! The way it works is
%       the first time, you manually call this function, and I will
%       temporarily save the signal to a file, so when MATLAB calls
%       this function without this parameter, I read the signal from
%       the file...When this parameter is provided, this function
%       ONLY saves the signal to a file and that's it. When not
%       provided, the function behaves as expected.
%
%% Output:
%
% The function of least squares 
%
%
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
% File created: 10-Jul-2007
% File last modified (before creation of this log): N/A. This method
%   had not been modified since creation.
%
% 20-May-2023: FOE
%   + Added this log. This method is so old it didn't even had the
%       labels @date and @modified, instead there was just the creation
%       date!!
%





if (nargin==0)
    %Clean...
    delete('./data_sos_suddenChange.mat');
elseif(nargin>1)
    %The signal is being provided. Save it to a file
    save('./data_sos_suddenChange.mat','s');
else
    %Normal behaviour
    
    %Start by reading the signal...
    load('./data_sos_suddenChange.mat');
    
    %Get alpha and gamma
    alpha=x(1);
    gamma=x(2);
    %Calculate the model
    nEquations=2; %2 equations for 2 model parameters seemsto be the best...
    [S,b,f]=nirs_neuroimage.doubleES(s(1:end-nEquations),alpha,gamma,nEquations);
    %And get the residuals...
    F=s(end-(nEquations-1):end)-f(end-(nEquations-1):end)';
end



end

function [alpha,gamma]=optimizeDESWeights(s)
%Optimize the double exponential smoothing weights alpha and gamma
%%
%%Date: 10-Jul-2007
%%Author: Felipe Orihuela-Espina
%%
%
% Optimize the double exponential smoothing weights alpha and gamma
%using the Levenberg-Marquardt algorithm.
%
%   [a,g]=optimizeDESWeights(s)
%
% The Levenberg-Marquardt optimization algorithm is implemented
%in the Optimization Toolbox of MATLAB in the function
%lsqnonlin. This function requires as first parameter a function
%of sum of squares to be minimized. This function has been
%implemented in:
%
%   function [F]=sosLM_suddenChange(x)
%
%Unfortunately, the Levenberg-Marquardt optimization algorithm
%provided by MATLAB does not support a bounded-constrained
%problem, as it is this case where alpha and gamma are
%constrained to the interval [0 1].
%
% I have found an implementation for MATLAB of the bounded-constrained
%Levenberg-Marquardt algorithm from Bardsley at the Univeristy of
%Montana:
%
%   http://www.math.umt.edu/bardsley/codes.html
%
%Parameters:
%-----------
%
%   s - The signal (time-series) for which the model parameters
%       alpha and gamma are to be optimized
%
%Output:
%-------
% The optimum values of alpha and gamma
%
%

%Choose an x0=<alpha_0, gamma_0> initial solution
x0=[0.5 0.5]';

%Initialize the sum-of-squares
%%Note that this time x0 will be ignored, and simply
%%the signal will be saved
nirs_neuroimage.sos_suddenChange(x0,s);

%Initialize some stuff for MATLAB
%optimset('LargeScale','off');
%optimset('Jacobian','off');
lowerBounds=[0.0001; 0.0001];
upperBounds=[0.9999; 0.9999]; %Value 0.95 to avoid overfitting alpha

%Now properly estimate the best alpha and gamma
tmp_opt=optimset('Display','off');
x=lsqnonlin(@nirs_neuroimage.sos_suddenChange,x0,lowerBounds,upperBounds,tmp_opt);
%and recover the optimized values
alpha=x(1);
gamma=x(2);

%Clean
nirs_neuroimage.sos_suddenChange;

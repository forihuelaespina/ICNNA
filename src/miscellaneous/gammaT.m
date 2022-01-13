function gamma_t = gammaT()
%Calculates the venous total haemoglobin ratio, gammaR
%%
%%Date: 12-Mar-2007
%%Author: Felipe Orihuela-Espina
%%
% This function returns a 1, but please keep reading...
%
% This function aims to calculate the venous total haemoglobin ratio,
% gammaT, which is necessary to calculate the cerebral metabolic rate of
% oxigen (CMRO2), for determining brain activation.
%
% The following is taken from (Boas et al,2003)
%
% The real equation to calculate the venous total haemoglobin ratio,
% gammaT, is given by
%
%
%            /  D([HbT]_v)   \   / /  D([HbT])   \
%   gammaT = | ------------- |  /  |------------- |
%            \   [HbT]_v,o   / /   \   [HbT]_o   /
%
%
% where:
%   - D([HbT]_v) is the variation of total haemoglobin concentration in the
%   localized venous compartment.
%   - D([HbT]) is the variation of total haemoglobin concentration across
%   all vascular compartments.
%   - [HbT]_v,o is the baseline total haemoglobin concentration in the
%   localized venous compartment.
%   - [HbT]_o is the baseline total haemoglobin concentration across
%   all vascular compartments.
%   
% Boas indicated that the above formula was described by other authors
% (Jones et al, 2001; Mayhew et al, 2001a and b).
%
% We do not know [HbT]_v,o nor D([HbT]_v), so we are unable to "calculate"
% gammaR. However Boas et al (2001), simply assume it to be 1. And this is
% why this function returns a 1 at the moment...
%
%
% See also gammaR.m
%

gamma_t=1;
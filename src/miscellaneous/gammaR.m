function gamma_r = gammaR()
%Calculates the venous deoxy-haemoglobin ratio, gammaR
%%
%%Date: 12-Mar-2007
%%Author: Felipe Orihuela-Espina
%%
% This function returns a 1, but please keep reading...
%
% This function aims to calculate the venous deoxy-haemoglobin ratio,
% gammaR, which is necessary to calculate the cerebral metabolic rate of
% oxigen (CMRO2), for determining brain activation.
%
% The following is taken from (Boas et al,2003)
%
% The real equation to calculate the venous deoxy-haemoglobin ratio,
% gammaR, is given by
%
%
%            /  D([HbR]_v)   \   / /  D([HbR])   \
%   gammaR = | ------------- |  /  |------------- |
%            \   [HbR]_v,o   / /   \   [HbR]_o   /
%
%
% where:
%   - D([HbR]_v) is the variation of deoxy-haemoglobin concentration in the
%   localized venous compartment.
%   - D([HbR]) is the variation of deoxy-haemoglobin concentration across
%   all vascular compartments.
%   - [HbR]_v,o is the baseline deoxy-haemoglobin concentration in the
%   localized venous compartment.
%   - [HbR]_o is the baseline deoxy-haemoglobin concentration across
%   all vascular compartments.
%   
% Boas indicated that the above formula was described by other authors
% (Jones et al, 2001; Mayhew et al, 2001a and b).
%
% We do not know [HbR]_v,o nor D([HbR]_v), so we are unable to "calculate"
% gammaR. However Boas et al (2001), simply assume it to be 1. And this is
% why this function returns a 1 at the moment...
%
% See also gammaT.m
%

gamma_r=1;
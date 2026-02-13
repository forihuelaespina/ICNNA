function res=compareVersions(verStr1,verStr2,operator)
%Compares 2 version strings according to some criterion e.g. '>='
%
% res=icnna.util.compareVersions(verStr1,verStr2,operator) Compares 2 version
%       strings according to some criterion e.g. '>='
%
%
%
%% Error handling
%
% This function issues an error if the operator is not recognised.
%
%% Remarks
%
% This function supersedes method version_IsHigherOrEqual
%
%
%% Input parameters
%
% verStr1 - char[]
%   Version string (as char array), e.g. '1.4.0'
%
% verStr2 - char[]
%   Version string (as char array), e.g. '1.4.0'
%
% operator - char[]
%   Comparing criterion. Ought to be one of the following;
%       {'==','<','<=','>','>='}
% 
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also 
%


%% Log
%
% Since v1.4.0
%
% 14-Dec-2025: FOE
%   + File created from code in version_IsHigherOrEqual
%


%% Tokenize
tokens1 = cellfun(@str2double, split(verStr1, '.'));
tokens2 = cellfun(@str2double, split(verStr2, '.'));


%% Pad the shorter version string with zeros to facilitate comparison
len1 = length(tokens1);
len2 = length(tokens2);
if len1 < len2
    tokens1 = [tokens1; zeros(len2 - len1, 1)];
elseif len2 < len1
    tokens2 = [tokens2; zeros(len1 - len2, 1)];
else %len1 == len2
    %Do nothing
end

%% Perform the comparison based on the operator
res=false;
switch (operator)
    case '=='
        res = isequal(tokens1, tokens2); % isequal works for array equality
    case '<'
        % Element-wise comparison until a difference is found
        idx = find(tokens1 ~= tokens2, 1, 'first');
        if isempty(idx)
            res = false; % They are equal
        else
            res = tokens1(idx) < tokens2(idx);
        end
    case {'<=','=<'}
        res = icnna.util.compareVersions(verStr1, verStr2, '<') ...
                || icnna.util.compareVersions(verStr1, verStr2, '==');
    case '>'
        res = ~icnna.util.compareVersions(verStr1, verStr2, '<') ...
                && ~icnna.util.compareVersions(verStr1, verStr2, '==');
    case {'>=','=>'}
        res = ~icnna.util.compareVersions(verStr1, verStr2, '<');
    otherwise
        error('icnna:util:compareVersion:InvalidOperator',...
              'Invalid comparison operator specified.');
end


end

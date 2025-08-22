function [S2]=getSubbundle(S,w,c)
% Retrieve a subbundle
%
% [S2]=getSubbundle(S,w,c)
%
%
% A subbundle can result from filtering:
%   + The base space
%   + The total space
%   + The projection
%
% In addition, the filtering can be done by case (row based) or
%by condition (column base)-see paramter c
%
%% Filtering the base space
%
% In this case, a subset of the points of the base space
%are picked, and only they and their preimages and associations
%are preserved.
%
%% Filtering the total space
%
% In this case, a subset of the cases of the total space
%are picked. In this case, base points for which their pre-image
%is no longer in the total space as well as no longer relevant
%associations will be removed from the bundle as well.
%
%% Filtering the projection
%
% This involves deleting some of the associations in the projection
%as well as the total space cases and base space elements no longer
%participating in any remaining association.
%
%% Parameters
%
% S - An @icnna.data.core.experimentBundle
%
% w - Char array. The subsetting criterion.
%   Filtering set flag; Whether 'base', 'total' or 'projection'.
%
% c - Int[] OR struct[]. The filtering case or condition. 
%   This can take two forms;
%       + A vector of indexes to the cases (rows) to be removed.
%       + A conditional criteria somewhat alike an SQL's WHERE
%       statement but encoded as a struct array where each struct
%       has the following fields;
%           .column - The column name upon which the filter is
%           is to be applied.
%           .value - Indicate the value (or values) to be preserved.
%           .logic - The operator e.g. '=', '>', etc
%
%% Output
%
% S2 - An @icnna.data.core.experimentBundle
%   The subbundle of S
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
% 
% See also icnna.data.core.experimentBundle
%

%% Log
%
%
% File created: 22-Aug-2025
%
%   + Available since v1.3.1
%
% 22-Aug-2025: FOE. 
%   + File created. Unfinished.
%


S2 = copy(S); %Deep copy the bundle.

if isvector (c)

    switch (c)
        case 'base'
            %1) Filter the base space
            %2) Filter the projection
            %3) Remove preimages with no association
        case 'total'
            %1) Filter the total space
            %2) Filter the projection
            %3) Remove images with no association
        case 'projection'
            %1) Filter the projection
            %2) Remove total preimages with no association
            %3) Remove base images with no association
        otherwise
            error('icnna:op:getSubbundle:InvalidParameter',...
                ['Invalid subsetting criterion w. w must be ' ...
                 '''base'',''total'', or ''projection''.']);
    end

else %c is struct[]

    switch (c)
        case 'base'
            %1) Filter the base space
            %2) Filter the projection
            %3) Remove preimages with no association
        case 'total'
            %1) Filter the total space
            %2) Filter the projection
            %3) Remove images with no association
        case 'projection'
            %1) Filter the projection
            %2) Remove total preimages with no association
            %3) Remove base images with no association
        otherwise
            error('icnna:op:getSubbundle:InvalidParameter',...
                ['Invalid subsetting criterion w. w must be ' ...
                 '''base'',''total'', or ''projection''.']);
    end
    
end

end
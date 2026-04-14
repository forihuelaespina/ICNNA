function [S]=getSubbundle(S,w,c)
% Retrieve a subbundle
%
% [S] = icnna.op.getSubbundle(S,w,c)
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
%       + A conditional criteria somewhat akin to an SQL's WHERE
%       statement but encoded as a struct array where each struct
%       has the following fields;
%           .column - String or char[]. The column name upon which
%               the filter is is to be applied.
%           .value - (Numeric|char|String)[] Indicate the value (or
%               values) to be preserved.
%               Cell arrays of values is NOT supported.
%           .logic - String or char[]. The operator e.g. '==', '>',
%               'ismember', etc
%               NOTE: For mathematical relational operators, you can
%               specify the operator itself e.g. '>=' or its equivalent
%               function name e.g. 'gt'
%               For instance;
%                   '==' is equivalent 'eq' (but beware how these
%                               differ when applied over scalars and
%                               vectors)
%                   '>'  => 'gt'
%                   '>=' => 'ge'
%                   etc
%
%           If t is the table associated to the subsetting criterion w
%           then each filtering condition is applied as;
%
%           arrayfun(@(x) c.logic(x,c.value),t{:,c.column})
%
%         If more than one condition is expressed, the AND operation
%       will be applied to merge the outcomes with the other conditions.
%
%       +----------------------------------------------+
%       | Beware of the distinct logic!                |
%       | * When using indexes you are expressing what |
%       | to discard.                                  |
%       | * When using struct you are expressing what  |
%       | to preserve.                                 |
%       +----------------------------------------------+
%
%   If c is empty, then the whole bundle is return unfiltered.
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
% 29-Aug-2025: FOE. 
%   + Function completed.
%
% 5-Aug-2025: FOE. 
%   + Improved support for string arrays and generalized logic
%   by using arrayfun.
%   + Added support for "empty" queries (c is empty).
%
% -- ICNNA v1.4.1
%
% 5-Aug-2025: FOE. 
%   + Return to pass-by-value.
%

%% 0) Preliminaries

if isempty(c) %No filter applied. Return the whole bundle.
    return
end

tmpE = S.E;
tmpB = S.B;
tmpp = S.p;



%% 1) Establish the rows to DISCARD
if isnumeric (c) %Indexes to the cases (rows) to be removed.
    idx = c;


else %c is struct[]. Conditional criteria encoded as a struct array

    %Get the rows to keep
    switch (w)
        case 'base'
            varStr = 'tmpB';
        case 'total'
            varStr = 'tmpE';
        case 'projection'
            varStr = 'tmpp';
        otherwise
            error('icnna:op:getSubbundle:InvalidParameter',...
                ['Invalid subsetting criterion w. w must be ' ...
                '''base'',''total'', or ''projection''.']);
    end
            
    idx = [];
    while ~isempty(c) %Apply one condition at a time
        tmpC    = c(end);
        c(end)  = [];

        %Replace math relational operators by their functions
        %See: https://uk.mathworks.com/help/matlab/matlab_prog/matlab-operators-and-special-characters.html
        switch (tmpC.logic)
            case '=='
                tmpC.logic = 'eq';
                    %See: https://uk.mathworks.com/help/matlab/ref/double.eq.html
            case '>'
                tmpC.logic = 'gt';
            case '<'
                tmpC.logic = 'lt';
            case '>='
                tmpC.logic = 'ge';
            case '<='
                tmpC.logic = 'le';
            case '~='
                tmpC.logic = 'ne';
            otherwise
                %Do nothing
        end

        if isnumeric(tmpC.value)
            tmpCStr = strcat("arrayfun(@(x) ",tmpC.logic,"(x,", ...
                        mat2str(tmpC.value),"),",varStr,"{:,""",tmpC.column,"""})");
        elseif ischar(tmpC.value)
            tmpCStr = strcat("arrayfun(@(x) ",tmpC.logic,"(x,", ...
                        tmpC.value,"),",varStr,"{:,""",tmpC.column,"""})");
        elseif isstring(tmpC.value)
                tmpCStr = strcat("arrayfun(@(x) ",tmpC.logic,"(x,[""", ...
                        strjoin(tmpC.value,'","'),"""]),",varStr,"{:,""",tmpC.column,"""})");                
        else
            error('icnna:op:getSubbundle:InvalidFilteringType',...
                ['Filtering condition over column ''' tmpC.column ''' ' ...
                 ' has an invalid type for field value.']);
        end
        %disp(tmpCStr)
        idx2 = eval(tmpCStr);

        if isempty(idx)
            idx = idx2;
        else
            idx = and(idx,idx2);
        end
    end
    idx = find(idx); %From logical to indexes


    %Inverse; i.e. get the indexes to discard
    switch (w)
        case 'base'
            idx = setdiff((1:size(tmpB,1))',idx);
        case 'total'
            idx = setdiff((1:size(tmpE,1))',idx);
        case 'projection'
            idx = setdiff((1:size(tmpp,1))',idx);
        otherwise
            error('icnna:op:getSubbundle:InvalidParameter',...
                ['Invalid subsetting criterion w. w must be ' ...
                '''base'',''total'', or ''projection''.']);
    end

end


%% 2) Proceed to filter
switch (w)
    case 'base'
        %1) Filter the base space
        tmpB(idx,:) = [];
        %2) Filter the projection
        %Note that this is not as easy as simply removing the
        %corresponding rows as the indexes to the base case points
        %has now been altered, and hence the projection entries
        %(that are meant to relate to these entries) also ought
        %to be updated accordingly.
        tmpp(ismember(S.p{:,'BaseSpacePoint'},idx),:) = [];
        tmpp.BaseSpacePoint = updateEntries(tmpp.BaseSpacePoint, idx);
        %3) Remove preimages with no association
        survivingPreimages = unique(tmpp{:,'FamilyOfSpaces'});
        idx2 = setdiff((1:size(tmpE,1))', survivingPreimages);
        tmpE(idx2,:) = [];
        tmpp.FamilyOfSpaces = updateEntries(tmpp.FamilyOfSpaces, idx2);

    case 'total'
        %1) Filter the total space
        tmpE(idx,:) = [];
        %2) Filter the projection
        tmpp(ismember(S.p{:,'FamilyOfSpaces'},idx),:) = [];
        tmpp.FamilyOfSpaces = updateEntries(tmpp.FamilyOfSpaces, idx);
        %3) Remove images with no association
        survivingImages = unique(tmpp{:,'BaseSpacePoint'});
        idx2 = setdiff((1:size(tmpB,1))', survivingImages);
        tmpB(idx2,:) = [];
        tmpp.BaseSpacePoint = updateEntries(tmpp.BaseSpacePoint, idx2);

    case 'projection'
        %1) Filter the projection
        tmpp(idx,:) = [];
        %2) Remove total preimages with no association
        survivingPreimages = unique(tmpp{:,'FamilyOfSpaces'});
        idx2 = setdiff((1:size(tmpE,1))', survivingPreimages);
        tmpE(idx2,:) = [];
        tmpp.FamilyOfSpaces = updateEntries(tmpp.FamilyOfSpaces, idx2);
        %3) Remove base images with no association
        survivingImages = unique(tmpp{:,'BaseSpacePoint'});
        idx2 = setdiff((1:size(tmpB,1))', survivingImages);
        tmpB(idx2,:) = [];
        tmpp.BaseSpacePoint = updateEntries(tmpp.BaseSpacePoint, idx2);

    otherwise
        error('icnna:op:getSubbundle:InvalidParameter',...
            ['Invalid subsetting criterion w. w must be ' ...
            '''base'',''total'', or ''projection''.']);
end





%% 3) Finally, update the bundle
S = S.setBundle(tmpE,tmpB,tmpp);



    %% AUXILIARY FUNCTIONS
    
    function A = updateEntries(A, idx)
    % Update entries in A using B(:,1) -> B(:,2) mapping
    
        %Build a replacement matrix B(:,1) -> B(:,2)
        oldEntries = setdiff(A,idx);
        B = [oldEntries (1:numel(oldEntries))'];
    
        % Find matching indices and their positions in B
        [isMatch, loc] = ismember(A, B(:,1));
    
        % Build replacement vector
        replacement = B(loc(isMatch), 2);
    
        % Apply replacements
        A(isMatch) = replacement;
    end

end
function [C,nRows,nCols] = padVectors(C)
%Pad the vectors/tensors in a cell array (likely in preparation to call cell2mat)
%
% [C,nRows,nCols] = icnna.util.padVectors(C)
%
% cell2mat cannot operate when the tensors in each cell have different
% dimensions. This function pads the tensors with NaN so that they are
% coherent in size for cell2mat.
%
%
%% Input parameters
%
% C - A cell array where each cell contains a tensor
%
%
%% Output
%
% C - A cell array where each cell contains a tensor
% nRows - Number of rows per cell column.
% nCols - Number of cols per cell column.
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also
%


%% Log
%
% Since v1.3.1
%
% 29-Aug-2025: FOE
%   + File created.
%

%Get lengths of cases
nRows    = cellfun(@(x) size(x,1),C);
nCols    = cellfun(@(x) size(x,2),C);

nRows = max(nRows,[],2);
nCols = max(nCols,[],1);

for iCell = 1:numel(C)
    [row,col] = ind2sub(size(C),iCell);
    tmp  = nan(nRows(row),nCols(col));
    tmp2 = C{iCell};
    [row,col] = size(tmp2);
    tmp(1:row,1:col) = tmp2;
    C(iCell) = {tmp};
end
end
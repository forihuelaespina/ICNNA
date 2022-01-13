function activityMatrix2xls(filename)
%Exports an activity matrix to a .xls file
%
%   activityMatrix2xls(filename) Exports an activity matrix to a .xls file
%
%
% One sheet is created for the activity matrix M itself, 2 for the
%sign matrices (oxy and deoxy) and 2 again for the p-values (oxy and
%deoxy).
%
%% Remarks
%
% Currently only works with "combined" acitivity matrices holding both
%oxy and deoxy information
%
%
%% Parameters
%
% filename -  The .mat containing the activity matrix and the sign and
%       p-values matrix
%
%
%% Output
%
% A .xls file containing the activity matrix and the sign and
%p-values matrix
%
%
%
% Copyright 2012
% @date: 17-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 17-Nov-2012
%
% See also 
%

load(filename);

tmpFilename= filename(1:end-4);%Remove extension .mat

nChannels=size(M,2);
chStr=cell(1,0);
for ch=1:nChannels
    chStr(ch)={['Ch.' num2str(ch)]};
end

tmp=M;
tmp2=[cell(1,1) chStr; ...
    sessLabels' mat2cell(tmp,ones(1,size(tmp,1)),ones(1,size(tmp,2)))];
xlswrite([tmpFilename '.xls'],tmp2,'M');

tmp=S(:,:,nirs_neuroimage.OXY);
tmp2=[cell(1,1) chStr; ...
    sessLabels' mat2cell(tmp,ones(1,size(tmp,1)),ones(1,size(tmp,2)))];
xlswrite([tmpFilename '.xls'],tmp2,'S(Oxy)');

tmp=S(:,:,nirs_neuroimage.DEOXY);
tmp2=[cell(1,1) chStr; ...
    sessLabels' mat2cell(tmp,ones(1,size(tmp,1)),ones(1,size(tmp,2)))];
xlswrite([tmpFilename '.xls'],tmp2,'S(Deoxy)');

tmp=P(:,:,nirs_neuroimage.OXY);
tmp2=[cell(1,1) chStr; ...
    sessLabels' mat2cell(tmp,ones(1,size(tmp,1)),ones(1,size(tmp,2)))];
xlswrite([tmpFilename '.xls'],tmp2,'p-value(Oxy)');

tmp=P(:,:,nirs_neuroimage.DEOXY);
tmp2=[cell(1,1) chStr; ...
    sessLabels' mat2cell(tmp,ones(1,size(tmp,1)),ones(1,size(tmp,2)))];
xlswrite([tmpFilename '.xls'],tmp2,'p-value(Deoxy)');


%deleteDefaultSheets(filename);
    %Not working yet because the open operation does not accept relative paths!

end

%% AUXILIAR FUNCTIONS
function deleteDefaultSheets(filename)
%Delete the default sheets

%excelFileName = 'Test.xls';
%excelFilePath = pwd; % Current working directory.
sheetName = 'Sheet'; % EN: Sheet, DE: Tabelle, etc. (Lang. dependent)

% Open Excel file.
objExcel = actxserver('Excel.Application');
%objExcel.Workbooks.Open(fullfile(excelFilePath, excelFileName)); % Full path is necessary!
objExcel.Workbooks.Open(filename); % Full path is necessary!

% Delete sheets.
try
% Throws an error if the sheets do not exist.
objExcel.ActiveWorkbook.Worksheets.Item([sheetName '1']).Delete;
objExcel.ActiveWorkbook.Worksheets.Item([sheetName '2']).Delete;
objExcel.ActiveWorkbook.Worksheets.Item([sheetName '3']).Delete;
catch
; % Do nothing.
end

% Save, close and clean up.
objExcel.ActiveWorkbook.Save;
objExcel.ActiveWorkbook.Close;
objExcel.Quit;
objExcel.delete;
end

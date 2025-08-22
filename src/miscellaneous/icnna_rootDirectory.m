function rootDir = icnna_rootDirectory()
% Returns name of the directory where ICNNA is installed.
%
%   rootDir = icnna_rootDirectory()
%
%% Remarks
%   icnna_rootDirectory returns the root folder of ICNNA regardless
%       of where ICNNA is installed.
%
% Basically, this function looks for this file and return the "parent"
%directory.
%
%% Output:
%
%   rootDir - Char array.
%       The directory where icnna is installed.
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
% 
% See also 
%

%% Log
%
%
% File created: 24-Jun-2025
%
% 25-Apr-2018: FOE. 
%   + File created
%   + Available since v1.3.1
%
% 
% 
whch = which( 'icnna_rootDirectory', '-all' );
assert( numel(whch)==1, ...
    ['ICNNA:icnna_rootDirectory. ' ...
    'More than one ICNNA on the search path.']);

tokens = strsplit( mfilename('fullpath'), filesep );
idx = find( strcmp( tokens, 'icnna_rootDirectory' ) );

rootDir = fullfile( tokens{1:idx-2} );
end

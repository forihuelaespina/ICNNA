function obj=export(obj,filename)
%RAWDATA_SNIRF/EXPORT Reads the raw light intensities 
%
% obj=export(obj,filename) Writes an .snirf file. The content of the
%   file depends on the content of the attribute .snirfImg which can
%   contain either light measurements or concentrations.
%
%
%% Input file(s) structure
%
% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
%
% https://github.com/fNIRS/snirf
%
% See snirf specifications
% 
%
%
%% Parameters
%
% filename - The NIRScout data file to import (.hdr or any of the valid
%       files *.wl* , *.evt, *.set, _config.txt or _probeInfo.mat).
%       Wherever the file is, it is assumed that at least the .hdr and
%       the .wl* files are also present in the same directory and with
%       the same filename (only changing the extension)!.
%
% 
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also rawData_Snirf, convert, import
%



%% Log
%
% 29-Aug-2023: FOE
%   + File created
%



%Check filename
[srcDir,theFilename,extension] = fileparts(filename);

if ~strcmp(extension,'.snirf')
    warning('ICNNA:rawData_Snirf:export:UnexpectedExtension',...
            'Extension is not .snirf.');
end


%This is easy peasy given that this is only a wrapper.
res = icnna.data.snirf.snirf.save(filename,obj.snirfImg);
if ~res
    error('ICNNA:rawData_Snirf:export:FileNotWritten',...
        ['Unable to write file ' filename '.']);
end

end
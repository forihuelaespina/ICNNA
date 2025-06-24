function obj=import(obj,filename)
%RAWDATA_SNIRF/IMPORT Reads the raw light intensities 
%
% obj = import(obj,filename) Reads the light intensities recorded in
%   a .csv file produced by the NIRx NIRScout NIRS family systems.
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
% filename - The .snirf data file to import.
%
% 
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also rawData_Snirf, convert, export
%



%% Log
%
% 13-May-2023: FOE
%   + File created
%
% 29-Aug-2023: FOE
%   + Some comments update. There was some residual garbage due to
% bad copy and paste practices.
%



%Check filename to decode the source directory and file extension
[srcDir,theFilename,extension] = fileparts(filename);

assert(strcmp(extension,'.snirf'), ...
    'ICNNA:rawData_Snirf:import:InvalidExtension');


%This is easy peasy given that this is only a wrapper.
obj.snirfImg = icnna.data.snirf.snirf.load(filename);

end
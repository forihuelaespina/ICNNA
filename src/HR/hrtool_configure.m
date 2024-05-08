function [appOptions]=hrtool_configure
%Loads the initial configuration options for the HR tool application
%
%
% [appOptions]=hrtool_configure Returns a struct with the
%   application configuration options.
%
%% Available options
%
% fontSize - Font size for plots
% lineWidth - Default line width for plots
% timescale -  Scale for the time axis in displacement plots. Permitted
%       scales are 'samples', 'milliseconds' (default), and 'seconds'.
%
%
% Copyright 2009
% @date: 20-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also rawData_BioHarnessECG, ecg, dataSource, guiHROptions
%
%

appOptions.fontSize=13;
appOptions.lineWidth=1.5;
appOptions.timescale='milliseconds';


function [appOptions]=registration_loadAppOptions
%Loads the initial configuration options for the MaTrICES application
%
%
% [appOptions]=registration_loadAppOptions Returns a struct with the
%   Registration tool configuration options.
%
%% Available options
%
%
% fontSize - Font size for plots
%
% Registration - A tiny tool to visualize the NIRS optode/channel
%registration to standard positioning systems.
%
%
% Copyright 2009-13
% @date: 1-Apr-2009
% @author Felipe Orihuela-Espina
% @date: 7-Sep-2013
%
% See also guiRegistration, guiRegistrationOptions
%
%

%% Log
%
% 7-Sep-2013: Update from optodeSpace struct to new channelLocationMap
%       object. Option Probe no longer needed.
%


appOptions.fontSize=13;
%appOptions.probe=1;

function theECG=convert(obj,varargin)
%RAWDATA_BIOHARNESSECG/CONVERT Convert raw ECG to a structured ECG
%
% theECG=convert(obj) Convert raw ECG to a structured ECG.
%
%
%% Parameters
%
% obj - The rawData_BioHarnessECG object to be converted
%
% varargin - Reserved for future usage
%
%
% 
% Copyright 2009-10
% @date: 19-Jan-2009
% @author: Felipe Orihuela-Espina
% @modified: 21-Jul-2010
% 
%
% See also rawData_BioHarnessECG, import, ecg
%

%% NOT YET FINISHED

[nSamples]=length(obj.data);
theECG=ecg(1);

%% Set values
theECG=set(theECG,'StartTime',get(obj,'StartTime'));
theECG=set(theECG,'SamplingRate',get(obj,'SamplingRate'));
theECG=set(theECG,'Data',get(obj,'RawData'));
theECG=setSignalTag(theECG,1,'ECG');

%% Set the timeline
theTimeline=timeline(nSamples);
theECG=set(theECG,'Timeline',theTimeline);
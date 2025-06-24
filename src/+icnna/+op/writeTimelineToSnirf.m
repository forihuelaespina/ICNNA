function [aSnirf] = writeTimelineToSnirf(aSnirf,t,options)
%Writes an ICNNA timeline to an iccna.data.snirf.snirf
%
% [res] = icnna.op.writeTimelineToSnirf(aSnirf,t)
%
% [res] = icnna.op.writeTimelineToSnirf(aSnirf,t,options)
%
% The way ICNNA and the .snirf standard stored the timelines are slightly
% different. The .snirf standard uses an array of stims (see
% @iccna.data.snirf.stim) plus timestamps are saved separately,
% whereas ICNNA as a combination of either;
%
%   @icnna.data.core.timeline and @icnna.data.core.condition - Newer
%   @timeline - Older
%
% This function writes an ICNNA formatted timeline and "converts" it
% to the .snirf standard timeline.
%
%% Parameters
%
% aSnirf - iccna.data.snirf.snirf
%   The snirf object from where the stims and timestamps are to be
%   extracted.
%
% t - A ICNNA timeline. Either;
%       + a @timeline, or
%       + a @icnna.data.core.timeline - Not yet available. Reserved for
%           future use.
%
% options - struct. A Struct of options
%   .iNirs - Int. Default is 1. Index to the nirs dataset to be acted upon
%   .overwriteStims - Bool. True for overwrite, False (default) for
%       append.
%   .overwriteTimestamps - Bool. False by default.
%       What says on the tin. Decide whether you overwrite the current
%       timestamps in aSnirf with those in t or not.
%   
%
%
%% Output
%
% 
%
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also @rawData_Snirf.convert
%

%% Log
%
% 12-Feb-2025: FOE
%   + File created, but reused some code from @rawData_Snirf.convert
%



%% Deal with options
opt.iNirs = 1;
opt.overwriteStims = false;
opt.overwriteTimestamps = false;
if exist('options','var')
    if isfield(options,'iNirs')
        opt.iNirs=options.iNirs;
    end
    if isfield(options,'overwriteStims')
        opt.overwriteStims=options.overwriteStims;
    end
    if isfield(options,'overwriteTimestamps')
        opt.overwriteTimestamps=options.overwriteTimestamps;
    end
end


if strcmp(t,'icnna.data.core.timeline')
    warning('ICNNA:op:writeTimelineToSnirf:OptionReserved',...
        ['Input parameter t being of class @icnna.data.core.timeline ' ...
         'reserved for future use. Currently only class @timeline is' ...
         'available.']);
end



theSamplingRate = 1/mean(aSnirf.nirs(opt.iNirs).data.time(2:end) ...
                         -aSnirf.nirs(opt.iNirs).data.time(1:end-1),...
                         'omitnan');



%% Main
if isa(t,'timeline')


    if opt.overwriteTimestamps
        aSnirf.nirs(opt.iNirs).data.time = t.timestamps;
        theSamplingRate  = t.samplingRate;
    end



    if opt.overwriteStims
        aSnirf.nirs(opt.iNirs).stim(:) = [];
    end

    %Allocate memory
    nStims = length(aSnirf.nirs(opt.iNirs).stim);
    aSnirf.nirs(opt.iNirs).stim(nStims+1:nStims+t.nConditions) = ...
            icnna.data.snirf.stim();

    for iCond = 1:t.nConditions
        theCond = t.conditions{iCond};
        %Each condition is a struct
        %with a tag (.conditions{i}.tag), the list of events.
        %(.conditions{i}.events) and a field to store information
        %associated to the events (.conditions{i}.eventsInfo).
        %The list of events is a two column matrix
        %where first column represents event onsets and second
        %column represents event durations.
        tmpStim = icnna.data.snirf.stim();
        tmpStim.name = theCond.tag;
        %convert events in samples to events in time

        [nEvents,nCols] = size(theCond.events);
        cEvents = theCond.events(:,1:2);
            %Just the onset and duration have to be converted
        cEvents = cEvents/theSamplingRate;
        if nCols == 2
            tmpStim.data = [cEvents ones(nEvents,1)]; %Add the magnitude
        else %nCols == 3
            tmpStim.data = [cEvents theCond.events(:,3)];
        end
        tmpStim.dataLabels = {'starttime','duration','amplitude'};
        aSnirf.nirs(opt.iNirs).stim(nStims+iCond) = tmpStim;
        
    end

end


end
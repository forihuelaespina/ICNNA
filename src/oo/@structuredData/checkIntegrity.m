function obj=checkIntegrity(obj,varargin)
%STRUCTUREDDATA/CHECKINTEGRITY Check the integrity of the channels
%
% obj=checkIntegrity(obj,...) Check the integrity for all the
%       channels. By default only UNCHECK elements are put
%       to test. However this can be override by setting
%       'testAllChannels' to true.
%
% obj=checkIntegrity(obj,whichChannels,...) Check the integrity
%       of the indicated channels only.
%       By default only UNCHECK elements are put
%       to test. However this can be override by setting
%       'testAllChannels' to true.
%
% obj=checkIntegrity(...,'TestName',true) Apply the selected
%       test.
% 
% obj=checkIntegrity(...,'testAllChannels',true) Force checking
%       of all channels, regardles whether they are still UNCHECK
%       or have already been checked.
%
%
%
% obj=checkIntegrity(...,'verbose',true/false)
%       Enable/Disable progression messages. Default is enabled.
%
% The function check only those artefacts tests set to 'true'.
%
%
%% Available Tests
%
% If channel data is missing, then integrityStatus will
%be set to MISSING. This test is always performed and cannot
%be deactivated.
%
%Please refer to subclasses for additional available
%integrity checks.
%
%% References
%
% 1) Orihuela-Espina, F.; Leff, D.R.; Darzi, A.W.; Yang, G.Z.
%    (2008) Data integrity in functional near infrared
%    spectroscopy. Unpublished
%
%
%
% Copyright 2008-10
% @date: 17-Jun-2008
% @author Felipe Orihuela-Espina
% @modified: 27-Sep-2010
%
% See also structuredData, integrityStatus, get, set
%

opt.testAllChannels=false;
opt.verbose=true;
nChannels = get(obj,'NChannels');
opt.whichChannels=1:nChannels;

if ~isempty(varargin)
    tmp=varargin{1};
    if ((~ischar(tmp) && isreal(tmp) && all(floor(tmp)==tmp)))
        opt.whichChannels=tmp;
        varargin(1)=[];
    end
end

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case 'testAllChannels'
        opt.testAllChannels = val;
    case 'verbose'
        opt.verbose = val;
    otherwise
      error(['Property ' prop ' not valid.'])
   end
end


if (getNElements(obj.integrity) ~= nChannels)
    error('Unexpected number of integrity elements.');
end


integrity=getStatus(obj.integrity,opt.whichChannels);
pos=1;
for ch=opt.whichChannels
  if (opt.testAllChannels || ...
	(getStatus(obj.integrity,ch)==integrityStatus.UNCHECK))
    if (opt.verbose)
        disp([datestr(now,13) ': Integrity check for channel ' ...
                   num2str(ch)]);
    end
    channelData=getChannel(obj,ch);
    condition=integrityStatus.FINE; %By default, assume the data is clean
                %Do not remove this line, so condition has
                %a value to assign at the end of the ifs
                
    
    %%%INSERT HERE THE integrity checks
    if (isempty(channelData))
        condition=integrityStatus.MISSING;
    end
     
    integrity(pos) = condition;
    pos=pos+1;
   end
end

obj.integrity=setStatus(obj.integrity,opt.whichChannels,integrity);


assertInvariants(obj);


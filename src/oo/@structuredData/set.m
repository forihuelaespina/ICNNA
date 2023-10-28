function obj = set(obj,varargin)
%STRUCTUREDDATA/SET DEPRECATED. Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%Modifying the underlying data also adjusts the timeline as appropriate.
%
%% Properties
% ID - Numerical ID
% Description - Description string
% Timeline - A timeline
% NSamples - Update the current number of samples
%   Data and timeline are cropped or zero padded as necessary
% NChannels - Update the current number of channels
%   Data and timeline are cropped or zero padded as necessary
% NSignals - Update the current number of signals
%   Data and timeline are cropped or zero padded as necessary
% Data - The full data. 3D matrix holding <samples,channels,signals>
% Integrity - An integrityStatus
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also structuredData, get
%





%% Log
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): 22-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   + Nested method cropOrRemoveEvents has now been separated
%   to a private method.
%



warning('ICNA:structuredData:set:Deprecated',...
        ['DEPRECATED. Use struct like syntax for setting the attribute ' ...
         'e.g. structuredData.' lower(varargin{1}) ' = ... ']); 



propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
       case 'id'
           obj.id =  val;
           % if (isscalar(val) && isreal(val) && ~ischar(val) ...
           %  && (val==floor(val)) && (val>0))
           %  %Note that a char which can be converted to scalar
           %  %e.g. will pass all of the above (except the ~ischar)
           %      obj.id = val;
           % else
           %     error('ICNNA:structuredData:set:InvalidID',...
           %           'Value must be a scalar natural/integer');
           % end

       case 'description'
           obj.description =  val;
           % if (ischar(val))
           %     obj.description = val;
           % else
           %     error('ICNNA:structuredData:set:InvalidPropertyValue',...
           %           'Value must be a string');
           % end

       case 'timeline'
           obj.timeline =  val;
           % if (isa(val,'timeline'))
           %     obj.timeline = timeline(val);
           % else
           %     error('ICNNA:structuredData:set:InvalidPropertyValue',...
           %           'Value must be of class Timeline');
           % end

       case 'nsamples'
           obj.nSamples =  val;
           % if (isscalar(val) && isnumeric(val) && val==floor(val) && val>=0)
           %     [nSamples]=size(obj.data,1);
           %     if (val~=nSamples)
           %         obj.timeline=set(obj.timeline,'Length',nSamples);
           %         if (val<nSamples) %Decrease size
           %             obj.data(val+1:end,:,:)= [];
           %         else %Increase size
           %             if isempty(obj.data)
           %                 obj.data(end+1:val,:,:)= zeros(val-nSamples,0,0);
           %             else
           %                 obj.data(:,end+1:val,:,:)= 0;
           %             end
           %         end
           %     end
           % else
           %     error('ICNNA:structuredData:set:InvalidPropertyValue',...
           %           ['Number of (time) samples must be 0 ' ...
           %         'or a positive integer']);
           % end

       case 'nchannels'
           obj.nChannels =  val;
           % if (isscalar(val) && isnumeric(val) && val==floor(val) && val>=0)
           %     [nChannels]=size(obj.data,2);
           %     if (val~=nChannels)
           %         if (val<nChannels) %Decrease size
           %             obj.data(:,val+1:end,:)= [];
           %         else %Increase size
           %             if isempty(obj.data)
           %                 obj.data(:,end+1:val,:)= zeros(0,val-nChannels,0);
           %             else
           %                 obj.data(:,end+1:val,:)= 0;
           %             end
           %         end
           %     end
           %     obj.integrity= ...
           %         setNElements(obj.integrity,get(obj,'NChannels'));
           % else
           %     error('ICNNA:structuredData:set:InvalidPropertyValue',...
           %           ['Number of channels must be 0 ' ...
           %         'or a positive integer']);
           % end
       case 'nsignals'
           obj.nSignals =  val;
           % if (isscalar(val) && isnumeric(val) && val==floor(val) && val>=0)
           %     [nSignals]=size(obj.data,3);
           %     if (val~=nSignals)
           %         if (val<nSignals) %Decrease size
           %             obj.data(:,:,val+1:end)= [];
           %             obj.signalTags(val+1:end)= [];
           %         else %Increase size
           %             if isempty(obj.data)
           %                 obj.data(:,:,end+1:val)= zeros(0,0,val-nSignals);
           %             else
           %                 obj.data(:,:,end+1:val)= 0;
           %             end
           %             nNewSignals=val-length(obj.signalTags);
           %             tmpTags=cell(1,nNewSignals);
           %             for tt=1:nNewSignals
           %                 tmpTags(tt)={['Signal ' ...
           %                      num2str(tt+length(obj.signalTags))]};
           %             end
           %             obj.signalTags(end+1:val)=tmpTags;  
           %         end
           %     end
           % else
           %     error('ICNNA:structuredData:set:InvalidPropertyValue',...
           %           ['Number of signals must be 0 ' ...
           %         'or a positive integer']);
           % end
       case 'data'
           obj.data =  val;
           % if (isnumeric(val)) % && ndims(val)==3) %This ndims test will not work if there's only 1 signal!!
           %     [nSamples,nChannels,nSignals]=size(val);
           %     obj.timeline=set(obj.timeline,'Length',nSamples);
           %     if isempty(val)
           %         %val will be empty as long as either
           %         %nSamples, nChannels or nSignals is 0.
           %         %however, the other two elements of the vector may not
           %         %be 0.
           %         %%%%obj.data=zeros(0,0,0); %Do not use it like this
           %         %%%%          %otherwise rawData_TobiiEyeTracker
           %         %%%%          %will crash upon converting empty
           %         %%%%          %data.
           %         obj.data=zeros(nSamples,nChannels,nSignals);
           %              %Ensure a 3D matrix
           %              %so that derivate attributes NSamples,
           %              %NChannels and NSignals works correctly
           %     else
           %         obj.data = val;
           %     end
           %     obj.integrity= ...
           %         setNElements(obj.integrity,get(obj,'NChannels'));
           %     if nSignals>length(obj.signalTags)
           %             nNewSignals=nSignals-length(obj.signalTags);
           %             tmpTags=cell(1,nNewSignals);
           %             for tt=1:nNewSignals
           %                 tmpTags(tt)={['Signal ' ...
           %                      num2str(tt+length(obj.signalTags))]};
           %             end
           %             obj.signalTags(end+1:nSignals)=tmpTags;
           %     elseif nSignals<length(obj.signalTags)
           %         obj.signalTags(nSignals+1:end)= [];
           %     end
           % else
           %     error('ICNNA:structuredData:set:InvalidPropertyValue',...
           %           'Data must be a numeric');
           % end
           % 
       case 'integrity'
           obj.integrity =  val;
           % if (isa(val,'integrityStatus'))
           %     obj.integrity = integrityStatus(val);
           % else
           %     error('ICNNA:structuredData:set:InvalidPropertyValue',...
           %           'Value must be of class integrityStatus');
           % end

    otherwise
      error('ICNNA:structuredData:set:InvalidProperty',...
            ['Property ' prop ' not valid.'])
   end
end
%assertInvariants(obj);

end
classdef structuredData
% structuredData    An observation stored in a convenient tensor.
%
%A structured data represents an observation stored
%in a convenient standard structure. This standard structure
%is independent of the original device from where the
%data was acquire or its particular meaning (see class
%rawData). Basically any data that I can think of at the
%moment can be conceptually wrapped in a 3D structure
%(regardless of the real implementation details):
%
%      Recorded
%       Signals /
%              /
%             /                       Spatial
%            +---------------------> Elements
%            |                      (Channel)
%   Temporal |
%   Elements |
%    (Time   |
%   Samples) |
%            |
%            v
%
% With this representation the location or spatial
%elements may represents the picture
%element; whether pixels, channels (NIRS), or voxels (fMRI) in
%a neuroimage, or simply correspond
%to one of the three dimensions of a 3D
%trajectory tracker, or perhaps a single detector in a
%physiological meter. It is in summary a channel of data
%which collapses the real 3D spatial dimensions.
%
% The temporal elements are the different data recordings
%at different time points.
%
%Finally, the signals are each stream of data received. For
%instance, in a NIRS image, it will be HbO2 and HHb (and perhaps
%cytochrome oxydasa), in an fMRI image that may be the BOLD
%response, in a tracker it may be ech of the tracked targets.
%
%
%In bringing all possible data into a common conceptual
%structure, it is now straight forward to manipulate all
%data in a similar way regardless of its origin.
%
%You can use 'NSamples', 'NChannels' and 'NSignals' in
%the get function to find out the number of time samples, spatial
%elements and signals respectively in the processedData.
%
% get(obj,'NSamples')
% get(obj,'NChannels')
% get(obj,'NSignals') 
%
%It is possible to access/modify the full stream of data
%data using
%
% get(obj,'Data') / set(obj,'Data')
%
%It is possible to access to the sub-images at:
%
% a) a certain time sample (getSample) i.e. a static image,
%   spatial distribution of all signals at the selected time.
% b) a certain location or spatial element (getChannel)
%   i.e. temporal course of all signals at the selected spatial element
% c) a certain signal (getSignal) i.e. full temporal and spatial
%   distribution of a particular signal.
%
%The processedData has an attached timeline with the associated
%experimental conditions onsets and durations. The length of this
%timeline is linked to the number of temporal samples of the image.
%See class timeline.
%
%% Signal Tags
%
%Signals can be assigned tags for easy recognition
%By default they will simply be named as 'Signal 1', 'Signal 2'
%and so on. It is recommended that if you derive new subclasses
%your new class will set this tags accordingly. These tags
%cannot be used to reference the signal, and their purpose
%is to be an easy "reminder" of which signal is which and
%to be used in figure legends.
%
%
%% Remarks
%
% I know. The class name is not particularly attractive, but my
%imagination is poor.
%
%% Properties
%
%   .id - A numerical identifier.
%   .description - A short description
%   .timeline - A timeline with its length attached to the data length.
%   .data - The data itself.
%   .integrity - Per channel integrity values.
%   .signalTags - A cell array of signals tags.
%
%% Known subclasses
%
% neuroimage - An neuroimage of any modality
% eyeTrack - Eye gaze recording
% physiologicalMeasurement - a physiological measurement
% trackingMeasurement - A 2D/3D target location/trajectory like data.
% body - A collection of rigidBodies.
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('structuredData') for a list of methods
% 
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also session, dataSource, neuroimage, timeline
%




%% Log
%
% File created: 20-Jun-2008
% File last modified (before creation of this log): 19-Apr-2010
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%



    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end




    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative} = 1; %Numerical identifier to make the object identifiable.
        description(1,:) char = 'StructuredData0001'; %A short description of the data.
        timeline(1,1) timeline = timeline; %The timeline of experimental conditions and events
        data(:,:,:) double = zeros(0,0,0); %The observation data in a 3D tensor format.
            %Ensures 3D
        integrity(1,1) integrityStatus = integrityStatus; %The integrity record for quality control.
        signalTags(1,:) cell = cell(1,0); %The list of signal tags.
    end

    properties (Dependent)
        nSamples
        nChannels
        nSignals
    end




    methods
        function obj=structuredData(varargin)
            %STRUCTUREDDATA StructuredData class constructor
            %
            % obj=structuredData() creates a default structuredData
            %   with ID equals 1.
            %
            % obj=structuredData(obj2) acts as a copy constructor
            %
            % obj=structuredData(id) creates a new structuredData
            %   with the given identifier (id). The name of the
            %   structuredData is initialised to
            %   'StructuredDataXXXX' where is the id preceded with 0.
            %
            % obj=structuredData(id,size) creates a new structuredData
            %   with the indicated identifier and size, where size
            %   is a vector <nSamples,nChannels,nSignals>. The
            %   data will be initialized to 0s.
            %
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'structuredData')
                obj=varargin{1};
                return;
            else
                obj.id =varargin{1};
                if (nargin>1) %Image size also provided
                    if ((isnumeric(varargin{2})) && (length(varargin{2})==3))
                        obj.integrity=setNElements(obj.integrity,varargin{2}(2));
                        obj.data=zeros(varargin{2});
                        nSignals=varargin{2}(3);
                        obj.signalTags=cell(1,nSignals);
                        for ii=1:nSignals
                            obj.signalTags(ii)={['Signal ' num2str(ii)]};
                        end
                        
                        t = obj.timeline;
                        t.length = varargin{2}(1);
                        obj.timeline=t;

                        
                    else
                        error('ICNNA:structuredData:set:InvalidPropertyValue',...
                            ['Not a valid size vector; ' ...
                            '[nSamples, nChannels, nSignals].']);
                    end
                end
            end
            obj.description = ['StructuredData' num2str(obj.id,'%04i')];
            obj.integrity=integrityStatus(obj.nChannels);
            assertInvariants(obj);
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end


    methods


      %Getters/Setters

      function res = get.id(obj)
         %Gets the object |id|
         res = obj.id;
      end
      function obj = set.id(obj,val)
         %Sets the object |id|
         obj.id = val;
         %assertInvariants(obj);
      end


      function res = get.description(obj)
         %Gets the object |description|
         res = obj.description;
      end
      function obj = set.description(obj,val)
         %Sets the object |description|
         obj.description = val;
         %assertInvariants(obj);
      end


      function res = get.timeline(obj)
         %Gets the object |timeline|
         %
         % An timeline object
         res = obj.timeline;
      end
      function obj = set.timeline(obj,val)
         %Sets the object |timeline|
         %
         % An timeline object
         obj.timeline = val;
         %assertInvariants(obj);
      end


      
      function res = get.integrity(obj)
         %Gets the object |integrity|
         %
         % An integrityStatus object
         res = obj.integrity;
      end
      function obj = set.integrity(obj,val)
         %Sets the object |integrity|
         %
         % An integrityStatus object
         obj.integrity = val;
         %assertInvariants(obj);
      end


      function res = get.nSamples(obj)
         %(DEPENDENT) Gets the object |nSamples|
         %
         % The number of samples in the data.
         % This is equivalent to size(obj.data,1)
         res = size(obj.data,1);
      end
      function obj = set.nSamples(obj,val)
         %Sets the object |nSamples|
         %
         % Update the current number of samples
         % Data and timeline are cropped or zero padded as necessary
           if (isscalar(val) && isnumeric(val) && val==floor(val) && val>=0)
               if (val~=obj.nSamples)
                   t = obj.timeline;
                   t.length = obj.nSamples;
                   obj.timeline = t;
                   if (val<obj.nSamples) %Decrease size
                       obj.data(val+1:end,:,:)= [];
                   else %Increase size
                       if isempty(obj.data)
                           obj.data(end+1:val,:,:)= zeros(val-obj.nSamples,0,0);
                       else
                           obj.data(:,end+1:val,:,:)= 0;
                       end
                   end
               end
           else
               error('ICNNA:structuredData:set:InvalidPropertyValue',...
                     ['Number of (time) samples must be 0 ' ...
                   'or a positive integer']);
           end
           %assertInvariants(obj);
      end


      function res = get.nChannels(obj)
         %(DEPENDENT) Gets the object |nChannels|
         %
         % The number of channels in the data.
         % This is equivalent to size(obj.data,2)
         res = size(obj.data,2);
      end
      function obj = set.nChannels(obj,val)
         %Sets the object |nChannels|
         %
         % Update the current number of channels
         % Data and timeline are cropped or zero padded as necessary
           if (isscalar(val) && isnumeric(val) && val==floor(val) && val>=0)
               if (val~=obj.nChannels)
                   if (val<obj.nChannels) %Decrease size
                       obj.data(:,val+1:end,:)= [];
                   else %Increase size
                       if isempty(obj.data)
                           obj.data(:,end+1:val,:)= zeros(0,val-obj.nChannels,0);
                       else
                           obj.data(:,end+1:val,:)= 0;
                       end
                   end
               end
               obj.integrity= setNElements(obj.integrity,obj.nChannels);
           else
               error('ICNNA:structuredData:set:InvalidPropertyValue',...
                     ['Number of channels must be 0 ' ...
                   'or a positive integer']);
           end
           %assertInvariants(obj);
      end


      function res = get.nSignals(obj)
         %(DEPENDENT) Gets the object |nSignals|
         %
         % The number of signals in the data.
         % This is equivalent to size(obj.data,3)
         res = size(obj.data,3);
      end
      function obj = set.nSignals(obj,val)
         %Sets the object |nSignals|
         %
         % Update the current number of signals
         % Data and timeline are cropped or zero padded as necessary
           if (isscalar(val) && isnumeric(val) && val==floor(val) && val>=0)
               if (val~=obj.nSignals)
                   if (val<obj.nSignals) %Decrease size
                       obj.data(:,:,val+1:end)= [];
                       obj.signalTags(val+1:end)= [];
                   else %Increase size
                       if isempty(obj.data)
                           obj.data(:,:,end+1:val)= zeros(0,0,val-obj.nSignals);
                       else
                           obj.data(:,:,end+1:val)= 0;
                       end
                       nNewSignals=val-length(obj.signalTags);
                       tmpTags=cell(1,nNewSignals);
                       for tt=1:nNewSignals
                           tmpTags(tt)={['Signal ' ...
                                num2str(tt+length(obj.signalTags))]};
                       end
                       obj.signalTags(end+1:val)=tmpTags;  
                   end
               end
           else
               error('ICNNA:structuredData:set:InvalidPropertyValue',...
                     ['Number of signals must be 0 ' ...
                   'or a positive integer']);
           end
           %assertInvariants(obj);
      end


      function res = get.data(obj)
         %Gets the object |data|
         %
         % The full data. 3D matrix holding <samples,channels,signals>
         res = obj.data;
      end
      function obj = set.data(obj,val)
         %Sets the object |data|
         %
         % The full data. 3D matrix holding <samples,channels,signals>
            if (isnumeric(val)) % && ndims(val)==3) %This ndims test will not work if there's only 1 signal!!
               [v_nSamples,v_nChannels,v_nSignals]=size(val);
               if isempty(val)
                   %val will be empty as long as either
                   %nSamples, nChannels or nSignals is 0.
                   %however, the other two elements of the vector may not
                   %be 0.
                   %%%%obj.data=zeros(0,0,0); %Do not use it like this
                   %%%%          %otherwise rawData_TobiiEyeTracker
                   %%%%          %will crash upon converting empty
                   %%%%          %data.
                   obj.data=zeros(v_nSamples,v_nChannels,v_nSignals);
                        %Ensure a 3D matrix
                        %so that derivate attributes NSamples,
                        %NChannels and NSignals works correctly
               else
                   obj.data = val;
               end
               t = obj.timeline;
               t.length = obj.nSamples;
               obj.timeline = t;
               obj.integrity= setNElements(obj.integrity,obj.nChannels);
               if v_nSignals>length(obj.signalTags)
                       nNewSignals=v_nSignals-length(obj.signalTags);
                       tmpTags=cell(1,nNewSignals);
                       for tt=1:nNewSignals
                           tmpTags(tt)={['Signal ' ...
                                num2str(tt+length(obj.signalTags))]};
                       end
                       obj.signalTags(end+1:v_nSignals)=tmpTags;
               elseif v_nSignals<length(obj.signalTags)
                   obj.signalTags(v_nSignals+1:end)= [];
               end
           else
               error('ICNNA:structuredData:set:InvalidPropertyValue',...
                     'Data must be a numeric');
           end
           %assertInvariants(obj);
      end


      function res = get.signalTags(obj)
         %Gets the object |signalTags|
         res = obj.signalTags;
      end
      function obj = set.signalTags(obj,val)
         %Sets the object |signalTags|
         obj.signalTags = val;
         %assertInvariants(obj);
      end






    end

end

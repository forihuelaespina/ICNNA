%Class structuredData
%
%A structured data represents a source of data stored
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
% Copyright 2008-10
% @date: 20-Jun-2008
% @author: Felipe Orihuela-Espina
% @modified: 19-Apr-2010
%
% See also session, dataSource, neuroimage, timeline
%
classdef structuredData
    properties (SetAccess=private, GetAccess=private)
        id=1;
        description='StructuredData0001';
        timeline=timeline;
        data=zeros(0,0,0); %Ensure 3D
        integrity=integrityStatus;
        signalTags=cell(1,0);
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
                obj=set(obj,'ID',varargin{1});
                if (nargin>1) %Image size also provided
                    if ((isnumeric(varargin{2})) && (length(varargin{2})==3))
                        obj.integrity=setNElements(obj.integrity,varargin{2}(2));
                        obj.data=zeros(varargin{2});
                        nSignals=varargin{2}(3);
                        obj.signalTags=cell(1,nSignals);
                        for ii=1:nSignals
                            obj.signalTags(ii)={['Signal ' num2str(ii)]};
                        end
                        
                        obj.timeline=set(obj.timeline,'Length',varargin{2}(1));

                        
                    else
                        error(['Not a valid size vector; ' ...
                            '[nSamples, nChannels, nSignals].']);
                    end
                end
            end
            obj=set(obj,'Description',...
                    ['StructuredData' num2str(obj.id,'%04i')]);
            obj.integrity=integrityStatus(get(obj,'NChannels'));
            assertInvariants(obj);
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
end

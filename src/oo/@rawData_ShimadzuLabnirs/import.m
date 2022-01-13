function obj=import(obj,filename)
%RAWDATA_SHIMADZULABNIRS/IMPORT Reads the converted hemodynamic concentrations 
%
% obj=import(obj,filename) Reads the converted hemodynamic concentrations.
%   This will overwrite any previous data in the corresponding probe set. 
%
%
%
%
%% The Shimadzu Labnirs device data
%
% lthough, the
%Shimadzu device can provide the raw data into a .OMM file, this file is
%not stored on plain text and currently we have no access to the file
%format. Currently we only have access to the already converted data that
%comes in a .csv file.
%
% The original file also contains some experimental parameters such as
%the sampling rate, channel distribution,a dn variable interoptode
%distance, wavelengths, etc... but again, we currently do not have
%access to it.
%
% While departing from the converted hemodynamic data we have no
%information about the interoptode distance or channel location.
% The Shimadzu Labnirs operates at 4 wavelengths:
%   {Dark, 780, 805, 830}
%
%... from which 3 haemoglobin species are reconstructed (oxy-, deoxy-, and
%total). Note that the total hemoglobin is not calculated as the sum of oxy
%and deocy but actually reconstructed as another physiological paranmeter.
%
%The data which has been provided to us, has 84 channels but the system can
%hold more than that.
%
% Data is the reconstructed haemoglobin concentrations file comes as
%follows:
%
% + Line 1: Channel headers (3 columns per channel)
% + Line 2: Signal headers (timestamps, timeline flags, mark, and data)
% + Lines 3-end: Hb data
%
% Note that available data at this point is already reconstructed.
%
%
%
%

%% Remarks
%
% Please note that the optode "effective" wavelengths at the different
% channels at which the optode is working might slightly differ from
% the "nominal" wavelengths. These effective wavelengths are also
% available at the Hitachi file, for each of the channels.
% However ICNA is not taking that into account at the moment, and I
% consider the nominal waveleghts to be the effective wavelengths.
%
%
% No effort is currently made in checking whether the file is
% an original Shimadzu Labnirs Hb converted data file. This is simply
% assumed to be true.
%
%% Parameters
%
% filename - The Shimadzu Labnirs Hb converted data file to import
%
%
% 
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 23-Sep-2016
%
% See also rawData_ShimadzuLabnirs, convert
%



%% Log
%
% 
%


% % Open the data file for conversion
% fidr = fopen(filename, 'r');
% if fidr == -1
%     error('ICNA:rawData_ShimadzuLabnirs:import:UnableToReadFile',...
%           'Unable to read %s\n', filename);
% end
% 
% 
% % h = waitbar(0,'Reading header...',...
% %     'Name','Importing raw data (Shimadzu Labnirs)');
% %fprintf('Importing raw data (Shimadzu Labnirs) -> 0%%');
% 
% %Read all file at once
% raw = textscan(fidr,'%s');
% 
% fclose(fidr);
% 
% %Discard header
% raw(1:2,:) =[];
% 
% %x=0.15;
% %waitbar(x,h,'Reading Data - 15%');
% %fprintf('\b\b\b15%%');

raw = csvread(filename,2,0); %Already ignores heading


%% Reading the Data ================================

%Get the timestamps
obj.timestamps = raw(:,1);

%Get the preTimeline flags
obj.preTimeline = raw(:,2);

%Get the marks
obj.marks = raw(:,3);

%Get the raw data
obj=set(obj,'rawData',raw(:,4:end));

%waitbar(1,h);
%close(h);
%fprintf('\b\b\b100%%\n');

assertInvariants(obj);


end
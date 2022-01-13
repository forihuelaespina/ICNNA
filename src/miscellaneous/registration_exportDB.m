function registration_exportDB(filename,g,DOptodes, DChannels)
%Export the registration distances database
%
% registration_exportDB(filename,g,DOptodes, DChannels) Export the
%       registration distances to a .csv formatted database
%
%% Parameters
%
% filename - The output filename
% g - The registered mesh
% DOptodes - Distances of optodes as obtained with registration_getDistances
% DChannels - Distances of channels as obtained with registration_getDistances
%
%
%
%
% Copyright 2014
% @date: 25-Mar-2014
% @author: Felipe Orihuela-Espina
% @modified: 25-Mar-2014
%
% See also 
%

   % Open the file for writing
   fidr = fopen(filename, 'w');
   if fidr == -1
       error('ICAF:registration_exportDB:UnableToOpenFile',...
           ['Unable to open ' filename]);
   end
   
   nPoints=size(g.coords,1);
   nOptodes=size(DOptodes,2);
   nChannels=size(DChannels,2);
   
   %Column Headers
   fprintf(fidr,'Position, ');
   for oo=1:nOptodes
        fprintf(fidr,'Optode  %d, ',oo);
   end
   for ch=1:nChannels
        fprintf(fidr,'Channel  %d, ',ch);
   end

   %Data
   for pp=1:nPoints
       if ~isempty(g.tags{pp}) %Exclude "irrelevant" untagged vertex
            fprintf(fidr,'\n%s, ',g.tags{pp});
            fprintf(fidr,'%.2f, ',DOptodes(pp,:));
            fprintf(fidr,'%.2f, ',DChannels(pp,:));
       end
   end

   fprintf(fidr,'\n');
   fclose(fidr);

   
end


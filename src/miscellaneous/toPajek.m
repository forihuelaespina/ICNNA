function toPajek(A,options)
%Exports graph to Pajek
%
% toPajek(A) Exports graph to Pajek
%
% toPajek(...,options) Exports graph to Pajek with the
%   indicated options
%
%% PARAMETERS
%
% A - Graph (Currently represented by a connectivity matrix
% options - A struct of options
%   .outputFile -  The output filename
%   .setVertexLocation - True if you want your vertex <x,y,z> locations
%       output to the file. This may only work with limited experiments
%       as this code inherited from previous ICNA versions. False
%       if you do not want your vertex locations to be written in the
%       output file, whether by preference or because this function
%       lacks support for your experiment (feel free to add it yourself!).
%   .vertexLocationConfig - A short string indicating the locations.
%       I might alter this in the future to accept here a locations matrix.
%
%% OUTPUT
%
% A file ready for Pajek
%
%
% Copyright 2010-13
% @date: 12-Jan-2010
% @author: Felipe Orihuela-Espina
% @modified: 9-Apr-2013
%
% See also structuredData, getConnectivity
%

%% Deal with options
opt.outputFile='./Pajek001.net';
opt.setVertexLocation = true;
opt.vertexLocationConfig = 'MICCAI2010';
if exist('options','var')
    if isfield(options,'outputFile')
        opt.outputFile = options.outputFile;
    end
    if isfield(options,'setVertexLocation')
        opt.setVertexLocation = options.setVertexLocation;
    end
    if isfield(options,'vertexLocationConfig')
        opt.vertexLocationConfig = options.vertexLocationConfig;
    end
end

nVertex = size(A,1);
nodeShape = 'circle'; %ellipse, box, diamond, triangle, cross, empty
nodeColor = 'Red';
nodeBorderColor = 'Black';  

fid = fopen(opt.outputFile,'w');
if fid == -1
    error('Unable to open file.');
end


%Each vertex is described using following description line:
%vertex num label [x y z] [shape] [changes of default parameters]
%See pajek manual, pg 71
fprintf(fid,'*Vertices %d\r\n',nVertex);
for vv=1:nVertex
    vStr='';
    vStr = [vStr num2str(vv)]; %Vertex number
    vStr = [vStr ' "Ch. ' num2str(vv) '"']; %Vertex label
    if opt.setVertexLocation
        [x,y,z]=getVertexLocation(vv,opt.vertexLocationConfig);
        vStr = [vStr ' ' num2str(x) ...
                     ' ' num2str(y) ...
                     ' ' num2str(z)]; %Vertex location
    end
    vStr = [vStr ' ' nodeShape]; %Vertex shape;
    vStr = [vStr ' ic ' nodeColor]; %Vertex color;
    vStr = [vStr ' bc ' nodeBorderColor]; %Vertex border color;
%   +-----------------------------------------+
%   | IMPORTANT: Pajek requires that the line |
%   | termination character is actually '\r\n'|
%   | instead of '\n' only!.                  |
%   +-----------------------------------------+
    vStr = [vStr '\r\n'];
%     fprintf(fid,'%d "Ch. %d" %s\r\n',vv,vv,nodeShape);
%     fprintf(fid,'%d ''Ch. %d'' %s ic %s bc %s\r\n',...
%             vv,vv,nodeShape,nodeColor,nodeBorderColor);
    fprintf(fid,vStr);
end

fprintf(fid,'*Matrix\r\n');
for vv=1:nVertex
    fprintf(fid,'%.02f ',A(vv,:));
    fprintf(fid,'\r\n');
end

fclose(fid);

end


%% AUXILIAR FUNCTION
function [x,y,z]=getVertexLocation(vv,config)
%Return a vertex location

%Locations are between 0 and 1
switch lower(config)
    case 'miccai2010'
                imgSize=[460 360];%Width x Height
                %In pixels...
                loc=[407 180 0; ...
                     384 217 0; ...
                     402 119 0; ...
                     374 159 0; ...
                     340 204 0; ...
                     369 103 0; ...
                     332 151 0; ...
                     368 52 0; ...
                     331 98 0; ...
                     296 137 0; ...
                     333 41 0; ...
                     288 87 0; ...
                     88 193 0; ...
                     51 166 0; ...
                     141 187 0; ...
                     97 150 0; ...
                     57 112 0; ...
                     150 141 0; ...
                     99 100 0; ...
                     197 137 0; ...
                     150 95 0; ...
                     121 65 0; ...
                     204 93 0; ...
                     177 54 0];
                %Normalize
                loc(:,1) = loc(:,1)/imgSize(1);
                loc(:,2) = loc(:,2)/imgSize(2);
    case 'cgc'
                imgSize=[640 614];%Width x Height
                %In pixels...
                loc=[174 112 0; ...
                     314 110 0; ...
                     452 101 0; ...
                     119 194 0; ...
                     250 197 0; ...
                     390 190 0; ...
                     520 178 0; ...
                     190 276 0; ...
                     326 275 0; ...
                     461 262 0; ...
                     140 340 0; ...
                     256 352 0; ...
                     394 341 0; ...
                     524 322 0; ...
                     206 413 0; ...
                     326 416 0; ...
                     460 400 0; ...
                     166 466 0; ...
                     270 473 0; ...
                     392 473 0; ...
                     521 446 0; ...
                     227 524 0; ...
                     336 528 0; ...
                     455 515 0];
                %Normalize
                loc(:,1) = loc(:,1)/imgSize(1);
                loc(:,2) = loc(:,2)/imgSize(2);
        
    otherwise
        error('Unexpected vertex location configuration');
end
x=loc(vv,1);
y=loc(vv,2);
z=loc(vv,3);
end
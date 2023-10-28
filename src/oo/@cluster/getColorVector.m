function rgb=getColorVector(ch)
%CLUSTER/GETCOLORVECTOR Returns a color vector from a caracter color 
%descriptor or an empty string if the caracter is not recognised.


%% Log
%
% File created: 21-Jul-2008 (corresponding to initial parent method set)
% File last modified (before creation of this log): N/A. This method had
%   not been modified since creation.
%
% 28-May-2023: FOE
%   + Method separated from method set and declared explicitly in class
%   description
%   + Added this log.
%

switch (ch)
    case 'r'
        rgb = [1 0 0];
    case 'g'
        rgb = [0 1 0];
    case 'b'
        rgb = [0 0 1];
    case 'k'
        rgb = [0 0 0];
    case 'w'
        rgb = [1 1 1];
    case 'm'
        rgb = [1 0 1];
    case 'c'
        rgb = [0 1 1];
    case 'y'
        rgb = [1 1 0];
    otherwise
        rgb=[];
end


end   
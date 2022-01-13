function display(obj)
%INTEGRITYSTATUS/DISPLAY Command window display of an integrityStatus
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 14-May-2008
% @author Felipe Orihuela-Espina
%
% See also integrityStatus, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
nelem=length(obj.elements);
for ee=1:nelem
    switch(obj.elements(ee))
        case obj.UNCHECK
            codeTag = 'Uncheck';
        case obj.FINE
            codeTag = 'Fine';
        case obj.MISSING
            codeTag = 'Missing';
        case obj.NOISE
            codeTag = 'Noise';
        case obj.OTHER
            codeTag = 'Other';
        
        case obj.MIRRORING
            codeTag = 'Saturation; Mirroring';
        case obj.NONRECORDINGS
            codeTag = 'Saturation; Non Recordings';
        case obj.NEGATIVERECORDINGS
            codeTag = 'Negative Light Recordings';
        case obj.OPTODEMOVEMENT
            codeTag = 'Optode movement';
        case obj.HEADMOTION
            codeTag = 'Head motion';
            
        otherwise
            codeTag = [num2str(obj.elements(ee)) ' - Code not recognised'];
        
    end
    disp(['   Element ' num2str(ee) ': ' codeTag]);
end
disp(' ');

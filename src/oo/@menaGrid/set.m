function obj = set(obj,varargin)
% MENAGRID/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%% Properties
%
% 'ID' - Changes the identifier of the object
% 'EdgeLineWidth' - Width of the frame lines
% 'EdgeLineColor' - The color of the frame lines as a normalized
%       RGB vector.
% 'HighlightCells' - A vector of indexes to grid cells that must be
%       highlighted
% 'HighlightEdgeColor' - The color of the cell boundaries as a normalized
%       RGB vector.
% 'HighlightFaceColor' - The color of the cell background as a normalized
%       RGB vector.
% 'HighlightFaceAlpha' - Transparency of the cell background. Value
%       must be in the range [0 1].
% 'LabelCells' - Whether to make the cell labels visible
% 'VertexVisible' - Visualize the grid vertex
% 'VertexColor' - Color of the marker representing the grid vertexes
%       as a nromalized RGB vector.
% 'VertexMarker' - Marker representing the grid vertexes
% 'VertexMarkerSize' - Size of the marker representing the grid vertexes
%
%
% Copyright 2008
% @date: 15-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also menaGrid, get
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case 'ID'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
            && (val==floor(val)) && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
            obj.id = val;
        else
            error('ICNA:menaGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
        end

        case 'EdgeLineWidth'
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
                obj.lineWidth = val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Value must be a scalar natural/integer');
            end

       case 'EdgeLineColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.edgeColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.edgeColor=val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end

            
       case 'HighlightCells'
           if (all(isreal(val)) &&  ~ischar(val) ...
               && all(val==floor(val)) && all(val>0) ...
               && all(val<=getNCells(obj)))
              obj.highlightCells= sort(unique(val));
           else
              error('ICNA:menaGrid:set:InvalidPropertyValue',...
                    ['Cell indexes must be a list positive ' ...
                     'integers and be within the number of ' ...
                     'existing cells.']);
           end

       case 'HighlightEdgeColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.highlightEdgeColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.highlightEdgeColor=val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end

       case 'HighlightFaceColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.highlightFaceColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.highlightFaceColor=val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end

    case 'HighlightFaceAlpha'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
             && (val>=0) && (val<=1))
            obj.highlightFaceAlpha = val;
        else
            error('ICNA:menaGrid:set:InvalidPropertyValue',...
                  'Value must be a positive real between 0 and 1.');
        end

        case 'LabelCells'
            if (~ischar(val) && isscalar(val))
                obj.labelCells=logical(val);
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end

        case 'VertexVisible'
            if (~ischar(val) && isscalar(val))
                obj.vertexVisible=logical(val);
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Value must be boolean');
            end

       case 'VertexColor'
            if (ischar(val) && length(val)==1)
                rgb=getColorVector(val);
                if isempty(rgb)
                    error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Invalid color descriptor.');
                else
                    obj.vertexColor=rgb;
                end
            elseif (isreal(val) && all([1 3]==size(val)) && ...
                    all(val<=1) &&  all(val>=0))
                obj.vertexColor=val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end

        case 'VertexMarker'
            if (ischar(val) && length(val)==1)
                if (ismember(val,'+o*.xsv^d><ph'))
                    obj.vertexMarker = val;
                else
                    error('ICNA:menaGrid:set:InvalidPropertyValue',...
                      'Invalid marker');
                end
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Value must be a char');
            end

        case 'VertexMarkerSize'
            if (isscalar(val) && isreal(val) && floor(val)==val && val>=0)
                obj.vertexMarkerSize = val;
            else
                error('ICNA:menaGrid:set:InvalidPropertyValue',...
                        'Invalid markerSize. Must be a positive integer.');
            end


    otherwise
      error(['Property ' prop ' not valid.'])
   end
end

end

function rgb=getColorVector(ch)
%Returns a color vector from a caracter color descriptor
%or an empty string if the caracter is not recognised.
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
    
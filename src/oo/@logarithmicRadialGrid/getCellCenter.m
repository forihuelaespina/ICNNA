function center=getCellCenter(obj,varargin)
%LOGARITHMICRADIALGRID/GETCELLCENTER Get the cartesian center of a cell
%
% center=getCellCenter(obj,posAngular,posRadial) Get the cartesian
%    center of a cell
%
%
% Copyright 2008
% date: 15-Aug-2008
% Author: Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, getNCells, inWhichCells, gridCell2ind,
% ind2gridCell
%

%Using varargin so it is compatible with superclass abstract definition
posAngular=varargin{1};
posRadial=varargin{2};


if ((posAngular==0) || (posRadial==0)) %central cell
    center=[0 0];
else
    %Algorithm for determining the intersection point of
    %two lines (or line segments) in 2 dimensions.
    %http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
    %
    % P1=(x1,y1);     P3 *\        * P2
    % P2=(x2,y2);          \ __   /
    % P3=(x3,y3);               \x__
    % P4=(x4,y4);               /   \__
    %                       P1 *       \__
    %                                     * P4
    %

    cartesianPol=getPolygon(obj,posAngular,posRadial);

    P1=[cartesianPol(1,1) cartesianPol(1,2)];
    P4=[cartesianPol(2,1) cartesianPol(2,2)];
    P2=[cartesianPol(3,1) cartesianPol(3,2)];
    P3=[cartesianPol(4,1) cartesianPol(4,2)];

    % The equations of the lines are
    %
    % Pa = P1 + ua ( P2 - P1 )
    %
    % Pb = P3 + ub ( P4 - P3 )
    %
    %Solving for the point where Pa = Pb gives the
    %following two equations in two unknowns (ua and ub)
    %
    %   x1 + ua (x2 - x1) = x3 + ub (x4 - x3)
    %
    %and
    %
    %   y1 + ua (y2 - y1) = y3 + ub (y4 - y3)
    %
    %Solving gives the following expressions for ua and ub
    %
    %       (x4-x3)(y1-y3)-(y4-y3)(x1-x3)
    % ua = ---------------------------------
    %       (y4-y3)(x2-x1)-(x4-x3)(y2-y1)
    %
    %       (x2-x1)(y1-y3)-(y2-y1)(x1-x3)
    % ub = ---------------------------------
    %       (y4-y3)(x2-x1)-(x4-x3)(y2-y1)
    %
    %The denominators for the equations for ua and ub are the same.
    % If the denominator for the equations for ua and ub is 0 then
    %the two lines are parallel.
    % If the denominator and numerator for the equations
    %for ua and ub are 0 then the two lines are coincident.

    den = (P4(2)-P3(2))*(P2(1)-P1(1)) - (P4(1)-P3(1))*(P2(2)-P1(2));
    if(den==0)
        error('ICNA:logarithmicRadialGrid:getCellCenter:InvalidCell',...
            'Lines are parallel')
    end
    ua = ((P4(1)-P3(1))*(P1(2)-P3(2)) - (P4(2)-P3(2))*(P1(1)-P3(1)))/den;
    %ub = ((P2(1)-P1(1))*(P1(2)-P3(2)) - (P2(2)-P1(2))*(P1(1)-P3(1)))/den;

    %Substituting either of these into the corresponding equation
    %for the line gives the intersection point. For example the
    %intersection point x=(x,y) is
    %
    %   x = x1 + ua (x2 - x1)
    %   y = y1 + ua (y2 - y1)
    %
    %The equations apply to lines, if the intersection of line
    %segments is required then it is only necessary to test if
    %ua and ub lie between 0 and 1. Whichever one lies within
    %that range then the corresponding line segment contains the
    %intersection point. If both lie within the range of 0 to 1
    %then the intersection point is within both line segments.
    center(1) = P1(1) + ua*(P2(1) - P1(1));
    center(2) = P1(2) + ua*(P2(2) - P1(2));

end

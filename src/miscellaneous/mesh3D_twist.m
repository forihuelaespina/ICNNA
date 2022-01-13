function [g]=mesh3D_twist(g,theta,par1,par2)
%Twist a 3D mesh about an arbitrary axes
%
% [g]=mesh3D_twist(g,theta,p1,p2) Twist a 3D mesh theta angles
%	about an arbitrary axes specified by 2 points p1 and p2.
%
% [g]=mesh3D_twist(g,theta,alpha,beta) Twist a 3D mesh theta angles
%	about an axes specified by two angles (and implicitly the
%	origin of coordinates. Angle alpha is expressed in radians
%	and expressed the angle against the XZ plane. Angle beta
%	is expressed in radians and expressed against the XY plane.
%
%
%% Algorithm
%
% The axis of twist can be located anywhere (6 d.o.f.).
%The idea is to make the axis coincident with one of the
%coordinate axis (Z axes), rotate by theta and then transform
%back (Ref. [1]). The transformation matrix is given by the
%Jacobian of the deformation funcion (Ref. [2]).
%
%
%
%% Parameters
% g - a Nx3 matrix representing a 3D mesh of N points
% theta - Rotation angle in radians
%
%
% alpha,beta - rotation angles along the planes in radians.
%	Use 0 for no rotation
%
%	- OR -
%
% p1,p2 - points delimiting the rotation axes
%
%
%% References
%
% [1] http://www.cs.brandeis.edu/~cs155/Lecture_07_6.pdf
% [2] Barr. Alan H. (1984) "Global and local deformations of
%   solid primitives" SIGGRAPH'84 Computer Graphics, 18(3):21-30
%
%
% Copyright 2009
% @author Felipe Orihuela-Espina
% @date: 23-Mar-2009
%
% See also mesh3D_scale, mesh3D_traslation, mesh3D_rotation
%


error('NOT YET FINISHED')

%% Deal with options
if ((length(par1)==1) && (length(par2)==1))
   %Input parameters are expressed as angles
   p1=[0 0 0];
   %Convert the angles to the second point
   [x,y,z] = sph2cart(par1,par2,1); %Spherical coordinates to cartesian
   p2=[x,y,z];
elseif ((length(par1)==3) && (length(par2)==3))
   %Input parameters are expressed as points
   p1=par1;
   p2=par2;
else
    error('ICAF:mesh3D_rotation:InvalidInput',...
        'Invalid input parameters.');
end

%Express p1 and p2 as column vectors
p1=reshape(p1,3,1);
p2=reshape(p2,3,1);


%Step 1: Translate p1 to the origin
T=eye(4);
T(1,4)=-p1(1);
T(2,4)=-p1(2);
T(3,4)=-p1(3);

%Step 2: Rotate p2 onto the z axes (Change of coordinates)
%Step 2.1: Constructiing an orthonormal system
%Step 2.1a: Vector w parallel to rotation axes (p1,p2)
s=p2-p1; w=s/norm(s);
%Step 2.1b: Vector v perpendicular to w
if all(cross(w,[0; 0; 1])==[0; 0; 0])
    %The cross product of two parallel vectors will [0 0 0] whose norm is 0
    %Manually assign a perpendicular vector
    v=[0; 1; 0];
else
    a=cross(w,[0; 0; 1]); v=a/norm(a);
end
%Step 2.1c: Vector u forming a right handed orthonormal system with w and v
u=cross(v,w);
%Step 2.2: change of coordinate matrix
M=[u' 0; v' 0; w' 0; 0 0 0 1];

%Step 3: Twist object around Z axes by angle theta

%%See Ref. [2]
%%NOT YET WORKING

R=[cos(theta) -sin(theta) -x*sin(theta)-y*cos(theta) 0; ...
   sin(theta)  cos(theta)   x*cos(theta)-y*sin(theta) 0; ...
        0          0                1 0; ...
	    0          0                0 1];

%Step 4: Rotate the axis to the original orientation
%MM=inv(M); %Use of the invserse inv is not efficient nor necessary
MM = [u(1) v(1) w(1) 0; ...
      u(2) v(2) w(2) 0; ...
      u(3) v(3) w(3) 0; ...
       0    0    0   1];

%Step 5: Translate to original position
%TT=inv(T); %Use of the invserse inv is not efficient nor necessary
TT =  eye(4);
T(1,4)=p1(1);
T(2,4)=p1(2);
T(3,4)=p1(3);

%Solve the rotation in Homogeneous Coordinates
%4x4 * 4xN= 4xN
g= TT * MM * R * M * T *[g'; ones(1,size(g,1))];
g(4,:)=[];
g=g';
end

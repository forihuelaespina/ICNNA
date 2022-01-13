function [centre,sqradius] = nsphere(A)
% Calculates the centre and radius of an n-sphere
%
%   [centre,sqradius] = nsphere(A) Calculates the centre and radius of an n-sphere
%
%
%==========================================================
%
%Determines the centre and radius of a n-sphere in a N dimensional space.
%
%Let
%      A1 = <a11, a12, a13, ..., a1n>
%      A2 = <a21, a22, a23, ..., a2n>
%      A3 = <a31, a32, a33, ..., a3n>
%        ...
%  A(n+1) = <a(n+1)1, a(n+1)2, a(n+1)3, ..., a(n+1)n>
%
% be any given (n+1) point set in the N dimensional space.
% Then there exist a unique point
%
%       C = <c1, c2, c3, ..., cn>
%
% which is equidistant from all the given points and whose coordinates are
% given by
%            N1          N2          N3             Nn 
%      c1 = ----   c2 = ----   c3 = ---- ...  cn = ----
%           2*Dn        2*Dn        2*Dn           2*Dn
%
% provided Dn<>0, where
%
%          | a21-a11       a22-a12       a23-a13       ...    a2n-a1n  |
%          | a31-a11       a32-a12       a33-a13       ...    a3n-a1n  |
%     Dn = |   ...           ...           ...         ...      ...    |
%          | a(n+1)1-a11   a(n+1)2-a12   a(n+1)3-a13   ...  a(n+1)n-a1n|
%
% and Ni = Dn with the i-th column being replaced by P
%
%          |   Sum_i=1^n (a2i^2 - a1i^2)   |
%          |   Sum_i=1^n (a3i^2 - a3i^2)   |
%      P = |              ...              |
%          | Sum_i=1^n (a(n+1)i^2 - a1i^2) |
%
%
% The radius being the distance (Euclidean) between the center C and any
% of the points Ai in the points set.
%
%The points set will contain exactly n+1 points. Providing less points will
%result in the function returning an error as there are infinite n-spheres.
%Providing more points will result in the function yielding a warning and
%discarding the unnecessary points.
%
%% Remarks
%
% This code is inherited and updated from my PhD matlab code
%
% ---------------
% IMPORTANT NOTE:
% ---------------
% Now I rely on Bernd Gaertner miniball program!!
% It now returns the squared radius
%
% The Bernd Gaertner miniball program is available at:
%
%   http://www.inf.ethz.ch/personal/gaertner/miniball.html
%
%% Parameters:
% A - n+1 points set in the sphere surface. A (N+1)xN matrix where
% each row is an N dimensional points (represented by its N euclidean
% coordinates).
%
%% Output:
% centre - The euclidean coordinate vector for the centre
% sqradius - The squared radius of the sphere
%
%
%
% Copyright 2001-12
% @date: At some point during my PhD! :)
% @author: Felipe Orihuela-Espina
% @modified: 17-Jun-2012
%
% See also myAlphaShape
%

[nPoints,Dim] = size(A);

if (nPoints < Dim+1)
    error('Not enough points');
end

if (nPoints > Dim+1)
    warning('Too many points. Discarding unneccessary ones.');
    nPoints = Dim+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Using Bernd Gartner miniball
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Old code ==========
%save('./hull/data/tempMiniBallDataSet.txt','A','-ascii','-tabs')}
%temp = [1:nPoints];
%save('./hull/data/tempMiniBallSimplexes.txt','temp','-ascii','-tabs')
%unix(['./hull/myMiniBall' num2str(Dim) 'D.exe ' ...
%     './hull/data/tempMiniBallDataSet.txt ' ...
%     './hull/data/tempMiniBallSimplexes.txt ' ...
%     './hull/data/tempMiniBallOutput.txt']);
%%====================
dataFile='./tempMiniBallDataSet.csv';
outputFile='./tempMiniBallOutput.csv';
if ispc
    dlmwrite(dataFile,A,'delimiter',',','newline','pc');
    dos(['.\util\MyMiniBall.exe ' dataFile ' ' outputFile]);
elseif isunix
    dlmwrite(dataFile,A,'delimiter',',','newline','unix');
    unix(['./util/MyMiniBall_linux.exe ' dataFile ' ' outputFile]);
else
    %Write as default
    dlmwrite(dataFile,A,'delimiter',',');
    command=['./util/myMiniBall.exe ' dataFile ' ' outputFile];
    eval(['!' command]);
end

%%%Old code ==========
%centre = load('./hull/data/tempMiniBallOutput.txt');
%%====================
centre = dlmread(outputFile);
sqradius = centre(:,1);
centre(:,1) = []; %%Remove attached squared radius

delete(dataFile,outputFile); %Remove temporary files


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% My simple and direct approach
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % for i = 2:nPoints
% %     Dn(i-1,:) = A(i,:) - A(1,:);
% %     P(i-1) = sum(A(i,:).^2 - A(1,:).^2);
% % end
% % 
% % for i = 1:Dim
% %     N = Dn;
% %     N(:,i) = P';
% %     C(i) = det(N)/(2*det(Dn));
% % end
% % 
% % centre = C;
% % radius = norm(C-A(1,:));

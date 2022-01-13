function [aS, aC, alpha, T, thresholds] = myAlphaShape(X,boundaryIndexes,Del)
%Computes the alpha-shape and alpha-complex of dataset X
%
% [aS, aC, alpha, T, thresholds] = myAlphaShape(X)
%   Computes the alpha-shape and alpha-complex of dataset X.
%   NOTE: Calling the function in this form results in the slowest
%       possible execution. It assumes all points to be external (i.e.
%       in the boundary, and thus it has to compute the nsphere for all
%       simplexes.
%
% [aS, aC, alpha, T, thresholds] = myAlphaShape(X,boundaryIndexes)
%   Computes the alpha-shape and alpha-complex of dataset X. Indicating
%   those points in the boundary of the dataset allows discrimination
%   of internal simplexes, and thus speeds up the algorithm.
%
% [aS, aC, alpha, T, thresholds] = myAlphaShape(X,boundaryIndexes,Del)
%   Computes the alpha-shape and alpha-complex of dataset X.
%       NOTE: If Delaunay triangulation is avaible, but the points in
%       the boundary are not, then assume all points are external,
%       that is make boundaryIndexes=[1:size(X,1)].
%       
%
%
%The alpha complex of a set of points by definition includes the
%k-simplexes in the Delaunay triangulation such that k<=Dim. This means
%that it is not only the k-simplexes with k=Dim but also their faces, edges
%and vertexes. In fact by definition X is contained in the alpha-Complex.
%
%Formally I do not calculate the aC as it is defined by Edelsbrunner
%containing the k-simplex with k<Dim. In fact, I only care for the
%higher order k-simplexes (k=Dim). And I consider the alpha shape made only
%of those k-simplexes such that k=Dim-1. Although this is not
%mathematically accurate, is enough for our needs as we know that our model
%will produce a somehow compact hypervolume. This also simplifies lots of
%mathematical formalities! 
%
%Note that with this small variation, finding the smallest alpha so
%that the sites (points) are all contained in the alpha-shape is almost
%trivial; it is enough to find all the alpha thresholds defining the
%intervals associated to the k-simplexes /k=Dim in the alphaComplex and
%iterate through them increasing alpha until we find the first one that
%contains the whole X.
%
%The second half of the alpha test (r<alpha && emptyBall(c,r,X)) is no
%longer neccessary, as for the k-simplexes with k-Dim, there are only
%interior intervals (see [EdelsbrunnerH1994]).
%
% 17-Feb-05: Now the algorithm to find the alpha complex take advantage of
% the knowledge of the problem by discriminating some k-simplexes when at
% least one of its vertex are internal (not in the boundary!!). When all
% vertexes of the k-simplex are boundary points, then I cannot assure
% whether the simplex is internal or external, so I just continue relying
% on the alpha test.
%
%% Remarks
%
% This code is inherited and updated from my PhD matlab code.
%
%% Parameters:
% X - the data set of points. One row per point and one column per
%   dimension
%
% boundaryIndexes - Optional. Indexes of points known to be in
%   the boundary of the cloud of points.
%       Indicating the points in the boundary speeds up the
%   algorithm, by allowing to automatically include in the alpha complex
%   those simplexes which are internal (i.e. those for which at least
%   one vertex is internal, that is those who at least one point is NOT
%   in the boundary. If it is not known which points are in the boundary
%   of the cloud then you can "assume" all points are external, that is, make
%   boundaryIndexes equals [1:size(X,1)]. This means that no simplex will
%   automatically be known to be part of the alpha complex, and the
%   nsphere will be computed for all simplexes.
%       If the set X is a subset representing a region, pass the local
%   indexes as if X were a whole set.
%
% Del - Optional. Precalculated Delaunay triangulation.
%   Useful when the set of points has been divided in regions,
%   and the Delaunay has been precalculated for each region
%   separately and then merged.
%     IMPORTANT NOTE: Pass the final DT already merged!!! not the separated
%     ones for each region. And remember to correct the indexes!!
%
%
%% Output:
% The alpha-shape, alpha-complex and Delaunay triangulation of X
%
% aS - Alpha shape. Contains the faces of the alpha shape. Each row
%   is a face. The face is indicated as the indexes to the points
%   in the dataset X.
% aC - Alpha complex. Contains the simplexes of the alpha complex. Each row
%   is a simplex. The simplex is indicated as the indexes to the points
%   in the dataset X.
% alpha - Alpha value
% T - Delaunay triangulation
% thresholds
%
%% References
%
% [EdelsbrunnerH1983] Edelsbrunner, H.; Kirkpatrick, D. G. & Seidel, R.
%   On the shape of a set of points in the plane.
%   IEEE Transactions on Information Theory, 1983, IT-29(4):551-559
%
% [EdelsbrunnerH1994] Edelsbrunner, H. & Mücke, E. P.
%   Three-dimensional alpha shapes.
%   ACM Transactions on Graphics, 1994, 13(1):43-72
%
%
% Copyright 2001-12
% @date: At some point during my PhD! :)
% @author: Felipe Orihuela-Espina
% @modified: 17-Jun-2012
%
% See also nsphere, volumeOfTriangulation
%
[nPoints,Dim] = size(X);

if ~exist('boundaryIndexes','var')
    boundaryIndexes=[1:size(X,1)];
        %Since I do not know the boundary points, assume all points are
        %external. This will force the algorithm to compute the nsphere
        %for all simplexes.
end    

%Calculate Dalaunay triangulation
if (nargin <3)
    disp([datestr(now(),13) ': Calculating Delaunay triangulation'])
    T=delaunayn(X);
else
    disp([datestr(now(),13) ': Fetching precalculated Delaunay triangulation'])
    T=Del;
end
T=sort(T,2);
disp(['   ' num2str(length(T)) ' number of simplexes'])
disp(['   ' num2str(floor(log2(length(T)))+1) ' maximum iterations expected'])

%Calculate intervals (alpha thresholds)
disp([datestr(now(),13) ': Calculating intervals'])
for s=1:length(T(:,1))
    if (mod(s,25000) == 0)
        disp(['   ' datestr(now(),13) ': Point ' num2str(s)])
    end
    if (length(intersect(boundaryIndexes,T(s,:))) < Dim+1)
        %At least one vertex is internal
        radius(s) = -1; %%Note that a radius cannot be negative, so setting
                        %%the radius to -1, means that they will always
                        %%be smaller than any alpha, and therefore the
                        %%simplex will be considered internal.
    else %all vertex are external
        [c,r] = nsphere(X(T(s,:),:));
        radius(s) = sqrt(r); %Note that the radius as returned by nsphere is squared
    end
end

%%Temporarily attach the Delaunay triangulation k-simplexes (k=Dim) to
%%their smallest wrapping n-sphere radius, so I can sorted them by this
%%criteria.
intervalsAndDT = sortrows([radius' T]);
intervals = intervalsAndDT(:,1)';
%Rocover sorted T (now the k-simplexes in T are sorted according to the
%radius of their envolving n-sphere)
T = intervalsAndDT;
thresholds = T(:,1);
T(:,1)=[]; %Deattach radius (thresholds)
clear intervalsAndDT

%Calculate alpha complex (Choose simplexes from DT in aC)
disp([datestr(now(),13) ': Calculating minimum \alpha'])
radius = sort(radius);


%%-1 is the "artificial" alpha that I have assigned to those k-simplexes in
%%Delaunay triangulation which I know are internal. In this sense, it is
%%for sure that -1 CANNOT be the alpha for the set of points. So in order
%%to reduce the number of interations in the loop for looking for the right
%%alpha I can reduce the list of valid thresholds by dropping those -1.
if (~isempty(find(intervals ~= -1)))
    intervals = intervals(min(find(intervals ~= -1)):length(intervals));
end

while (length(intervals) > 1)
    %Take the middle value
    alpha = intervals(floor(length(intervals)/2));
    disp(['   ' datestr(now(),13) ': Testing \alpha=' num2str(alpha)])

    aC=T;
    lastValidSimplex = find(radius == alpha); %Radius has been previously sorted
    lastValidSimplex = lastValidSimplex(length(lastValidSimplex)); %%Last
    aC(lastValidSimplex+1:length(aC(:,1)),:)=[];
    
% %     %%Temporarily build alpha-complex (Choose simplexes from DT in aC)
% %     nSimplexesInAlphaComplex = 0;
% %     for s=1:length(T(:,1))
% %         simplex = T(s,:);
% %         if (alphaTestT(alpha,simplex,X))
% %             nSimplexesInAlphaComplex = nSimplexesInAlphaComplex + 1;
% %             aC(nSimplexesInAlphaComplex,:) = simplex;
% %         end
% %     end

    %Test if X is contained in the alphaComplex (valid alpha)
    if (isempty(find(isnan(tsearchn(X,aC,X)) == 1)))
        disp(['      X contained in aC -> Valid alpha (=' num2str(alpha) ')'])
        intervals = intervals(1:floor(length(intervals)/2));
    else
        disp(['      X NOT contained in aC -> not valid alpha (=' num2str(alpha) ')'])
        intervals = intervals(floor(length(intervals)/2)+1:length(intervals));
    end
end
%At the end of the loop the interval has only 1 position with the right
%alpha!! ...so just build the aC with that alpha

%%Build alpha-complex (Choose simplexes from DT in aC)
alpha = intervals(1);
% %%Manual increase of minimum alpha
% indAlpha = find(radius == alpha);
% for d=1:Dim
%     if ((indAlpha+1)<length(radius))
%         indAlpha = indAlpha +1;
%     end
% end
% alpha = radius(indAlpha);

disp([datestr(now(),13) ': Calculating \alpha-complex for \alpha=' ...
      num2str(alpha)])
  
      aC=T;
      lastValidSimplex = find(radius == alpha); %Radius has been previously sorted
      lastValidSimplex = lastValidSimplex(length(lastValidSimplex)); %%Last
      aC(lastValidSimplex+1:length(aC(:,1)),:)=[];

      
% nSimplexesInAlphaComplex = 0;
% for s=1:length(T(:,1))
%     simplex = T(s,:);
%     if (alphaTestT(alpha,simplex,X))
%         nSimplexesInAlphaComplex = nSimplexesInAlphaComplex + 1;
%         aC(nSimplexesInAlphaComplex,:) = simplex;
%     end
% end
if (isempty(find(isnan(tsearchn(X,aC,X)) == 1)))
    disp(['      X contained in aC -> Valid alpha (=' num2str(alpha) ')'])
else
    disp(['      X NOT contained in aC -> not valid alpha (=' num2str(alpha) ')'])
end


%Calculate alpha-Shape (surface -boundary- faces of aC)
disp([datestr(now(),13) ': Calculating \alpha-shape'])
aC = sort(aC,2);

Permut = nchoosek([1:1:Dim+1],length(1:1:Dim+1)-1);
faces = [];
for pp = 1:length(Permut(:,1))
    faces = [faces; aC(:,Permut(pp,:))];
end    

faces=sortrows(faces); %sort will pair replicate faces one after
                       %the other.

%%Find the replicated faces
k = find(all(diff(faces)==0,2));
%%Drop the replicated faces
faces([k;k+1],:)=[];
aS = faces;
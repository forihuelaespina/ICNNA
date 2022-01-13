function [vi,s2vi] = kriging3D(vstruct,x,y,z,v,xi,yi,zi,chunksize)

% interpolation with ordinary kriging in two dimensions
%
% Syntax:
%
%     [vi,vivar] = kriging(vstruct,x,y,z,v,xi,yi,zi)
%     [vi,vivar] = kriging(vstruct,x,y,z,v,xi,yi,zi,chunksize)
%
% Description:
%
%     kriging uses ordinary kriging to interpolate a variable z measured at
%     locations with the coordinates x and y at unsampled locations xi, yi.
%     The function requires the variable vstruct that contains all
%     necessary information on the variogram. vstruct is the forth output
%     argument of the function variogramfit.
%
%     This is a rudimentary, but easy to use function to perform a simple
%     kriging interpolation. I call it rudimentary since it always includes
%     ALL observations to estimate values at unsampled locations. This may
%     not be necessary when sample locations are not within the
%     autocorrelation range but would require something like a k nearest
%     neighbor search algorithm or something similar. Thus, the algorithms
%     works best for relatively small numbers of observations (100-500).
%     For larger numbers of observations I recommend the use of GSTAT.
%
%     Note that kriging fails if there are two or more observations at one
%     location or very, very close to each other. This may cause that the 
%     system of equation is badly conditioned. Currently, I use the
%     pseudo-inverse (pinv) to come around this problem. If you have better
%     ideas, please let me know.
%
% Input arguments:
%
%     vstruct   structure array with variogram information as returned
%               variogramfit (forth output argument)
%     x,y,z     coordinates of observations
%     v         values of observations
%     xi,yi,zi  coordinates of locations for predictions 
%     chunksize nr of elements in zi that are processed at one time.
%               The default is 100, but this depends largely on your 
%               available main memory and numel(x).
%
% Output arguments:
%
%     vi        kriging predictions
%     vivar     kriging variance
%
% Example:
%
%     % create random field with autocorrelation
%     [X,Y,Z] = meshgrid(0:500);
%     V = randn(size(X));
%     V = imfilter(V,fspecial('gaussian',[40 40],8));
%
%     % sample the field
%     n = 500;
%     x = rand(n,1)*500;
%     y = rand(n,1)*500;
%     z = rand(n,1)*500;
%     v = interp3(X,Y,Z,V,x,y,z);
%
%     % plot the random field
%     subplot(2,2,1)
%     %This is unliely to work in 3D
%     imagesc(X(1,:),Y(:,1),Z(:,1),V); axis image; axis xy
%     hold on
%     plot3(x,y,z,'.k')
%     title('random field with sampling locations')
%
%     % calculate the sample variogram
%     g = variogram([x y z],v,'plotit',false,'maxdist',100);
%     % and fit a spherical variogram
%     subplot(2,2,2)
%     [dum,dum,dum,vstruct] = variogramfit(g.distance,g.val,[],[],[],'model','stable');
%     title('variogram')
%
%     % now use the sampled locations in a kriging
%     [Vhat,Vvar] = kriging3D(vstruct,x,y,z,v,X,Y,Z);
%     subplot(2,2,3)
%     %This is unliely to work in 3D
%     imagesc(X(1,:),Y(:,1),Z(:,1),Vhat); axis image; axis xy
%     title('kriging predictions')
%     subplot(2,2,4)
%     contour(X,Y,Z,Vvar); axis image
%     title('kriging variance')
%
%
% see also: variogram, variogramfit, consolidator, pinv
%
% Date: 13. October, 2010
% Author: Wolfgang Schwanghart (w.schwanghart[at]unibas.ch)
% Adapted to 3D by Felipe Orihuela Espina


%% Log
%
% 18-Oct-2013: FOE: Added verbose option

opt.verbose=false;


% size of input arguments
sizest = size(xi);
numest = numel(xi);
numobs = numel(x);

% force column vectors
xi = xi(:);
yi = yi(:);
zi = zi(:);
x  = x(:);
y  = y(:);
z  = z(:);
v  = v(:);

if nargin == 8;
    chunksize = 100;
elseif nargin == 9;
else
    error('wrong number of input arguments')
end

% check if the latest version of variogramfit is used
if ~isfield(vstruct, 'func')
    error('please download the latest version of variogramfit from the FEX')
end


% variogram function definitions
switch lower(vstruct.model)    
    case {'whittle' 'matern'}
        error('whittle and matern are not supported yet');
    case 'stable'
        stablealpha = vstruct.stablealpha; %#ok<NASGU> % will be used in an anonymous function
end


% distance matrix of locations with known values
%Original line:
%Dx = hypot(bsxfun(@minus,x,x'),bsxfun(@minus,y,y'));
Dx = sqrt(abs(bsxfun(@minus,x,x')).^2 ...
        + abs(bsxfun(@minus,y,y')).^2 ...
        + abs(bsxfun(@minus,z,z')).^2);

% if we have a bounded variogram model, it is convenient to set distances
% that are longer than the range to the range since from here on the
% variogram value remains the same and we don£t need composite functions.
switch vstruct.type;
    case 'bounded'
        Dx = min(Dx,vstruct.range);
    otherwise
end

% now calculate the matrix with variogram values 
A = vstruct.func([vstruct.range vstruct.sill],Dx);
if ~isempty(vstruct.nugget)
    A = A+vstruct.nugget;
end

% the matrix must be expanded by one line and one row to account for
% condition, that all weights must sum to one (lagrange multiplier)
A = [[A ones(numobs,1)];ones(1,numobs) 0];

% A is often very badly conditioned. Hence we use the Pseudo-Inverse for
% solving the equations
A = pinv(A);

% we also need to expand v
v  = [v;0];

% allocate the output vi
vi = nan(numest,1);

if nargout == 2;
    s2vi = nan(numest,1);
    krigvariance = true;
else
    krigvariance = false;
end

% parametrize engine
nrloops   = ceil(numest/chunksize);

if opt.verbose
% initialize the waitbar
h  = waitbar(0,'Kr...kr...kriging');
end

% now loop 
for r = 1:nrloops;
    if opt.verbose
    % waitbar 
    waitbar(r / nrloops,h);
    end
    
    % built chunks
    if r<nrloops
        IX = (r-1)*chunksize +1 : r*chunksize;
    else
        IX = (r-1)*chunksize +1 : numest;
        chunksize = numel(IX);
    end
    
    % build b
    %Original line
    %b = hypot(bsxfun(@minus,x,xi(IX)'),bsxfun(@minus,y,yi(IX)'));
    b = sqrt(abs(bsxfun(@minus,x,xi(IX)')).^2 ...
            + abs(bsxfun(@minus,y,yi(IX)')).^2 ...
            + abs(bsxfun(@minus,z,zi(IX)')).^2);
    % again set maximum distances to the range
    switch vstruct.type
        case 'bounded'
            b = min(vstruct.range,b);
    end
    
    % expand b with ones
    b = [vstruct.func([vstruct.range vstruct.sill],b);ones(1,chunksize)];
    if ~isempty(vstruct.nugget)
        b = b+vstruct.nugget;
    end
    
    % solve system
    lambda = A*b;
    
    % estimate zi
    vi(IX)  = lambda'*v;
    
    % calculate kriging variance
    if krigvariance
        s2vi(IX) = sum(b.*lambda,1);
    end
    
end

if opt.verbose
% close waitbar
close(h)
end

% reshape vi
vi = reshape(vi,sizest);

if krigvariance
    s2vi = reshape(s2vi,sizest);
end

function obj = setSites(obj,theSites)
%Sets the sampling sites
%
% obj = setSites(obj,theSites)
%
%   
%% Parameters
%
% theSites  - table. Default is empty
%       A table describing the sampling sites. In the simplest case,
%       at least 2 keys; the Site.id and the Site.name, and 1 descriptor
%       are needed for each site.
%       The (sampling) sites can be described by any set of descriptors
%       that can be tailored by the user. Some examples of descriptors
%       may be:
%           - channel numbers
%           - sources or detector indexes
%           - a (nominal) 3D location
%           - Other
%
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.experimentBundle
%


%% Log
%
% File created: 26-Jul-2025
%
% -- ICNNA v1.3.1
%
% 26-Jul-2025: FOE 
%   + File created. 
%
%
% -- ICNNA v1.4.0
%
% 11-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Improved some comments
%



obj.sites = theSites;


end
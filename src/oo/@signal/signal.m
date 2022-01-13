function obj=signal(varargin)
%SIGNAL Signal class constructor
%
% obj=signal() creates a default empty signal
%
% obj=signal(obj2) acts as a copy constructor of signal
%
% obj=signal(vec) creates a new signal 
%
%
%% The Signal Class
%
% A signal object represents a recorded digital neurosignal
%at a particular location (picture element) by means of time
%samples or scans along the experiment timecourse. The i-th
%sample is the value of the signal at time t=i.
%
%
% The class signal is like a unidimensional vector as it represents
%the signal imaged at a particular location (not the full neuroimage).
%
%
%% Properties
%
%   .samples - A (column) vector of samples for this signal.
%
%% Methods
%
% Type methods('signal') for a list of methods
% 
% Copyright 2008
% date: 18-Apr-2008
% Author: Felipe Orihuela-Espina
%
% See also channel
%

if (nargin==0)
    obj=initFields;
elseif isa(varargin{1},'signal')
    obj=varargin{1};
    return;
else
    obj=initFields;
    %Ensure it is stored as column vector
    if isvector(varargin{1})
        [nRows,nCols]=size(varargin{1});
        if (nCols == 1)
            obj.samples=varargin{1};
        else
            obj.samples=varargin{1}';
        end
    else
        error('Argument must be a vector.');
    end
end
obj=class(obj,'signal');


%=========================================
% Auxiliary Functions

function obj=initFields()
%Fields must always be constructed in the same order.
%So this is just a dummy initialization.
obj.samples=[];



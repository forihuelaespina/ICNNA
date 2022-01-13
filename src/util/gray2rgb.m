function [B]=gray2rgb(A)
%Convert an grayscale image to RGB image
%
% [B]=gray2rgb(A) convert an grayscale image to RGB image
%   by replicating the intensity channel of the original
%   image in the three R, G an B channels of the RGB.
%
%% Parameters
%
% A - A grayscale image
% 
% Copyright 2010
% @date: 28-May-2010
% @author: Felipe Orihuela-Espina
% @modified: 28-May-2010
%
% See also rgb2hsi
%
B = repmat(A,[1 1 3]);
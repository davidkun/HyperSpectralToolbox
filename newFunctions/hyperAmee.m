function [U] = hyperAmee(M, q, Smin, Smax, L)
% HYPERAMEE Performs the AMEE algorithm to find q endmembers
%   Performs the Automated Morphological Endmember Extraction (AMEE) 
%  algorithm to find q endmembers. If only M is
%  given as input, this function calls hyperHfcVd to estimate the number
%  of endmembers (q) and then hyperPct to reduce dimensionality to (q-1).
%
% Usage
%   [U] = hyperAmee(M, q, Smin)
%   [U] = hyperAmee(M, q, Smin, Smax)
%   [U] = hyperAmee(M, q, Smin, Smax, L)
% Inputs
%   M - 3d matrix of HSI data (m x n x p)
%   q - Number of endmembers to find
%   Smin - minimum kernel size
%   Smax - maximum kernel size
%   L    - maximum iterations
% Outputs
%   U - Recovered endmembers (p x N)
% 
% References
%   Plaza, Antonio, et al. "Spatial/spectral endmember extraction 
% by multidimensional morphological operations." Geoscience and 
% Remote Sensing, IEEE Transactions on 40.9 (2002): 2025-2041.

% Error trapping
if ndims(M) ~= 3
    error('Input image must be (m x n x p)');
else
    [h, w, p] = size(M);
end

if nargin == 2
    Smax = Smin;
elseif nargin == 3
    L = 5;
end

% Morphological Eccentricity Index Score (MEI)
MEI = zeros(h,w);
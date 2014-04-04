function [ U, X, n ] = hyperAmee( M, q, U_init )
% HYPERAMEE Performs the AMEE algorithm
%   Performs the  Automated Morphological Endmember Extraction (AMEE) 
% algorithm; performs unsupervised pixel purity determination and 
% endmember extraction. This function utilizes FastICA.
%
% Usage
%   [ U, X, n ] = hyperAmee( M, q, U_init )
% Inputs
%   M - HSI data in 2D (p x N)
%   q - Number of materials to unmix
%   U_init - Initia l endmembers (p x #)
% Outputs
%   U - matrix of recovered endmembers (p x q)
%   X - material abundance maps (q x N)
%   n - (optional) Indicies of recovered endmembers (q x 1)
%
% References
%   A. Plaza et al., "Spatial/spectral endmember extraction 
% by multidimensional morphological operations." Geoscience
% and Remote Sensing, IEEE Transactions on 40.9 (2002): 2025-2041.

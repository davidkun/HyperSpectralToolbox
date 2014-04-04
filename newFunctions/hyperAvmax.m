function [ U, X, n ] = hyperAvmax( M, q, U_init )
% HYPERAVMAX Performs the AVMAX algorithm
%   Performs the Alternating Volume Maximization (AVMAX) algorithm
% to find unsupervised pixel purity determination and 
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
%  T.H. Chan et al., "A simplex volume maximization framework 
% for hyperspectral endmember extraction." Geoscience and Remote
% Sensing, IEEE Transactions on 49.11 (2011): 4177-4193.

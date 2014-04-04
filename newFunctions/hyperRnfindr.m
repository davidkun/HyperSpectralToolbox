function [ U, X, n ] = hyperRnfindr( M, q, U_init )
% HYPERRNFINDR Performs the RN-FINDR (endmember extraction) algorithm
%   Performs the RN-FINDR algorithm to generate abundance maps
% and find the purest pixels.  This function utilizes FastICA.
%
% Usage
%   [ U, X, n ] = hyperNfindr( M, q, U_init )
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
%   C. Chang, C.C. Wu, and C.T. Tsai., "Random N-finder (N-FINDR)
% endmember extraction algorithms for hyperspectral imagery." 
% Image Processing, IEEE Transactions on 20.3 (2011): 641-656.
function [ U, X, n ] = hyperNfindr( M, q, U_init )
% HYPERNFINDR Performs the N-FINDR (endmember extraction) algorithm
%   Performs the N-FINDR algorithm to generate abundance maps
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
%   M. Winter, "N-findr: an algorithm for fast autonomous 
% spectral endmember determination in hyperspectral data," SPIE’s 
% International Symposium on Optical Science, Engineering, and 
% Instrumentation, pages 266–275. International Society for Optics 
% and Photonics, 1999.

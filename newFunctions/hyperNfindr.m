function [results] = hyperNfindr(M, B, S)
% HYPERNFINDR Performs the hybrid unstructured detector (HUD) algorithm
%   Performs the hybrid unstructured detector algorithm for target
% detection.
%
% Usage
%   [results] = hyperHud(M, B, S)
% Inputs
%   M - 2d matrix of HSI data (p x N)
%   B - 2d matrix of background endmembers (p x q)
%   S - 2d matrix of target endmembers (p x #target_sigs)
% Outputs
%   results - vector of detector output (N x 1)
%
% References
%   J Broadwater & R Chellappa.  "Hybrid Detectors for Subpixel Targets."
% IEEE PAMI. Vol 29. No 11. November 2007.
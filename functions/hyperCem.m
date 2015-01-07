function [results] = hyperCem(M, target)
% HYPERCEM Performs constrained energy minimization (CEM) algorithm
%   Performs the constrained energy minimization algorithm for target
% detection.
%
% Usage
%   [results] = hyperCem(M, target)
% Inputs
%   M - 2d matrix of HSI data (p x N)
%   target - target of interest (p x 1)
% Outputs
%   results - vector of detector output (N x 1)
%
% References
%   Qian Du, Hsuan Ren, and Chein-I Cheng. A Comparative Study of 
% Orthogonal Subspace Projection and Constrained Energy Minimization.  
% IEEE TGRS. Volume 41. Number 6. June 2003.

% Check dimensions
if ndims(M) ~= 2
    error('Input image must be p x N.');
end

p = size(M,1);

if ~isequal(size(target), [p,1])
    error('Input target must be p x 1.');
end

% CEM uses the correlation matrix, NOT the covariance matrix. Therefore,
% don't remove the mean from the data.
R_hat = hyperCorr(M);

% Equation 6 : w = inv( target'*inv(R)*target ) * inv(R)*target
invRtarget = R_hat\target; % inv(R)*target
weights    = ( target'*invRtarget ) \ invRtarget;

results    = weights'*M;

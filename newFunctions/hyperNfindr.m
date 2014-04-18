function [U] = hyperNfindr(M, q)
% HYPERNFINDR Performs the N-FINDR (endmember extraction) algorithm
%   Performs the N-FINDR algorithm to find the purest pixels
% and generate abundance maps.
%
% Usage
%   [U] = hyperNfindr(M)
%   [U] = hyperNfindr(M, q)
% Inputs
%   M - 2d matrix of HSI data (p x N)
%   q - Number of endmembers to find (if not given, default q equals p-1)
% Outputs
%   U - Recovered endmembers (p x N)
%
% If only M is given as input, this function calls hyperHfcVd to estimate
%  the number of endmembers (q) and then PCA to reduce dimensionality to (q-1).
% 
% References
%   M. Winter, "N-findr: an algorithm for fast autonomous 
% spectral endmember determination in hyperspectral data," SPIE’s 
% International Symposium on Optical Science, Engineering, and 
% Instrumentation, pages 266–275. International Society for Optics 
% and Photonics, 1999.

[p, N] = size(M);
M_orig = M;
if nargin == 1
    q = hyperHfcVd(M_orig, [10^-3]);
    M = hyperPct(M, q-1);
elseif q < p+1
    M = hyperPct(M, q-1);
    warning('WarnTests:dim', ...
    strcat('N-FINDR requires (q+1) spectral bands.',...
           '\nPerforming PCA to reduce dimensionality.'))
elseif q > p+1
    warning('WarnTests:dim', ...
    strcat('N-FINDR requires (q+1) spectral bands.',...
           '\nPerforming PCA to reduce dimensionality.'))
    error('ErrTests:dim', ...
        strcat('N-FINDR cannot find more than (p+1) endmembers (q),\n', ...
               'where p is the number of available spectral bands.'))
end

% Initialize
M         = M*1e4;
U_idx     = randperm(N,q);
E         = M(:,U_idx);
V         = abs(det([ones(1,q); E])) / factorial(q-1);
vols      = zeros(q,1);

% Search for maximum volume
for j = 1:N;
    % Replace each column of E with sample vector M(:,j) 
    % and compute the volume for each
    for k = 1:q;
        E_tmp      = E;
        E_tmp(:,k) = M(:,j);
        vols(k)    = abs(det([ones(1,q); E_tmp])) / factorial(q-1);
    end
    % If max volume is greater than previous V, update E and V
    [V_tmp,k_idx] = max(vols);
    if V_tmp > V
        V            = V_tmp;
        E(:,k_idx)   = M(:,j);
        U_idx(k_idx) = j;
    end
end

% Return endmembers
U = M_orig(:, U_idx);











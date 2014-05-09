function [U] = hyperAvmax(M, q)
% HYPERAVMAX Performs the AVMAX algorithm
%   Performs the Alternating Volume Maximization (AVMAX) algorithm
%  to find q endmembers. If only M is given as input, this function 
%  calls hyperHfcVd to estimate the number of endmembers (q) and
%  then hyperPct to reduce dimensionality to (q-1).
%
% Usage
%   [U] = hyperNfindr(M)
%   [U] = hyperNfindr(M, q)
% Inputs
%   M - 2d matrix of HSI data (p x N)
%   q - Number of endmembers to find
%       -- if not given, q is obtained from hyperHfcVd(M, 10^-3)
% Outputs
%   U - Recovered endmembers (p x q)
%
% References
%  T.H. Chan et al., "A simplex volume maximization framework 
% for hyperspectral endmember extraction." Geoscience and Remote
% Sensing, IEEE Transactions on 49.11 (2011): 4177-4193.

% Error trapping
if ndims(M) ~= 2
    warning('WarnTests:dim', ...
            'Input image must be p x N.\n',...
            'Converting with hyperConvert2d.\n')
    M = hyperConvert2d(M);
end

M_orig = M;
[p, N] = size(M);

if nargin == 1
    q = hyperHfcVd(M_orig, [10^-3]);
    M = hyperPct(M, q-1);
elseif q < p+1
    M = hyperPct(M, q-1);
    warning('WarnTests:dim', ...
    strcat('AVMAX requires (q-1) spectral bands.\n',...
           'Performing PCA to reduce dimensionality.\n'))
elseif q > p+1
    warning('WarnTests:dim', ...
    strcat('AVMAX requires (q-1) spectral bands.\n',...
           'Performing PCA to reduce dimensionality.\n'))
    error('ErrTests:dim', ...
        strcat('AVMAX cannot find more than (p+1) endmembers (q),\n', ...
               'where p is the number of available spectral bands.\n'))
end

% Initialize
M      = M*1e2;           % Scale up reflectances to reduce numerical errors
tol    = 5e-5;            % Convergence tolerance
maxitr = 1e2;             % Maximum iterations for search

% Step 1
U_idx = randperm(N,q);    % Random endmember selection
U     = [M(:,U_idx);      % Initialize endmember matrix
         ones(1,q)];
bj    = zeros(q-1,1);

% Step 2
rho   = det(U);           % Initial volume

% Begin search
for zeta = 1:maxitr

    for j = 1:q
        % Step 3
        U_tmp1       = U;
        U_tmp1(:,j)  = [];     % Remove j-th column
        U_tmp2       = U_tmp1;
        for i = 1:q-1
            U_tmp2(i,:)  = []; % Remove i-th row
            bj(i) = (-1)^(i+j) * det(U_tmp2);
            U_tmp2 = U_tmp1;   % Add back i-th row
        end

        % Step 4
        [val,l] = max(bj.'*M);
        U(1:q-1,j) = M(:,l);   % Update endmember matrix
        U_idx(j)   = l;        % Keep track of indices   
    end

    % Step 5
    rho_bar = det(U);

    % Step 6
    if abs(rho_bar-rho)/rho > tol
        rho = rho_bar;
    else
        break
    end
end

if zeta == maxitr
    warning('WarnTests:maxitr', ...
    ['Maximum iterations reached without convergence.\n ', ...
    'Convergence tolerance:\t %0.5g \n Limit reached: %0.5g \n', ...
    ' Iterations: %d \n'], ...
     tol, abs(rho_bar-rho)/rho, zeta)
else
    fprintf('Total iterations: %d', zeta)
end

% Return endmembers
U = M_orig(:, U_idx);

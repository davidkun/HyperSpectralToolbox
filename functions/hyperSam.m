function [errRadians] = hyperSam(a, b)
% HYPERSAM Computes the spectral angle error (in radians) between two
% vectors, or between a vector and every column or row of a matrix
%
% Usage
%   [errRadians] = hyperSam(a, b)
%   [errRadians] = hyperSam(A, b)
%   [errRadians] = hyperSam(a, B)
% Inputs
%   a - vector, (px1)
%   b - vector, (px1)
%   A - matrix, (pxN)
%   B - matrix, (pxN)
% Outputs
%   errRadians - angle between vectors a and b in radians, (1xN)

% Check dimensions
if ~any(size(a)==size(b)),
    error('Incorrect dimensions provided.');
elseif ~any([isvector(a),isvector(b)]),
    error('Incorrect inputs. At least one input must be a vector.');
end

% Turn row vectors to column vectors if necessary
if isrow(a), a=a'; end
if isrow(b), b=b'; end

% Get dimensions
p1 = size(a,1);
p2 = size(b,1);

% Transpose matrix if necessary
if ~isvector(a), % a is a matrix, b is a vector
    if p1~=p2, a=a'; end
    errRadians = getSam(a,b);
    return
    
elseif ~isvector(b) % b is a matrix, a is a vector
    if p2~=p1, b=b'; end
    errRadians = getSam(b,a);
    return
    
elseif all([isvector(a),isvector(b)]) % a and b are both vectors
    errRadians = getSam(a,b);
    return
    
else
    error('Unknown error. See help hyperSam.')
end


function errRadians = getSam(a, b)
% GETSAM computes the spectral angle error between the vector b and
% every column of matrix a (or just the first column, if a is a vector)

[~,N] = size(a);
errRadians = zeros(1,N);

for k=1:N
    tmp = a(:,k);
    errRadians(k) = acos(dot(tmp, b)/ (norm(b) * norm(tmp)));
end

function [U] = hyperAmee(M, q, Smin, Smax, Imax)
% HYPERAMEE Performs the AMEE algorithm to find q endmembers
%   Performs the Automated Morphological Endmember Extraction (AMEE) 
%  algorithm to find q endmembers. If only M is
%  given as input, this function calls hyperHfcVd to estimate the number
%  of endmembers (q) and then hyperPct to reduce dimensionality to (q-1).
%
% Usage
%   [U] = hyperAmee(M, q, Smin)
%   [U] = hyperAmee(M, q, Smin, Smax)
%   [U] = hyperAmee(M, q, Smin, Smax, Imax)
% Inputs
%   M    - 3d matrix of HSI data (m x n x p)
%   q    - Number of endmembers to find
%   Smin - minimum kernel size (Smin x Smin)
%   Smax - maximum kernel size (Smax x Smax)
%   Imax - maximum iterations
% Outputs
%   U - Recovered endmembers (p x q)
% 
% References
%   Plaza, Antonio, et al. "Spatial/spectral endmember extraction 
% by multidimensional morphological operations." Geoscience and 
% Remote Sensing, IEEE Transactions on 40.9 (2002): 2025-2041.

% Error trapping
if nargin < 3 || nargin > 5
    help hyperAmee
    error('Not enough input arguments. See function description.')
elseif nargin == 3
    % i.e. Smax and Imax not given
    Smax = Smin;
    Imax = 1;
elseif nargin == 4
    % i.e. if Imax not given
    if Smin <= Smax
        Imax = round((Smax-Smin)/2)+1;
    else
        help hyperAmee
        error('Smax cannot be less than Smin. See function description.')
    end
elseif nargin == 5
    if Smin == Smax && Imax < 2
        help hyperAmee
        error('Cannot iterate more than once with these S limits.')
    elseif Imax > (Smax-Smin+1)
        Imax = round((Smax-Smin)/2)+1;
    end
end

if ndims(M) ~= 3
    error('Input image must be (m x n x p)');
else
    [h, w, p] = size(M);
end


% Build pixel vectors from M
pixVec = cell(h, w);
for hIter = 1:h
    for wIter = 1:w
        pixVec{hIter,wIter} = squeeze(M(hIter,wIter,:));
    end
end

% Morphological Eccentricity Index Score (MEI)
MEI = zeros(h, w);

% Kernel (structuring element)
for B = round(linspace(Smin, Smax, Imax));
    % Create non-overlapping arrays (to reduce computational load)
    hArray = 1:B:h; hArray(end) = h-B+1;
    wArray = 1:B:w; wArray(end) = w-B+1;

    % Move B though all pixels in M
    for wPixel = wArray;
        for hPixel = hArray;
            % (hPixel,wPixel) defines the top-left pixel of the current kernel
            ker = pixVec(hPixel:hPixel+B-1, wPixel:wPixel+B-1);
            [x, y, mei] = spatialSearch( ker );
            % global (x,y) from local (x,y)
            x = x+hPixel-1;
            y = y+wPixel-1;
            % set MEI value at max pixel location
            MEI(x, y) = mei;
        end
    end
end

% Find q largest MEI values
[tmp,idx] = sort(MEI(:), 'descend');
top       = idx(1:q)';

% Return endmembers
U = cell2mat(pixVec(top));

end % hyperAmee function


function [xMax, yMax, mei] = spatialSearch( ker )
%function [xMax, yMax, mei] = spatialSearch( ker )
% spatialSearch finds the max and min cumulative distances
% between each pixel vector and its neighbors inside a kernel
% of size (B x B) and computes the local MEI.

if ~iscell(ker)
    error('ker is not a cell! See line 57 of hyperAmee.m')
end

B = size(ker,1);

dist = zeros(B);
for i = 1:B;
    for j = 1:B;
        dist(i,j) = Dist(ker{i,j}, ker);
    end
end

% Morphological erosion to find minimum pixel vector in region B
[tmp,rowIdx] = min(dist);
[val,colIdx] = min(tmp);
xMin = rowIdx(colIdx);
yMin = colIdx;

% Morphological dilation to find maximum pixel vector in region B
[tmp,rowIdx] = max(dist);
[val,colIdx] = max(tmp);
xMax = rowIdx(colIdx);
yMax = colIdx;

% MEI computation
mei = Dist(ker{xMin, yMin}, ker{xMax, yMax});

end % spatialSearch function



function dist = Dist(a, C)
%function dist = Dist(a, C)
% Cumulative distance measure between a pixel vector and its neighbor(s).
% Plaza et al. used the Spectral Angle Mapper (SAM) measure.
% 
% Inputs
%   a - pixel vector of interest (p x 1)
%   C - all pixels in neighborhood (or a single pixel vector)
% Outpus
%   dist - (cumulative) SAM distance

if ~iscell(C)
    dist = acos(dot(a,C)/(norm(a)*norm(C)));
else
    dist = 0;
    for k = 1:numel(C);
        dist = dist + acos(dot(a,C{k})/(norm(a)*norm(C{k})));
    end
end

end % Dist function




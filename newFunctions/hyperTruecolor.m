function [tColor] = hyperTruecolor(rflFile, height, width, bands, rgbBands, strechtype)
% HYPERTRUECOLOR Returns a truecolor composite image, given a reflectance file
%   hyperTruecolor returns a truecolor composite image, given an AVIRIS reflectance file,
%  with an optional enhancement of the image using one of two contrast streches.
%
% Usage
%   [tColor] = hyperTruecolor(rflFile, height, width, bands)
%   [tColor] = hyperTruecolor(rflFile, height, width, bands, rgbBands)
%   [tColor] = hyperTruecolor(rflFile, height, width, bands, rgbBands, strechtype)
% Inputs
%   rflFile    - Path and filename of AVIRIS reflectance measurements
%   height     - Height in pixels
%   width      - Width in pixels
%   bands      - Number of bands
%   rgbBands   - [Red, green, blue] bands (1x3 vector)
%                [31,20,12] is the default if no argument is given
%   strechtype - truecolor enhancement contrast strech (string):
%                'none'         : default if no argument is given
%                'stretchlim'   : linear contrast stretch
%                'decorrstretch': decorrelation stretch
%                   (enhanced color separation across highly correlated channels)
% Outputs
%   tColor - Truecolor composite image

if nargin < 4 || nargin > 6
    help hyperTruecolor
    error('Incorrect usage, see function description above.')
end

if nargin == 4
    % RGB bands: [665.73, 557.07, 478.17] nm
    rgbBands   = [31,20,12];
    strechtype = 'none';
elseif nargin == 5
    strechtype = 'none';
end

h = height;
w = width;
p = bands;

% Read the 3 RGB bands
tColor = multibandread(rflFile, [h w p], 'int16', 0, 'bip', 'ieee-be', ...
            {'Row', 'Range', [1 h]}, {'Column', 'Range', [1 w]}, ...
            {'Band', 'Direct', rgbBands} );

% Normalize to proper reflectance units.
tColor = tColor ./ 1e4;

switch lower(strechtype)
    case 'none'
        return
    case 'stretchlim'
        % Apply a linear contrast stretch to the truecolor composite image
        tColor = imadjust(tColor, stretchlim(tColor));
    case 'decorrstretch'
        % Apply a decorrelation stretch to the truecolor composite image
        tColor = decorrstretch(tColor, 'Tol', 0.01);
    otherwise
        help hyperTruecolor
        error(sprintf('Unknown method %s. See function description above.', strechtype))
end

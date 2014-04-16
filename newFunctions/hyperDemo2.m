function hyperDemo2
% HYPERDEMO2 Demonstrates new functions in the hyperspectral toolbox
clear all; close all; clc; dbstop if error;
%--------------------------------------------------------------------------
% Parameters
dataDir    = ['~' filesep 'Downloads' filesep 'data' filesep];
resultsDir = [dataDir filesep 'results' filesep];
%--------------------------------------------------------------------------

fprintf('Storing results in %s directory.\n', resultsDir);
mkdir(resultsDir);

% Read in an HSI image and display one band
bndnum  = 132; % Band Number
rflFile = [dataDir filesep 'f970620t01p02_r03_sc02.a.rfl']
slice   = hyperReadAvirisRfl(rflFile, [1 100], [1 614], [bndnum bndnum]);
figure; imagesc(slice); axis image; colormap(gray);
title(strcat('Band ', num2str(bndnum)));

% Read part of AVIRIS reflectance data file that we will further process
rflFile = [dataDir filesep 'f970620t01p02_r03_sc02.a.rfl']
M = hyperReadAvirisRfl(rflFile, [1 100], [1 614], [1 224]);
M = hyperNormalize(M);

% Read AVIRIS .spc file
spcFile = [dataDir filesep 'f970620t01p02_r03.a.spc']
lambdasNm = hyperReadAvirisSpc(spcFile);

% Isomorph
[h, w, p] = size(M);
M = hyperConvert2d(M);

% Resample AVIRIS image.
desiredLambdasNm = 400:(2400-400)/(224-1):2400;
M = hyperResample(M, lambdasNm, desiredLambdasNm);

% Remove low SNR bands.
goodBands = [10:100 116:150 180:216];
M = M(goodBands, :);
p = length(goodBands);

% Demonstrate difference spectral similarity measurements
M = hyperConvert3d(M, h, w, p);
target = squeeze(M(32, 257, :));
figure; plot(desiredLambdasNm(goodBands), target); grid on;
title('Target Signature; Pixel (32, 257)');
ylabel('Reflectance [0-1]'); xlabel('Wavelength [nm]')   

%% --------------------------------------------------------------------------
% Perform various endmember determination algorithms
    
% PPI
U = hyperPpi(hyperConvert2d(M), 50, 1000);
figure; plot(U); title('PPI Recovered Endmembers'); grid on;

% N-FINDR
U = hyperNfindr(hyperConvert2d(M), 50, 1000);
figure; plot(U); title('N-FINDR Recovered Endmembers'); grid on;

% AVMAX
% U = hyperAvmax(hyperConvert2d(M), 50, 1000);
% figure; plot(U); title('AVMAX Recovered Endmembers'); grid on;

%% --------------------------------------------------------------------------
% Perform a fully unsupervised exploitation chain using HFC, ATGP, and NNLS
fprintf('Performing fully unsupervised exploitation using HFC, ATGP, and NNLS...\n');
M = hyperConvert2d(M);

% Estimate number of endmembers in image.
q = hyperHfcVd(M, [10^-3]);
% q = 50;

%% PCA the data to remove noise
% hyperWhiten(M)
M = hyperPct(M, q);

%% Unmix AVIRIS image.
% U = hyperVca(M, q);
U = hyperAtgp(M, q);
figure; plot(U); title('ATGP Recovered Endmembers'); grid on;

%% Create abundance maps from unmixed endmembers.
abundanceMaps = hyperNnls(M, U);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);

for i=1:q
    tmp = hyperOrthorectify(abundanceMaps(:,:,i), 21399.6, 0.53418);
    figure; imagesc(tmp); colorbar; axis image; 
        title(sprintf('Abundance Map %d', i));
        hyperSaveFigure(gcf, sprintf('%s/chain3-mam-%d.png', resultsDir, i));
        close(gcf);
end
fprintf('Done.\n');

%% --------------------------------------------------------------------------
% Perform another fully unsupervised exploitation chain using ICA
fprintf('Performing fully unsupervised exploitation using ICA...');
[U, abundanceMaps] = hyperIcaEea(M, q);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);
for i=1:q
    tmp = hyperOrthorectify(abundanceMaps(:,:,i), 21399.6, 0.53418);
    figure; imagesc(tmp); colorbar; axis image; 
        title(sprintf('Abundance Map %d', i));
        hyperSaveFigure(gcf, sprintf('%s/chain4-mam-%d.png', resultsDir, i));
        close(gcf);
end
fprintf('Done.\n');


function hyperDemo2
% HYPERDEMO2 Demonstrates new functions in the hyperspectral toolbox
clear all; close all; clc; dbstop if error;
%--------------------------------------------------------------------------
% Measurements and reflectance (input) files/directory
% dataDir    = ['~' filesep 'Downloads' filesep 'data'];
% rflFile    = [dataDir filesep 'f970620t01p02_r03_sc02.a.rfl']
% spcFile = [dataDir filesep 'f970620t01p02_r03.a.spc'];
dataDir    = ['~' filesep 'Downloads' filesep 'f970619t01p02r02c'];
rflFile    = [dataDir filesep 'f970619t01p02_r02_sc01.a.rfl'];
spcFile = [dataDir filesep 'f970619t01p02_r02.a.spc'];

% Results (output) directory
resultsDir = ['~' filesep 'Downloads' filesep 'data' filesep 'results'];
%--------------------------------------------------------------------------

fprintf('  Reading data from %s \n  in the directory %s.\n', rflFile, resultsDir);
fprintf('  Storing results in %s directory.\n', resultsDir);
if ~isdir(resultsDir)
    mkdir(resultsDir);
end

% Read in an HSI image and display one band
bndnum  = 132; % Band Number
slice   = hyperReadAvirisRfl(rflFile, [1 500], [1 614], [bndnum bndnum]);
figure; imagesc(slice); axis image; colormap(gray);
title(strcat('Band ', num2str(bndnum)));

%% Read part of AVIRIS reflectance data file that we will further process
M = hyperReadAvirisRfl(rflFile, [1 500], [1 614], [1 224]);
M = hyperNormalize(M);

% Read AVIRIS .spc file
lambdasNm = hyperReadAvirisSpc(spcFile);

% Resample AVIRIS image
[h, w, p] = size(M);
M = hyperConvert2d(M);
desiredLambdasNm = 400:(2400-400)/(224-1):2400;
M = hyperResample(M, lambdasNm, desiredLambdasNm);

% Remove low SNR bands.
goodBands = [10:100 116:150 180:216];
M = M(goodBands, :);
p = length(goodBands);

M = hyperConvert3d(M, h, w, p);

%% --------------------------------------------------------------------------
% Perform various endmember determination algorithms
q = 10; % number of endmembers
% PPI
Uppi = hyperPpi(hyperConvert2d(M), q, 1000);
figure; plot(desiredLambdasNm(goodBands), Uppi); 
title('PPI Recovered Endmembers'); grid on;
ylabel('Reflectance [0-1]'); xlabel('Wavelength [nm]');

%% N-FINDR
Unfindr = hyperNfindr(hyperConvert2d(M), q);
figure; plot(desiredLambdasNm(goodBands), Unfindr); 
title('N-FINDR Recovered Endmembers'); grid on;
ylabel('Reflectance [0-1]'); xlabel('Wavelength [nm]');

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

% PCA the data to remove noise
% hyperWhiten(M)
M = hyperPct(M, q);

% Unmix AVIRIS image.
% U = hyperVca(M, q);
Uatgp = hyperAtgp(M, q);
figure; plot(desiredLambdasNm(goodBands), Uatgp); 
title('ATGP Recovered Endmembers'); grid on;
ylabel('Reflectance [0-1]'); xlabel('Wavelength [nm]')

%% Create abundance maps from unmixed endmembers
% From ATGP results:
abundanceMaps = hyperNnls(M, Uatgp);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);

for i=1:q
    tmp = hyperOrthorectify(abundanceMaps(:,:,i), 21399.6, 0.53418);
    figure; imagesc(tmp); colorbar; axis image; 
        title(sprintf('Abundance Map %d', i));
        hyperSaveFigure(gcf, sprintf('%s/chain-atgp-%d.png', resultsDir, i));
        close(gcf);
end
fprintf('Done.\n');

% From PPI results:
abundanceMaps = hyperNnls(hyperConvert2d(M), Uppi);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);

for i=1:q
    tmp = hyperOrthorectify(abundanceMaps(:,:,i), 21399.6, 0.53418);
    figure; imagesc(tmp); colorbar; axis image; 
        title(sprintf('Abundance Map %d', i));
        hyperSaveFigure(gcf, sprintf('%s/chain-ppi-%d.png', resultsDir, i));
        close(gcf);
end
fprintf('Done.\n');

% From N-FINDR results:
abundanceMaps = hyperNnls(hyperConvert2d(M), Unfindr);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);

for i=1:q
    tmp = hyperOrthorectify(abundanceMaps(:,:,i), 21399.6, 0.53418);
    figure; imagesc(tmp); colorbar; axis image; 
        title(sprintf('Abundance Map %d', i));
        hyperSaveFigure(gcf, sprintf('%s/chain-nfindr-%d.png', resultsDir, i));
        close(gcf);
end
fprintf('Done.\n');


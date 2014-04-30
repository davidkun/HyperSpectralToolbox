function hyperDemo2
% HYPERDEMO2 Demonstrates new functions in the hyperspectral toolbox
clear all; close all; clc;
%--------------------------------------------------------------------------
% Measurements and reflectance (input) files/directory
% The data files are obtained from: http://aviris.jpl.nasa.gov/data/free_data.html
% (the reflectance .rar file for Cuprite)
dataDir    = ['~' filesep 'Downloads' filesep 'f970619t01p02r02c'];
rflFile    = [dataDir filesep 'f970619t01p02_r02_sc04.a.rfl'];
spcFile = [dataDir filesep 'f970619t01p02_r02.a.spc'];

% Results (output) directory
resultsDir = '~/Dropbox/Purdue Grad/Semester 2/AAE 590/Project/Simulation/results';
%--------------------------------------------------------------------------

fprintf('  Reading data from %s \n  in the directory %s.\n', rflFile, dataDir);
fprintf('  Storing results in %s directory.\n', resultsDir);
if ~isdir(resultsDir)
    mkdir(resultsDir);
end

%% Read in an HSI image and display one band
bndnum  = 120; % Band Number
slice   = hyperReadAvirisRfl(rflFile, [1 512], [1 614], [bndnum bndnum]);
figure; imagesc(slice); axis image; colormap(gray);
title(sprintf('Hyperspectral Image, band = %d',bndnum));

%% Pseudo-True Color Image, rgb = [32,19,10]
% rmap = hyperReadAvirisRfl(rflFile, [1 512], [1 614], [32 32]);
% gmap = hyperReadAvirisRfl(rflFile, [1 512], [1 614], [19 19]);
% bmap = hyperReadAvirisRfl(rflFile, [1 512], [1 614], [10 10]);
% 
% figure;
% hRmap = imagesc(rmap); axis image; hold on;
% colormap([linspace(0,1,10)',zeros(10,1),zeros(10,1)]);
% alpha('color'); 
% rAlpha = get(hRmap, 'AlphaData');
% hGmap = imagesc(gmap); axis image;
% colormap([zeros(10,1),linspace(0,1,10)',zeros(10,1)]);
% alpha('color'); 
% gAlpha = get(hGmap, 'AlphaData');
% hBmap = imagesc(bmap);
% colormap([zeros(10,1),zeros(10,1),linspace(0,1,10)']);
% alpha('color'); 
% set(hRmap, 'AlphaData', rAlpha);
% set(hGmap, 'AlphaData', gAlpha);

%% Read part of AVIRIS reflectance data file that we will further process
M = hyperReadAvirisRfl(rflFile, [1 512], [1 614], [1 224]);
% M = hyperNormalize(M);

% Read AVIRIS .spc file
lambdasNm = hyperReadAvirisSpc(spcFile);

% Resample AVIRIS image
[h, w, p] = size(M);
M = hyperConvert2d(M);
desiredLambdasNm = 400:(2400-400)/(224-1):2400;

fprintf('Resampling M for desired wavelengths...\n'); tic;
M = hyperResample(M, lambdasNm, desiredLambdasNm);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);

% Remove low SNR bands and bands affected by water absorption
%  ( source: Chang, Chein-I., "Random N-finder (N-FINDR) endmember 
%  extraction algorithms for hyperspectral imagery." Image Processing,
%  IEEE Transactions on 20.3 (2011): 641-656. )
fprintf('Removing low SNR bands...\n');
goodBands = [4:104 116:149 171:224];
M         = M(goodBands, :);
p         = length(goodBands);
lambdasNm = desiredLambdasNm(goodBands);

% Final hyperspectral data cube that will be used throughout this demo
M = hyperConvert3d(M, h, w, p);
fprintf('...Done\n');

%% --------------------------------------------------------------------------
% Perform various endmember determination algorithms
q = 5;                      % number of endmembers to find
Mnorm = hyperNormalize(M);  % normalized [0-1] reflectance

%% PPI
fprintf('Performing PPI for endmember determination...\n'); tic;
Uppi = hyperPpi(hyperConvert2d(Mnorm), q, 1000);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);
% Uppi = hyperNormalize(Uppi); % Normalize signatures

% Plot endmember signatures
figure; plot(lambdasNm, Uppi, '.'); grid on;
title('PPI Recovered Endmembers', 'Interpreter', 'Latex', 'FontSize', 14);
ax(1) = ylabel('Reflectance [0-1]'); 
ax(2) = xlabel('Wavelength [nm]');
set(ax, 'Interpreter', 'Latex', 'FontSize', 12);
l = legend(cellstr(num2str((1:q)'))', 'Location', 'EastOutside');
a = get(l, 'children'); set(a(1:3:end), 'MarkerSize', 20);
print(gcf, '-r600', '-depsc', sprintf('%s/endmmbrs-ppi', resultsDir));

%% N-FINDR
fprintf('Performing N-FINDR for endmember determination...\n'); tic;
Unfindr = hyperNfindr(hyperConvert2d(Mnorm), q);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);

% Plot endmember signatures
figure; plot(lambdasNm, Unfindr, '.'); grid on;
title('N-FINDR Recovered Endmembers', 'Interpreter', 'Latex', 'FontSize', 14);
ax(1) = ylabel('Reflectance [0-1]'); 
ax(2) = xlabel('Wavelength [nm]');
set(ax, 'Interpreter', 'Latex', 'FontSize', 12);
l = legend(cellstr(num2str((1:q)'))', 'Location', 'EastOutside');
a = get(l, 'children'); set(a(1:3:end), 'MarkerSize', 20);
print(gcf, '-r600', '-depsc', sprintf('%s/endmmbrs-nfindr', resultsDir));

%% AVMAX
fprintf('Performing AVMAX for endmember determination...\n'); tic;
Uavmax = hyperAvmax(hyperConvert2d(Mnorm), q);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);

% Plot endmember signatures
figure; plot(lambdasNm, Uavmax, '.'); grid on;
title('AVMAX Recovered Endmembers', 'Interpreter', 'Latex', 'FontSize', 14);
ax(1) = ylabel('Reflectance [0-1]'); 
ax(2) = xlabel('Wavelength [nm]');
set(ax, 'Interpreter', 'Latex', 'FontSize', 12);
l = legend(cellstr(num2str((1:q)'))', 'Location', 'EastOutside');
a = get(l, 'children'); set(a(1:3:end), 'MarkerSize', 20);
print(gcf, '-r600', '-depsc', sprintf('%s/endmmbrs-avmax', resultsDir));

%% --------------------------------------------------------------------------
% Create abundance maps from unmixed endmembers
%% From PPI results:
fprintf('Creating abundance maps from PPI endmember results...\n'); tic;
abundanceMaps = hyperNnls(hyperConvert2d(M), Uppi);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);
%%
fprintf('Plotting and saving PPI abundance maps...\n');
for i=1:q
    if i==1; figure; end;
    clf; imagesc(abundanceMaps(:,:,i)); colorbar; axis image; 
    title(sprintf('Abundance Map %d/%d', i, q), 'Interpreter', 'Latex');
    print(gcf, '-depsc', '-r600', sprintf('%s/abund-ppi-%d', resultsDir, i))
end
close(gcf); fprintf('...Done.\n');

%% From N-FINDR results:
fprintf('Creating abundance maps from N-FINDR endmember results...\n'); tic;
abundanceMaps = hyperNnls(hyperConvert2d(M), Unfindr);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);

fprintf('Plotting and saving N-FINDR abundance maps...\n');
for i=1:q
    if i==1; figure; end;
    clf; imagesc(abundanceMaps(:,:,i)); colorbar; axis image; 
    title(sprintf('Abundance Map %d/%d', i, q), 'Interpreter', 'Latex');
    print(gcf, '-depsc', '-r600', sprintf('%s/abund-nfindr-%d', resultsDir, i))
end
close(gcf); fprintf('...Done.\n');

%% From AVMAX results:
fprintf('Creating abundance maps from AVMAX endmember results...\n'); tic;
abundanceMaps = hyperNnls(hyperConvert2d(M), Uavmax);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);

fprintf('Plotting and saving AVMAX abundance maps...\n');
for i=1:q
    if i==1; figure; end;
    clf; imagesc(abundanceMaps(:,:,i)); colorbar; axis image; 
    title(sprintf('Abundance Map %d/%d', i, q), 'Interpreter', 'Latex');
    print(gcf, '-depsc', '-r600', sprintf('%s/abund-avmax-%d', resultsDir, i))
end
close(gcf); fprintf('...Done.\n');


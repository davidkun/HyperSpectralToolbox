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
if ~isdir(resultsDir)
    mkdir(resultsDir);
end

%--------------------------------------------------------------------------
% Record outputs (not including figures)
% diary(sprintf('%s/log.txt',resultsDir))
% dnt = fix(clock); % date and time
% fprintf('%d/%d/%d  %d:%d:%d\n\n', dnt([2,3,1,4,5,6]))

fprintf('  Reading data from %s \n  in the directory %s.\n', rflFile, dataDir);
fprintf('  Storing results in %s directory.\n', resultsDir);

%% Read in an HSI image and display one band
bndnum  = 120; % Band Number
tmp     = hyperReadAvirisSpc(spcFile);
bnd     = tmp(bndnum);
slice   = hyperReadAvirisRfl(rflFile, [1 512], [1 614], [bndnum bndnum]);
figure; imagesc(slice); axis image; colormap(gray);
title(['Slice of HSI, at $\lambda=$',sprintf('%5.6g nm',bnd)],...
    'Interpreter', 'Latex', 'FontSize', 14);
print(gcf, '-r600', '-depsc', sprintf('%s/sampleSlice', resultsDir));

%% True Color Composite
rgbBands = [31,20,12]; % RGB bands (default): [665.73, 557.07, 478.17] nm
tColor   = hyperTruecolor(rflFile, 512, 614, 224, rgbBands, 'stretchlim');
figure; imagesc(tColor); axis image
title('Cuprite, Nevada. AVIRIS 1997 data.', 'Interpreter', 'Latex', 'FontSize', 14);
print(gcf, '-r600', '-depsc', sprintf('%s/truecolor', resultsDir));

%% Read part of AVIRIS reflectance data file that we will further process
M = hyperReadAvirisRfl(rflFile, [1 512], [1 614], [1 224]);

% Read AVIRIS .spc file
lambdasNm = hyperReadAvirisSpc(spcFile);

% Resample AVIRIS image
[h, w, p] = size(M);
M2d = hyperConvert2d(M);
desiredLambdasNm = 400:(2400-400)/(224-1):2400;

fprintf('Resampling M for desired wavelengths...\n'); tic;
M2d = hyperResample(M2d, lambdasNm, desiredLambdasNm);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);

%% Remove low SNR bands and bands affected by water absorption
% Examine the spectral profile of some random pixels (targets)
M = hyperConvert3d(M2d, h, w, p);
ntarg   = 20;                 % number of targets
htarg   = randi(h, 1, ntarg); % h position of targets
wtarg   = randi(w, 1, ntarg); % w position of targets
targets = zeros(ntarg, p);
for idx = 1:ntarg
    targets(idx,:) = squeeze(M(htarg(idx), wtarg(idx), :));
end

figure; 
set(0,'Units','pixels'); scnsz = get(0,'ScreenSize');
set(gcf, 'OuterPosition',[1,1,scnsz(3)/3,scnsz(4)],'PaperPositionMode', 'auto');
subplot(211);
plot(desiredLambdasNm, targets, '.'); grid on; ylim([0,0.6]);
title(sprintf('(a) %d Target Signatures (All Bands)', ntarg), 'Interpreter', 'Latex', 'FontSize', 14);
ax(1) = xlabel('Wavelengths [nm]');
ax(2) = ylabel('Reflectance');
set(ax, 'Interpreter', 'Latex', 'FontSize', 12);

fprintf('Removing low SNR bands...\n');
% [rows,cols,vals]=find(sum(M2d,2)==0);
% goodBands = [4:104 116:149 171:224];
goodBands = [4:104 116:135 137:149 172:224];
M2d       = M2d(goodBands, :);
p         = length(goodBands);
lambdasNm = desiredLambdasNm(goodBands);

% Final hyperspectral data cube that will be used throughout this demo
M = hyperConvert3d(M2d, h, w, p);
fprintf('...Done\n');

% Plot new target signatures (only good bands now)
targets = zeros(ntarg, p);
for idx = 1:ntarg
    targets(idx,:) = squeeze(M(htarg(idx), wtarg(idx), :));
end
subplot(212); plot(lambdasNm, targets, '.'); grid on; ylim([0,0.6]);
title(sprintf('(b) %d Target Signatures (Good Bands)', ntarg), 'Interpreter', 'Latex', 'FontSize', 14);
ax(1) = xlabel('Wavelengths [nm]');
ax(2) = ylabel('Reflectance');
set(ax, 'Interpreter', 'Latex', 'FontSize', 12);
print(gcf, '-r600', '-depsc', sprintf('%s/targets_spectra', resultsDir));

%% --------------------------------------------------------------------------
% Perform various endmember determination algorithms
% Estimate number of endmembers in image.
% q = hyperHfcVd(M2d, [10^-3]);   % doesn't work because corr(M') returns
% some NaNs, which means that there's no variance in some of the bands...
q = 6;                          % number of endmembers to find
% M2dnorm = hyperNormalize(M2d);  % normalized [0-1] reflectance

%% PPI
fprintf('Performing PPI for endmember determination...\n'); tic;
Uppi = hyperPpi(M2d, q, 1000);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);

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
Unfindr = hyperNfindr(M2d, q);
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
Uavmax = hyperAvmax(M2d, q);
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
abundanceMaps = hyperNnls(M2d, Uppi);
abundanceMaps = hyperConvert3d(abundanceMaps, h, w, q);
et=toc; fprintf('...Done. (~%1.3g seconds)\n',et);

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
abundanceMaps = hyperNnls(M2d, Unfindr);
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
abundanceMaps = hyperNnls(M2d, Uavmax);
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

%% End log file
diary off

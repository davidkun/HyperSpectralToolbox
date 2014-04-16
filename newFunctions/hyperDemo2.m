function hyperDemo2
% HYPERDEMO2 Demonstrates new functions in the hyperspectral toolbox
clear all; close all; clc; dbstop if error;
%--------------------------------------------------------------------------
% Parameters
resultsDir = ['~' filesep 'Downloads' filesep 'results' filesep];
dataDir    = ['~' filesep 'Downloads' filesep 'data' filesep];
%--------------------------------------------------------------------------

mkdir(resultsDir);

% Read part of AVIRIS data file that we will further process
rflFile = [dataDir filesep 'f970620t01p02_r03_sc02.a.rfl']
M = hyperReadAvirisRfl(rflFile, [1 100], [1 614], [1 224]);
M = hyperNormalize(M);

% Read AVIRIS .spc file
spcFile = [dataDir filesep 'f970620t01p02_r03.a.spc']
lambdasNm = hyperReadAvirisSpc(spcFile);

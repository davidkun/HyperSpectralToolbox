## HyperSpectral Matlab Toolbox ##

Originally writted by [Isaac Gerg](http://www.gergltd.com/home/). (Under GNU General Public License version 2.0 (GPLv2).)
[Visit original site](http://sourceforge.net/apps/mediawiki/matlabhyperspec/index.php?title=Main_Page)

### Dependencies ###

- FastICA (from [my Github repo](https://github.com/davidkun/FastICA) or from [Aalto University](http://research.ics.aalto.fi/ica/fastica/code/dlcode.shtml))

### Setup ###

    cd ~/path-to-directory
    git clone https://github.com/davidkun/HyperSpectralToolbox.git
    git clone https://github.com/davidkun/FastICA.git

Open Matlab. The default directory should contain a file `startup.m`, if not create it and add the following code to it (make sure to modify `path-to-directory` so it matches the actual path):

    addtopath('~/path-to-directory/FastICA', ...
              '~/path-to-directory/HyperSpectralToolbox/functions', ...
              '~/path-to-directory/HyperSpectralToolbox/newFunctions');

You're ready to go now! Check out the demo files `hyperDemo.m` in `functions/` and `hyperDemo2.m` in `newFunctions/` to learn how to use the toolbox.

### Description ###

The open source Matlab Hyperspectral Toolbox is a matlab toolbox containing various hyperspectral exploitation algorithms. The toolbox is meant to be a concise repository of current state-of-the-art exploitation algorithms for learning and research purposes. The toolbox includes functions for:

- Target Detection
  - Constrained Energy Minimization (CEM)
  - Orthogonal Subspace Projection (OSP)
  - Generalized Liklihood Ratio Test (GLRT)
  - Adaptive Cosine/Coherent Estimator (ACE)
  - Adaptive Matched Subspace Detector (AMSD)
- Endmember Determination
  - Automatic Target Generation Procedure (ATGP)
  - Independent component analysis - endmember extraction algorithm (ICA-EEA)
- Material Abundance Map (MAM) Generation
- Spectral Comparison
  - Spectral angle mapper (SAM)
  - Spectral information divergence (SID)
  - Normalize cross correlation
- Anomaly Detectors
  - Reed-Xiaoli Detector (RX)
- Least Square Solvers (for abundance map estimation)
  - Fully-constrained least squares (FCLS)
  - Non negative least squares (NNLS)
- Material Count Estimation
  - HFC virtual dimensionality (VD) for material count estimate
- Automated Processing
- Change Detection
- Visualization
- Reading / Writing Files (.rfl, .asd, ect)

### Algorithms to be added (suggested by Dr. Gerg): ###

- (Joint) Affine Matched filter
- Generalization of matched filter which includes signature statistics
- RAF-SAM, an improvement to SAM - http://proceedings.spiedigitallibrary.org/proceeding.aspx?articleid=793174
- ELM for radiance to reflectance conversion - http://www.cis.rit.edu/files/197_SPIE_2005_Grimm.pdf
- Covariance matrix inversion methods (e.g. Dominant Mode Rejection)
- Quadratic Detector
- SMACC - http://proceedings.spiedigitallibrary.org/proceeding.aspx?articleid=844250
- AMEE - http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=1046852
- ~~N-FINDR - http://proceedings.spiedigitallibrary.org/proceeding.aspx?articleid=994814~~
- Fast PPI - http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=1576691
- ~~Joshua Broaderwater's hybrid detectors (HUD, etc)~~
- Variations on ACE - e.g. adaptive covariance estimated ACE, etc

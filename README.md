# HyperSpectral Matlab Toolbox #

Originally writted by [Isaac Gerg](http://www.gergltd.com/home/). (Under GNU General Public License version 2.0 (GPLv2).)
[Visit original site](http://sourceforge.net/apps/mediawiki/matlabhyperspec/index.php?title=Main_Page)

## Dependencies ##

- FastICA ([from my Github repo](https://github.com/davidkun/FastICA) or [from Aalto University](http://research.ics.aalto.fi/ica/fastica/code/dlcode.shtml))

## Description ##

The open source Matlab Hyperspectral Toolbox is a matlab toolbox containing various hyperspectral exploitation algorithms. The toolbox is meant to be a concise repository of current state-of-the-art exploitation algorithms for learning and research purposes. The toolbox includes functions for:

- Target detection
  - Constrained Energy Minimization (CEM)
  - Orthogonal Subspace Projection (OSP)
  - Generalized Liklihood Ratio Test (GLRT)
  - Adaptive Cosine/Coherent Estimator (ACE)
  - Adaptive Matched Subspace Detector (AMSD)

- Endmember Finders
  - Automatic Target Generation Procedure (ATGP)
  - Independent component analysis - endmember extraction algorithm (ICA-EEA)

- Material abundance map (MAM) generation

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

- Automated processing
- Change detection
- Visualization
- Reading / writing files (.rfl, .asd, ect)

### Algorithms to be added (requested by Dr. Gerg):


- (Joint) Affine Matched filter
- Generalization of matched filter which includes signature statistics
- RAF-SAM, an improvement to SAM from: Improving the Classification Precision of Spectral Angle Mapper
- ELM for radiance to reflectance conversion - http://www.cis.rit.edu/files/197_SPIE_2005_Grimm.pdf
- Covariance matrix inversion methods (e.g. Dominant Mode Rejection)
- Quadratic Detector
- SMACC - http://proceedings.spiedigitallibrary.org/proceeding.aspx?articleid=844250
- AMEE - http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=1046852
- N-FINDR - http://proceedings.spiedigitallibrary.org/proceeding.aspx?articleid=994814
- Fast PPI - http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=1576691
- Joshua Broaderwater's hybrid detectors (HUD, etc)
- Variations on ACE - e.g. adaptive covariance estimated ACE, etc

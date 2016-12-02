quasar
=====

A collection of MATLAB routines used to perform **Qu**antitative **A**nalysis of **S**acculus **A**rchitectural **R**emodeling. While these routines have been designed for analyzing fluorescent images for a specific experimental design, they can be easily modified or adapted for other designs. 

## Requirements
These routines utilize MATLAB and the following toolboxes 

+ Statistics and Machine Learning Toolbox
+ Curve Fitting Toolbox
+ Optimization Toolbox
+ Image Processing Toolbox
 
From the [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/), these routines also utilize

+ *uipickfiles*
+ *transcodeDate*
+ *histcn*
+ *progressbar*

## Pipeline
### Segmentation
Segment the images into individual cells and generate an ordered list of coordinates that define the contour around each cell. Although the routines here assume segementation data formatted from Morphometrics (<http://observenature.tumblr.com/research>, [Ursell et al., 2014, PNAS](https://dx.doi.org/10.1073%pnas.1317174111)) any image segmentation package could be used.

### Color alignment
For some microscope configurations, there is a shift in where each of the color channels is imaged. Instead of aligning each cell individually, use the routine *alignContoursGui* to determine the best shift between entire fields of view.

### Extract fluorescence intensity along contours

Utilizing the segementations from above and multiple fluorescent color channels, extract the intensity along the cell outlines using *extractFluorContour*. This operates on individual image files.

### Calculate intensity properties along contours
The routine *calculateFluorMetrics* uses the geometric information about the contours and the fluorescence intensity to calculate various properties such as the integrated intensity on each face and pole, fraction of intensity in each pole, etc. This operates on a collection of image files and generates one assembled dataset for each condition.

### Assemble larger dataset

Use the routine *aggregateAllCells* to merge multiple datasets together and *restructure_aggCells* to represent the data as an nObject x mMeasurement numeric array instead of a structure array.

### Swap sides

Depending on the preferred method of defining the inner and outer faces of a cell, the routine *swapSides* can be used to iterate over the aggregated dataset and check for cells who need to have their faces swapped.

### Visualize results
To visualize the dynamics of sacculus remodeling, use the routine *plotMetric_innerOuter*. It requires the aggregated dataset as an input. The routine *showParticularCell* gives an example of how to visualize the contour of a single cell colored by geometry or fluorescent intensity.


## Other utilities

For an example routine that assists in correcting naming conventions and dealing with ND2 files, see *mergeDeleteSplits*.

The function *bpbFWHM* calculates the **f**ull **w**idth at **h**alf **m**aximum (FWHM) as well as the positions at which the half-max occurred.

To simulate a cell that curves as it grows, use the routine *drawCurvedCells* to visualize a single cell or *predictCurvaturePlotter* to display the predicted time evolution of centerline curvature.

To see an example script that adds additional measurements to a previously analyzed dataset, see *addCellDiameter*.

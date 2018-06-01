# amyloids
Code for Amyloids Project

Description of each code:

1) loadImagesSaveZproj.m iterates over all ".lif" files in the imageFolder directory and does Z-Projection on each slice of each image. ASSUMPTIONS: each file *should* start with the Dye name, otherwise the script will not work.

2) saveAggregates.m iterates over all Zprojections and performs edge detection (segmentation.m) on each slice. All aggregates are saved in the output folder "aggregates" (already uploaded in Polybox) together with the labels for each slice. 

3) featureExtractionInterpolatedFast.m loads all images in the aggregates folder, computes the Zernike moments for each image and saves the features in an N x d matrix, where N = # aggregates, d = dimension of the Zernike polynomial. The polynomial degree and the size at which the image is interpolated are defined in the first lines of the code. The output is a .mat file with the features for ALL dyes.

4) extract_cur_FSB_BF188.m gets as input the .mat file for all dyes and separate into 3 different .mat files: one for each dye (curcumine, BF188 and FSB).

5) preComputeZernikeBasis.m and zernikeUsingPreComputedBasis.m are optimized codes for computing the Zernike moments. The basis are computed first based on the degree and the size of the image. The Zernike moments are computed performing an inner product of the aggregate images with the pre computed basis. We use the recurrence relations of Zernike polynomials to optimize all calculations. Do NOT edit these please. :)

6) imReconstruct.m reads one aggregate image (needs to be in your folder), computes the Zernike moments for this image and reconstructs the image until a certain degree. The error plot (RMSE and Frob. Norm) are shown with the degree of reconstruction. It a good way to visualize until what point the image reconstruction improves when increasing the degree.

7) PCAtest.m loads the features, subsamples aggregates from each patient (optional), classify all patients based on mutation type, filter out aggregates based on mutation (selecting only mutation types we want to analyse), runs the dimensionality reduction algorithm (PCA or any other available from the list), and plots the principal components and eigenvectors. There are other experiments in some sections as well. PS: The dimensionality reduction will *not* work if you don't download and install compute_mapping (https://lvdmaaten.github.io/drtoolbox/#download)

8) kMeansImplemented.m is an implementation of Kmeans using 3 different similarity functions: Gaussian, Euclidian and Cosine.

9) kMeansFirstTrial.m performs kMeans on the data and reconstructs an image using the closest datapoint to each centroid.

10) tableMutationCluster.m is a kMeans experiment to analyse how many patients of each type falls inside the clusters. The output is a similarity matrix where x = mutation type (or patients), y = clusters 1:k

11) reconfromplot.m and reconfromplot.fig are a graphical interface (GUI) where the PCA is plotted in 2D and you can click on each datapoint to reconstruct the image. 

--- Important files ---

1) patients-all-dataset-input-new.csv: do not edit this. It's the table with the patient number, patient ID, mutation type and metadata name. All codes above will give wrong results if the .csv file is changed. 

2) A set of features (features-deg50-cur-selected-binary-interpol-100.mat) is uploaded so you don't need to run codes (1-5). The name means: Zernike features up to 50 degrees for the dye Curcumine in the binary aggregates interpolated to 100x100pixels.










% Generate a cell array of length 3 of all of the images of 
% a gaussian pyramid created using the original image passed in
% and a 3x3 gaussian filter with standard deviation 1.  Each subsequent
% level of the pyramid is created by convolving with the filter and then
% resizing such that if the original image is m x n, then subsequent levels
% are m/sqrt(2) x n/sqrt(2).
%
% inputImage: The image to create the pyramid from
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function images = gaussianPyramid(inputImage, level)

% Use a 3x3 gaussian filter with Standard Deviation 1
filter = fspecial('gaussian',3,1);

% The first element is the original image
images{1} = inputImage;

% Iterate through each level and fill in a cell array
% with the convolve of the previous image matrix and the filter
for i=2:level
   % Convolve the image with the previous pyramid image
   images{i}=conv2(images{i-1},filter,'same');
   
   % Reduce the size of the image by 1/sqrt(2)
   images{i} = imresize(images{i},1 / sqrt(2),'nearest');
end
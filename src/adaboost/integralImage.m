% function integralImage = integralImage(inputImage)
%
% Create an integral image.  Each location in the integral image
% is defined as the sum of the pixels above and to the left in the
% regular image + itself.  IE:
%
% ii 1 2 3      1  3  6
%    4 5 6    = 5  12 21
%    7 8 9      12 27 45
%
% inputImage: The image to create the integral image from
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function integralImage = integralImage(inputImage)
    integralImage = cumsum(cumsum(inputImage,2));
end
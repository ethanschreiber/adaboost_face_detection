%function normalizedImages = normalizeImages(images)
%
% Normalize an image cube.  The cube is as follows:
%
% images - rows x cols x NUM_IMAGES cube of images.
%
% Each image is normalized individually.
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function normalizedImages = normalizeImages(images, stdThreshold)

    %images = images ./ 255;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reshape rows x cols x NUM_IMAGES cube to %
    % (rows * cols) x NUM_IMAGES matrix.       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    imagesVector = reshape(images,size(images,1) * size(images,2), size(images,3));
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Normalize each image by dividing by standard deviation %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate the standard deviation of each image
    imagesStdVector = std(imagesVector);
    
     for (i=1:length(imagesStdVector))
        if (imagesStdVector(i) < .01)
            imagesStdVector(i) = 1;
        end
     end
    
    % Divide each pixel by the std
    for (i=1:size(imagesVector,1))
        imagesVector(i,:) = imagesVector(i,:) ./ imagesStdVector;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reshape the image vectors back to their original orientation. %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    normalizedImages = reshape(imagesVector,size(images,1),size(images,2),size(images,3));
    
    % make the images go from 0->1 for easier calculation
%     for (i=1:size(normalizedImages,3))
%         normalizedImages(:,:,i) = mat2gray(normalizedImages(:,:,i));
%     end
 end
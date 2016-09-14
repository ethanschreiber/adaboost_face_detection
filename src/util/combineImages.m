% function images = combineImages(faceImages, nonFaceImages)
% 
% Combine the face image cube and non face image cube into 
% one face image cube.  (ie, 16x16x5000 combined with 16x16x10,000
% into 16x16x15,000)
% 
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function images = combineImages(faceImages, nonFaceImages)
    
    % Reshape rows x cols x NUM_IMAGES cube to (rows * cols) x NUM_IMAGES matrix.
    faceImagesVector    = reshape(faceImages,size(faceImages,1) * size(faceImages,2), size(faceImages,3));
    nonFaceImagesVector = reshape(nonFaceImages, size(nonFaceImages,1) * size(nonFaceImages,2), size(nonFaceImages,3));
    
    % Combine the two
    imagesVector = [faceImagesVector nonFaceImagesVector];
    
    % Reshape the combined image vector back to row x col x num_combined_images.
    images = reshape(imagesVector,size(faceImages,1),size(faceImages,2),size(imagesVector,2));

end
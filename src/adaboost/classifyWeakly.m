% function hjx = classifyWeakly(classifier,integralImages)
%
% Classify a list of images as face or non face using a simple classifier.
% This is referred to as h_j(x) in the Viola and Jones paper.
%
% h_j(x)=1 if parity * classifier(trainingImage) < parity * threshold
% h_j(x)=0 otherwise
%
% classifier - The classifier we are using to classify.   This is a struct
% with thr following fields:
%   filter:     This calculates an integer value given an integral image.  
%               This is a 9x3 matrix with the first column is a row in the 
%               integral image, the 2nd column is a column in the integral 
%               image and the third column is a coefficient.  The value is:
%               integralImage(classifier(1,1), classifier(1,2)) *
%               classifier(1,3) +
%               integralImage(classifier(2,1), classifier(2,2)) *
%               classifier(2,3) + ... for each row in this matrix.
%               (We also refer to this as f_j(x))
%   threshold:  If the classifier value is less than the threshold (or
%               greater depending on the parity bit), then it is classified 
%               as a face, otherwise it is classified as a non-face.
%               (We also refer to this as theta_j)
%   parity:     Determines whether the classified value needs to be < or > 
%               the threshold value to be considered a face.  This needs 
%               to be -1 or 1.  (We also refer to this as p_j)
%
% integralImages - A row x col x num_images integral image cube
%
% returns:  1xnum_images list of 1 if the integral image is classified as a 
%           face and 0 otherwise.  This is returned as a logical datatype.
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function hjx = classifyWeakly(classifier,integralImages)
    
    % Calculate the filter value of each integral image
    filteredValues = calculateFilter(classifier.filter,integralImages);
    
    % convert the feature vector to a row vector)
    fjx = double(filteredValues(:)');

    % h_j(x) from section 3 of viola and jones: The classifier
    % based on the feature, parity and threshold we learned earlier
    % h_j(x)=1 if p_j f_j(x) < p_j * theta_j, 0 otherwise.
    %
    % We use a second threshold that is always the opposite parity of the 
    % first to hopefully get better weak classifiers.  The .* is the same
    % as && but works for vectors  This makes sense since true is 1 and
    % flase is 0.  Only 1 .* 1 = 1.
    hjx = logical( ( (classifier.parity .* fjx)       < (classifier.parity .* classifier.threshold) ) .* ...
                   ( (classifier.parity .* -1 .* fjx) < (classifier.parity .* -1 .* classifier.threshold2))); 
    
%      for (i=1:length(hjx))
%          fprintf('%d = %d * %d < %d * %d\n',hjx(i), classifier.parity, fjx(i), classifier.parity, classifier.threshold);
%      end
    
end
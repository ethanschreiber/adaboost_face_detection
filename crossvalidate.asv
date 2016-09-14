% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007

clc;        % clear the console
clear;      % Clear all data from memory
close all;  % Close all figure windows

%%%%%%%%%%%%%%
% Parameters %
%%%%%%%%%%%%%%
% The number of cross validation sets
NUM_CROSS_VALIDATE_SETS = 5;

% The width of each training image
IMAGE_WIDTH = 16;

% The height of each training image
IMAGE_HEIGHT = 16;

% Ignore all patches with std below 8.  This is only for
% detection in the final image, not for training.
STD_THRESHOLD = 8;

% The minimum size of the component rectangle of the filters.
% IE, for a 2 rectangle left right filter, the minimum width
% is 2 * FILTER_SIZE and the minimum height is FILTER_SIZE
%
% This number must be a positive integer.  If you make the number less
% than 3, it will take a long time to run and you could run into memory
% issues.  If you make it larger, the results will not be as good.  I 
% believe 3 is a good number although the assignment suggested 4.
FILTER_SIZE = 3;

% The number of iterations to train for
T = 200;

% The number of histogram bins to use;
% The larger this number is, theh more accurate the classifier
% thresholds will be.  However, if you make the number too large, the 
% program will run out of memory.  64 seems to be a good tradeoff.
NUM_BINS = 64; 

% Should we retrain the classifiers on each iteration of adaboost?
% In the true viola/jones algorithm, this happens.  However, the results are not
% much different if this is set to false and each training cycle takes
% about 3.5 seconds for 6000 features and 15,000 training images as opposed
% to about 100 seconds if set to true.
RETRAIN_CLASSIFIERS = true;

% The base directory of the project
BASE_DIR = sprintf('%s%s',pwd,filesep);    

% The base of the image directory for loading images.
BASE_DATA_DIR = sprintf('%s%s%s',BASE_DIR,'data',filesep);    

% The base directory for all of the source code
BASE_SRC_DIR =  sprintf('%s%s%s',BASE_DIR,'src',filesep);    

% Set Path
path(path,sprintf('%s%s%s',BASE_SRC_DIR,'adaboost',filesep));
path(path,sprintf('%s%s%s',BASE_SRC_DIR,'util',filesep));
path(path,sprintf('%s%s%s',BASE_SRC_DIR,'writeup',filesep));
path(path,sprintf('%s%s%s',BASE_DIR,'lib',filesep));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and preprocess images %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load images
[faceImages, nonFaceImages, testingImage] = loadImages(BASE_DATA_DIR);

% Normalize Images
faceImages    = normalizeImages(faceImages);
nonFaceImages = normalizeImages(nonFaceImages);
%testingImage = normalizeImages(testingImage);

% Calculate the Integral Images
faceIntegrals    = integralImage(faceImages);
nonFaceIntegrals = integralImage(nonFaceImages);

clear faceImages;
clear nonFaceImages;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the filters.                                                     %
%                                                                         %
% params are: min filter size, max filter size, image width, image height %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[filters filterTypes] = createFilters(FILTER_SIZE,16,IMAGE_WIDTH,IMAGE_HEIGHT);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the training and testing sets %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numFaces = size(faceIntegrals,3);
numNonFaces = size(nonFaceIntegrals,3);

faceTrainingSize    = floor(numFaces / NUM_CROSS_VALIDATE_SETS);
nonFaceTrainingSize = floor(numNonFaces / NUM_CROSS_VALIDATE_SETS);

permutedFaceIndices    = randperm(numFaces);
permutedNonFaceIndices = randperm(numNonFaces);

for (i=1:NUM_CROSS_VALIDATE_SETS)
    
    index0 = ((i-1) * faceTrainingSize);
    permutedFaceIntegrals(:,:,:,i) = ...
         faceIntegrals(:,:,permutedFaceIndices(index0+1:(index0+faceTrainingSize)));
    
    index0 = ((i-1) * nonFaceTrainingSize);
    permutedNonFaceIntegrals(:,:,:,i) = ...
        nonFaceIntegrals(:,:,permutedNonFaceIndices(index0+1:(index0+nonFaceTrainingSize)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%
% Boost the classifiers %
%%%%%%%%%%%%%%%%%%%%%%%%%

% Treat each of the 5 sets as the testing set
for (i=1:NUM_CROSS_VALIDATE_SETS)
    fprintf('Cross Validating [%d/%d]\n\n',i,NUM_CROSS_VALIDATE_SETS);
    
    trainingIndices = [[1:i-1] [i+1:NUM_CROSS_VALIDATE_SETS]]; 

    % Create the training and testing sets from the permuted images
    trainingFaceIntegrals = reshape(permutedFaceIntegrals(:,:,:,trainingIndices),16,16,...
                                size(permutedFaceIntegrals,3) *...
                                    (NUM_CROSS_VALIDATE_SETS - 1));
    testingFaceIntegrals  = reshape(permutedFaceIntegrals(:,:,:,i),16,16,...
                                size(permutedFaceIntegrals,3));

    trainingNonFaceIntegrals = reshape(permutedNonFaceIntegrals(:,:,:,trainingIndices),16,16,...
                                size(permutedNonFaceIntegrals,3) *...
                                    (NUM_CROSS_VALIDATE_SETS - 1));
    testingNonFaceIntegrals  = reshape(permutedNonFaceIntegrals(:,:,:,i),16,16,...
                                size(permutedNonFaceIntegrals,3));

    % Train the classifiers based on the training/testing sets
    [trainedClassifiers] = adaboost(filters,filterTypes,trainingFaceIntegrals, ...
                    trainingNonFaceIntegrals, RETRAIN_CLASSIFIERS,T,NUM_BINS);

    
    % Test the results
    numFaces = size(testingFaceIntegrals,3);
    numNonFaces = size(testingNonFaceIntegrals,3);

    testingIntegrals = combineImages(testingFaceIntegrals, testingNonFaceIntegrals);

    fprintf('\n');
    for (j=1:T)
        results = classifyStrongly(trainedClassifiers(1:j),testingIntegrals);

        falseNegativeRate = (numFaces - sum(results(1:numFaces))) / (2 * numFaces);
        falsePositiveRate = (sum(results(numFaces+1:end))) / (2 * numNonFaces);

        errors{i}.falseNegativeRate(j) = falseNegativeRate;
        errors{i}.falsePositiveRate(j) = falsePositiveRate;                        
        fprintf('   T=%d FNR: %f FPR: %f\n',j,falseNegativeRate,falsePositiveRate);
    end

    fprintf('\nCross Validation [%d/%d] complete!\n\n',i,NUM_CROSS_VALIDATE_SETS);

    
    close all;
    
    figure(1)
    for (i=1:length(errors))
        subplot(2,3,i)
        
        plot(1:T,errors{i}.falseNegativeRate + errors{i}.falsePositiveRate);
        xlabel('T');
        ylabel('Percent Incorrect');
        title(sprintf('Data Set %d',i));
    end
    suptitle('Cross Validation Results');

end



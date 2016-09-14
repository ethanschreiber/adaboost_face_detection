
% 
% This is for drawing the strong classifiers.  It is for reporting only.
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function [valueRange, faceHistogram, nonFaceHistogram,threshold, parity,totalAlpha] = ...
     calculateStrongClassifierHistrogram(trainedClassifiers, faceIntegrals, nonFaceIntegrals,figureNo, NUM_BINS)


    % Iterate for each t depending on how many times we ran the adaboost
    % trainer.  (The size of h, theta and p depend on the adaboost trainer)
    totalAlpha = 0.0;
    for (t=1:size(trainedClassifiers,2))        
        alpha_htx_face(:,t) = trainedClassifiers(t).alpha .* ...
            classifyWeakly(trainedClassifiers(t).classifier,faceIntegrals)';

        alpha_htx_non_face(:,t) = trainedClassifiers(t).alpha .* ...
            classifyWeakly(trainedClassifiers(t).classifier,nonFaceIntegrals)';

            totalAlpha = totalAlpha + trainedClassifiers(t).alpha;
    end
    
    faceValues      = sum(alpha_htx_face,2);
    nonFaceValues   = sum(alpha_htx_non_face,2);

    minValue = min(min(faceValues),min(nonFaceValues));
    maxValue = max(max(faceValues),max(nonFaceValues));

    % Find the minimum and maximum filter values.
    binSize = (maxValue - minValue) / 1000;
    valueRange = double(minValue:binSize:maxValue);

    valueRange = linspace(minValue,maxValue,NUM_BINS);

    faceHistogram    = hist(double(faceValues),valueRange);
    nonFaceHistogram = hist(double(nonFaceValues),valueRange);

    % normalize
    faceHistogram = faceHistogram ./ sum(faceHistogram);
    nonFaceHistogram = nonFaceHistogram ./ sum(nonFaceHistogram);

    % Take the cumulative sum of each distribution
    cumFaceHistogram    = cumsum(faceHistogram);
    cumNonFaceHistogram = cumsum(nonFaceHistogram);

    [maxThresholdValue maxThresholdIndex] = max(cumFaceHistogram - cumNonFaceHistogram);
    [minThresholdValue minThresholdIndex] = min(cumFaceHistogram - cumNonFaceHistogram);
    
    if (abs(minThresholdValue) > abs(maxThresholdValue))
        parity=-1;
        threshold = valueRange(minThresholdIndex);
    else
        parity=1;
        threshold = valueRange(maxThresholdIndex);
    end
           
    
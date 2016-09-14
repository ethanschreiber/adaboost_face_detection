% function [falsePositiveRates, truePositiveRates] = calculateROC(trainedClassifiers, integralImages)
% 
% This is for drawing the ROC Curve.  It is for reporting only.
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function [falsePositiveRates, truePositiveRates] = calculateROC(trainedClassifiers, faceIntegrals, nonFaceIntegrals)

    % Combine the images into one image
    integralImages = combineImages(faceIntegrals,nonFaceIntegrals);

    % Iterate for each t depending on how many times we ran the adaboost
    % trainer.  (The size of h, theta and p depend on the adaboost trainer)
    totalAlpha = 0.0;
    for (t=1:size(trainedClassifiers,2))        
        alpha_htx(:,t) = trainedClassifiers(t).alpha .* ...
            classifyWeakly(trainedClassifiers(t).classifier,integralImages)';
            
            totalAlpha = totalAlpha + trainedClassifiers(t).alpha;
    end
    
    sumAlphaHtx = sum(alpha_htx,2);
    a = min(sumAlphaHtx)-1;
    b = max(sumAlphaHtx) + 1;
  
    i = 1;
    for (threshold= linspace(a,b,100))
        results = sumAlphaHtx >= threshold;
        numFaces = size(faceIntegrals,3);
        falsePositiveRates(i)= sum(results(numFaces+1:end)) / size(nonFaceIntegrals,3);
        truePositiveRates(i) = sum(results(1:numFaces))     / numFaces;
%         fprintf('t=%d threshold=%f (fp/tp) (%f/%f)(\n',length(trainedClassifiers),...
%             threshold,falsePositiveRates(i), truePositiveRates(i));
        i = i+1;
    end    
end
% function results = classifyStrongly(alpha h p theta)
% 
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function results = classifyStrongly(trainedClassifiers, integralImages)

    % Iterate for each t depending on how many times we ran the adaboost
    % trainer.  (The size of h, theta and p depend on the adaboost trainer)
    totalAlpha = 0.0;
    for (t=1:size(trainedClassifiers,2))        
        alpha_htx(:,t) = trainedClassifiers(t).alpha .* ...
            classifyWeakly(trainedClassifiers(t).classifier,integralImages)';
            
            totalAlpha = totalAlpha + trainedClassifiers(t).alpha;
    end
    %fprintf('%f %f\n',sum(alpha_htx,2), totalAlpha);
    results = sum(alpha_htx,2) > 1/2 .* totalAlpha;
end
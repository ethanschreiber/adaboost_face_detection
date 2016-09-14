function classifiers = thresholdStrongClassifier(trainedClassifiers, faceIntegrals, nonFaceIntegrals,figureNo, NUM_BINS)


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
    mean(faceValues)
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

    i=1;
    % Note that we add the minValue to the threshold because the
    % histogram goes from 0 to (maxValue-minValue) and our
    % threshold needs to be between minValue and maxValue.
    if (abs(minThresholdValue) > abs(maxThresholdValue))
        classifiers(i).parity=-1;
        classifiers(i).threshold = valueRange(minThresholdIndex);
    else
        classifiers(i).parity=1;
        classifiers(i).threshold = valueRange(maxThresholdIndex);
    end
           
            figure(figureNo);

            subplot(3,4,1:4)
            plot(valueRange,faceHistogram,'g');
            hold on;
            plot(valueRange,nonFaceHistogram,'r');
            hold on;
            vline(classifiers(i).threshold,'k');
            legend('face','non face','threshold');
            title(sprintf('Threshold: %.03f      Parity: %d      1/2.* totalAlpha: %.03f      Number of Bins: %d',classifiers(i).threshold, classifiers(i).parity, 1/2 .* totalAlpha,NUM_BINS));
            hold off;

            subplot(3,4,5)
            plot(valueRange, faceHistogram);
            hold on;
            vline(classifiers(i).threshold,'k');
            hold off;
            title('Face histogram');

            subplot(3,4,6)
            plot(valueRange, cumFaceHistogram);
            hold on;
            vline(classifiers(i).threshold,'k');
            hold off;
            title('Cumulative Face histogram');

            subplot(3,4,7)
            plot(valueRange, nonFaceHistogram);
            hold on;
            vline(classifiers(i).threshold,'k');
            hold off;
            title('non face histogram');

            subplot(3,4,8)
            plot(valueRange, cumNonFaceHistogram);
            hold on;
            vline(classifiers(i).threshold,'k');
            hold off;
            title('Cumulative Non Face histogram');

            subplot(3,4,9:10)
            plot(valueRange, cumFaceHistogram - cumNonFaceHistogram );
            hold on;
            vline(classifiers(i).threshold,'k');
            hold off;
            title(sprintf('Threshold function (cumFace - cumNonFace) - min: %f max: %f',...
                min(cumFaceHistogram - cumNonFaceHistogram), max(cumFaceHistogram - cumNonFaceHistogram)));

            suptitle(sprintf('Strong Classifier: T=%d',length(trainedClassifiers)));
                fprintf('press key to continue.\n');
            
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % End Visualization         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
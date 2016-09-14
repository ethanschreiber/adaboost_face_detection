% function classifiers = trainClassifiers(filters,faceValues,nonFaceIntegrals);
%
% Returns a vector of structs.  Each struct has the following fields:
%
% 'filter' - The filter for the classifier.
% 'threshold' - The threshold for the classifier.
% 'parity' - The parity of the classifier.
%
% The classifier works as follows:
%
% h(x) =    1, if p * f(x) < p * theta
%           2, otherwise
%
% where:
%   p is the parity (1 or -1)
%   f(x) is the value of the filter
%   theta is the threshold
%   type The type of filter.  Can be (1,2,3,4).  See createFilters for
%       a description of these types.
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function classifiers = ...
    trainClassifiers(filters,filterTypes,faceValues,nonFaceValues, ...
                      valueRanges, faceWeights, nonFaceWeights)

    if (size(filters,3) ~= size(filterTypes,2))
       error(sprintf('The number of filters %d needs to be the same as the number of filter types %d', size(filters,3), size(filterTypes,2)));
    end
    
      % Iterate through each of the filters
    for (i=1:size(filters,3))
        % Save on lookup as we do this a number of times
        valueRange = valueRanges(i,:);
        
        % Weighted Histogram
        faceHistogram    = whistc(double(faceValues(i,:))   , faceWeights, valueRange);
        nonFaceHistogram = whistc(double(nonFaceValues(i,:)), nonFaceWeights, valueRange);

        % Take the cumulative sum of each distribution
        cumFaceHistogram    = cumsum(faceHistogram);
        cumNonFaceHistogram = cumsum(nonFaceHistogram);

        difference = cumFaceHistogram - cumNonFaceHistogram;
        [maxThresholdValue maxThresholdIndex] = max(difference);
        [minThresholdValue minThresholdIndex] = min(difference);

        % Note that we add the minValue to the threshold because the
        % histogram goes from 0 to (maxValue-minValue) and our 
        % threshold needs to be between minValue and maxValue.
        if (abs(minThresholdValue) > abs(maxThresholdValue))
            classifiers(i).parity=-1;
            classifiers(i).threshold = valueRange(minThresholdIndex);
            classifiers(i).threshold2 = valueRange(maxThresholdIndex);
        else
            classifiers(i).parity=1;
            classifiers(i).threshold = valueRange(maxThresholdIndex); 
            classifiers(i).threshold2 = valueRange(minThresholdIndex);
        end

        classifiers(i).filter = filters(:,:,i);
        classifiers(i).type = filterTypes(i);

        
        %visualizeClassifier(valueRange,faceHistogram,nonFaceHistogram,...
        %     cumFaceHistogram,cumNonFaceHistogram,classifiers,i);
        
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualize the results here %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function i = visualizeClassifier(valueRange,faceHistogram,nonFaceHistogram,...
                            cumFaceHistogram,cumNonFaceHistogram,classifiers,i)
        figure(1);
faceHistogram
        subplot(3,4,1:4)
        plot(valueRange,faceHistogram,'g');   
        hold on;
        plot(valueRange,nonFaceHistogram,'r');
        hold off;
        vline(classifiers(i).threshold,'k');
        legend('face','non face','threshold');
        title(sprintf('Threshold: %f Parity: %d',...
            classifiers(i).threshold, classifiers(i).parity));
        

        subplot(3,4,5)
        plot(valueRange, faceHistogram);
        vline(classifiers(i).threshold,'k');            
        title('Face histogram');

        subplot(3,4,6)
        plot(valueRange, cumFaceHistogram);
        vline(classifiers(i).threshold,'k');
        title('Cumulative Face histogram');

        subplot(3,4,7)
        plot(valueRange, nonFaceHistogram);
        vline(classifiers(i).threshold,'k');
        title('non face histogram');

        subplot(3,4,8)
        plot(valueRange, cumNonFaceHistogram);
        vline(classifiers(i).threshold,'k');
        title('Cumulative Non Face histogram');

        subplot(3,4,9:10); 
        plot(valueRange, cumFaceHistogram - cumNonFaceHistogram );
        vline(classifiers(i).threshold,'k');

        title(sprintf('Threshold function (cumFace - cumNonFace) - min: %f max: %f',...
            min(cumFaceHistogram - cumNonFaceHistogram), max(cumFaceHistogram - cumNonFaceHistogram)));

        subplot(3,4,11:12);
        imagesc(displayFilter(classifiers(i).filter,classifiers(i).type,16,16))
        colormap(gray);
        title('Filter');

        fprintf('press key to continue.\n');
        pause;
end

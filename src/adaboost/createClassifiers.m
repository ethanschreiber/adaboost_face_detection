% function classifiers = createClassifiers(filters,faceIntegrals,nonFaceIntegrals);
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
function classifiers = createClassifiers(filters,filterTypes,faceIntegrals,nonFaceIntegrals, isDebug)

    if (size(filters,3) ~= size(filterTypes,2))
       error(sprintf('The number of filters %d needs to be the same as the number of filter types %d', size(filters,3), size(filterTypes,2)));
    end
    
    % The number of histogram bins to use;
    NUM_BINS = 32;

    %h = waitbar(0,sprintf('Finding classifier thresholds [%d/%d]',1,size(filters,3))); 
    % Iterate through each of the filters
    for (i=1:size(filters,3))
       % waitbar(i / size(filters,3),h,sprintf('Finding classifier thresholds [%d/%d]',i,size(filters,3))); 
        % Iterate through each of the 9 mathematical
        % operations in each classifier

        faceValues    = calculateFilter(filters(:,:,i),faceIntegrals);
        nonFaceValues = calculateFilter(filters(:,:,i),nonFaceIntegrals);

        minValue = min(min(faceValues),min(nonFaceValues));
        maxValue = max(max(faceValues),max(nonFaceValues));

        % Find the minimum and maximum filter values.
        binSize = (maxValue - minValue) / NUM_BINS;
        valueRange = double(minValue:binSize:maxValue);

        faceHistogram    = whistc(double(faceValues),valueRange);
        nonFaceHistogram = whistc(double(nonFaceValues),valueRange);

        % normalize
        faceHistogram = faceHistogram ./ sum(faceHistogram);
        nonFaceHistogram = nonFaceHistogram ./ sum(nonFaceHistogram);

        % Take the cumulative sum of each distribution
        cumFaceHistogram    = cumsum(faceHistogram);
        cumNonFaceHistogram = cumsum(nonFaceHistogram);

        [maxThresholdValue maxThresholdIndex] = max(cumFaceHistogram - cumNonFaceHistogram);
        [minThresholdValue minThresholdIndex] = min(cumFaceHistogram - cumNonFaceHistogram);

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

        classifiers(i).filter = filters(:,:,i);
        classifiers(i).type = filterTypes(i);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Visualize the results here %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (isDebug && classifiers(i).type == 3)
            figure(1);

            subplot(3,4,1:4)
            hold on;
            plot(valueRange,faceHistogram,'g');   
            plot(valueRange,nonFaceHistogram,'r');
            vline(classifiers(i).threshold,'k');
            legend('face','non face','threshold');
            title(sprintf('Threshold: %d Parity: %d',...
                classifiers(i).threshold, classifiers(i).parity));
            hold off;

            subplot(3,4,5)
            hold on;
            plot(valueRange, faceHistogram);
            vline(classifiers(i).threshold,'k');            
            title('Face histogram');
            hold off;

            subplot(3,4,6)
            hold on;
            plot(valueRange, cumFaceHistogram);
            vline(classifiers(i).threshold,'k');
            title('Cumulative Face histogram');
            hold off;
            
            subplot(3,4,7)
            hold on;
            plot(valueRange, nonFaceHistogram);
            vline(classifiers(i).threshold,'k');
            title('non face histogram');
            hold off;
            
            subplot(3,4,8)
            hold on;
            plot(valueRange, cumNonFaceHistogram);
            vline(classifiers(i).threshold,'k');
            title('Cumulative Non Face histogram');
            hold off;

            subplot(3,4,9:10); 
            hold on;
            plot(valueRange, cumFaceHistogram - cumNonFaceHistogram );
            vline(classifiers(i).threshold,'k');
            hold off;

            title(sprintf('Threshold function (cumFace - cumNonFace) - min: %f max: %f',...
                min(cumFaceHistogram - cumNonFaceHistogram), max(cumFaceHistogram - cumNonFaceHistogram)));

            subplot(3,4,11:12);
            imagesc(displayFilter(classifiers(i).filter,classifiers(i).type,16,16))
            colormap(gray);
            title('Filter');

            fprintf('press key to continue.\n');
            pause;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % End Visualization         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
   % close(h);
end
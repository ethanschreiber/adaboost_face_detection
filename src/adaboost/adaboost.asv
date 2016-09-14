% function weights =
% adaboost(classifiers,faceIntegrals,nonFaceIntegrals)
% 
% Train the classifier according to the adaboost algorithm.  This is
% detailed in "Rapid Object Detection using a Boosted Cascade of Simplehre
% Features" by Paul Viola and Michael Jones in Table 1.
%
% filters - The filters created using createFilters
%
% filterTypes - The types of the filters created using createFilters
%
% faceIntegrals - The integral images of the face examples as detailed in
% the Viola and Jones paper.
%
% nonFaceIntegrals - The integral images of the non-face examples.
%
% retrainClassifiers - If true, we will retrain the classifiers on each
% iteration of the adaboost algorithm which respect to the weights.
% Otherwise, we train the classifiers once using uniform weights (weighted
% based on the number of face/nonFace images.  See below for details).
%
% T - The number of boosted classifiers to create.
%
% NUM_BINS - The number of bins to use for learning the threshold of each
% classifier.  The larger the number, the more precise the threshold but
% also the more memory you use.  64 seems like a good number.  Too many and
% you will run out of memory.
%
% Returns a vector of structs each with the following fields:
%   classifier: The classifier struct for the the t^th boosted classifier
%   beta: The beta value for the t^th boosted classifier.
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function [trainedClassifiers] = adaboost(filters,filterTypes,faceIntegrals,nonFaceIntegrals, retrainClassifiers, T,NUM_BINS)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % We have lots of initialization to do first %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf('Initializing adaboost!\n\n');
    % Calculate the filter values to be used when thresholding the classifiers
     faceValues    = single(zeros(size(filters,3),size(faceIntegrals,3)));
     nonFaceValues = single(zeros(size(filters,3),size(nonFaceIntegrals,3)));

     fprintf('Calculating filter values\n');
     % Calculate filter values for each filter on each image
     for (i=1:size(filters,3))
            faceValues(i,:)    = calculateFilter(filters(:,:,i),faceIntegrals);
            nonFaceValues(i,:) = calculateFilter(filters(:,:,i),nonFaceIntegrals);
     end

    % Get the min % max classifier values for each filter for the histogram
    maxClassifierValues = double(max([max(faceValues,[],2) max(nonFaceValues,[],2)],[],2));
    minClassifierValues = double(min([min(faceValues,[],2) max(nonFaceValues,[],2)],[],2));

    % Allocate memory for the ranges of the histogram
    valueRanges = zeros(size(maxClassifierValues,1),NUM_BINS);

    % The ranges of each histogram.  Divide into NUM_BINS equally sized bins.
    for (i=1:length(maxClassifierValues))
        valueRanges(i,:) = linspace(minClassifierValues(i),maxClassifierValues(i),NUM_BINS);
    end

    % Initialize the weights to 1/2m and 1/2l where m and l are the number
    % of face images to train on and non face images to train on
    % respectively
    faceWeights    = ones(1,size(faceIntegrals,3)) 	* 1/(2 * size(faceIntegrals,3)); 
    nonFaceWeights = ones(1,size(nonFaceIntegrals,3)) * 1/(2 * size(nonFaceIntegrals,3));

    % Concatenate the two different values
    w = [faceWeights nonFaceWeights];
    
    % The y_i (labels) -> y_i = 1 for faces and 0 for non-faces.
    % Since this is all 0 and 1, we store as a logical array to save space
    y = logical([ones(1,size(faceIntegrals,3)) zeros(1,size(nonFaceIntegrals,3))]);
        
    % Combine the faceIntegrals and nonFaceIntegrals into one image cube
    integralImages = combineImages(faceIntegrals,nonFaceIntegrals);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is if you don't want to retrain each iteration %
    % We will train the classifiers once and store the    %
    % unweighted error for each classifier.  Then, we can %
    % very efficiently compute the weighted error at each %
    % iteration of adaboost.                              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (~retrainClassifiers)
       classifiers = trainClassifiers(filters, filterTypes, faceValues,...
                                       nonFaceValues, valueRanges,...
                                       faceWeights, nonFaceWeights);

                                   

        % preallocating the memory is much faster than iteratively making the
        % matrix larger!  We allocate the memory BUFFER_SIZE at a time.  This
        % is because we need to allocate doubles before converting to logical.
        % If we allocate too many doubles, we will run out of memory.
        BUFFER_SIZE = 3000;
        unweightedError = logical(zeros(min(BUFFER_SIZE,length(classifiers)),size(integralImages,3)));

        for i= 2:ceil(length(classifiers) / BUFFER_SIZE)        
            rowsToAdd = min(length(classifiers) - ((i-1) * BUFFER_SIZE),BUFFER_SIZE);
            unweightedError = [unweightedError; logical(zeros(rowsToAdd,size(integralImages,3)))];        
        end

        for (j=1:size(classifiers,2))
            % vote either 1 (face) or 0 (non-face) for each image using
            % the j^th weak classifier.
            hjx = classifyWeakly(classifiers(j),integralImages);

            % The error with respect to the weight w. 
            % counts the number of misclassifications and multiplies
            % by the weight.
            %
            % Notice we cast this to a logical so that it fits into memory.
            % This is ok since all of the data is 0 or 1.
            %
            % The size of this vector will be 
            % (rows,cols) = (# classifiers, # images)

            unweightedError(j,:) = logical(abs(hjx - y));
        end       
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Adaboost main loop!  Train for T iterations %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Beginning adaboost!\n\n');
    for (t=1:T)
        fprintf('t=%d: ',t);
        tic;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % numbered comments taken from viola and Jones paper.   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 1. Normalize the weights so that w_t is a probability %
        % distribution                                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        w = w ./ sum(w);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Train the filters with respect to the weights          %
        % This is an option.  If retrainClassifiers is true,     %
        % we will retrain (find the best threshold with respect  %
        % to the current weights, w.), otherwise we always use   %
        % the thresholds based on the original weights           %
        % (1/num_faces for the faces and 1/num_non_faces for the %
        % non faces.)                                            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (retrainClassifiers)
            classifiers = trainClassifiers(filters, filterTypes, faceValues,...
                                            nonFaceValues, valueRanges,...
                                            faceWeights, nonFaceWeights);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 2. For each feature, j, train a classifier h_j which is restricted %
        % to using a single feature.  The error is evaluated with respect    %
        % to w_t, epsilon_j = \sum_i w_i |h_j(x_i) - y_i|                    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for (j=1:length(classifiers))
            
            % If we retrained the classifiers, than we need to reclassify
            % all of the images with the new classifiers.
            if (retrainClassifiers)
                % vote either 1 (face) or 0 (non-face) for each image using
                % the j^th weak classifier.
                hjx = classifyWeakly(classifiers(j),integralImages);

                % The error of each classifier with respect to the weight w. 
                % counts the number of misclassifications and multiplies
                % by the weight.
                epsilon(j) = sum(w .* abs(hjx - y));
                
            % If we did not retrain the classifiers, we can use the
            % original unweighted error found and stored and then just
            % multiply the error by the weights            
            else
                epsilon(j) = sum(w .* unweightedError(j,:));
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print out the weak classifiers %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (t == 1)
            [Y,I] = sort(epsilon,'ascend');

            figure(1);
            for (i=1:25)
                subplot(5,5,i);
                imagesc(displayFilter(classifiers(I(i)).filter,classifiers(I(i)).type,16,16))
                colormap(gray);
                title(sprintf('(%d, %.02f)',i,epsilon(I(i))));
            end
            suptitle('Top weak classifiers - (rank, epsilon)');    
           
            drawnow;
        end

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 3. Choose the classifier, h_t, with the lowest error epsilon_t %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [epsilon_t lowestErrorIndex] = min(epsilon);
        timeElapsed = toc;

        fprintf('Lowest epsilon: %f (Filter #%d) Time Elapsed: %f\n',epsilon_t,lowestErrorIndex,timeElapsed); 
        
        trainedClassifiers(t).classifier = classifiers(lowestErrorIndex);
        trainedClassifiers(t).epsilon = epsilon_t;          % For debugging/display
        trainedClassifiers(t).index = lowestErrorIndex;     % For debugging/display
        
        % Classify each sample again with the lowest error weak
        % classifier.  (We could not store the results the first time
        % because it would take too much memory so we compute it a second 
        % time.)
        htx = classifyWeakly(trainedClassifiers(t).classifier, integralImages);

        %%%%%%%%%%%%%%%%%%%%%%%%%
        % 4. Update the weights %
        %%%%%%%%%%%%%%%%%%%%%%%%%
        
        % for each sample, 0 if classified correctly, 1 otherwise
        % (vector operation)
        e = abs(htx - y);

        % Definition of beta according to viola and jones
        beta_t = epsilon_t / (1-epsilon_t);

        % save in order to be used for strong classification later.
        trainedClassifiers(t).alpha = log (1 / beta_t);

        % Update the weights, w (vector operation)
        w = w .* beta_t.^(1-e);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot the error for each classifier for this round %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         close all;
        %         figure(1);
        %         plot(1:length(epsilon),epsilon);
        %         pause;
        %%%%%%%%%%%%%%%%%
    end
end
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function success = printResults(trainedClassifiers,faceIntegrals,nonFaceIntegrals, testingImage, T, FILTER_SIZE, NUM_BINS, RETRAIN_CLASSIFIERS, IMAGE_WIDTH, IMAGE_HEIGHT, STD_THRESHOLD)

    %%%%%%%%%%%%%%%%%%%%%%%%
    % Save figures to disk %
    %%%%%%%%%%%%%%%%%%%%%%%%

    % Put all the figures here
    WRITEUP_DIR = sprintf('%s%s%s%s',pwd,filesep,'writeup',filesep);
    if RETRAIN_CLASSIFIERS 
        BASE_FILENAME=sprintf('%sretrain_filter_%d_bins_%d_',WRITEUP_DIR,FILTER_SIZE,NUM_BINS);
    else
        BASE_FILENAME=sprintf('%sno_retrain_filter_%d_bins_%d_',WRITEUP_DIR,FILTER_SIZE,NUM_BINS);
    end

    % Make the figures open full screen;
    set(0, 'DefaultFigurePosition', get(0,'ScreenSize')); 

    % For the histograms and ROC Curves.
    Ts=[2 5 10 50 100 200];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display the histograms for the strong classifiers %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Generating Strong Classifier Histograms\n');
    figure(2);
    i=1;
    for (t=Ts)
        if (t <= T)
            [valueRange, faceHistogram, nonFaceHistogram,threshold, parity,totalAlpha] = ...
                calculateStrongClassifierHistogram(trainedClassifiers(1:t),faceIntegrals,nonFaceIntegrals,1,NUM_BINS);
            subplot(3,2,i);
            bar(valueRange,faceHistogram,'g');
            hold on;
            bar(valueRange,nonFaceHistogram,'r');
            hold on;
            vline(threshold,'k');
            legend('face','non face','threshold');
            title(sprintf('T: %d      Threshold: %.03f      Parity: %d      # Bins: %d',...
                t,threshold, parity,NUM_BINS));
            hold off;
            i=i+1;
        end
    end
    suptitle('Histograms for the Strong Classifiers');
    % Save it to disk as a png file
    %print('-dpng','-f2','-r300',sprintf('%s%s',BASE_FILENAME,'strong_classifier_histograms.png'));    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Draw the ROC Curve on the training Set %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Generating ROC Curves\n');
    figure(3);
    linespec = {'-o' '-+' '-.' ':' '--' '-'};
    i = 1;
    for (t=Ts)
        [falsePositiveRates, truePositiveRates]= calculateROC(trainedClassifiers(1:t),faceIntegrals,nonFaceIntegrals);
        plot(falsePositiveRates,truePositiveRates,linespec{i});
        i = i+1;
        hold on;
    end
    axis([-.03 .4 .7 1.03]);
    title('ROC Curve for Face Detector on Training Set');
    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
    legend('t=2','t=5','t=10','t=50','t=100','t=200')
    hold off;
    % Save it to disk as a png file
    %print('-dpng','-f3',sprintf('%s%s',BASE_FILENAME,'strong_classifier_roc.png'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display the first 25 boosted classifiers %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Generating Top 25 Boosted Classifiers\n');
    figure(4);
    for (i=1:25)
        subplot(5,5,i);
        imagesc(displayFilter(trainedClassifiers(i).classifier.filter,trainedClassifiers(i).classifier.type,16,16))
        colormap(gray);
        title(sprintf('(%d, %.02f, %.02f)',i, trainedClassifiers(i).epsilon, trainedClassifiers(i).alpha));
    end
    suptitle('Top boosted classifiers - (rank, epsilon, alpha)');

    % Save it to disk as a png file
    print('-dpng','-f3','-r600',sprintf('%s%s',BASE_FILENAME,'25_boosted_classifiers.png'));    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create gaussian pyramid of class image %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     fprintf('Generating Classified Test Image\n');
     pyramid = gaussianPyramid(testingImage,8);

    % % Display the pyramids with 16x16 rectangles to see if the size is
    % % reasonable
    % for (i=1:length{pyramid})
    %      figure(2 + i);
    %     imagesc(pyramid{i}); 
    %     colormap gray;  
    %     title(sprintf('Pyramid Level %d: (%d,%d)',i,size(pyramid{i},2), size(pyramid{i},1)));
    %     plotRectangles(pyramid{i},10, 16, 16);
    % end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Iterate through the class image patches %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    strongClassifiers = trainedClassifiers(1:T);
    halfHeight = IMAGE_HEIGHT / 2;
    halfWidth = IMAGE_WIDTH / 2;

    baseHeight = size(pyramid{1},1);
    baseWidth  = size(pyramid{1},2);

    baseCoordsCount = 1;
    selectedFace = zeros(16,16,0);
    selectedFaceStd = zeros(0)
    for (level = 3:length(pyramid))
    %     figure(4 + i);
    %     imagesc(pyramid{i}); 
    %     colormap gray;  
    %     axis image;
    %     hold on;
    %     
    %    title(sprintf('Pyramid Level %d: (%d,%d)',i,size(pyramid{i},2), size(pyramid{i},1)));
        %plotRectangles(pyramid{i},10, 16, 16);

        h = waitbar(0,sprintf('Image %d/%d',level,length(pyramid))); 


        numRows = size(pyramid{level},1);
        numCols = size(pyramid{level},2);

        for (row=1:2:numRows-16)
            idx = 1;

            colValues = 1:2:size(pyramid{level},2)-15;

            patches = zeros(16,16,length(colValues));
            for (col=colValues)
                patches(:,:,idx) = pyramid{level}(row:row+15,col:col+15);               
                idx = idx + 1;
            end

            normalizedPatches = normalizeImages(patches);
            patchIntegrals = integralImage(normalizedPatches);
            results = classifyStrongly(strongClassifiers,patchIntegrals);

            for (i=1:length(results))
                if (results(i))
                     % Calculate the coords of this found face in the base
                     % image

                     % A face must have some standard deviation.  This removes
                     % perfectly uniform spaces which can pass the test.
                        patch = patches(:,:,i);
                        patchStd = std(patch(:));

                        selectedFace(:,:,end+1) = patch;
                        selectedFaceStd(end+1) = patchStd;

                    if (patchStd > STD_THRESHOLD)
                        col = colValues(i);

                        baseX = col * baseWidth / numCols;
                        baseY = row * baseHeight / numRows;
                        baseFilterWidth = IMAGE_WIDTH * baseWidth / numCols;
                        baseFilterHeight = IMAGE_HEIGHT * baseHeight / numRows;


                        baseCoords(baseCoordsCount,:) = [baseX baseY baseFilterWidth baseFilterHeight];

                        baseCoordsCount = baseCoordsCount+1; 
                    end
                end
            end


            percentDone = row/(numRows-16);

            waitbar(percentDone,h,sprintf('Image [%d/%d] %f%% done',level,length(pyramid),percentDone * 100));

        end
        hold off;
        close(h);
    end




    figure(10)
    imagesc(pyramid{1}); 
    colormap(gray)

    hold on;   

    for i=1:size(baseCoords,1)
        rectangle('Position',baseCoords(i,:));
    end
    hold off;
    axis image;

    if (RETRAIN_CLASSIFIERS)
        title(sprintf('Class picture with T=%d, retraining of classifiers and minimum filter size of %d',T,FILTER_SIZE)); 
    else
        title(sprintf('Class picture with T=%d, no retraining of classifiers and minimum filter size of %d',T,FILTER_SIZE)); 
    end

    % Save it to disk as a png file
    print('-dpng','-f10',sprintf('%s%s',BASE_FILENAME,'strong_classifier_histograms.png'));    
    
    % This is a nonsense return value;
    success=1; 
end
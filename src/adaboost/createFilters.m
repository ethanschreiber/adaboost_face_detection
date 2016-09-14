% function filterMatrix = createFilters()
%
% Create the matrix of classifiers.  Each classifier is a 3xn_i array where i 
% represents a 2, 3 or 4 rectangle filter.  n_2 = 6.  n_3 = 8 and 
% n_4=9.  The return classifierMatrix will be 3x9xNUM_POSSIBLE_CLASSIFIERS.  For the 2 and 3
% rectangle matrices, the 7tth, 8th and 9th value will have their value
% set to 0 and row, col set to 1 as described below.
%
% Each of the 3-tuples (row,col,val) describes a multiplication.
%
% You multiply the value at (row,col) in each integral image by
% val.  val will be 0,1 or 2.  There are
% val.
%
% The return filterTypes identifies each of the filters as either
% a 2 rectangle left right, 2 rectangle, top bottom, 3 rectangle or 4
% rectangle filter.  The values of the columns of this vector are the
% integers {1,2,3,4) which represent these 4 cases respectively.
%
% minFilterSize - The smallest dimension of a filter to create.
% maxFilterSize - The largest dimension of a filter to create.
% imageWidth - The width of the image we are to classify.
% imageHeight - The height of the image we are to classify.
%
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function [filterMatrix filterTypes] = createFilters(minFilterSize, maxFilterSize, ...
                                        imageWidth, imageHeight)
        
    OUTPUT_FILE = sprintf('%s%s%s%s%s%d%s',pwd,filesep,'data',filesep,'filters_',minFilterSize,'.mat');    
    if (exist(OUTPUT_FILE,'file')) 
        fprintf('Loading from %s.\n',OUTPUT_FILE);
        load(OUTPUT_FILE);
    else

        
        i = 1;
        % ie, if minFilterSize is 4 and imageHeight is
        % 16, then the top left of a filter can go as high
        % as row 13  (13,14,15,16 is size 4)

        % Start the anchor at row 1 and go to the size of the image
        % - the smallest possible filter height
        h = waitbar(0,sprintf('Creating Filters')); 

        for (rowAnchor=1:(imageHeight-minFilterSize)+1) 
            waitbar(rowAnchor / ((imageHeight-minFilterSize)+1), h, 'Creating Filters');
            
            for (colAnchor=1:(imageWidth-minFilterSize)+1)
                
                % Notice the -1 for each.  This is because we want to
                % subtract the rectangle one above, to the left and to the
                % above/right.
                TL = [rowAnchor - 1 colAnchor - 1];          % Top Left

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Create the 2 rectangle left/right filters %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %  v-- (rowAnchor-1, colAnchor-1)
                % TL|     TM |      TR|
                % --+--------+--------+
                %   |        |        |
                %   |        |        |
                %   |   -    |   +    |
                %   |        |        |
                % BL|      BM|      BR<-- (rowAnchor + filterHeight - 1,
                % --|--------+--------+    colAnchor + (2*filterWidth) - 1)
                %                                    
                % 
                % (BR + TM - BM - TR) - (BM + TL - BL - TM) 
                %  = 2TM - 2BM + BR - TR -TL + BL
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                for (filterWidth=minFilterSize:floor((imageWidth - colAnchor + 1) / 2))
                    for (filterHeight=minFilterSize:(imageHeight - rowAnchor + 1))
                        BR = [(TL(1) + filterHeight) (TL(2) + (2 * filterWidth))]; % Bottom Right
                        TR = [TL(1) BR(2)]; % row from TL, col from BR  % Top Right
                        BL = [BR(1) TL(2)]; % row from BR, col from TL  % Bottom Left

                        TM = [TL(1) (TL(2) + filterWidth)];   % Top Middle
                        BM = [BR(1) TM(2)];                       % Bottom Middle

                        % the 0s are dummy variables so the calculation matrices are the
                        % same size for 2,3 and 4 rectangle filters.
                        filterMatrix(:,:,i) = [TL -1; TR -1; BL 1; BR 1; TM 2; BM -2; 0 0 0; 0 0 0; 0 0 0];
                        filterTypes(i) = 1;
                        i = i+1;
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Create the 2 rectangle top/bottom filters %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %  TL|               TR| 
                %  --+-----------------+
                %    |                 |
                %    |        +        |                    
                %  ML|               MR|
                %  --+-----------------+ 
                %    |                 |
                %    |        -        |
                %  BL|               BR|
                %  --+-----------------+
                %                    
                % 
                % (MR + TL - ML - TR) - (BR + ML -BL - MR)
                %  = 2MR - 2ML + TL - TR - BR + BL)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                for (filterWidth=minFilterSize:(imageWidth - colAnchor + 1))
                    for (filterHeight=minFilterSize:floor((imageHeight - rowAnchor + 1) / 2))
                       BR = [(TL(1) + (2 * filterHeight))...
                             (TL(2) + (filterWidth) )]; % Bottom Right
                       TR = [TL(1) BR(2)]; % row from TL, col from BR  % Top Right
                       BL = [BR(1) TL(2)]; % row from BR, col from TL  % Bottom Left
                        
                       ML = [(TL(1) + filterHeight) TL(2) ];  % Middle Left
                       MR = [ ML(1) TR(2) ];                       % Middle Right

                       filterMatrix(:,:,i) = [TL 1; TR -1; BL 1; BR -1; ML -2; MR 2; 0 0 0; 0 0 0; 0 0 0];
                       filterTypes(i) = 2;
                        i = i+1;
                    end
                end
 
                for (filterWidth=minFilterSize:floor((imageWidth - colAnchor + 1) / 3))
                    for (filterHeight=minFilterSize:(imageHeight - rowAnchor + 1))
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Create the 3 rectangle LR filters              %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %
                        % Note that we weight the center section by 2 here
                        % so that the mean of the filter values is 0.
                        %
                        %  TL|    TML|    TMR|     TR|
                        %  --+-------+-------+-------+
                        %    |       |       |       |
                        %    |       |       |       |            
                        %    |       |  2x   |       |
                        %    |   -   |   +   |   -   |
                        %    |       |       |       |
                        %    |       |       |       |
                        %  BL|    BML|    BMR|     BR|
                        %  --+-------+-------+-------+
                        % 
                        % 2*(BMR + TML - BML -TMR) - (BR + TMR - TR - BMR) -
                        %  (BML + TL - BL -TML) 
                        %  = 3BMR + 3TML - 3BML -3TMR - BR + TR -TL + BL
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BR = [(TL(1) + filterHeight)...
                              (TL(2) + (3 * filterWidth))]; % Bottom Right
                        TR = [TL(1) BR(2)]; % row from TL, col from BR  % Top Right
                        BL = [BR(1) TL(2)]; % row from BR, col from TL  % Bottom Left
                       
                        TML = [TL(1) (TL(2)  + filterWidth)];
                        TMR = [TL(1) (TML(2) + filterWidth)];
                        BML = [BL(1) TML(2)];
                        BMR = [BL(1) TMR(2)];

                        filterMatrix(:,:,i) = [TL -1; TR 1; BL 1; BR -1; TML 3; TMR -3; BML -3; BMR 3; 0 0 0];
                        filterTypes(i) = 3;
                        i = i+1;
                    end
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Create the 4 rectangle checkerboard filters    %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %  TL|    TM |    TR |
                %  --+-------+-------|
                %    |       |       |
                %    |   -   |   +   |            
                %  ML|      M|     MR|
                %  --+-------+-------+ 
                %    |       |       |
                %    |   +   |   -   |
                %  BL|     BM|     BR|
                %  --+-------+-------+
                %    BL           
                % 
                %   (MR + TM - M - TR) + (BM + ML -BL -M) 
                %  -(BR + M - BM -MR) - (M + TL + ML + TM) 
                %  =(2MR + 2TM + 2ML + 2BM - 4M - TR - BL  -BR -TL
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for (filterWidth=minFilterSize      :floor((imageWidth  - colAnchor + 1) / 2))
                    for (filterHeight=minFilterSize :floor((imageHeight - rowAnchor + 1) / 2))
                        BR = [(TL(1) + ( 2 * filterHeight))...
                              (TL(2) + ( 2 * filterWidth)) ]; % Bottom Right
                        TR = [TL(1) BR(2)]; % row from TL, col from BR  % Top Right
                        BL = [BR(1) TL(2)]; % row from BR, col from TL  % Bottom Left
                        
                        TM = [TL(1) (TL(2) + filterWidth)];             % Top Middle
                        BM = [BR(1) TM(2)];                             % Bottom Middle

                        ML = [(TL(1) + filterHeight) TL(2) ];           % Middle Left
                        MR = [ ML(1) TR(2) ];                           % Middle Right

                        M  = [ML(1) TM(2)];
                        
                        filterMatrix(:,:,i) = [TL -1; TR -1; BL -1; BR -1; TM 2; ML 2; M -4; MR 2; BM 2];
                        filterTypes(i) = 4;
                        i = i+1;
                        %fprintf('(%d %d) - %d\n',filterHeight,
                        %filterWidth, i);
                    end
                end

            end            
        end
     
        fprintf('Saving filterMatrix and filterTypes to %s.\n',OUTPUT_FILE);
        save(OUTPUT_FILE,'filterMatrix','filterTypes');
        close(h);
    end
end
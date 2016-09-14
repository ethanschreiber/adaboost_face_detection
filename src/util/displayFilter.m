% function filter = displayFilter(classifier, filterHeight, filterWidth)
%
% Given a 9x3 filter, this creates 
% a visual of the filter with the positive in white, the negative in WHITE
% and the neutral in gray.
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function filterImage = displayFilter(filter, filterType, filterHeight, filterWidth)

    % The background is gray;
    filterImage = ones(filterHeight, filterWidth) * 127;
    BLACK = 0;
    WHITE = 255;
    
    % the top left row is actually stored
    % as the row and col just up and to the left
    % for purposes of calculation.  For display, add 1 back
    % to each.
    tlRow = filter(1,1) + 1;
    tlCol = filter(1,2) + 1;

    % Some of these variables are never used but we keep them nonetheless
    % for clarity since the speed of this method does not matter (plus the
    % difference is negligible, Big O people!)
    trRow = filter(2,1);
    trCol = filter(2,2);

    blRow = filter(3,1);
    blCol = filter(3,2);

    brRow = filter(4,1);
    brCol = filter(4,2);
    
    
    switch (filterType)
        case (1) % 2 rectangle left right
            %disp('2 rectangle left right');
            % [TL -1; TR -1; BL 1; BR 1; TM 2; BM -2; 1 1 0; 1 1 0; 1 1 0];
            
            tmCol = filter(5,2);
            
            filter
            fprintf('%d:%d, %d:%d    %d:%d, %d:%d\n',tlRow,blRow,tlCol,tmCol,tlRow,blRow,tmCol+1,trCol);
            filterImage(tlRow     :blRow, ...
                        tlCol     :tmCol) = WHITE;
            filterImage(tlRow     :blRow, ...
                        tmCol + 1 :trCol) = BLACK;             
        case (2) % 2 rectangle top bottom
            %disp('2 rectangle top bottom');
            % [TL 1; TR -1; BL 1; BR -1; ML -2; MR 2; 1 1 0; 1 1 0; 1 1 0];
            
            mlRow = filter(5,1);
            
            filterImage(tlRow     :mlRow, ...
                        tlCol     :trCol) = BLACK;
            filterImage(mlRow + 1 :blRow, ...
                        tlCol     :trCol) = WHITE;             
        case (3) % 3 rectangle
            %disp('3 rectangle');
            % [TL -1; TR 1; BL 1; BR -1; TML 2; TMR -2; BML -2; BMR 2; 1 1 0];
            tmlCol = filter(5,2);
            tmrCol = filter(6,2);
            filterImage(tlRow      :blRow, ...
                        tlCol      :tmlCol) = WHITE;
            filterImage(tlRow      :blRow, ...
                        tmlCol + 1 :tmrCol) = BLACK;             
            filterImage(tlRow      :blRow, ...
                        tmrCol + 1 :trCol) = WHITE;
        case (4) % 4 rectangle  
            %disp('4 rectangle');
            % [TL -1; TR -1; BL -1; BR -1; TM 2; ML 2; M -4; MR 2; BM 2];
            mRow = filter(7,1);
            mCol = filter(7,2);
            
            filterImage(tlRow    :mRow, ...
                        tlCol    :mCol) = WHITE;  % TL
            filterImage(tlRow    :mRow, ...
                        mCol + 1 :trCol) = BLACK;  % TR        
            filterImage(mRow + 1 :blRow, ...
                        tlCol    :mCol) = BLACK;  % BL
            filterImage(mRow + 1 :blRow, ...
                        mCol + 1 :trCol) = WHITE;  % BR      
    end
end
%
% CS 276 (Fall 2007) - Project 2
% Author: Ethan L. Schreiber
% Date: November/December, 2007
function imageValues = calculateFilter(filter,imageIntegrals)
    numIntegrals = size(imageIntegrals,3);
    imageValues = zeros(1,numIntegrals);
    
    for (j=1:size(filter,1))
        row = filter(j,1);
        col = filter(j,2);
        coefficient = filter(j,3);

        % if the row or col is 0, this means that there is no
        % rectangle above or to the left that needs to be subtracted
        % so we can skip it.
        if (row > 0 && col > 0)
           % fprintf('(%d,%d) - %d\n',row,col,coefficient);
            imageValues = imageValues + ...
                (coefficient .* reshape(imageIntegrals(row,col,:),1,numIntegrals));
        end
    end
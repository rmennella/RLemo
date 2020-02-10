function [shuffleMatrix] = randpermrows(matrix)
%function to permute randomly columns in a matrix
    [nrows, ncols] = size(matrix);
    randrows = randperm(nrows);
    shuffleMatrix = zeros(nrows, ncols);
    for i = 1:nrows
        shuffleMatrix(i,:) = matrix(randrows(i), :);
    end
    
end


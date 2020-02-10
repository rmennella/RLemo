function [shuffleMatrix] = randpermcol(matrix)
%function to permute randomly columns in a matrix
    randcol = randperm(length(matrix));
    [nrows, ncols] = size(matrix);
    shuffleMatrix = zeros(nrows, ncols);
    for i = 1:length(matrix)
        shuffleMatrix(:,i) = matrix(:, randcol(i));
    end
    
end
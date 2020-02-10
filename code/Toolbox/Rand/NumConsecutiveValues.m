function [compte] = NumConsecutiveValues(allStims, line, number)
%NUMCONSECUTIVESVALUES Summary of this function goes here
%   Detailed explanation goes here
    compte = 0;
    for i = 1:(length(allStims)-1)
        if (allStims(line, i) == number && allStims(line, i+1) == number)
            compte = compte+1;
        end
    end
end


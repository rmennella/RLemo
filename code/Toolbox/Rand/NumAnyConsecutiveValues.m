function [compte] = NumAnyConsecutiveValues(allStims, line)
%NUMCONSECUTIVESVALUES Summary of this function goes here
%   Detailed explanation goes here
    compte = 0;
    for i = 1:(length(allStims)-2)
        if ((allStims(line, i) == allStims(line, i+1)) && (allStims(line, i) == allStims(line, i+2)))
            compte = 1;
            break
        end
    end
end


function [shuffleBlocStim] = randbloc(blocStim)
    %RANDPERMSTIM Summary of this function goes here
    %   Detailed explanation goes here
    randCol = randperm(length(blocStim));
    shuffleBlocStim = nan(1, length(blocStim), []);
    for i = 1:length(blocStim)
        shuffleBlocStim(i).emotion = blocStim(randCol(i)).emotion;
        shuffleBlocStim(i).trial = blocStim(randCol(i)).trial;
        
        shuffleBlocStim(i).gender = blocStim(randCol(i)).gender;
        shuffleBlocStim(i).pair = blocStim(randCol(i)).pair;
        
        shuffleBlocStim(i).side = blocStim(randCol(i)).side;
        shuffleBlocStim(i).orient = blocStim(randCol(i)).orient;
        shuffleBlocStim(i).intensity = blocStim(randCol(i)).intensity;
        
        shuffleBlocStim(i).actor1 = blocStim(randCol(i)).actor1;
        shuffleBlocStim(i).actor2 = blocStim(randCol(i)).actor2;
        
        shuffleBlocStim(i).file{1} = blocStim(randCol(i)).file{1};
        shuffleBlocStim(i).file{2} = blocStim(randCol(i)).file{2};
    end
end


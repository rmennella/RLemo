function [firstChoice, lastChoice, timeFirstChoice, timelastChoice ] = KeyFreeChoice(ecran)
%DRAWLINE Summary of this function goes here
%   Detailed explanation goes here

    addpath('../IO');

    KbName('UnifyKeyNames');
    lKeyhand = KbName('Q');
    rKeyhand = KbName('M');
    
    firstChoice = 'NoAnswer';
    timeFirstChoice = -1;

    leftdot = [960 900];
    rightdot = [960 900];

    neutralway = [];

    neutralway.xorigin = 960;
    neutralway.yorigin = 830;

    neutralway.xtarget = 960;
    neutralway.ytarget = 830;

    startTime = GetSecs;
    if CheckKeyPress(lKeyhand) && ~CheckKeyPress(rKeyhand)
        
        Screen('DrawDots', ecran, leftdot, 20, [255 0 0 1]);
        t = Screen('Flip',ecran);
        if timeFirstChoice < 0
            timeFirstChoice = GetSecs-startTime;
            
        end

        leftdot(1) = leftdot(1)-3.20;
        rightdot(1) = rightdot(1)+3.20;

        leftdot(2) = leftdot(2)-2;
        rightdot(2) = rightdot(2)-2;

        neutralway.ytarget = leftdot(2);



    elseif CheckKeyPress(rKeyhand) && ~CheckKeyPress(lKeyhand)

        Screen('DrawDots', ecran, rightdot, 20, [0 255 0 1]);
        t = Screen('Flip',ecran);

        leftdot(1) = leftdot(1)-3.20;
        rightdot(1) = rightdot(1)+3.20;

        leftdot(2) = leftdot(2)-2;
        rightdot(2) = rightdot(2)-2;

        neutralway.ytarget = rightdot(2);

    else
        
        Screen('DrawLine', ecran, [0 0 255 1], neutralway.xorigin, neutralway.yorigin, neutralway.xtarget, neutralway.ytarget, 20);
        t = Screen('Flip',ecran);

        neutralway.ytarget = neutralway.ytarget-2;

        leftdot(1) = leftdot(1)-3.20;
        rightdot(1) = rightdot(1)+3.20;

        leftdot(2) = leftdot(2)-2;
        rightdot(2) = rightdot(2)-2;

    end
            
        
end


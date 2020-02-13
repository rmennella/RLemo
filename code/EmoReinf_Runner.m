
% BEFORE RUNNING THE SCRIPT FOR THE FIRST TIME FOR EACH SUBJECT BE SURE
% THAT YOU CLEAR ALL

% If it's the first run, get all the info
if ~exist('participant', 'var')
    %% SETUP
    clear('all');
    close('all');
    clc;
    
    % initialise random number generator0
    seed = sum(100*clock);
    rand('twister',seed);
    randn('state',seed);
    
    
    % get participant information
    argindlg = inputdlg({'Identifier (S##)','Gender (M/F)','Age (y)','Handedness (L/R)','Training (0) or Task (1)'},'',1);
    if isempty(argindlg)
        error('Experiment cancelled!');
    end
    participant            = [];
    participant.identifier = argindlg{1};
    participant.gender     = argindlg{2};
    participant.age        = argindlg{3};
    participant.handedness = argindlg{4};
    participant.date       = datestr(now,'yyyymmdd-HHMM');
    task = logical(str2double(argindlg{5}));
    
    % check subject identifier
    sid = sscanf(participant.identifier,'S%d');
    if isempty(sid)
        error('Invalid subject identifier!');
    end

    
else % otherwise just ask if training or task is wanted
    
    task = str2double(inputdlg({'Training (0) or Task (1)'},'',1));
    
    % Training again or true task?
    if isempty(task)
        error('Specify if you want to launch training or task');
    end
    
end


% build experiment (if not previously done)
if ~exist('stimulus', 'var')
    stimulus = EmoReinf_Build_Experiment(400);
end

if ~task
    %% TRAINING CENTER
    %build training
 
    stimulustraining = EmoReinf_BuildTraining(20);
    prob_reward = 0.5;
    % run training
   [stimulustraining,responsetraining,tstimchecktraining] = EmoReinf_Run_Experiment(sid,stimulustraining,prob_reward, task, 0);
     
else
        %% EXPERIMENT MANIP CENTER
    % in this version of the code we run bloc separately in order to be sure
    % that if something happens we can still restart from the block that we want

    % If something goes wrong and you want to restart from the last block, just clear all, 
    % reload the last good block, and run. Otherwise, you can simply click again Run and it will continue
    % from the next one
   
    isRobot     = 0;
    prob_reward = 0.8;
    physio      = 1; % do you want to record physiological signals?
    
    % run experiment
    [stimulus,response,tstimcheck] = EmoReinf_Run_Experiment(sid,stimulus, prob_reward, task, isRobot, physio);
    % save data at each block, including present block number)
    filename = sprintf('../data/EmoReinf_%s_%s.mat',participant.identifier,participant.date);
    save(filename, 'response', 'stimulus', 'tstimcheck', 'prob_reward')
%     checkTiming
end
function [stimulus_rand,response,tstimcheck] = EmoReinf_Run_Experiment(sid,stimulus_rand, prob_reward, task, isRobot, physio)
% Fonction permettant de faire lancer l'experience
% Arguments d'entrée :
% sid = numéro du participant
% stimulus_rand = matrice de stimuli sortant de la fonction Build_experiment
% the probability of reward associated with the good response
% is this a task (1) or a training (0) session?
% do you want a robot to respond for you? (yes = 1, no = 0)
% do you want to record physio? (yes = 1, no = 0)

% Arguments de sortie :
% stimulus = matrice des stimuli utilisés dans la fonction
% response = caractéristiques de réponses du sujet
% tstimcheck = variables controlées dans l'experience

if task
    stimulus = stimulus_rand.stimulus;
else
    stimulus = stimulus_rand;
end
nstims = length(stimulus);

if task
    cumsumReversals = cumsum(stimulus_rand.reversals);
    nReversals      = length(cumsumReversals);
end
%% General settings and variables initialisation
% add toolbox functions
addpath('./Toolbox/IO');
addpath('./Toolbox/Draw');

% conditions
anger = {'A', 7}; % lettre correspondant a l'emotion : ici Angry
neutral = {'N', 0}; % lettre correspondant a l'emotion : ici Neutre

% mean luminance and contrast to standardize images
mean_lumi = 0.4284;
mean_contr = 0.2022;

% N of pixel for cutting the original images. They will be always display
% on the full left and right part of the screen

% this cuts out the external arms of the chairs
% this will be cut on the right of the img on the left and on the right of the other one.
% figures on the y axis will be cut in proportion at line ...
cut_img_x = 70;


% set button inputs for response collection (different for IRM and comport)
KbName('UnifyKeyNames');
keyquit = KbName('ESCAPE');
keywait = KbName('space');
lKeyhand = KbName('S');
rKeyhand = KbName('L');


% SET JITTER's EXTREMES in seconds
jitter = [0.5 0.75];

% set scene fixed duration
timeStim = 1.500;

% set gray screen fixed duration
timeGrScreen = 0.500;

scrumble_time = 0.2; %affichage scene with new emotion and ID participant
FB_time = 0.5;

% Is this a pilot session with simulated responses?
if isRobot
    %Initialize the java engine
    import java.awt.*;
    import java.awt.event.*;
    
    %Create a Robot-object to do the key-pressing
    rob=Robot;
end

% Is this a  session with physiological recordings?
if physio
    
    %Open Serial Port
    s1 = serial('COM4', 'BaudRate', 115200,'DataBits', 8, 'StopBits', 1, 'FlowControl', 'none', 'Parity', 'none', 'Terminator', 'CR', 'Timeout', 400, 'InputBufferSize', 16000);
    fopen(s1);
    
    % Initialize markers
    
    % general markers
    m_startInstruction = 20;
    m_pause            = 30;
    m_endExperiment    = 40;
    
    % specific markers
    m_greyscreen = 1;
    m_fixation   = 2;
    m_scene      = 3;
    m_scrumble   = 4;
    m_respCorr   = 5;
    m_respUncorr = 6;
    
    m_approach   = 7;
    m_avoidance  = 8;
    m_miss       = 9;
end


try
    %% launch psychtoolbox
    HideCursor;
    FlushEvents;
    ListenChar(2);
    Screen('Preference','VisualDebuglevel',3);
    Screen('Preference','SkipSyncTests',0);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask','General','UseFastOffscreenWindows');
    PsychImaging('AddTask','General','NormalizedHighresColorRange');
    
    % create a video variable with all the video parameters
    video = struct;
    video.id = max(Screen('Screens'));
    video.h = PsychImaging('OpenWindow',video.id,0);
    [video.x,video.y] = Screen('WindowSize',video.h);
    % refresh rate of the monitor
    video.ifi = Screen('GetFlipInterval',video.h,100,50e-6,10);
    
    % all screen parameters
    Screen('BlendFunction',video.h,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    LoadIdentityClut(video.h);
    Screen('ColorRange',video.h,1);
    Screen('TextFont',video.h,'Arial');
    Screen('TextSize',video.h,22);
    Screen('TextStyle',video.h,0);
    Priority(MaxPriority(video.h));
    
    % print on screen a rectangle of the size of the screen
    Screen('FillRect',video.h,0);
    t = Screen('Flip',video.h);
    roundfr = @(dt)(round(dt/video.ifi)-0.5)*video.ifi;
    aborted = false;
    
    
    % Coordonnées d'apparition de la photo du participant
    targetDistonXaxis = video.x/12; % sur l'axe des x (150)
    targetDistonYaxis = video.y/2; % sur l'axe des y (400)
    
    %% Initialise response variables
    tstimcheck = struct;
    response = struct;
    
    for xxx = 1:nstims
        
        tstimcheck(xxx).greyscreen    = nan; %%%quand écran gris apparait
        tstimcheck(xxx).scene         = nan;%%%%quand scene+cross apparait
        tstimcheck(xxx).progrJitter   = nan; %%%jitter programme
        tstimcheck(xxx).realJitter    = nan; %%% jitter réel
        tstimcheck(xxx).t_scrumble    = nan;
        tstimcheck(xxx).feedback      = nan;
        tstimcheck(xxx).tot           = nan;
        tstimcheck(xxx).totReal       = nan;
        
        
        response(xxx).iscor = nan; % correct answer if resp is 1 or 2
        response(xxx).resp = nan;  % 2:right 1:left 0: no rep
        response(xxx).timeResponse = nan; % 0: no rep
        response(xxx).coin = nan; % renvoi le nombre aleatoire tiré entre 0 et 1
        response(xxx).side_emo = nan; % de quel coté est apparu lemotion
        response(xxx).probability = nan;
        response(xxx).goodButton = nan;
        response(xxx).reversal = nan;
        response(xxx).pause = nan;
        response(xxx).reward = nan;
        response(xxx).hits = nan;
        % this is useful when we simulate responses
        response(xxx).simulRT = nan;
        response(xxx).programmedRT = nan;
        response(xxx).simulbutton = nan;
        
    end
    %% INSTRUCTIONS
    % ------------------------------------------------------------------------------------------------%
    %                                        PAGE 1
    % ------------------------------------------------------------------------------------------------%
    labeltxt = strcat('Instructions :');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2 - video.y/3);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Une scène va apparaître, vous êtes dans une salle d''attente et vous devez choisir à quelle place vous souhaitez vous asseoir.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2 - video.y/4);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Si vous souhaitez choisir le siège de gauche, appuyez sur S.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Si vous souhaitez choisir le siège de droite, appuyez sur L.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2 + video.y/10);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Appuyez sur espace pour la deuxieme partie des consignes');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2 + video.y/3);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    Screen('DrawingFinished',video.h);
    Screen('Flip',video.h,t+roundfr(1.000+0.250*rand));
    
    if physio % if this a  session with physiological recording
        % send marker for start istruction
        fprintf(s1,['mh',m_startInstruction]);
    end
    
    
    % wait for the subject to press a button to go to the 2nd page
    WaitKeyPress(keywait);
    
    % ------------------------------------------------------------------------------------------------%
    %                                 PAGE 2
    % ------------------------------------------------------------------------------------------------%
    
    labeltxt = strcat('Avant chaque scène, un écran gris avec une croix de fixation va apparaître.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Vous devrez fixer la croix TOUT AU LONG de l''essai.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2 + video.y/10);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat(sprintf('Merci d''appuyer sur espace pour lancer l''experience'));
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt), video.x/2,video.y/2 + video.y/3);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    Screen('DrawingFinished',video.h);
    Screen('Flip',video.h,t+roundfr(1.000+0.250*rand));
    
    % wait for the subject to press a button to end instructions
    WaitKeyPress(keywait);
    
    
    
    %%%% LOAD THINGS THAT YOU CAN LOAD IN ADVANCE %%%%%%
    
    % where does the picture of the participant have to attain?
    target = [];
    target.left = [targetDistonXaxis targetDistonYaxis];
    target.right = [video.x-targetDistonXaxis targetDistonYaxis];
    
    
    % fixation cross
    [cross, ~, alpha] = imread('CROSS3.png');
    cross(:,:,4) = alpha(:,:);
    patchtex_cross = Screen('MakeTexture',video.h,cross,[],[],[]);
    patchrct_cross = CenterRectOnPoint(Screen('Rect',patchtex_cross),video.x/2,video.y/2 - video.y/3);
    
    % grey screen
    img_greyscreen = double(imread('Greyscreen.jpg'))/255;
    img_greyscreen = img_greyscreen(:,:,1);
    patchtex_greyscreen = Screen('MakeTexture',video.h,img_greyscreen,[],[],1);
    patchrct_greyscreen = CenterRectOnPoint(Screen('Rect',patchtex_greyscreen),video.x/2,video.y/2);
    
    % Participant's ID
    part = double(imread(sprintf('S%02d.jpg', sid)))/255;
    part = part(:,:,1);
    patchtex_ID = Screen('MakeTexture',video.h,part,[],[],1);
    
    % Define position for actors' images
    patchrct_act1 = [0 0 video.x/2 video.y];
    patchrct_act2 = [video.x/2 0 video.x video.y];
    
    %     % define position of the scrumbled images
    %     patchrct_scrumble_act1 = [video.x/4.5 video.y/40 video.x/2-(video.x/40) video.y/2];
    %     patchrct_scrumble_act2 = [video.x/2+(video.x/40) video.y/40 video.x-(video.x/4.5) video.y/2];
    %
    % define negative feedback
    negfb = strcat('TROP LENT !!');
    label_feedback = CenterRectOnPoint(Screen('TextBounds',video.h,negfb), video.x/2,video.y/2 - video.y/3);
    
    % define pause message
    pause_msg = strcat('PAUSE : Appuyez sur ESPACE lorsque vous souhaitez reprendre');
    label_pause_msg = CenterRectOnPoint(Screen('TextBounds',video.h,pause_msg),video.x/2,video.y/2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    % signal to the subject that the task is about to start
    labeltxt = 'Préparez-vous !';
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2-100);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    Screen('DrawingFinished',video.h);
    
    Screen('Flip',video.h);
    WaitSecs(0.5);
    
    
    %% START STIMULI LOOP
    for istim = 1:nstims
        
        t_initNewTrial = GetSecs;
        
        response(istim).goodButton = stimulus(istim).goodButton;
        response(istim).reversal = stimulus(istim).reversal;
        response(istim).probability = prob_reward;
        
        % Is this a pilot session with simulated responses?
        if isRobot
            % flip the coin to choose left or roght response
            coin = rand(1);
            if coin >= 0.5
                robotResp = 1;
            else
                robotResp = 2;
            end
            
            simRT = round(rand(1)+0.1,1); %simulated RT
            
        end
        
        % CALCULATE THE JITTER FOR THE FIXATION
        % it gives at min 0.501 sec: can you hange that?
        timeCrossGrey = jitter(1) + (randi((jitter(2)*1000) - (jitter(1)*1000)))/1000;
        
        
        % Check for escape button to terminate trial eventually
        if CheckKeyPress(keyquit)
            aborted = true;
            break;
        end
        
        % ------------------------------------------------------------------------------------------------%
        %                                 LOAD IMAGES OF THE SCENE
        % ------------------------------------------------------------------------------------------------%
        
        % load neutral
        cond_img1 = neutral;
        cond_img2 = neutral;
        
        % Picture on the left
        img = double(imread(sprintf(stimulus(istim).file{1},cond_img1{1},cond_img1{2})))/255;
        img = img(:,:,1);
        
        % Picture on the right
        img2 = double(imread(sprintf(stimulus(istim).file{2},cond_img2{1},cond_img2{2})))/255;
        img2 = img2(:,:,1);
        
        % use the function to adjust lumi, contrast and cut the scene
        [img, img2] = treatScene(img, img2, mean_lumi,mean_contr,cut_img_x, video);
        
        % scramble images
        % actor left
        out_act1 = img(reshape(randperm(numel(img)), size(img/2)));
        % actor right
        out_act2 = img2(reshape(randperm(numel(img2)), size(img2/2)));
        
        % Create texture for neutral actors' and of scrumbled images
        patchtex_act1 = Screen('MakeTexture',video.h,img,[],[],1);
        patchtex_act2 = Screen('MakeTexture',video.h,img2,[],[],1);
        patchtex_scrumble_act1 = Screen('MakeTexture',video.h,out_act1,[],[],1);
        patchtex_scrumble_act2 = Screen('MakeTexture',video.h,out_act2,[],[],1);
        
        
        % ------------------------------------------------------------------------------------------------%
        %                                 LOAD AND FLIP GRAYSCREEN
        % ------------------------------------------------------------------------------------------------%
        
        % grey screen without cross first
        Screen('DrawTexture',video.h,patchtex_greyscreen,[],patchrct_greyscreen);
        
        tstart_greyscreen = Screen('Flip',video.h, [], [1]); % flip greyscreen
        
        if physio % if this a  session with physiological recording
            % send marker for start grey screen
            fprintf(s1,['mh',m_greyscreen]);
        end
        
        % ------------------------------------------------------------------------------------------------%
        %                                 LOAD GREY SCREEN + FIXATION
        % ------------------------------------------------------------------------------------------------%
        
        %grey screen
        Screen('DrawTexture',video.h,patchtex_greyscreen,[],patchrct_greyscreen);
        
        %cross
        Screen('DrawTexture',video.h,patchtex_cross,[],patchrct_cross);
        
        % ------------------------------------------------------------------------------------------------%
        %                                 FLIP GREY SCREEN + FIXATION
        % ------------------------------------------------------------------------------------------------%
        
        % calculate precise timing for grey screen
        tcheckGrey = GetSecs;
        while tcheckGrey - tstart_greyscreen < timeGrScreen-video.ifi
            tcheckGrey = GetSecs;
        end
        
        tstartCross = Screen('Flip',video.h, [], [1]); %affichage grey+cross
        tstimcheck(istim).greyscreen = tstartCross - tstart_greyscreen; % temps exact de l'affichage de la croix
        
        if physio % if this a  session with physiological recording
            % send marker for start fixation
            fprintf(s1,['mh',m_fixation]);
        end
        
        
        % ------------------------------------------------------------------------------------------------%
        %                         IMAGES IN THE BACKGROUND AND FLIP SCENE
        %                                   (during fixation jitter)
        % ------------------------------------------------------------------------------------------------%
        % keep in mind that this is only the 1st flip of the scene, which we need for precise time
        % info about the presence of the scene on the screen.
        
        
        %1st actor male
        Screen('DrawTexture',video.h,patchtex_act1,[],patchrct_act1);
        
        %2nd actor male
        Screen('DrawTexture',video.h,patchtex_act2,[],patchrct_act2);
        
        %cross
        Screen('DrawTexture',video.h,patchtex_cross,[],patchrct_cross);
        
        % calculate precise timing for fixation
        tcheckFix = GetSecs;
        while tcheckFix - tstartCross < timeCrossGrey - video.ifi
            tcheckFix = GetSecs;
        end
        
        % flip the neutral images
        tstartScene = Screen('Flip',video.h, [], 1);
        
        if physio % if this a  session with physiological recording
            % send marker for start scene
            fprintf(s1,['mh',m_scene]);
        end
        
        isPressed =0; % enregistrement des touches
        response(istim).iscor = 0;
        
        tstim = GetSecs;
        
        while tstim - tstartScene < timeStim && ~isPressed % tant que Tmax n'est pas atteind et que rien nest presse
            
            % buttonPressed : 1 = lKeyhand ; 2 = rKeyhand
            [buttonPressed, timeResp] = CheckKeyPress([lKeyhand,rKeyhand]);
            
            %update time calculation
            tstim = GetSecs;
            
            
            if isRobot
                
                % simulate participant response (1st click around 0.5 and
                % 2nd around 1s)
                if round(tstim - tstartScene, 1)  == simRT
                    if robotResp == 1
                        rob.keyPress(KeyEvent.VK_S)
                    elseif robotResp == 2
                        rob.keyPress(KeyEvent.VK_L)
                    end
                    response(istim).simulRT = GetSecs - tstartScene;
                    response(istim).simulbutton = robotResp;
                    response(istim).programmedRT = simRT;
                end
            end
            
            
            if buttonPressed > 0 % if one of the two button is pressed
                response(istim).iscor = 1;
                response(istim).timeResponse = timeResp - tstartScene;
                response(istim).resp = buttonPressed;
                isPressed = 1;
                
                if physio % if this a  session with physiological recording
                    
                    if response(istim).resp == stimulus(istim).goodButton
                        
                        % send marker for correct response
                        fprintf(s1,['mh',m_respCorr]);
                        
                    else
                        % send marker for correct response
                        fprintf(s1,['mh',m_respUncorr]);
                    end
                end
                
                
                if response(istim).simulbutton == 1
                    rob.keyRelease(KeyEvent.VK_S)
                elseif response(istim).simulbutton == 2
                    rob.keyRelease(KeyEvent.VK_L)
                end
                
                % flip coin and determine a random nb between 0 and 1
                response(istim).coin = rand(1);
                
                % goodButton = 2 = right :
                % more chanches that anger is displayed on the left
                if stimulus(istim).goodButton == 2 && task
                    
                    % if coin < prob_reward : anger on the left = reward
                    if response(istim).coin < prob_reward
                        cond_img1 = anger;
                        response(istim).side_emo = 1;
                    else
                        % if coin > prob_reward : anger on the right = punishment
                        cond_img2 = anger;
                        response(istim).side_emo = 2;
                    end
                    
                    % goodButton = 1 = left :
                    % more chance that anger displayed on the right
                elseif stimulus(istim).goodButton == 1 && task
                    
                    % if coin < prob_reward : anger on the right = reward
                    if response(istim).coin < prob_reward
                        cond_img2 = anger;
                        response(istim).side_emo = 2;
                    else
                        % if coin > prob_reward : anger on the left = punishment
                        cond_img1 = anger;
                        response(istim).side_emo = 1;
                    end
                    
                end
                
                % process the new couple of images
                img = double(imread(sprintf(stimulus(istim).file{1},cond_img1{1},cond_img1{2})))/255;
                img = img(:,:,1);
                img2 = double(imread(sprintf(stimulus(istim).file{2},cond_img2{1},cond_img2{2})))/255;
                img2 = img2(:,:,1);
                
                % use the function to adjust lumi, contrast and cut the scene
                [img, img2] = treatScene(img, img2, mean_lumi,mean_contr,cut_img_x, video);
                
                
                % create patchtex actor on the left after clic
                patchtex_new_act1 = Screen('MakeTexture',video.h,img,[],[],1);
                
                % create patchtex of actor on the right after clic
                patchtex_new_act2 = Screen('MakeTexture',video.h,img2,[],[],1);
                
                % create patchtex of ID participant
                if response(istim).resp == 1
                    patchrct_ID = CenterRectOnPoint(Screen('Rect',patchtex_ID),target.left(1), video.y-target.left(2));
                else
                    patchrct_ID = CenterRectOnPoint(Screen('Rect',patchtex_ID),target.right(1), video.y-target.right(2));
                end
                
                
                %DRAW TEXTURES FOR MASKed scene
                % actor left
                Screen('DrawTexture',video.h,patchtex_new_act1,[],patchrct_act1);
                % actor right
                Screen('DrawTexture',video.h,patchtex_new_act2,[],patchrct_act2);
                
                %cross
                Screen('DrawTexture',video.h,patchtex_cross,[],patchrct_cross);
                
                % participant's ID
                %                     Screen('DrawTexture',video.h,patchtex_ID,[],patchrct_ID);
                
                % left scramble
                Screen('DrawTexture',video.h,patchtex_scrumble_act1,[],patchrct_act1); % patchrct_scrumble_act1
                %right scramble
                Screen('DrawTexture',video.h,patchtex_scrumble_act2,[],patchrct_act2); % patchrct_scrumble_act2
                
                % affichage scene with scrumble, new emotion and ID participant
                t_scrumble = Screen('Flip',video.h);
                if physio % if this a  session with physiological recording
                    % send marker for scrumble
                    fprintf(s1,['mh',m_scrumble]);
                end
            end
        end
        
        %% FEEDBACK
        
        if isPressed
            
            %DRAW TEXTURES FOR FEEDBACK
            % actor left
            Screen('DrawTexture',video.h,patchtex_new_act1,[],patchrct_act1);
            % actor right
            Screen('DrawTexture',video.h,patchtex_new_act2,[],patchrct_act2);
            
            %cross
            Screen('DrawTexture',video.h,patchtex_cross,[],patchrct_cross);
            
            % participant's ID
            Screen('DrawTexture',video.h,patchtex_ID,[],patchrct_ID);
            
            % affichage scene with only new emotion and ID participant
            t_feedback = Screen('Flip',video.h, t_scrumble + scrumble_time); %affichage scene with new emotion and ID participant
            
            if task
                response(istim).reward = response(istim).resp ~= response(istim).side_emo;
                response(istim).hits = response(istim).resp == stimulus(istim).goodButton;
                
                if physio % if this a  session with physiological recording
                    
                    if response(istim).reward
                        % send marker for avoidance (rewarded) response
                        fprintf(s1,['mh',m_avoidance]);
                    else
                        % send marker for m_approach (punished) response
                        fprintf(s1,['mh',m_approach]);
                    end
                end
                
            else
                response(istim).reward = 0;
                response(istim).hits   = 0;
            end
            
            t_endFeedack = WaitSecs(FB_time - (GetSecs- t_feedback));
            
        else
            
            if physio % if this a  session with physiological recording
                % send marker for missed response
                fprintf(s1,['mh',m_miss]);
            end
            
            response(istim).iscor = 0;
            response(istim).resp = 0;
            response(istim).timeResponse = 0;
            
            % si le participant a trop attendu flip negative feedback on a grey screen
            % print on screen a rectangle of the size of the screen ù
            % take this out
            Screen('FillRect',video.h,0);
            
            %grey screen
            Screen('DrawTexture',video.h,patchtex_greyscreen,[],patchrct_greyscreen);
            % negative FB
            Screen('TextSize',video.h,30);
            Screen('DrawText',video.h,negfb,label_feedback(1),label_feedback(2),0);
            
            Screen('Flip', video.h);
            WaitSecs(0.2);
        end
        
        
        % display response on screen
        fprintf('Good button = %d ; Subject response = %d ; consequence (1 = REWARD (away)) = %d ; RT = %3d \n' , ...
            stimulus(istim).goodButton, response(istim).resp, response(istim).reward , round(response(istim).timeResponse,3)*1000)
        
        
        % save programmed and real fixation duration
        tstimcheck(istim).progrJitter = timeCrossGrey;
        tstimcheck(istim).realJitter = tstartScene - tstartCross;
        
        %calcul scene
        
        tstimcheck(istim).scene = tstim - tstartScene;
        
        if buttonPressed
            tstimcheck(istim).t_scrumble = t_feedback - t_scrumble;
            tstimcheck(istim).feedback = t_endFeedack - t_feedback;
            
            tstimcheck(istim).tot = ...
                tstimcheck(istim).greyscreen + ...
                tstimcheck(istim).realJitter + ...
                tstimcheck(istim).scene + ...
                tstimcheck(istim).t_scrumble + ...
                tstimcheck(istim).feedback;
        end
        
        if CheckKeyPress(keyquit)
            aborted = true;
            break;
        end
        
        tstimcheck(istim).totReal = GetSecs - t_initNewTrial;
        
        %% Pause when they are at 1/4, 2/4 and 3/4 of the task more or less, in correspondance with the last trial before the reversal
        if task
            if istim  ==  cumsumReversals(round(nReversals/4)) || istim  ==  cumsumReversals(round(nReversals/4)*2) || istim  ==  cumsumReversals(round(nReversals/4)*3)
                response(istim).pause = 1;
                Screen('DrawText',video.h,pause_msg,label_pause_msg(1),label_pause_msg(2),1);
                Screen('Flip', video.h);
                
                if physio % if this a  session with physiological recording
                    % send marker for pause
                    fprintf(s1,['mh',m_pause]);
                end
                
                if ~isRobot
                    WaitKeyPress(keywait);
                end
            else
                response(istim).pause = 0;
            end
        end
        
        
        if aborted
            if physio % if this a  session with physiological recording
                % send marker for end Experiment
                fprintf(s1,['mh',m_endExperiment]);
                
                %close the parallel port
                fclose(s1);
            end
            
            Priority(0);
            Screen('CloseAll');
            FlushEvents;
            ListenChar(0);
            ShowCursor;
            break
        end
        
    end
    
    if physio % if this a  session with physiological recording
        % send marker for end Experiment
        fprintf(s1,['mh',m_endExperiment]);
        
        %close the parallel port
        fclose(s1);
    end
    
    Priority(0);
    Screen('CloseAll');
    FlushEvents;
    ListenChar(0);
    ShowCursor;
    
catch
    
    if physio % if this a  session with physiological recording
        % send marker for end Experiment
        fprintf(s1,['mh',m_endExperiment]);
        
        %close the parallel port
        fclose(s1);
    end
    
    Priority(0);
    Screen('CloseAll');
    FlushEvents;
    ListenChar(0);
    ShowCursor;
    rethrow(lasterror);
    
end
end

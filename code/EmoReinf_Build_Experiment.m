function [stimulus_rand] = EmoReinf_Build_Experiment(nst)
% Fonction servant à randomiser les stimuli utilisés pour l'experience
% Argument d'entrée :
% nst = total number of stimuli (doit être un multiple de 20, minimum N of trials
% to have the whole representation of factors' levels)

addpath('./Toolbox/Rand');
stimulus_rand.stimulus = [];

sOrient = {'L_cent','R_cent'}; % pour acteurs présentés au centre
folder = 'center';

if ~exist(strcat('../stim_',folder),'dir')
    error('stim folder not found!');
end

% DEFINE YOUR PARAMETERS
sEmot = {'N'};           %emotion letter : N => Neutral
snbActor = 2;            %number of actors by pair


% list of factors

nbPair = 5;             %number of pairs by gender
nbGender = 2;           %number of gender
nbOrientation = 2;      %number of organisation possible for actors

mult_fact = nbPair*nbGender*nbOrientation;

isaninteger = @(x)isfinite(x) & x==floor(x);

if ~isaninteger(nst /mult_fact) % verifie la condition nombre de stim doit etre divisible par 20
    error(['nst should be divisible by ' num2str(mult_fact)])
end

stimulus = struct; %matrix to fill with a random order of the stims
%alternance = nan(nbBlocs,nbStims,[]); %matrix to fill with a random order of the stims


%to find easier actors, creation of a matrix with all combinaisons possible
%men actors
mactone = {'M02' 'M03' 'M04' 'M06' 'M14'};
macttwo = {'M16' 'M10' 'M15' 'M11' 'M18'};

%women actors
factone = {'F01' 'F04' 'F06' 'F10' 'F14'};
facttwo = {'F02' 'F12' 'F09' 'F13' 'F15'};

%creation of the index of each pair in the L-R and R-L order
actors = cell(snbActor,nbPair,nbGender,nbOrientation); %actors(nbactor, pair, gender, orientation)

actors(1,:,1,1) = mactone;
actors(2,:,1,1) = macttwo;
actors(1,:,2,1) = factone;
actors(2,:,2,1) = facttwo;
actors(1,:,1,2) = macttwo;
actors(2,:,1,2) = mactone;
actors(1,:,2,2) = facttwo;
actors(2,:,2,2) = factone;

% create the based structure (all possibilities)
AllNeutral_stimulus      = zeros(3,nst);
AllNeutral_stimulus(1,:) = repmat([zeros(1,nst/nbGender) ones(1,nst/nbGender)] + 1, 1);   %gender (1:Male 2:Female)
AllNeutral_stimulus(2,:) = repmat([zeros(1,nst/nbGender/nbOrientation) ones(1,nst/nbGender/nbOrientation)] + 1, 1,nbOrientation);   %orientation (1: actor1-actor2 2:actor2-actor1)
AllNeutral_stimulus(3,:) = repmat(1:nbPair, 1, nst/nbPair);   %pair (1 to 5)
%AllNeutral_stimulus(4,:) = nan(nbBlocs,nbStims);


% shuffle pairs WITHIN BLOCK
% we don't want to show the same couple of actors more than twice
% consecutevely

fprintf('Running randomisation ...\n');
moreThan2repetitions = 1; % controle que jamais un couple soit presente plus de deux fois consecutives
tic
while moreThan2repetitions
    AllNeutral_stimulus = randpermcol(AllNeutral_stimulus);
    moreThan2repetitions = HasMoreThan2Repetitions(AllNeutral_stimulus, 3);
end
toc

%% create stims

reversalare = repmat([20 24 26 30],1,4);
consecutiveValues = 1; % controle que jamais un couple soit presente plus de deux fois consecutives
while consecutiveValues > 0
    reversalorders = randperm(length(reversalare));
    consecutiveValues = HasConsecutiveValues(reversalare(reversalorders));
end
stimulus_rand.reversals = reversalare(reversalorders);

if ~sum(stimulus_rand.reversals)==400
   error('something wrong with the reversals!') 
end

% determine the good button for each trial
goodButton = [];
% choose at random the starting button for each subject
if round(rand) == 1
    startButton = 1;
else
    startButton = 2;
end

temp_button = startButton;
    
for rr = 1:length(stimulus_rand.reversals)
goodButton = [goodButton;repmat(temp_button,stimulus_rand.reversals(rr),1)];
temp_button = 2-temp_button+1;
end



for istim = 1:size(AllNeutral_stimulus,2)
    
    % create stimulus structure
    stimulus(istim).emotion = sEmot{1};
    stimulus(istim).gender  = AllNeutral_stimulus(1, istim);
    stimulus(istim).orient  = AllNeutral_stimulus(2, istim);
    stimulus(istim).pair    = AllNeutral_stimulus(3, istim);
    stimulus(istim).actor1  = actors{1,stimulus(istim).pair,stimulus(istim).gender,stimulus(istim).orient};
    stimulus(istim).actor2  = actors{2,stimulus(istim).pair,stimulus(istim).gender,stimulus(istim).orient};
    
    % acteur 1
    stimulus(istim).file{1} = sprintf(strcat('../stim_',folder,'/%s_D_%s_%s_',sOrient{1},'.jpg'), ... %formate les noms de fichiers
        stimulus(istim).actor1, '%c', '%d');
    % acteur 2
    stimulus(istim).file{2} = sprintf(strcat('../stim_',folder,'/%s_D_%s_%s_',sOrient{2},'.jpg'), ... %formate les noms de fichiers
        stimulus(istim).actor2, '%c', '%d');
    
    stimulus(istim).goodButton = goodButton(istim);
    if istim >1
        if stimulus(istim).goodButton == stimulus(istim-1).goodButton
            stimulus(istim).reversal = 0;
        else
            stimulus(istim).reversal = 1;
        end
    end
    
end
stimulus(1).reversal = 0;
stimulus_rand.stimulus = stimulus;

fprintf('done!\n');

% check if you are coding well the reversal in stimulus.reversal
if ~isequal(find([stimulus.reversal]),cumsum(stimulus_rand.reversals(1:end-1))+1)
    error('problem in saving the reversals in each trial, check your code!')
end


end

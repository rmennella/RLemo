clear all;
close all;
clc
folder = 'C:\Users\Social 4\Desktop\Manip_M1\Marine_Emoreinf\data\';

sublist = {'16' '17' '18' '19' '20' '21' '22' '23' };

j=1;
nsub = length(sublist);

for isub = 1:nsub
    
    fprintf('\nsubject %s... ',sublist{isub});
    name_file = dir([folder 'EmoReinf_S' sublist{isub} '_*.mat']);
    
    load([folder name_file.name]);
    
    nstims = size(response,2);
    
    xlswrite('Data_EmoReinf', {'subject', 'pause', 'trial', 'gender', 'pair',  'orient', 'act1', 'act2', 'probability', ...
        'goodButton', 'response','RT', 'iscor', 'hits', 'reversal', 'reward'},'Feuil1');
    xlswrite('Data_EmoReinf', ones(nstims,1)*(str2double(sublist{isub})),  'Feuil1', strcat('A',num2str(j+1)));
    xlswrite('Data_EmoReinf', [response.pause]', 'Feuil1' , strcat('B',num2str(j+1)));
    xlswrite('Data_EmoReinf', (1:nstims)', 'Feuil1' , strcat('C',num2str(j+1)));
    xlswrite('Data_EmoReinf', [stimulus.stimulus.gender]','Feuil1' , strcat('D',num2str(j+1)));
    xlswrite('Data_EmoReinf', [stimulus.stimulus.pair]','Feuil1' , strcat('E',num2str(j+1)));
    xlswrite('Data_EmoReinf', [stimulus.stimulus.orient]', 'Feuil1' , strcat('F',num2str(j+1)));
    xlswrite('Data_EmoReinf', {stimulus.stimulus.actor1}', 'Feuil1' , strcat('G',num2str(j+1)));
    xlswrite('Data_EmoReinf', {stimulus.stimulus.actor2}', 'Feuil1' , strcat('H',num2str(j+1)));
    
    xlswrite('Data_EmoReinf', [response.probability]', 'Feuil1' , strcat('I',num2str(j+1)));
    xlswrite('Data_EmoReinf', [response.goodButton]', 'Feuil1' , strcat('J',num2str(j+1)));
    xlswrite('Data_EmoReinf', [response.resp]', 'Feuil1' , strcat('K',num2str(j+1)));
    xlswrite('Data_EmoReinf', [response.timeResponse]', 'Feuil1' , strcat('L',num2str(j+1)));
    xlswrite('Data_EmoReinf', [response.iscor]', 'Feuil1' , strcat('M',num2str(j+1)));
    xlswrite('Data_EmoReinf', double([response.hits])', 'Feuil1' , strcat('N',num2str(j+1)));
    xlswrite('Data_EmoReinf', [response.reversal]', 'Feuil1' , strcat('O',num2str(j+1)));
    xlswrite('Data_EmoReinf', double([response.reward])', 'Feuil1' , strcat('P',num2str(j+1)));
    j= j+size(response,2);
    fprintf('done! ');
    
    fprintf('\n');
    
end

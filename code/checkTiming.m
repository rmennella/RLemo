close all
% Grey screen
subplot(7,1,1)
plot([tstimcheck.greyscreen])
title('Grey screen (0.5s)') 


% Jitter
subplot(7,1,2)
plot([tstimcheck.progrJitter], 'b')
hold on
plot([tstimcheck.realJitter], 'r')
hold off
title('Jitter Fixation') 


% scene + RT
subplot(7,1,3)
plot([tstimcheck.scene])
hold on
plot([response.simulRT], 'b')
plot([response.timeResponse], 'r')
hold off
legend({'scene', 'simulRT', 'RT'})

% RT differences
subplot(7,1,4)
plot(abs([response.simulRT] - [response.timeResponse]), 'b')
title('Difference in Response Time (VRAI - CODED)')

% scrumble (200ms)
subplot(7,1,5)
plot([tstimcheck.t_scrumble], 'b')
title('Scrumble')

% feedback (500ms)
subplot(7,1,6)
plot([tstimcheck.feedback], 'b')
title('Feedack')

% total time (real)
subplot(7,1,7)
plot([tstimcheck.totReal], 'b')
title('tot Time')
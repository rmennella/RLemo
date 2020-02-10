function dot = nextpoint(point, target, nextx)
% find the next point to draw with an y=ax+b function from 'point' to
% 'target'
%   Detailed explanation goes here
[a, b] = y_egal_ax_plus_b (point, target);
dot = [nextx a*nextx+b];

return


function [a, b] = y_egal_ax_plus_b(pointA, pointB)

a = (pointB(2)-pointA(2))/(pointB(1)-pointA(1));
b = pointA(2) - a*pointA(1);
return


function [X Y] = fun_circle(center,radius,n)
%code from http://www.mathworks.com/matlabcentral/answers/24614-cricle-packed-with-circles
THETA = linspace(0, 2 * pi, n);
RHO = ones(1, n) * radius;
[X Y] = pol2cart(THETA, RHO);
X = X + center(1);
Y = Y + center(2);
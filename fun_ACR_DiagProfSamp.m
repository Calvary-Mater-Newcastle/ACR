function [ln_vec]=fun_ACR_DiagProfSamp(FOV_x,FOV_y,pt,k)
% This function finds the x&y coord on the image for a straight line with a
% known gradient, k. Because the image coord origin locates at the top left
% corner of the image, the line equation is still y=kx+b, but need to
% convert y to -y at the end. This function uses the known point which the 
% line goes through to calc the y-intercept, b. It then calc the y-val for 
% all x-val starting from x=1. It only exports the points whose x&y are 
% both positive, because no negtive point is shown on image.
%
% Input:
%   FOV_x: image x-direction range
%   FOV_y: image y-direction range
%   pt: the point the line goes through (2-by-1 vec [x;y])
%   k: line gradient
% Output:
%   ln_vec: line vector with only positive value (2-by-n vec [X;Y])
% Usage: 
%   
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (14/07/15)
%          v.2 ()(search for v2)
% History: v.1
%          v.2 
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.calc y-intercept
b=pt(2)-k*pt(1);
%2.sample line starting from x=1
x=1:FOV_x;
f=fittype('poly1');%linear line
c=cfit(f,k,-b);
y=feval(c,x);
if k>0
    y=abs(FOV_y+y);
elseif k<0
    %do nothing
end
%3.combine x&y
dummy=cat(1,x,y');
%4.record only positive values
cnt=1;
for j=1:size(dummy,2)
    if dummy(1,j)>0 && dummy(2,j)>0
        ln_vec(:,cnt)=dummy(:,j);
        cnt=cnt+1;
    end
end
end
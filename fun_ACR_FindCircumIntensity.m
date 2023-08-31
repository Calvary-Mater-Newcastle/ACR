function [Int_circum]=fun_ACR_FindCircumIntensity...
    (I_masked,r_pxl,ind_centre_d,rad_interval)
% This function finds the intensity profile along the circumference of a
% circle with know radius. It is used in fun_ACR_7_S8S9S10S11.m.
%
% Input:
%   I_masked: masked image with low contrast disk only
%   r_pxl: radius of circle in pixel
%   ind_centre_d: 1-by-2 vector of the centre of disk obtained from imtool
%   rad_interval: 0.1 for 2 larger radius, 0.16 for smallest radius
%
% Output:
%   Int_circum: intensity profile along circumference
%
% HW: (search for HW)
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (06/06/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.define the centre of circle & angle interval
x0=ind_centre_d(1,2);
y0=ind_centre_d(1,1);
theta=0:rad_interval:2*pi;%change interval to get desired sampling interval
%2.find intensity along circumference
Int_circum=zeros(1,1);
cnt=1;
for i=1:size(theta,2)
    xi=r_pxl*cos(3*pi/2+theta(1,i))+x0;
    yi=r_pxl*sin(3*pi/2+theta(1,i))+y0;
    Int_circum(1,cnt)=I_masked(round(yi),round(xi));
    cnt=cnt+1;
end
end
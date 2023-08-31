function [Intensity_line]=fun_ACR_FindIntensityonRadius...
    (I_masked,radius,ind_centre_d,theta,bndry,visual)
% This function finds all the intensity value along a radius of circle at
% any given angle. It is used in ACR low contrast object detectability.
%
% Input:
%   I_masked: applied disk mask to the original image
%   radius: disk radius
%   ind_centre_d: centre of disk
%   theta: current radius angle
%   bndry: excluded outer disk region (in pixel)
%   visual: if display image and plot for visualisation purpose (1 or 0)
%
% Output:
%   Intensity_line: 1-by-n vector includes intensity values along radius
%
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (30/04/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

if ~exist('visual','var')||isempty(visual)
    visual=0;
end
if visual==1
    figure;
    imshow(I_masked,[]);%for visualisation purpose only
else
    disp(['You have turned off graph visualisation '...
        'in fun_ACR_FindIntensityonRadius.']);
end
x0=ind_centre_d(1,2);
y0=ind_centre_d(1,1);
Intensity_line=zeros(1,radius-bndry);
cnt=1;
for i=1:radius-bndry
    xi=(radius-radius+i)*cos(theta)+x0;
    yi=(radius-radius+i)*sin(theta)+y0;
    if visual==1
        impoint(gca,xi,yi);%for visualisation purpose only
    end
    Intensity_line(1,cnt)=I_masked(round(yi),round(xi));%y=row,x=col
    cnt=cnt+1;
end
if visual==1
    figure;plot(Intensity_line);
end
end
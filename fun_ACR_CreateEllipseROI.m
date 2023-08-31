function [centre_coord,contour_xy,I_bin]=fun_ACR_CreateEllipseROI...
    (I,phan_centre,phan_bndry,FOV_bndry,wl_pxl,pxl_sz,choice)
% This function creates an ellipse ROI between the edge of phantom and FOV
% in one of four locations specified by ACR doc. It reads the distance
% between edge and FOV and based on the distance, creates an ellipse ROI
% with length to width ratio = 4:1, area of ROI is ~10 cm2 and the centre 
% of ROI is always along with phantom centre.
%
% Input:
%   I: original image
%   phan_centre: 1-by-2 vector of the phantom centre
%   phan_bndry: phantom boundary value closest to the ROI (e.g. for top ROI
%               phan_bndry=row number of top phantom, for bottom ROI
%               phan_bndry=row number of bottom phantom)
%   FOV_bndry: size of image FOV (e.g. for top ROI FOV_bndry=0, for bottom
%              ROI FOV_bndry=size of image)
%   wl_pxl: normal ellipse ROI size parameters [width,length]
%   pxl_sz: image pixel size 2-by-1 vector
%   choice: which ROI to create. 2=top ROI, 3=bottom ROI, 4=left ROI,
%           5=right ROI
%
% Output:
%   centre_coord: 1-by-2 vector of the ROI centre coordinate
%   contour_xy: 2-by-n vector [x;y] for plotting contour purpose
%   I_bin: mask image of ellipse ROI
%   
% HW: (search for HW)
%   initial setup of ROI to phantom distance is 5 pixels
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (24/04/13)
%          v.2 (17/11/13)(search for v2)
% History: v.1
%          v.2: solved ROI generation bug, now always create 10cm2 ROI
%               now the ROI is 1 pxl away frmo FOV edge
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if there is enough space to create ROI between phantom and FOV
empty_space=abs(phan_bndry-double(FOV_bndry));
ROI_phan_distance=5;%HW:default ROI to phantom distance
if empty_space>wl_pxl(1,1)+ROI_phan_distance+1%v2
    disp('You have enough space to create ROI.');
    w_pxl=wl_pxl(1,1);
    l_pxl=wl_pxl(1,2);
else
    disp('Not enough empty space, re-calculate ROI width to fit in.');
    w_pxl=(empty_space-ROI_phan_distance-1);%1 pxl away from FOV edge%v2
    l_pxl=4*1000/(pi*w_pxl)/pxl_sz(2,1);%make sure 10cm2 area%v2
%     w_pxl=(empty_space-ROI_phan_distance)/2;
%     l_pxl=(wl_pxl(1,1)*wl_pxl(1,2))/w_pxl;
    fprintf('New ROI width is %2d and ROI length is %2d\n',w_pxl,l_pxl);
end
%2.define ellipse ROI centre coord
switch choice
    case 2
        x_c=phan_centre(1,2);
        y_c=phan_bndry-ROI_phan_distance-w_pxl/2+1;%1 pxl away from FOV edge
    case 3
        x_c=phan_centre(1,2);
        y_c=phan_bndry+ROI_phan_distance+w_pxl/2+1;%1 pxl away from FOV edge
    case 4
        x_c=phan_bndry-ROI_phan_distance-w_pxl/2+1;%1 pxl away from FOV edge
        y_c=phan_centre(1,1);
    case 5
        x_c=phan_bndry+ROI_phan_distance+w_pxl/2+1;%1 pxl away from FOV edge
        y_c=phan_centre(1,1);
end
centre_coord=[x_c,y_c];
%3.create mask image
theta=0:0.01:2*pi;
if choice==2 || choice==3
    x=l_pxl/2*cos(theta)+x_c;%v2
    y=w_pxl/2*sin(theta)+y_c;%v2
elseif choice==4 || choice==5
    x=w_pxl/2*cos(theta)+x_c;%v2
    y=l_pxl/2*sin(theta)+y_c;%v2
end
I_bin=roipoly(I,x,y);
% imtool(I_bin,[]);%for test visualisation only
%4.output x&y contour
contour_xy=[x;y];
end
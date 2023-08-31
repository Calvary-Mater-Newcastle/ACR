function [cen]=fun_FindPillCen(I,I_bin,pxl_sz)
% This function identifies the centroid of the pill that attached to the
% phantom anterior surface. The purpose of the pill is to solve the losing
% liquid problem. The missing liquid prevents accurately measuring phantom
% AP direction diameter.
% This function first threshold image into a binary image and then
% identifies the anterior/posterior edge of the pill based on the vert sum
% of the image. It then identifies the lateral edge based on the hori sum,
% with the assumption of there is nothing outside phantom on the binary
% image except pill. It creates a ROI with 5mm expansion around pill (4mm
% expansion in posterior direction to avoid having water in ROI). Then it
% creates a mask around pill and sums hori/vert directions and then use
% interpolation to identifies the pill centroid with 4 dp precesion. If a
% binary image is provided, that means a thresholded image already exists
% and no thresholding is required.
%
% Input:
%   I: orig 2D image
%   I_bin: thresholded img
%   pxl_sz: image pixel size (2-by-1 vec)
% Output:
%   cen: pill centroid (2-by-1 vec)[x;y]
% Usage: 
%   
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1
%          v.2 (search for v2)
% History: v.1 (12/07/15)
%          v.2 
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.threshold image if no binary image input
if ~exist('I_bin','var')
    level=graythresh(I);
    BW=im2bw(I,level);
else
    BW=I_bin;
    disp('Binary image input exists, no thresholding required.');
end
%2.ID pill anterior/posterior y coord
dummy1=sum(BW,2);
search_rng=round(10/pxl_sz(1,1));%assume pill diameter<=10mm
row=find(dummy1>0,search_rng,'first');
dummy2=diff(row);
pill_a_y=row(1);%1st one is pill anterior
pill_p_y=row(find(dummy2>1));%1st one>1 is the pill posterior
%3.ID pill lateral x coord
dummy=sum(BW(pill_a_y:pill_p_y,:),1);
pill_l_x=find(dummy>0,1,'first');%assume nothing at the same level as pill
pill_r_x=find(dummy>0,1,'last');%assume nothing at the same level as pill
%4.extend bndry by 5mm (wall thickness is 8mm) to make ROI around pill
pill_ROI_a_y=pill_a_y-round(5/pxl_sz(1,1));
pill_ROI_p_y=pill_p_y+round(4/pxl_sz(1,1));%posterior expand 4mm in order to avoid water signal
pill_ROI_l_x=pill_l_x-round(5/pxl_sz(1,1));
pill_ROI_r_x=pill_r_x+round(5/pxl_sz(1,1));
%5.masked out everything except pill
dummy_mask=zeros(size(I,1),size(I,2));
dummy_mask(pill_ROI_a_y:pill_ROI_p_y,pill_ROI_l_x:pill_ROI_r_x)=1;
dummy=fun_apply_mask(I,dummy_mask);
%6.sum hori/vert directions
dummy_hori=sum(dummy,1);
dummy_vert=sum(dummy,2);
x=1:length(dummy_hori);
dummy_hori_ft=fit(x',dummy_hori','gauss1');%fit Gaussian
dummy_hori_fit=feval(dummy_hori_ft,x);
dummy_vert_ft=fit(x',dummy_vert,'gauss1');%fit Gaussian
dummy_vert_fit=feval(dummy_vert_ft,x);
%7.interpolate data
% x=1:length(dummy_hori);
xx=1:1e-3:length(dummy_hori);
% dummy_hori_interp=interp1(x,dummy_hori,xx,'spline');
% dummy_vert_interp=interp1(x,dummy_vert,xx,'spline');
dummy_hori_interp=interp1(x,dummy_hori_fit,xx,'spline');
dummy_vert_interp=interp1(x,dummy_vert_fit,xx,'spline');
%8.ID pk coord
pill_cen_x=peakfinder(dummy_hori_interp)*1e-3+1;%+1 to start from 0. Otherwise the measurement is 1 pxl longer
pill_cen_y=peakfinder(dummy_vert_interp)*1e-3+1;%+1 to start from 0
cen=[pill_cen_x;pill_cen_y];
end
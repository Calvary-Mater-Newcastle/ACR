function [cen_pxl,phant_a_y,phant_p_y,phant_l_x,phant_r_x,pill_cen]=...
    fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice,pill_r,wall_thk)
% This function finds the phantom centre and also the boundary of phantom. 
% It has two choices, with & without pill. A pill can be attached to the 
% phantom anterior region in order to solve the missing liquid problem. If 
% no pill is attached, then the 1st signal along vertical direction is 
% considered as the phantom anterior starting point.
%
% Input:
%   I: orig 2D image
%   I_bin: thresholded img
%   pxl_sz: image pixel size (2-by-1 vec)
%   pill_choice: with.without pill attached (1=with, 0=without)
%   pill_r: pill max radius in mm
%   wall_thk: phantom wall thickness in mm
% Output:
%   cen_pxl: phantom centroid coord in pxl (2-by-1 vec)[x;y]
%   phant_a_y: phantom anterior boundary pxl y-coord
%   phant_p_y: phantom posterior boundary pxl y-coord
%   phant_l_x: phantom left boundary pxl x-coord
%   phant_r_x: phantom right boundary pxl x-coord
%   pill_cen: pill centre in pxl (2-by-1 vec)[x;y]
% Usage: 
%   
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (14/07/15)
%          v.2 (search for v2)(31/07/15)
% History: v.1 
%          v.2 Set image edge to be zero if the pxl larger than 0. This
%              edge thickness is 5 pxl. This aims to solve the ghost signls
%              sometime appear at the image edge, it affects the phantom
%              centre ID accuracy.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%======================v2 start======================
for i=1:5%top 5 rows
    for j=1:size(I_bin,2)
        if I_bin(i,j)>=0
            I_bin(i,j)=0;
        end
    end
end
for i=size(I_bin,1)-4:size(I_bin,1)%bottom 5 rows
    for j=1:size(I_bin,2)
        if I_bin(i,j)>=0
            I_bin(i,j)=0;
        end
    end
end
for i=1:size(I_bin,1)%left 5 cols
    for j=1:5
        if I_bin(i,j)>=0
            I_bin(i,j)=0;
        end
    end
end
for i=1:size(I_bin,1)%right 5 cols
    for j=size(I_bin,2)-4:size(I_bin,2)
        if I_bin(i,j)>=0
            I_bin(i,j)=0;
        end
    end
end
%======================v2 end======================
%1.ID phantom posterior edge
dummy=sum(I_bin,2);
phant_p_y=find(dummy>0,1,'last');
%2.ID phantom anterior edge
if pill_choice==1
    disp('You have attached a pill to phantom anterior.');
    pill_cen=fun_FindPillCen(I,I_bin,pxl_sz);
    phant_a_y=pill_cen(2,1)+...
        pill_r/pxl_sz(1)+...
        wall_thk/pxl_sz(1);%take away pill radius and wall thickness
elseif pill_choice==0
    disp('You didn''t attached a pill to phantom anterior.');
    phant_a_y=find(dummy>0,1,'first');
    pill_cen=[0;0];%if no pill output=0
end
%3.ID phantom lateral edge
dummy=sum(I_bin,1);
phant_l_x=find(dummy>0,1,'first');
phant_r_x=find(dummy>0,1,'last');
%4.cal phantom centre
cen_pxl(1,1)=(phant_r_x-phant_l_x)/2+phant_l_x;%x coord
cen_pxl(2,1)=(phant_p_y-phant_a_y)/2+phant_a_y;%y coord
end
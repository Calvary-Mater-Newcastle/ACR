function [bndry_top,bndry_bottom]=fun_ACR_FindWaterBndryBinaryCol...
    (I_bin,col_ind)
% This function is used to find the boundary location of water phantom
% along a column vector on a binary image, which has water=1 and else=0.
%
% Input:I_bin,col_ind
% Output:bndry_top,bndry_bottom
%
% HW: (search for HW)
%    
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (26/03/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.define row vector on binary image
col_dummy=I_bin(:,col_ind);
col_dummy=col_dummy';
%2.define 2 empty row with 1 element shorter
diff_d_col_dummy=zeros(1,size(col_dummy,2)-1);%down direction (on image)
diff_u_col_dummy=zeros(1,size(col_dummy,2)-1);%up direction
%3.take difference between element and the next element
for i=1:size(col_dummy,2)-1%for down direction
    diff_d_col_dummy(1,i)=col_dummy(1,i)-col_dummy(1,i+1);
end
for i=1:size(col_dummy,2)-1%for up direction
    diff_u_col_dummy(1,i)=col_dummy(1,i+1)-col_dummy(1,i);
end
%4.find boundary of non-water material
ind_b=find(diff_d_col_dummy,1);       %BE CAREFUL:
ind_t=find(diff_u_col_dummy,1,'last');%NEED TO +1 TO ind_t (see next line)
%5.find boundaries
bndry_top=ind_t+1;
bndry_bottom=ind_b;
end
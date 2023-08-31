function [bndry_low,bndry_high]=fun_ACR_FindBndryBinaryRow(I_bin,row_ind)
% This function is used to find the boundary location of a non-water
% material inside water phantom along a row vector on a binary image, which
% has water=1 and else=0.
%
% Input:I_bin,row_ind
% Output:bndry_low,bndry_high
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
row_dummy=I_bin(row_ind,:);
%2.define 2 empty row with 1 element shorter
diff_p_row_dummy=zeros(1,size(row_dummy,2)-1);
diff_n_row_dummy=zeros(1,size(row_dummy,2)-1);
%3.take difference between element and the next element
for i=1:size(row_dummy,2)-1%for positive direction
    diff_p_row_dummy(1,i)=row_dummy(1,i)-row_dummy(1,i+1);
end
for i=1:size(row_dummy,2)-1%for negative direction
    diff_n_row_dummy(1,i)=row_dummy(1,i+1)-row_dummy(1,i);
end
%4.find boundary of non-water material
ind_p=find(diff_p_row_dummy,1);       %BE CAREFUL:
ind_n=find(diff_n_row_dummy,1,'last');%NEED TO +1 TO ind_n (see next line)
%5.find boundaries
bndry_low=ind_p;
bndry_high=ind_n+1;
end
function [mu]=fun_ACR_FindAveRectROI(I,bndry_row,bndry_col)
% This function finds the average value of a rectangular ROI, that is
% specified by the input boundary. It is used in slice thickness accuracy
% test.
%
% Input:
%   I: phantom image
%   bndry_row: vert bndry of ROI (1-by-2 vector)
%   bndry_col: hori bndry of ROI (1-by-2 vector)
%
% Output:
%   mu: average intensity value of ROI
%
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (02/04/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.take sum by rows
sum_row=sum(I(bndry_row(1,1):bndry_row(1,2),...
    bndry_col(1,1):bndry_col(1,2)),1);
%2.take sum by col to find total summation
sum_total=sum(sum_row,2);
%3.find mean
mu=sum_total/((bndry_row(1,2)-bndry_row(1,1)+1)*...
    (bndry_col(1,2)-bndry_col(1,1)+1));
end
%this function can be simplified by mean(mean(I())).
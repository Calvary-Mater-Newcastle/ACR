function [pks]=fun_ACR_FindPeaksBinary(row_ROI)
% This function is created to replace the FINDPEAKS function in 
% FUN_ACR_3_S1.m, because the Matlab in MP's laptop does not has the access
% to the signal processing toolbox. Original FINDPEAKS function considers 
% the left most 1 as the peak on a binary image. This function aims to do a
% similar job
%
% Input:
%   row_ROI: a row vector from the binary image used to find slice
%            thickness
%   
% Output:
%   pks: a row vector contains all the left most 1 as peak
%
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1(27/08/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.define peaks vector and cnt
pks=0;
cnt_pks=1;
%2.search 1 within row vector
for i=2:size(row_ROI,2)
    if row_ROI(1,i-1)==0 && row_ROI(1,i)==1
        pks(1,cnt_pks)=i;
        cnt_pks=cnt_pks+1;
    end
end
end
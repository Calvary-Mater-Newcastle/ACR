function [l]=fun_ACR_FindLorRLength_2(I_bin,centre_hori,ind_row_ROI)
% This function is used to find the pixel length of ramp on the binary
% image when doing slice thickness accuracy test. 
%
% Input:
%   I_bin: binary image after masking
%   centre_hori: the horizontal coord of ramp centre
%   ind_row_ROI: row index of top/bottom ROI
%   
% Output:
%   l: pixel length of ramp
%
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1(04/04/13)
% History: v.1(27/08/13)
%          v.2: replace findpeaks with fun_ACR_FindPeaksBinary, because
%               Matlab in MP's laptop does not have signal processing
%               toolbox
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.find peaks of row intensity vector, result is left side of peak
row_ROI=I_bin(ind_row_ROI,:);
% [~,pks]=findpeaks(double(row_ROI));%double is required
pks=fun_ACR_FindPeaksBinary(row_ROI);%v2
%2.find the peak closest to ramp centre, this is one isde of length
distance=abs(pks-centre_hori);
[~,min_distance_ind]=min(distance);
l_a=pks(min_distance_ind);
%3.find the other side of length based on the choice
for i=l_a:size(row_ROI,2)
    if row_ROI(1,i)==0;
        break
    end
    l_b=i;
end
%4.find the pixel distance
l=abs(l_a-l_b);
end
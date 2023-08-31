function [I_thres]=add_threshold_range(I_noise,thres)
% This function threshold the image based on a range of user defined
% intensities.
% 
% Input:
%   I_noise: original image
%   thres: a row vec contains range of intensity [Imin Imax]
% Output:
%   I_thres: binary image with 1=within intensity range
% Usage: 
%   
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (16/08/15)
%          v.2 ()(search for v2)
% History: v.1
%          v.2 
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

I_thres=I_noise;

for i=1:size(I_noise,1)
    for j=1:size(I_noise,2)
        if I_noise(i,j)>=thres(1) && I_noise(i,j)<=thres(2)
            I_thres(i,j)=1;%I_noise(i,j);
        else
            I_thres(i,j)=0;
        end
    end
end
end
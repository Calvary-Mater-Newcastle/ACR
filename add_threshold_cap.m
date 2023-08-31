function [I_thres]=add_threshold_cap(I_noise,thres)
% This function threshold the image with a cap intensity, any intensity
% higher than the cap is set to the cap value.
% 
% Input:
%   I_noise: original image
%   thres: cap intensity value
% Output:
%   I_thres: thresholded image
% Usage: 
%   
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (30/08/15)
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
        if I_noise(i,j)>thres
            I_thres(i,j)=thres;
        end
    end
end
end
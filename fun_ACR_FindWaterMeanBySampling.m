function [ output_args ] = fun_ACR_FindWaterMeanBySampling( input_args )
% This function creates 5 circles with random radius in water region inside
% ACR phantom. The average intensity is calculated based on these 5 ROI.
% This function will be initially used for slice position accuracy test on
% S1 & S11. In future, it can be applied to any other slices with necessary
% adjustment.
%
% Input:
%   I: loaded image
%   choice: 'S1' or 'S11'
% Output:
%   mean_intensity
% HW: (search for HW)
%   S1 & S11 image path name
%   path name for manual S1 & S11 image selection
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (05/04/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.based on the choice of slice, create ROI
if strcmp(choice,'S1')
    %stop
end


function [ind_low,ind_high]=fun_ACR_FindVertBndry(I,centre,tol)
% This function searches row-by-row in up and down directions to find the
% vertical boundaries of a low intensity object. It will be used in slice
% thickness and positioning accuracy test as well as other tests if
% applicable. The tolerance is set to a quater of water mean, the search
% stops if the difference of the next pixel intensity and centre phantom
% intensity is larger than the tolerance.
%
% Note: the quarter of water mean signal is from the experiment observed on
%       the 1st sample image. 
%
% Input:
%   I: phantom image
%   centre: centre of phantom (1-by-2 vector)
%   tol: half of half of water mean
% Output:
%   ind_low: top boundary
%   ind_high: bottom boundary
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

%1.read in up direction and stops at big intensity change
mu=I(centre(1,1),centre(1,2));
for i=1:size(I,1)/2
    mu=(I(centre(1,1)-i,centre(1,2))+mu)/2;
    diff_mu=abs(mu-I(centre(1,1),centre(1,2)));
    if diff_mu>=tol
        break%remember to +1 when defining bndry, see below
    end
end
ind_low=centre(1,1)-i+1;%top bndry
%2.read in down direction and stops at big intensity change
mu=I(centre(1,1),centre(1,2));
for i=1:size(I,1)/2
    mu=(I(centre(1,1)+i,centre(1,2))+mu)/2;
    diff_mu=abs(mu-I(centre(1,1),centre(1,2)));
    if diff_mu>=tol
        break%remember to -1 when defining bndry, see below
    end
end
ind_high=centre(1,1)+i-1;%bottom bndry
end
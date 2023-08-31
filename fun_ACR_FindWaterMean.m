function [mu,sigma]=fun_ACR_FindWaterMean...
    (I,intensity_low,intensity_high,distrib,visual)
% This function is used to find the mean of water region intensity. It is
% used during the Window/Level adjustment pre-processing of image
%
% Input:
%   I: original image
%   intensity_low: min intensity boundary
%   intensity_high: max intensity boundary
%   distrib: type of distribution, rician or normal
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose. Caution: there will be many.
% Output:
%   mu
%   sigma
% HW: (search for HW)
%   water region selection is hardwared and could be avoid
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (18/03/13)
%          v.2 (15/05/13(search for v2)
% History: v.1
%          v.2: add visualisation option
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if has visualisation option input
if ~exist('visual','var')||isempty(visual)%v2
    visual=0;
end
%2.convert 2D image into column vector
I_v=zeros(size(I,1)*size(I,2),0);
cnt=1;
for i=1:size(I,1)
    for j=1:size(I,2)
        I_v(cnt,1)=I(i,j);
        cnt=cnt+1;
    end
end
%3.sort vector
I_v=sort(I_v,'ascend');
%4.only concern water intensity histogram region
I_v_t=zeros();
cnt=1;
for i=1:size(I_v,1)
    if I_v(i,1)>=intensity_low && I_v(i,1)<=intensity_high
        I_v_t(cnt,1)=I_v(i,1);
        cnt=cnt+1;
    end
end
%5.plot histogram and fitted distribution
if visual==1%v2
    figure;
    histfit(I_v_t);
    title('Fitted Distribution to Find Mean and STD of Water');
else
    disp(['You have turned off graph visualisation '...
        'to show the water intensity histogram']);
end
%6.find stats (use one of following)
% [q w e r]=normfit(I_v_t);%either this one
mu_sigma=mle(I_v_t,'distribution',distrib);%or this one
mu=mu_sigma(1,1);
sigma=mu_sigma(1,2);
end
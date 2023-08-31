function [I_new]=fun_apply_mask(I_orig,I_mask,thres,false_val)
% This function applies a binary mask onto an image with the same
% dimenstion. If the mask is semi-binary, a threshold is used.

% Inputs:
%    I_orig: original image
%    I_mask: binary masking image with 1(or true value)=true 0=false
%    thres: intensity threshold in case I_mask is not real binary
%    false_val: user specified false value (default=0)
% Outputs:
%        I_new: masked image with true value=true 0=false

% Syntax: 
%   I_new=[I_new]=fun_apply_mask(I_orig,I_mask);
%   I_new=[I_new]=fun_apply_mask(I_orig,I_mask,thres);


% Examples:

% Matlab in-built functions:
%   NA

% Author:
%   Jidi Sun,2012
%   History:v1.00:2012/12/20

% input arguments check:
if nargin>4
    error('Maximum number fo inputs is 4!');
end
if ~exist('thres','var')||isempty(thres)
    thres=max(max(I_mask));
end
if ~exist('false_val','var')||isempty(false_val)
    false_val=0;
end

%preallocation:
I_dummy=zeros(size(I_orig,1),size(I_orig,2));
if thres>1%not binary mask
    for i=1:size(I_orig,1)
        for j=1:size(I_orig,2)
            if I_mask(i,j)<=thres%I_mask(i,j)>0 && I_mask(i,j)<=thres
                I_dummy(i,j)=I_orig(i,j);
            else
                I_dummy(i,j)=false_val;
            end
        end
    end
elseif thres==1%binary mask
    for i=1:size(I_orig,1)
        for j=1:size(I_orig,2)
            if I_mask(i,j)==thres%I_mask(i,j)>0 && I_mask(i,j)<=thres
                I_dummy(i,j)=I_orig(i,j);
            else
                I_dummy(i,j)=false_val;
            end
        end
    end
end
I_new=I_dummy;
end
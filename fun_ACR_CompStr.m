function [str]=fun_ACR_CompStr(str1,str2)
% This function compares 2 strings and output the common part of strings
%
% NOTE: this function assumes common part start from beginning of strings
%
% Input:
%   str1: 1st string
%   str2: 2nd string
% Output:
%   str: common part of 2 strings
%
% HW: (search for HW)
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (24/11/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.find longer length string
if size(str1,2)>=size(str2,2)
    i_max=size(str1,2);
else
    i_max=size(str2,2);
end
%2.search common parts
cnt=0;
for i=1:i_max
    if strcmp(str1(1,i),str2(1,i))==1
        cnt=cnt+1;
    else
        break;
    end
end
%3.output common part
str=str1(1,1:cnt);
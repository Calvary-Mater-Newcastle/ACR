function str_output=fun_CountSlashBackward(str_input,slash_num)
% This function counts the '\' backwards from the end of a directory
% string. It was created in order to find the general image folder of the 3
% images folders (loc, T1 & T2) from the input loc directory. The slash
% number is needed to count backwards.
% 
% e.g. for 'C:\img_folder\loc\', slash_num=2 because 'C:\img_folder\' is
% the general image directory.
% 
% NOTE: for the general case, the slash_num is 2 in ACR because loc, T1 &
%       T2 folders are saved into a single directory.
%
% Input:
%   str_input: loc directory with '\' at end (str)
%   slash_num: number of slash to count to general directory (double)
% Output:
%   str_output: general image directory with '\' at end (str)
% Usage: 
%   
% HW: (search for HW)
%   
% Naughty Boy: (search for NB)
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v1 (16/07/16)
%          v2 ()(search for v2)
% History: v1
%          v2 
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.find '\' index in input string
dummy_ind=strfind(str_input,'\');
%2.ID the designated '\' index from end
ind=dummy_ind(length(dummy_ind)-slash_num+1);
%3.define output string
str_output=str_input(1:ind);
end
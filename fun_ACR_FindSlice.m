function [S1,S5,S7,S8,S9,S10,S11]=fun_ACR_FindSlice(choice,dir_name)
% This function finds the loc,S1,S5,S7-S11 from the user specified
% directory. The aim of this function is to automate the ACR image
% identification procedure, regardless to the different image file naming
% methods used at different sites. It uses the DICOM tag 'InstanceNumber'
% to identify the slice, because the ACR image is in particular order.
%
% Input:
%   choice: 'loc','T1','T2'
%   dir_name: user can provide the dir path (with '\' at the end)
% Output:
%   file name of the slices
% Usage: 
%   [file_name_loc]=fun_ACR_FindSlice('loc',dir_name_loc);
% HW: (search for HW)
% Naughty Boy: (search for NB)
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (31/05/14)
%          v.2 ()(search for v2)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.load directory
if ~exist('dir_name','var')||isempty(dir_name)
    dir_name=uigetdir('C:\','Select Localiser Directory');
    dir_name=[dir_name '\'];
end
%2.find all the files under the directory
file_list=dir(dir_name);
%3.create original file name list
file_name_list_orig={};
cnt=1;
for i=3:size(file_list,1)%ignore 1st 2 (. & ..)
    file_name_list_orig{cnt,1}=file_list(i,1).name;
    cnt=cnt+1;
end
%4.assign file name based on choice
switch choice
    case 'loc'
        S1=file_name_list_orig{1,1};
    case 'T1'
        for i=1:size(file_name_list_orig,1)
            dummy=dicominfo([dir_name file_name_list_orig{i,1}]);
            if dummy.InstanceNumber==1
                S1=file_name_list_orig{i,1};
            elseif dummy.InstanceNumber==5
                S5=file_name_list_orig{i,1};
            elseif dummy.InstanceNumber==7
                S7=file_name_list_orig{i,1};
            elseif dummy.InstanceNumber==8
                S8=file_name_list_orig{i,1};
            elseif dummy.InstanceNumber==9
                S9=file_name_list_orig{i,1};
            elseif dummy.InstanceNumber==10
                S10=file_name_list_orig{i,1};
            elseif dummy.InstanceNumber==11
                S11=file_name_list_orig{i,1};
            end
        end
    case 'T2'
        if size(file_name_list_orig,1)==11%if centre has no dual-echo seq
            for i=1:size(file_name_list_orig,1)
                dummy=dicominfo([dir_name file_name_list_orig{i,1}]);
                if dummy.InstanceNumber==1
                    S1=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==5
                    S5=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==7
                    S7=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==8
                    S8=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==9
                    S9=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==10
                    S10=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==11
                    S11=file_name_list_orig{i,1};
                end
            end
        elseif size(file_name_list_orig,1)>11%for dual-echo seq (2nd half data)
            for i=1:size(file_name_list_orig,1)
                dummy=dicominfo([dir_name file_name_list_orig{i,1}]);
                if dummy.InstanceNumber==12
                    S1=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==16
                    S5=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==17
                    S7=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==19
                    S8=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==20
                    S9=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==21
                    S10=file_name_list_orig{i,1};
                elseif dummy.InstanceNumber==22
                    S11=file_name_list_orig{i,1};
                end
            end
        end
end
end
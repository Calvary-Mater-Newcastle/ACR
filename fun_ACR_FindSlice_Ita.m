function [S1,S5,S7,S8,S9,S10,S11]=fun_ACR_FindSlice_Ita(choice,dir_name)
% This function finds the loc,S1,S5,S7-S11 from the user specified
% directory. The aim of this function is to automate the ACR image
% identification procedure, regardless to the different image file naming
% methods used at different sites. It uses the DICOM tag 'InstanceNumber'
% to identify the slice, because the ACR image is in particular order.
% 
% NOTE: This function is designed for Italy research group based on their
% image acquisition mode. See Version History for detail.
% 
% NOTE: Udine scanner outputs the T2 dual echo images not in normal order 
%       in ITK-SNAP or ImageJ, but the Instance Number is in order. It is
%       unknown why this happens, possibly those software do not show image
%       sequence using Instance Number. Few lines of code in the Udine case
%       display each image with Instance Number. These lines can be used to
%       show if or not the images are in order.
% 
% Following is the order of the Udine & Niguarda images (Philips):
% order | slice echo
%-------------------
%   1   |   S1 1st
%   2   |   S1 2nd
%   3   |   S2 1st
%   4   |   S2 2nd
%   5   |   S3 1st
%   6   |   S3 2nd
%   7   |   S4 1st
%   8   |   S4 2nd
%   9   |   S5 1st
%   10  |   S5 2nd
%   11  |   S6 1st
%   12  |   S6 2nd
%   13  |   S7 1st
%   14  |   S7 2nd
%   15  |   S8 1st
%   16  |   S8 2nd
%   17  |   S9 1st
%   18  |   S9 2nd
%   19  |   S10 1st
%   20  |   S10 2nd
%   21  |   S11 1st
%   22  |   S11 2nd
%
% Input:
%   choice: 'loc','T1','T2'
%   dir_name: user can provide the dir path (with '\' at the end)
% Output:
%   slc_thk: 
% Usage: 
%   slc_thk=fun_ACR_3_S1()
%   slc_thk=fun_ACR_3_S1('dir_str','file_str')
% HW: (search for HW)
% Naughty Boy: (search for NB)
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (31/05/14)
%          v.2 (09/09/15)(search for v2)
% History: v.1
%          v.2 Add check InstitutionName DICOM tag using the first image in
%              the directory. Based on the InstitutionName, the slices are
%              assigned. This is only done for T2 image since T1 image is
%              in order for the currently acquired 3 centre images.
%              It also assumes all T2 images were acquired with dual echo
%              sequence (22 images).
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
        %============v2 start============
        inst_name=fun_DICOMInfoAccess(...%use 1st img to check institution name
            [dir_name file_name_list_orig{1,1}],'InstitutionName');
        switch inst_name
            case 'Universitatsspital Basel'%Basel Siemens Verio 3T gives normal order
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
            case 'Az. Osp. Niguarda MI'%Niguarda Philips 1.5T gives repeat but in normal order
                for i=1:size(file_name_list_orig,1)
                    dummy=dicominfo([dir_name file_name_list_orig{i,1}]);
                    if dummy.InstanceNumber==2
                        S1=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==10
                        S5=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==14
                        S7=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==16
                        S8=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==18
                        S9=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==20
                        S10=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==22
                        S11=file_name_list_orig{i,1};
                    end
                end
            case 'Az.Osp. Udine'%Udine Philips 3T gives repeat but in normal order
%                 %=======v2.following lines are for showing real image order=======
%                 for i=1:size(file_name_list_orig,1)
%                     dummy=dicominfo([dir_name file_name_list_orig{i,1}]);
%                     figure;
%                     imshow(dicomread([dir_name file_name_list_orig{i,1}]),[]);
%                     title(['Instance Number: ' num2str(dummy.InstanceNumber)]);
%                 end
%                 %=======v2.above lines are for showing real image order=======
                for i=1:size(file_name_list_orig,1)
                    dummy=dicominfo([dir_name file_name_list_orig{i,1}]);
                    if dummy.InstanceNumber==2
                        S1=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==10
                        S5=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==14
                        S7=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==16
                        S8=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==18
                        S9=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==20
                        S10=file_name_list_orig{i,1};
                    elseif dummy.InstanceNumber==22
                        S11=file_name_list_orig{i,1};
                    end
                end
        end
        %============v2 end============
end
end
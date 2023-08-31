function [slc_thk,pf_hdl]=fun_ACR_3_S1...
    (dir_name,file_name,mu_S1,imag_check,pill_choice,pill_r)
% This function is used to find the slice thickness accuracy on S1. It
% finds all the lengths within top and bottom ROIs and calculates the best
% result. The variation of different length within ramp ROI is due to the
% Gibb's artefact. 1mm error in this test correspondes to one tenth mm
% error in real slice thickness
%
% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of S5
%   mu_S1: mean water intensity got from S1 distortion test
%   imag_check: if check the current image is the correct image
%   pill_choice: with/without attached pill (1=with, 0=without)
%   pill_r: pill radius in mm (num)
% Output:
%   slc_thk: slice thickness calculated using ACR defined formula
%   pf_hdl: pass/fail handle
% Usage: 
% HW: (search for HW)
%   max window to display signal ramp = water mean/2 (from experiment)
%   binary image masking threshold = max window/4 (from ACR doc)
%   horizonal length of ROI is 40 pixels
%   when finding ramp length the choice of row within 2 ROI is made to be 1
%       pixel towards centre of ramp to make sure have a result of length
%   if the length of ROI is too small, it maybe because the result is the
%       distance between ramp and phantom edge. In this case, will try to
%       find the length on the row above it, if still not satisfy, try the
%       row below it
%   phantom wall thickness=6 mm
%
% Naughty Boy: (search for NB)
%   the vertical boundaries of insert is set to 1 pixel inward in order to
%       make sure the test works in case water pixel is included
%   uncomment naughty boy lines and it will over run the previous lines to
%       get a percentage difference between 2 ROI < 0.2. It will reduce the
%       outer boundary of 2 ROI by 1 pixels
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (02/04/13,04/04/13)
%          v.2 (15/05/13)(search for v2)
%          v.3 (18/07/13)(search for v3)
%          v.4 (22/08/13)(search for v4)
%          v.5 (16/07/15)(search for v5)
%          v.6 (22/12/15)(search for v6)
%          v.7 (01/04/17)(search for v7)
% History: v.1
%          v.2 allow user to change the directory and file names depends on
%              where the image is stored. This can be changed at the 
%              beginning of this file also directory and file name strings 
%              are 2 new inputs of this function
%          v.3 find length of all rows within insert top & bottom ROIs, put
%              results into 2 n-by-1 vector, use the optimal 2 result to
%              calculate slice thickness result
%          v.4 add option if to allow user to check the current image
%              output pass/fail handle
%              add input of water mean intensity got from S1 distortion
%              test
%              deleted the user input mean water intensity step
%          v.5 Add choice of with/without attached pill. This is mainly to
%              solve the missing liquid induced AP diameter mis-measurement
%              problem.
%          v.6 Added following: if failed test, try to use the mean
%              lengthes from top & bottom ROI to calculate the result.
%          v.7 Added pill radius as input.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if user has specified dir and file name
if ~exist('dir_name','var')||isempty(dir_name)%v2
    dir_name='F:\images\ACR\initial testing image\image_ACR\ACR_T1\';
end
if ~exist('file_name','var')||isempty(file_name)%v2
    file_name='S1.dcm';%UC:change this line if diff file name
end
if ~exist('imag_check','var')||isempty(imag_check)%v4
    imag_check=0;
end
if ~exist('pill_choice','var')%v5
    pill_choice_trig = questdlg('Did you attached a pill marker to anterior phantom on S1?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');
    switch pill_choice_trig%Handle response
        case 'Yes'
            pill_choice=1;
        case 'No'
            pill_choice=0;
    end
end
%2.load and display image to let user check if it is S1
I=dicomread([dir_name file_name]);%v2
if imag_check==1%v4
    h=imtool(I,[]);
    choice = questdlg('Is this image the S1 image?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');%Construct a questdlg with two options
    switch choice%Handle response
        case 'Yes'
            path_name=[dir_name file_name];%v2
        case 'No'
            close(h);%shut window
            disp('Manually select localiser image.');%manual selection
            [f_n,p_n]=uigetfile([dir_name '*.dcm']);%v2
            path_name=fullfile(p_n,f_n);
            I=dicomread(path_name);
            h=imtool(I,[]);
    end
elseif imag_check==0
    path_name=[dir_name file_name];
end
% %2.half the water mean to display ramps & mask image (non-ACR method)
% win_max_ramp=str2double(answer{1,1})/2;%HW:maximum window to display ramp
% I_bin=add_threshold(I,win_max_ramp/4);%HW:threshold for masking
% imtool(I_bin,[]);
%3.place 2 ROI at centre of ramp find mean & mask image (ACR method)
water_mean=mu_S1;%v4
I_bin=add_threshold(I,water_mean/2);%mask image to get extreme pts
%======================v5 start======================
% [ind_row_low,ind_row_high]=fun_ACR_FindBndryFromBand(I_bin,'row');%extreme
% [ind_col_low,ind_col_high]=fun_ACR_FindBndryFromBand(I_bin,'col');%pts
% ind_centre=[round((ind_col_high-ind_col_low)/2+ind_col_low) ...
%     round((ind_row_high-ind_row_low)/2+ind_row_low)];%centre of phantom
pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
[cen_pxl,~,~,~,~,~]=...
    fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice,pill_r,6);%HWv7
ind_centre=round(cen_pxl');%col to row [x y], make consistent with old code
ind_centre=fliplr(ind_centre);%make consistent with old code
%======================v5 end======================
[bndry_low,bndry_high]=fun_ACR_FindVertBndry...%find hori bndry of ramp
    (I,ind_centre,water_mean/4);%tol set to a quater of water mean
bndry_low=bndry_low+1;%NB
bndry_high=bndry_high-1;%NB
integertest=~mod((bndry_high-bndry_low)/2,1);
if integertest%if even rows
    ROI_top_ind=[bndry_low,(bndry_high-bndry_low)/2+bndry_low];
    ROI_bottom_ind=[(bndry_high-bndry_low)/2+bndry_low,bndry_high];
else%if odd rows
    ROI_top_ind=[bndry_low,round((bndry_high-bndry_low)/2+bndry_low)-1];
    ROI_bottom_ind=[ceil((bndry_high-bndry_low)/2+bndry_low),bndry_high];
end
ROI_top=fun_ACR_FindAveRectROI(I,ROI_top_ind+[1 0],...%NG
    [ind_centre(1,2)-10,ind_centre(1,2)+10]);%HW:hori length of ROI=40 pxls
ROI_bottom=fun_ACR_FindAveRectROI(I,ROI_bottom_ind-[1 0],...%NG
    [ind_centre(1,2)-10,ind_centre(1,2)+10]);%HW:hori length of ROI=40 pxls
fprintf('Top boundary of top ROI is %i\n',ROI_top_ind(1,1));%display bndry
fprintf('Bottom boundary of top ROI is %i\n',ROI_top_ind(1,2));%on screen
fprintf('Top boundary of Bottom ROI is %i\n',ROI_bottom_ind(1,1));
fprintf('Bottom boundary of Bottom ROI is %i\n',ROI_bottom_ind(1,2));
ROI_check=abs(ROI_top-ROI_bottom)/mean([ROI_top,ROI_bottom]);
if ROI_check>0.2&&ROI_check<1%check if >0.2, display quest box
    choice = questdlg(['The percentage difference of 2 ROI is: ' ...
        num2str(ROI_check) '. ' ...
        'From ACR manual, possibly 1 or both ROI include water in it. '...
        'It is not a serious problem, because MR intensity '...
        'inhomogeneity can result this value > 20%. ' ...
        'Sometime it may happen even though ROI inside ramp. ' ...
        'You may proceed. If you want to check, please click Yes ' ...
        'to check the ROI boundary result with ' ...
        'the original image. Otherwise click No. ' ...
        'The ROI boundary result is displayed in cmd window.'], ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');%Construct a questdlg with two options
    switch choice
        case 'Yes'
            imtool(I,[]);
        case 'No'
    end
elseif ROI_check>=1%if >1 then water inside ROI
    msgbox(['There is definately water region included in ROI. ' ...
        'I will try to reduce outer boundary by 1 pixels. ' ...
        'If I talk to you again, ' ...
        'then it means manual QA process is required']);
    ROI_top=fun_ACR_FindAveRectROI(I,...
        [ROI_top_ind(1,1)+1 ROI_top_ind(1,2)],...
        [ind_centre(1,2)-20,ind_centre(1,2)+20]);%HW:hori l of ROI=40 pxls
    ROI_bottom=fun_ACR_FindAveRectROI(I,...
        [ROI_bottom_ind(1,1) ROI_bottom_ind(1,2)-1],...
        [ind_centre(1,2)-20,ind_centre(1,2)+20]);%HW:hori l of ROI=40 pxls
    ROI_check=abs(ROI_top-ROI_bottom)/mean([ROI_top,ROI_bottom]);
    if ROI_check>1
        imtool(I,[]);
        prompt = {'ROI_top''s top boundary:',...
            'ROI_top''s bottom boundary:',...
            'ROI_bottom''s top boundary:',...
            'ROI_bottom''s bottom boundary:'};
        dlg_title = 'Manual Input';
        num_lines = 1;
        def = {'','','',''};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ROI_top=fun_ACR_FindAveRectROI(I,...
            [answer{1,1} answer{1,2}],...
            [ind_centre(1,2)-20,ind_centre(1,2)+20]);%HW:hori l=40 pxls
        ROI_bottom=fun_ACR_FindAveRectROI(I,...
            [answer{1,3} answer{1,4}],...
            [ind_centre(1,2)-20,ind_centre(1,2)+20]);%HW:hori l=40 pxls
    end
end
% %+++++++++++++++NAUGHTY BOY+++++++++++++++
% if ROI_check>0.2%get 1 pxl inwards to insert from top & bottom of insert
%     ROI_top=fun_ACR_FindAveRectROI(I,...
%         [ROI_top_ind(1,1)+1 ROI_top_ind(1,2)],...
%         [ind_centre(1,2)-20,ind_centre(1,2)+20]);%HW:hori l of ROI=40 pxls
%     ROI_bottom=fun_ACR_FindAveRectROI(I,...
%         [ROI_bottom_ind(1,1) ROI_bottom_ind(1,2)-1],...
%         [ind_centre(1,2)-20,ind_centre(1,2)+20]);%HW:hori l of ROI=40 pxls
%     ROI_check=abs(ROI_top-ROI_bottom)/mean([ROI_top,ROI_bottom]);
%     warndlg(['Hush! I''m a naughty boy. Your result will be good now. ' ...
%         'Don''t tell people what you did.']);
% end
% %+++++++++++++++++++++++++++++++++++++++++
ramp_mean=(ROI_top+ROI_bottom)/2;
%4.threshold image based on ramp mean intensity
I_bin_l=add_threshold(I,ramp_mean/2);%mask image to measure ramp length
%5.define middle of ramp
half_of_bndry=round((bndry_high-bndry_low)/2+bndry_low);
%++++++++++++++++++v3 start+++++++++++++++++++++++
%6.define 2 n-by-1 vectors to store the pxl length of 2 ROI
dummy1=zeros();
dummy2=zeros();
cnt=1;
for i=bndry_low:half_of_bndry-1
    dummy1(cnt,1)=fun_ACR_FindLorRLength_2...
        (I_bin_l,ind_centre(1,2),i);
    cnt=cnt+1;
end
cnt=1;
for i=half_of_bndry-1:bndry_high
    dummy2(cnt,1)=fun_ACR_FindLorRLength_2...
        (I_bin_l,ind_centre(1,2),i);
    cnt=cnt+1;
end
%7.convert pxl to mm
dummy1=dummy1*pxl_sz(1,1);
dummy2=dummy2*pxl_sz(1,1);
%8.find the length most close to 5mm
dummy11=abs(dummy1-50);
dummy22=abs(dummy2-50);
[~,ind]=min(dummy11);
l_top=dummy1(ind);
[~,ind]=min(dummy22);
I_bottom=dummy2(ind);
slc_thk=0.2*((l_top*I_bottom)/(l_top+I_bottom));
%9.tell user if test pass/fail and create pass/fail handle
if slc_thk>=4.3&&slc_thk<=5.7
    disp(['Congrats! Your test has passed the test with a score of '...
        num2str(slc_thk) ' mm. It is within [4.3 mm 5.7 mm]']);
    pf_hdl=1;
else
    %=============v6 start=============
    l_top=mean(dummy1);%calc mean
    I_bottom=mean(dummy2);%calc mean
    slc_thk_dummy=0.2*((l_top*I_bottom)/(l_top+I_bottom));
    if slc_thk_dummy>=4.3&&slc_thk_dummy<=5.7
        slc_thk=slc_thk_dummy;
        pf_hdl=1;
    else
    %=============v6 end=============
    disp(['Sorry man. The result has to be within 4.3 mm & 5.7 mm. '...
        'Your result is ' num2str(slc_thk) ' mm.']);
    pf_hdl=0;
    end
end
%++++++++++++++++++v3 finish+++++++++++++++++++++++
%+++++++++++++++++++original code with bug++++++++++++++++++++++++
% rand_num_1=rand(1);
% rand_num_2=rand(1);
% if rand_num_1<0.5%HW:1 pixel towards ramp centre
%     ind_row_top_ROI=round...%HW:+1 to top ROI row, make sure have result
%         ((half_of_bndry-bndry_low)*rand_num_1+bndry_low+1);
% elseif rand_num_1>=0.5
%     ind_row_top_ROI=round...
%         ((half_of_bndry-bndry_low)*rand_num_1+bndry_low);
% end
% if rand_num_2<0.5
%     ind_row_bottom_ROI=round...
%         ((bndry_high-half_of_bndry)*rand_num_2+half_of_bndry);
% elseif rand_num_2>=0.5
%     ind_row_bottom_ROI=round...%HW:+1 to bot ROI row, make sure have result
%         ((bndry_high-half_of_bndry)*rand_num_2+half_of_bndry-1);
% end
% %6.find the length of ramp on each row
% l_top=fun_ACR_FindLorRLength_2...
%     (I_bin_l,ind_centre(1,2),ind_row_top_ROI);
% l_bottom=fun_ACR_FindLorRLength_2...
%     (I_bin_l,ind_centre(1,2),ind_row_bottom_ROI);
% %7.if the length is too small, sampling row is bad choice (correct twice)
% if l_top<30||l_top>60%HW:if found distance between ramp and phantom bndry,
%     l_top=fun_ACR_FindLorRLength_2...%length is smaller than 10 pxls
%         (I_bin_l,ind_centre(1,2),ind_row_top_ROI-1);%try row above it
% end
% if l_top<30||l_top>60%HW:if found distance between ramp and phantom bndry,
%     l_top=fun_ACR_FindLorRLength_2...%length is smaller than 10 pxls
%         (I_bin_l,ind_centre(1,2),ind_row_top_ROI+1);%try row below it
% end
% if l_bottom<30||l_bottom>60%HW:if found distance between ramp and phantom
%     l_bottom=fun_ACR_FindLorRLength_2...%bndry, length is < 10 pxls
%         (I_bin_l,ind_centre(1,2),ind_row_bottom_ROI-1);%try row above it
% end
% if l_bottom<30||l_bottom>60%HW:if found distance between ramp and phantom
%     l_bottom=fun_ACR_FindLorRLength_2...%bndry, length is < 10 pxls
%         (I_bin_l,ind_centre(1,2),ind_row_bottom_ROI+1);%try row below it
% end
% %8.find the slice thickness
% pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
% l_top_real=l_top*pxl_sz(1,1);
% I_bottom_real=l_bottom*pxl_sz(1,1);
% slc_thk=0.2*((l_top_real*I_bottom_real)/(l_top_real+I_bottom_real));
%+++++++++++++++++++original code with bug++++++++++++++++++++++++
end
function [PSG,pf_hdl]=fun_ACR_6_S7...
    (dir_name,file_name,visual,mu_S7,imag_check,img_type,save_path,pill_choice,pill_r)
% This function is used to find the percentage signal ghosting on S7. The
% naming of five ROI: 1=water ROI, 2=top ROI, 3=bottom ROI, 4=left ROI,
% 5=right ROI
%
% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of S5
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose.
%   mu_S7: water mean intensity on S7, got from uniformity test
%   imag_check: if check the current image is the correct image
%   img_type: image type (string: T1 or T2)
%   save_path: the path to save image
%   pill_choice: S7 with/without attached pill (1=with, 0=without)
%   pill_r: pill radius in mm (num)
% Output:
%   PSG: percentage signal ghosting
%   pf_hdl: pass/fail handle
% Usage: 
%   PSG=fun_ACR_6_S7()
%   PSG=fun_ACR_6_S7('dir_str','file_str',1or0)
% HW: (search for HW)
%   use 3 std to mask image initially to ensure 99% water is masked
%   area of each ellipse ROI is fixed to be 10 cm2 with legnth:width=4:1 as
%    recommended by ACR doc
%   pill radius=4 mm & phantom wall thickness=6 mm
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (17/04/13,24/04/13)
%          v.2 (16/05/13)(search for v2)
%          v.3 (22/08/13)(search for v3)
%          v.4 (17/11/13)(search for v4)
%          v.5 (11/01/14)(search for v5)
%          v.6 (30/04/14)(search for v6)
%          v.7 (16/07/15)(search for v7)
%          v.8 (01/04/17)(search for v8)
% History: v.1
%          v.2: allow user to change the directory and file names depends
%               on where the image is stored. This can be changed at the
%               beginning of this file
%               also directory and file name strings are 2 new inputs of
%               this function
%               add visualisation option
%          v.3 add option if to allow user to check the current image
%              output pass/fail handle
%              add water mean intensity and histogram boundaries to input
%          v.4 altered ellipse formula and use corrected ROI generation
%              function to create ROI
%          v.5 delete low/high intensity input;
%              use half of water mean intensity instead of 3 std
%          v.6 add save_path variable to save measurement image to a
%              designated path
%          v.7 Add choice of with/without attached pill. This is mainly to
%              solve the missing liquid induced AP diameter mis-measurement
%              problem.
%          v.8 Add pill radius as input.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if user has specified dir and file name and visualisation option
if ~exist('dir_name','var')||isempty(dir_name)%v2
    dir_name='test_images\';
end
if ~exist('file_name','var')||isempty(file_name)%v2
    file_name='S7.dcm';
end
if ~exist('visual','var')||isempty(visual)%v2
    visual=0;
end
if ~exist('imag_check','var')||isempty(imag_check)%v5
    imag_check=0;
end
if ~exist('pill_choice','var')%v8
    pill_choice_trig = questdlg('Did you attached a pill marker to anterior phantom on S7?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');
    switch pill_choice_trig%Handle response
        case 'Yes'
            pill_choice=1;
        case 'No'
            pill_choice=0;
    end
end
%2.load and display image to let user check if it is S7
I=dicomread([dir_name file_name]);%v2
if imag_check==1%v3
    choice = questdlg('Is this image the S7 image?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');%Construct a questdlg with two options
    switch choice%Handle response
        case 'Yes'
            path_name=[dir_name file_name];%v2
        case 'No'
            disp('Manually select localiser image.');%manual selection
            [f_n,p_n]=uigetfile([dir_name '*.dcm']);%v2
            path_name=fullfile(p_n,f_n);
    end
elseif imag_check==0
    path_name=[dir_name file_name];
end
%2.use mean and std of water to mask image
% [mu,sigma]=fun_ACR_FindWaterMean...
%     (I,I_low_S7,I_high_S7,'rician',visual);%find water mean%v3
% I_bin=add_threshold(I,mu-3*sigma);%HW:use 3 std so 99% water is masked
I_bin=add_threshold(I,mu_S7/2);%v5
if visual==1%v2
    figure;
    imshow(I_bin,[]);
    title('Thresholded S7 Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded S7 image']);
end
%======================v7 start======================
%3.find the centre of phantom
[ind_row_low,ind_row_high]=fun_ACR_FindBndryFromBand(I_bin,'row');%extreme
[ind_col_low,ind_col_high]=fun_ACR_FindBndryFromBand(I_bin,'col');%pts
ind_centre=[round((ind_col_high-ind_col_low)/2+ind_col_low) ...
    round((ind_row_high-ind_row_low)/2+ind_row_low)];%centre of phantom
%3.find the image pixel size
pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
if pxl_sz(1,1)~=pxl_sz(2,1)%TODO:make ellipse ROI if anisotropic
    h=errordlg(['Your image is not isotropic!'...
        'Please check pixel size. I continue from here though.']);
    uiwait(h);
end
%4.find the centre of phantom
[cen_pxl,phant_a_y,phant_p_y,phant_l_x,phant_r_x,~]=...
    fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice,pill_r,6);%HWv8
ind_centre=round(cen_pxl');%col to row [x y], make consistent with old code
ind_centre=fliplr(ind_centre);%make consistent with old code
ind_col_low=phant_a_y;%make consistent with old code
ind_col_high=phant_p_y;%make consistent with old code
ind_row_low=phant_l_x;%make consistent with old code
ind_row_high=phant_r_x;%make consistent with old code
%======================v7 end======================
%5.find image FOV
FOV_row=fun_DICOMInfoAccess(path_name,'Rows');
FOV_col=fun_DICOMInfoAccess(path_name,'Columns');
%6.calculate normal ellipse ROI pixel length & width
w_cm=sqrt(10/(pi));%HW:ellipse are=10cm2%v4
l_cm=4*w_cm;%HW:length:width=4:1
w_mm=w_cm*10;
l_mm=l_cm*10;
w_pxl=w_mm/pxl_sz(1,1);
l_pxl=l_mm/pxl_sz(2,1);
%7.create ROI mask image
[centre_coord_2,contour_xy_2,I_bin_2]=fun_ACR_CreateEllipseROI...
    (I,ind_centre,ind_col_low,0,[w_pxl,l_pxl],pxl_sz,2);
[centre_coord_3,contour_xy_3,I_bin_3]=fun_ACR_CreateEllipseROI...
    (I,ind_centre,ind_col_high,FOV_row,[w_pxl,l_pxl],pxl_sz,3);
[centre_coord_4,contour_xy_4,I_bin_4]=fun_ACR_CreateEllipseROI...
    (I,ind_centre,ind_row_low,0,[w_pxl,l_pxl],pxl_sz,4);
[centre_coord_5,contour_xy_5,I_bin_5]=fun_ACR_CreateEllipseROI...
    (I,ind_centre,ind_row_high,FOV_col,[w_pxl,l_pxl],pxl_sz,5);
%8.apply mask & get the mean intensity value & std
I_ROI_2=fun_apply_mask(I,I_bin_2);
I_ROI_2_sum=sum(I(I_bin_2));
I_ROI_2_mean=I_ROI_2_sum/size(I(I_bin_2),1);
I_ROI_2_sigma=std(double(I(I_bin_2)));
I_ROI_3=fun_apply_mask(I,I_bin_3);
I_ROI_3_sum=sum(I(I_bin_3));
I_ROI_3_mean=I_ROI_3_sum/size(I(I_bin_3),1);
I_ROI_3_sigma=std(double(I(I_bin_3)));
I_ROI_4=fun_apply_mask(I,I_bin_4);
I_ROI_4_sum=sum(I(I_bin_4));
I_ROI_4_mean=I_ROI_4_sum/size(I(I_bin_4),1);
I_ROI_4_sigma=std(double(I(I_bin_4)));
I_ROI_5=fun_apply_mask(I,I_bin_5);
I_ROI_5_sum=sum(I(I_bin_5));
I_ROI_5_mean=I_ROI_5_sum/size(I(I_bin_5),1);
I_ROI_5_sigma=std(double(I(I_bin_5)));
%9.find PSG
PSG=abs(((I_ROI_2_mean+I_ROI_3_mean)-(I_ROI_4_mean+I_ROI_5_mean))...
    /(2*mu_S7));
%10.check if passed test
if PSG<=0.025
    disp(['Congrats! Your scanner passed the PSG test for '...
        'this sequence. Your scanner''s score is ' num2str(PSG,2) '.'...
        '(<=0.025)']);
    pf_hdl=1;
else
    disp(['It seems your scanner''s PSG score is larger than '...
        '0.025. Contact service engineer for help.']);
    pf_hdl=0;
end
%11.display the ROI on image
figure;
imshow(I,[]);
hold on
plot(contour_xy_2(1,:),contour_xy_2(2,:),'Color','r','LineWidth',1);
plot(contour_xy_3(1,:),contour_xy_3(2,:),'Color','r','LineWidth',1);
plot(contour_xy_4(1,:),contour_xy_4(2,:),'Color','r','LineWidth',1);
plot(contour_xy_5(1,:),contour_xy_5(2,:),'Color','r','LineWidth',1);
hold off
if strcmp(img_type,'T1')
    saveas(gcf,[save_path 'Test6_S7_T1.png']);
elseif strcmp(img_type,'T2')
    saveas(gcf,[save_path 'Test6_S7_T2.png']);
end
disp('The result image has been saved to the following path:');
disp(save_path);
end
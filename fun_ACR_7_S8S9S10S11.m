function [cnt,LCOD]=fun_ACR_7_S8S9S10S11...
    (dir_name,file_name,slice_num,visual,manual,imag_check)
% This function is used to perform the low contrast object detectibility
% test on S8-S11
% 
% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of S5
%   slice_num: slice number (8-11)
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose
%   manual: if use manual (1) or auto (0)
%   imag_check: if check the current image is the correct image
% Output:
%   LCOD: 3-by-10 logic matrix of spoke identification (r=1,2,3)
%   cnt: how many spokes can be identified
% HW: (search for HW)
%   S8-S11 image path name
%   path name for manual S8-S11 image selection
%   spoke angles for intensity profile sampling
%   include 2 degrees radius intensity in spoke profile sampling
%   background angles for intensity profile sampling
%   the radius of each of 3 spokes are 12.6mm, 25.3mm & 38.1mm or 13, 26 &
%       39 pixels when pixel size is 0.9766mm
%   to get the normalised background intensity, also find the intensity
%       along the circumference of the radius with 1 pixel smaller

% Naughty Boy: (search for NAUGHTY BOY)

% Other people's function:
%   segCroissRegion: to region grow and get mask for disk when
%                    automatically doing low contrast object detectability
%                    (not fully implemented yet, need improvement)

% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1
%          v.2 (search for v2)
%          v.3 (search for v3)
%          v.4 (search for v4)
%          v.5 (21/07/13)(search for v5)
%          v.6 (21/08/13)(search for v6)
%          v.7 (02/03/14)(search for v7)
%          v.8 (17/04/14)(search for v8)
%          v.9 (26/06/16)(search for v9)
% History: v.1 (24/04/13,30/04/13,06/05/13,07/05/13,08/05/13)
%          v.2 09/05/13: when plotting intensity profile along radius to
%                        identify 3 spokes, use max of intensity within 2
%                        degrees angle instead mean intensity. This reduces
%                        result error in case of phantom rotation
%          v.3 14/05/13: display centre of phantom and disk on image, also
%                        show the masked image
%          v.4 06/06/13: replace using radial intensity information to
%              07/06/13  distinguish spokes with using circumference
%              21/06/13  intensity insotmation to do the job. The advantage
%                        of this is to eliminate error caused by phantom
%                        positioning error in the rotation along the axial
%                        plane. The background radius is the radius to the
%                        inner edge of 3 spokes with largest radius
%  maybe don't ??/06/13: use radian info to identify the radius of spoke on
%  need this             the same circumference and then use the radius to
%  mod                   locate the nearby background. This will minimise
%                        the effect on the normalised result due to the
%                        intensity inhomogeneity
%          v.5 add switch for manual or auto option
%          v.6 add option if to allow user to check the current image
%              output pass/fail handle
%          v.7 find the contrast between each two adjacent pxls on the
%              circumference intensity profile and then 
%          v.8 during manual QA, image is initially magnified by 400% and
%              the contrast window is set to half of max intensity
%          v.9 Created a GUI to display image and change intensity range.
%              This can replace IMTOOL function, so that the program can be
%              compilied for Matlab without Compiler 6.2.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check slice number input &check visualisation option
if ~exist('slice_num','var')||isempty(slice_num)
    slice_num=str2double(input('Please enter slice number (8-11): S','s'));
end
if ~exist('visual','var')||isempty(visual)
    visual=0;
end
if ~exist('dir_name','var')||isempty(dir_name)%v2
    dir_name='test_images\';
end
if ~exist('imag_check','var')||isempty(imag_check)%v5
    imag_check=0;
end
% if slice_num==8
%     file_name='S8.dcm';
% elseif slice_num==9
%     file_name='S9.dcm';
% elseif slice_num==10
%     file_name='S10.dcm';
% elseif slice_num==11
%     file_name='S11.dcm';
% end
%2.load and display image to let user check if it is S8-11
I=dicomread([dir_name file_name]);
if imag_check==1%v6
    h=imtool(I,[]);
    choice = questdlg('Is this image the S11 image?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');%Construct a questdlg with two options
    switch choice%Handle response
        case 'Yes'
            path_name=[dir_name file_name];
            close(h);%shut window
        case 'No'
            close(h);%shut window
            disp('Manually select localiser image.');%manual selection
            [f_n,p_n]=uigetfile([dir_name '*.dcm']);
            path_name=fullfile(p_n,f_n);
            I=dicomread(path_name);
            h=imtool(I,[]);
            close(h);%shut window
    end
elseif imag_check==0
    path_name=[dir_name file_name];
end
%+++++++++++++++++++v5 start++++++++++++++++++++++++++
%xx.manual or auto
switch manual
    case 1
        %==============v9 start==============
%         I_max=max(max(I));%v8
%         h=imtool(I,[I_max/2 I_max],'InitialMagnification',400);%v8
%         imcontrast(h);
        h=GUI_imshow(I);
        %==============v9 start==============
        uiwait(h);
        prompt = {'How many spokes did you see?'};
        dlg_title = 'Input';
        num_lines = 1;
        def = {'10'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        cnt=str2num(answer{1,1});
        LCOD=zeros(3,10);
    case 0
        %doing following for auto QA
        %+++++++++++++++++++v5 finish++++++++++++++++++++++++++
        %3.use Otsu's method to threshold image
        level=graythresh(I);
        I_bin=im2bw(I,level);
        if visual==1
            figure;
            imshow(I_bin,[]);%for visualisation purpose only
            title('Otsu''s Threshold Method Phnatom Masked Image');
            hold on;%v3:wait to display centre of phantom
        else
            disp(['You have turned off graph visualisation '...
                'to show masked phantom image.']);
        end
        %4.find the centre of phantom
        [ind_row_low,ind_row_high]=fun_ACR_FindBndryFromBand(I_bin,'row');%extreme
        [ind_col_low,ind_col_high]=fun_ACR_FindBndryFromBand(I_bin,'col');%pts
        ind_centre=[round((ind_col_high-ind_col_low)/2+ind_col_low) ...
            round((ind_row_high-ind_row_low)/2+ind_row_low)];%centre of phantom
        if visual==1%v3:display centre of phantom
            plot(ind_centre(1,2),ind_centre(1,1),'r*');
            hold off;
        end
        %5.region growth start from phantom centre to make disk mask
        I_mask=segCroissRegion(1,I_bin,ind_centre(1,1),ind_centre(1,2),0);
        if visual==1
            figure;
            imshow(I_mask,[]);%for visualisation purpose only
            title('Disk Mask Image');
            hold on;%v3:display centre of disk
        else
            disp(['You have turned off graph visualisation '...
                'to show disk mask image.']);
        end
        %6.find centre of disk
        [ind_row_low_d,ind_row_high_d]=fun_ACR_FindBndryFromBand(I_mask,'row');
        [ind_col_low_d,ind_col_high_d]=fun_ACR_FindBndryFromBand(I_mask,'col');
        ind_centre_d=[round((ind_col_high_d-ind_col_low_d)/2+ind_col_low_d) ...
            round((ind_row_high_d-ind_row_low_d)/2+ind_row_low_d)];%centre of disk
        if visual==1%v3:display centre of disk
            plot(ind_centre_d(1,2),ind_centre_d(1,1),'r*');
            hold off;
        end
        %7.create line segment, radiating from disk centre
        I_masked=fun_apply_mask(I,I_mask);%apply disk mask to original image
        radius=round((ind_row_high_d-ind_row_low_d)/2);%radius of disk
        if visual==1%v3:display masked disk image
            figure;
            imshow(I_masked,[]);%for visualisation purpose only
            title('Masked Image');
        else
            disp(['You have turned off graph visualisation '...
                'to show masked disk image.']);
        end
        %++++++++++++++++++++++++++v4 start++++++++++++++++++++++++++
        %8.find radius of 3 spokes
        r_mm_spk1=12.6;%HW:mean of measurement on S11
        r_mm_spk2=25.3;%HW:mean of measurement on S11
        r_mm_spk3=38.1;%HW:mean of measurement on S11
        pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
        r_pxl_spk1=round(r_mm_spk1/pxl_sz(1,1));
        r_pxl_spk2=round(r_mm_spk2/pxl_sz(1,1));
        r_pxl_spk3=round(r_mm_spk3/pxl_sz(1,1));
        %====================v7 start====================
        %9.sample circumference intensity of 3 radius for spokes
        Int_circum_1=fun_ACR_FindCircumIntensity(I_masked,r_pxl_spk1,ind_centre_d,0.001);
        Int_circum_2=fun_ACR_FindCircumIntensity(I_masked,r_pxl_spk2,ind_centre_d,0.001);
        Int_circum_3=fun_ACR_FindCircumIntensity(I_masked,r_pxl_spk3,ind_centre_d,0.001);
        %10.remove repeated intensities from profile
        cnt=1;
        Int_circum_1_f=0;
        for j=1:size(Int_circum_1,2)-1
            if Int_circum_1(1,j+1)~=Int_circum_1(1,j)
                Int_circum_1_f(1,cnt)=Int_circum_1(1,j);
                cnt=cnt+1;
            end
        end
        cnt=1;
        Int_circum_2_f=0;
        for j=1:size(Int_circum_2,2)-1
            if Int_circum_2(1,j+1)~=Int_circum_2(1,j)
                Int_circum_2_f(1,cnt)=Int_circum_2(1,j);
                cnt=cnt+1;
            end
        end
        cnt=1;
        Int_circum_3_f=0;
        for j=1:size(Int_circum_3,2)-1
            if Int_circum_3(1,j+1)~=Int_circum_3(1,j)
                Int_circum_3_f(1,cnt)=Int_circum_3(1,j);
                cnt=cnt+1;
            end
        end
        %====================v7 finish====================
%         %9.sample circumference intensity of 3 radius for spokes
%         Int_circum_1=fun_ACR_FindCircumIntensity(I_masked,r_pxl_spk1,ind_centre_d,0.16);
%         Int_circum_2=fun_ACR_FindCircumIntensity(I_masked,r_pxl_spk2,ind_centre_d,0.1);
%         Int_circum_3=fun_ACR_FindCircumIntensity(I_masked,r_pxl_spk3,ind_centre_d,0.1);
%         %10.calculate radius to the inner edge of 3 spokes with largest radius
%         spoke_dia_mm=7;
%         r_pxl_inner1=r_pxl_spk1-round(spoke_dia_mm/(2*pxl_sz(1,1)));
%         r_pxl_inner2=r_pxl_spk2-round(spoke_dia_mm/(2*pxl_sz(1,1)));
%         r_pxl_inner3=r_pxl_spk3-round(spoke_dia_mm/(2*pxl_sz(1,1)));
%         %11.sample circumference intensity of 3 radius for background
%         Int_circum_bkgd_1=fun_ACR_FindCircumIntensity...
%             (I_masked,r_pxl_inner1,ind_centre_d,0.16);
%         Int_circum_bkgd_2=fun_ACR_FindCircumIntensity...
%             (I_masked,r_pxl_inner2,ind_centre_d,0.1);
%         Int_circum_bkgd_3=fun_ACR_FindCircumIntensity...
%             (I_masked,r_pxl_inner3,ind_centre_d,0.1);
%         Int_circum_bkgd_1_dash=fun_ACR_FindCircumIntensity...
%             (I_masked,r_pxl_inner1-1,ind_centre_d,0.16);%HW:-1 in radius to get norm
%         Int_circum_bkgd_2_dash=fun_ACR_FindCircumIntensity...
%             (I_masked,r_pxl_inner2-1,ind_centre_d,0.1);%HW:-1 in radius to get norm
%         Int_circum_bkgd_3_dash=fun_ACR_FindCircumIntensity...
%             (I_masked,r_pxl_inner3-1,ind_centre_d,0.1);%HW:-1 in radius to get norm
%         %12.find the normalised spoke intensity
%         spk1_norm=Int_circum_1./Int_circum_bkgd_1;
%         spk2_norm=Int_circum_2./Int_circum_bkgd_2;
%         spk3_norm=Int_circum_3./Int_circum_bkgd_3;
%         %13.find the normalised background intensity
%         bkgd1_norm=Int_circum_bkgd_1./Int_circum_bkgd_1_dash;
%         bkgd2_norm=Int_circum_bkgd_2./Int_circum_bkgd_2_dash;
%         bkgd3_norm=Int_circum_bkgd_3./Int_circum_bkgd_3_dash;
%         %14.find the spoke peaks
%         [spk1_pks,spk1_pks_loc]=fun_ACR_FindSpokePeak...
%             ([],1,spk1_norm,0.16,visual);
%         [spk2_pks,spk2_pks_loc]=fun_ACR_FindSpokePeak...
%             ([],2,spk2_norm,0.1,visual);
%         [spk3_pks,spk3_pks_loc]=fun_ACR_FindSpokePeak...
%             ([],3,spk3_norm,0.1,visual);
%         %15.find the min values between 2 peaks
%         [spk1_vly,spk1_vly_loc]=fun_ACR_FindSpokeValley...
%             ([],1,spk1_norm,spk1_pks_loc,visual);
%         [spk2_vly,spk2_vly_loc]=fun_ACR_FindSpokeValley...
%             ([],2,spk2_norm,spk2_pks_loc,visual);
%         [spk3_vly,spk3_vly_loc]=fun_ACR_FindSpokeValley...
%             ([],3,spk3_norm,spk3_pks_loc,visual);
%         %16.use peak and min to find the contrast
%         spk1_vly_diff=spk1_pks-spk1_vly;
%         spk2_vly_diff=spk2_pks-spk2_vly;
%         spk3_vly_diff=spk3_pks-spk3_vly;
%         %17.compare the calculated contrast to given contrast
%         dummy_diff=cat(1,spk1_vly_diff,spk2_vly_diff,spk3_vly_diff);
%         dummy_bkgrd=cat(1,std(bkgd1_norm),std(bkgd2_norm),std(bkgd3_norm));
%         disp('LCOD shows if can identify spoke on r=1,2,3:');
%         for i=1:10
%             LCOD(:,i)=dummy_diff(:,i)>dummy_bkgrd;
%         end
%         %18.count the spokes
%         cnt=0;
%         for i=1:10
%             if sum(LCOD(:,i))==3
%                 cnt=cnt+1;
%             else
%                 break;
%             end
%         end
        %bug:if cannot find spoke peak, function stops (S8&S9)
        %1.try -2 radius for background or half radius for background
        %2.add +/- 1 pxl radius uncertainty to all 3 radius of spoke intensity
        %3.can i use the normalised infor or other info to find the contrast value
        %of the current disk (yes i can and the value is < expected value)
        %++++++++++++++++++++++++++v4 finish++++++++++++++++++++++++++
end
end
% %+++++++following: before v4 (use radial intensity info) start+++++++
% %8.plot intensity profile of radius along 3 spokes
% if slice_num==11%for S11
%     cnt=1;
%     for i=26:36:360%HW:S11 spoke angles (36 degree separation)
%         cnt_dash=1;
%         for j=i-2:i+2%HW:include 2 degree radius intensity too
%             dummy=fun_ACR_FindIntensityonRadius...%up=0 degee
%                 (I_masked,radius,ind_centre_d,pi*2/360*(360-90+j),3,0);
%             dummy_M(cnt_dash,:)=dummy;
%             cnt_dash=cnt_dash+1;
%         end
% %         Int_spoke(cnt,:)=sum(dummy_M,1)/size(dummy_M,1);%ave of all samples
%         Int_spoke(cnt,:)=max(dummy_M,[],1);%v2:max value for intensity
% %+++following: single radius, may be affected by phantom rotation+++
% %         [dummy]=fun_ACR_FindIntensityonRadius...
% %             (I_masked,radius,ind_centre_d,pi*2/360*(360-90+i),3,0);%up=0deg
% %         Int_spoke(cnt,:)=dummy;%spoke intensity profiles
% %+++delete above box++++++++++++++++++++++++++++++++++++++++++++++++
%         if visual==1%visualise sampled radius
%             figure;
%             imshow(I_masked,[]);
%             x0=ind_centre_d(1,2);
%             y0=ind_centre_d(1,1);
%             for j=1:radius
%                 xi=(radius-radius+j)*cos(pi*2/360*(360-90+i))+x0;
%                 yi=(radius-radius+j)*sin(pi*2/360*(360-90+i))+y0;
%                 impoint(gca,xi,yi);
%             end
%         end
%         cnt=cnt+1;
%     end
%     cnt=1;%no need to include 2 degree uncertainty for background
%     for i=26+36/2:36:360+26%HW:S11 background angles (36 degree separation)
%         [dummy]=fun_ACR_FindIntensityonRadius...%up=0 degee
%             (I_masked,radius,ind_centre_d,pi*2/360*(360-90+i),3,0);
%         Int_b(cnt,:)=dummy;%background intensity profiles
%         cnt_dash=1;
%         for j=i:i+1%for each angle find the nearby angle too
%             dummy=fun_ACR_FindIntensityonRadius...%up=0 degee
%                 (I_masked,radius,ind_centre_d,pi*2/360*(360-90+j),3,0);
%             dummy_M(cnt_dash,:)=dummy;
%             cnt_dash=cnt_dash+1;
%         end
%         Int_b_norm(cnt,:)=dummy_M(1,:)./dummy_M(2,:);%get norm bkgrd noise
%         cnt=cnt+1;
%     end
% elseif slice_num==10%for S10
%     cnt=1;
%     for i=15:36:340%HW:S11 spoke angles (36 degree separation)
%         cnt_dash=1;
%         for j=i-2:i+2%HW:include 2 degree radius intensity too
%             dummy=fun_ACR_FindIntensityonRadius...%up=0 degee
%                 (I_masked,radius,ind_centre_d,pi*2/360*(360-90+j),3,0);
%             dummy_M(cnt_dash,:)=dummy;
%             cnt_dash=cnt_dash+1;
%         end
% %         Int_spoke(cnt,:)=sum(dummy_M,1)/size(dummy_M,1);%ave of all samples
%         Int_spoke(cnt,:)=max(dummy_M,[],1);%v2:max value for intensity
%         if visual==1%visualise sampled radius
%             figure;
%             imshow(I_masked,[]);
%             x0=ind_centre_d(1,2);
%             y0=ind_centre_d(1,1);
%             for j=1:radius
%                 xi=(radius-radius+j)*cos(pi*2/360*(360-90+i))+x0;
%                 yi=(radius-radius+j)*sin(pi*2/360*(360-90+i))+y0;
%                 impoint(gca,xi,yi);
%             end
%         end
%         cnt=cnt+1;
%     end
%     cnt=1;%no need to include 2 degree uncertainty for background
%     for i=15+36/2:36:360%HW:S11 background angles (36 degree separation)
%         [dummy]=fun_ACR_FindIntensityonRadius...%up=0 degee
%             (I_masked,radius,ind_centre_d,pi*2/360*(360-90+i),3,0);
%         Int_b(cnt,:)=dummy;%background intensity profiles
%         cnt_dash=1;
%         for j=i:i+1%for each angle find the nearby angle too
%             dummy=fun_ACR_FindIntensityonRadius...%up=0 degee
%                 (I_masked,radius,ind_centre_d,pi*2/360*(360-90+j),3,0);
%             dummy_M(cnt_dash,:)=dummy;
%             cnt_dash=cnt_dash+1;
%         end
%         Int_b_norm(cnt,:)=dummy_M(1,:)./dummy_M(2,:);%get norm bkgrd noise
%         cnt=cnt+1;
%     end
% elseif slice_num==9%for S9
%     cnt=1;
%     for i=9:36:340%HW:S11 spoke angles (36 degree separation)
%         cnt_dash=1;
%         for j=i-3:i+3%HW:include 2 degree radius intensity too
%             dummy=fun_ACR_FindIntensityonRadius...%up=0 degee
%                 (I_masked,radius,ind_centre_d,pi*2/360*(360-90+j),3,0);
%             dummy_M(cnt_dash,:)=dummy;
%             cnt_dash=cnt_dash+1;
%         end
% %         Int_spoke(cnt,:)=sum(dummy_M,1)/size(dummy_M,1);%ave of all samples
%         Int_spoke(cnt,:)=max(dummy_M,[],1);%v2:max value for intensity
%         if visual==1%visualise sampled radius
%             figure;
%             imshow(I_masked,[]);
%             x0=ind_centre_d(1,2);
%             y0=ind_centre_d(1,1);
%             for j=1:radius
%                 xi=(radius-radius+j)*cos(pi*2/360*(360-90+i))+x0;
%                 yi=(radius-radius+j)*sin(pi*2/360*(360-90+i))+y0;
%                 impoint(gca,xi,yi);
%             end
%         end
%         cnt=cnt+1;
%     end
%     cnt=1;%no need to include 2 degree uncertainty for background
%     for i=9+36/2:36:360%HW:S11 background angles (36 degree separation)
%         [dummy]=fun_ACR_FindIntensityonRadius...%up=0 degee
%             (I_masked,radius,ind_centre_d,pi*2/360*(360-90+i),3,0);
%         Int_b(cnt,:)=dummy;%background intensity profiles
%         cnt_dash=1;
%         for j=i:i+1%for each angle find the nearby angle too
%             dummy=fun_ACR_FindIntensityonRadius...%up=0 degee
%                 (I_masked,radius,ind_centre_d,pi*2/360*(360-90+j),3,0);
%             dummy_M(cnt_dash,:)=dummy;
%             cnt_dash=cnt_dash+1;
%         end
%         Int_b_norm(cnt,:)=dummy_M(1,:)./dummy_M(2,:);%get norm bkgrd noise
%         cnt=cnt+1;
%     end
% elseif slice_num==8%for S8
%     cnt=1;
%     for i=0:36:330%HW:S11 spoke angles (36 degree separation)
%         cnt_dash=1;
%         for j=i-3:i+3%HW:include 2 degree radius intensity too
%             dummy=fun_ACR_FindIntensityonRadius...%up=0 degee
%                 (I_masked,radius,ind_centre_d,pi*2/360*(360-90+j),3,0);
%             dummy_M(cnt_dash,:)=dummy;
%             cnt_dash=cnt_dash+1;
%         end
% %         Int_spoke(cnt,:)=sum(dummy_M,1)/size(dummy_M,1);%ave of all samples
%         Int_spoke(cnt,:)=max(dummy_M,[],1);%v2:max value for intensity
%         if visual==1%visualise sampled radius
%             figure;
%             imshow(I_masked,[]);
%             x0=ind_centre_d(1,2);
%             y0=ind_centre_d(1,1);
%             for j=1:radius
%                 xi=(radius-radius+j)*cos(pi*2/360*(360-90+i))+x0;
%                 yi=(radius-radius+j)*sin(pi*2/360*(360-90+i))+y0;
%                 impoint(gca,xi,yi);
%             end
%         end
%         cnt=cnt+1;
%     end
%     cnt=1;%no need to include 2 degree uncertainty for background
%     for i=0+36/2:36:360%HW:S11 background angles (36 degree separation)
%         [dummy]=fun_ACR_FindIntensityonRadius...%up=0 degee
%             (I_masked,radius,ind_centre_d,pi*2/360*(360-90+i),3,0);
%         Int_b(cnt,:)=dummy;%background intensity profiles
%         cnt_dash=1;
%         for j=i:i+1%for each angle find the nearby angle too
%             dummy=fun_ACR_FindIntensityonRadius...%up=0 degee
%                 (I_masked,radius,ind_centre_d,pi*2/360*(360-90+j),3,0);
%             dummy_M(cnt_dash,:)=dummy;
%             cnt_dash=cnt_dash+1;
%         end
%         Int_b_norm(cnt,:)=dummy_M(1,:)./dummy_M(2,:);%get norm bkgrd noise
%         cnt=cnt+1;
%     end
% end
% %9.normalise intensity profile
% for i=1:10
%     Int_norm(i,:)=Int_spoke(i,:)./Int_b(i,:);
% end
% Int_b_norm_std=std(Int_b_norm,0,2);
% if visual==1
%     figure;
%     for i=1:10
%         subplot(2,5,i);
%         plot(Int_spoke(i,:));
%         title(['Intensity of 3 Spokes On Radius ' num2str(i)]);
%     end
% else
%     disp(['You have turned off graph visualisation '...
%         'to show spoke intensity plot.']);
% end
% if visual==1
%     figure;
%     for i=1:10
%         subplot(2,5,i);
%         plot(Int_b(i,:));
%         title(['Intensity of Background Near Radius ' num2str(i)]);
%     end
% else
%     disp(['You have turned off graph visualisation '...
%         'to show background intensity plot.']);
% end
% if visual==1
%     figure;
%     for i=1:10
%         subplot(2,5,i);
%         plot(Int_norm(i,:));
%         hold on;
%         plot(1:size(Int_norm(i,:),2),...%x=1:size of Int_norm,y=1+std
%             1+Int_b_norm_std(i,:)*ones(1,size(Int_norm(i,:),2)),...
%             'r');
%         title(['Normalised Intensity of 3 Spokes On Radius ' num2str(i)]);
%     end
% else
%     disp(['You have turned off graph visualisation '...
%         'to show background intensity plot.']);
% end
% %10.find radius of 3 spokes
% r_mm_spk1=12.6;%HW:mean of measurement on S11
% r_mm_spk2=25.3;%HW:mean of measurement on S11
% r_mm_spk3=38.1;%HW:mean of measurement on S11
% pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
% r_pxl_spk1=round(r_mm_spk1/pxl_sz(1,1));
% r_pxl_spk2=round(r_mm_spk2/pxl_sz(1,1));
% r_pxl_spk3=round(r_mm_spk3/pxl_sz(1,1));
% %11.find the normalised intensity value around 3 spokes
% cnt=1;
% for i=1:10%check spokes on each radius
%     dummy=Int_norm(i,r_pxl_spk1);%1st spoke
%     if Int_norm(i,r_pxl_spk1-1)>dummy
%         dummy=Int_norm(i,r_pxl_spk1-1);
%     elseif Int_norm(i,r_pxl_spk1+1)>dummy
%         dummy=Int_norm(i,r_pxl_spk1+1);
%     end
%     I_spk1(cnt,1)=dummy;
%     dummy=Int_norm(i,r_pxl_spk2);%2nd spoke
%     if Int_norm(i,r_pxl_spk2-1)>dummy
%         dummy=Int_norm(i,r_pxl_spk2-1);
%     elseif Int_norm(i,r_pxl_spk2+1)>dummy
%         dummy=Int_norm(i,r_pxl_spk2+1);
%     end
%     I_spk2(cnt,1)=dummy;
%     dummy=Int_norm(i,r_pxl_spk3);%3rd spoke
%     if Int_norm(i,r_pxl_spk3-1)>dummy
%         dummy=Int_norm(i,r_pxl_spk3-1);
%     elseif Int_norm(i,r_pxl_spk3+1)>dummy
%         dummy=Int_norm(i,r_pxl_spk3+1);
%     end
%     I_spk3(cnt,1)=dummy;
%     cnt=cnt+1;
% end
% I_spk=cat(2,I_spk1,I_spk2,I_spk3);%same radius spoke on same row
% %12.find the normalised intensity value around between spoke
% cnt=1;
% for i=1:10%check spokes on each radius
%     spk1spk2=round((r_pxl_spk2-r_pxl_spk1)/2+r_pxl_spk1);%index btwn spk 1&2
%     dummy=Int_norm(i,spk1spk2);%1st spoke
%     if Int_norm(i,spk1spk2-1)<dummy
%         dummy=Int_norm(i,spk1spk2-1);
%     elseif Int_norm(i,spk1spk2+1)<dummy
%         dummy=Int_norm(i,spk1spk2+1);
%     end
%     I_spk1spk2(cnt,1)=dummy;
%     spk2spk3=round((r_pxl_spk3-r_pxl_spk2)/2+r_pxl_spk2);%index btwn spk 2&3
%     dummy=Int_norm(i,spk2spk3);%2nd spoke
%     if Int_norm(i,spk2spk3-1)<dummy
%         dummy=Int_norm(i,spk2spk3-1);
%     elseif Int_norm(i,spk2spk3+1)<dummy
%         dummy=Int_norm(i,spk2spk3+1);
%     end
%     I_spk2spk3(cnt,1)=dummy;
%     cnt=cnt+1;
% end
% I_spk_b=cat(2,I_spk1spk2,I_spk1spk2,I_spk2spk3);%same radius spoke on same row
% %13.compare 3 spokes on same radius to normalised background noise std
% diff_spk_spk_b=abs(I_spk-I_spk_b);%
% dummy=cat(2,Int_b_norm_std,Int_b_norm_std,Int_b_norm_std);
% LCOD_vector=sum(diff_spk_spk_b>dummy,2)/3;%3=all visible
% % dummy=1+cat(2,Int_b_norm_std,Int_b_norm_std,Int_b_norm_std);
% % LCOD_vector=sum(I_spk>dummy,2)/3;%sum all 3 spokes logic, 3=all visible
% LCOD_logic=zeros(10,1);
% for i=1:10
%     if LCOD_vector(i,1)==1%only =1 when all 3 spoke visible
%         LCOD_logic(i,1)=1;
%     else
%         break;%stop when 1 of 3 spokes is invisible
%     end
% end
% %14.calculate LCOD & state result
% LCOD=sum(LCOD_logic);
% h=msgbox(['The low contrast object detectability on S '...
%     num2str(slice_num) ' is ' num2str(LCOD) '.']);
% uiwait(h);
% %+++++++++++before v4 (use radial intensity info) finish+++++++++++
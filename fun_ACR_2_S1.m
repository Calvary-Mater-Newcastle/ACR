function [HCSR,pf_hdl]=fun_ACR_2_S1...
    (dir_name,file_name,visual,manual,imag_check,myContrast,pill_choice,pill_r)
% This function performs the high contrast spatial resolution test on S1.
% This script assumes the coordinant of the 3 pairs of high contrast hole
% sets has constant distance from the phantom centre for all phantom. For
% different phantom, user can record the distance from the corner to the
% phantom centre at the beginning and use the recorded distance for your
% own site QA.

% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of S5
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose
%   hole_coord: 6-by-2 vector. Column is x,y coord, each two rows are UL
%               corner of UL hole set and UR corner of LR hole set distance
%               from the phantom centre in pixel. It starts from left hole
%               pairs
%   manual: if use manual (1) or auto (0)
%   imag_check: if check the current image is the correct image
%   myContrast: user's personal contrast (obtained from fun_TestContrast.m)
%   pill_choice: with/without attached pill (1=with, 0=without)
%   pill_r: pill radius in mm (num)
% Output:
%   HCSR: distinguishability of each hole pairs, 2-by-1 vector, with
%         1st row for UL pair and 2nd row for LR pair
%   pf_hdl: pass/fail handle
% HW: (search for HW)
%   the width of intensity profile to sample is set to 11 pixels in case of
%       pixel size=0.9766mm. User can change this value if pixel size is
%       different
%   the row number in holes profile matrix is fixed to suit the definition
%       of hole_loc order
%   the randomly select background row intensity profile is 1~5 pixels
%       above the holes
%   the length of background column intensity profile is 5 pixels, in order
%       to fit within insert
%   phantom wall thickness=6 mm
%   
% Naughty Boy: (search for NAUGHTY BOY)
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1
%          v.2 (search for v2)
%          v.3 (21/07/13)
%          v.4 (21/08/13)(search for v4)
%          v.5 (01/03/14)(search for v5)
%          v.6 (08/08/14)(search for v6)
%          v.7 (14/07/15)(search for v7)
%          v.8 (01/04/17)(search for v8)
% History: v.1 (13/05/13,16/05/13,23/05/13)
%          v.2 27/05/13: minimum peak height changed from background noise
%                        to mean intensity of insert. keep the distinguish
%                        judgement as the background noise
%          v.3 add switch for manual or auto option
%          v.4 add option if to allow user to check the current image
%              output pass/fail handle
%          v.5 for automatic QA, use user's personal visual contrast as the
%              threshold to judge if the intensity profile peaks can be
%              distinguished
%          v.6 replace FINDPEAKS with PEAKFINDER, so that the function
%              still runs without Signal Processing Toolbox. NOTE: need to
%              set the max/min difference threshold to 0 in order to be
%              consistent with the FINDPEAKS function.
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
if ~exist('dir_name','var')||isempty(dir_name)
    dir_name='test_images\';%UC:change this line if diff path
end
if ~exist('file_name','var')||isempty(file_name)
    file_name='S1.dcm';%UC:change this line if diff file name
end
if ~exist('visual','var')||isempty(visual)
    visual=0;
end
if ~exist('pill_choice','var')%v7
    pill_choice_trig = questdlg('Did you attached a pill marker to anterior phantom on this slice?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');
    switch pill_choice_trig%Handle response
        case 'Yes'
            pill_choice=1;
        case 'No'
            pill_choice=0;
    end
end
pxl_sz=fun_DICOMInfoAccess([dir_name file_name],'PixelSpacing');
pxl_sz=pxl_sz(2,1);
if ~exist('hole_coord','var')||isempty(hole_coord)
%     hole_coord=[-24 30;-7 37;0 30;16 37;24 31;39 37];%input vec num in pxl
    hole_coord=round([-23.44 29.30;-6.84 36.13;0 29.30;15.63 36.13;...
        23.44 30.27;38.09 36.13]/pxl_sz);%input vec num in mm
end
if ~exist('imag_check','var')||isempty(imag_check)%v5
    imag_check=0;
end
%2.load and display image to let user check if it is S1
I=dicomread([dir_name file_name]);
if imag_check==1%v4
    h=imtool(I,[]);
    choice = questdlg('Is this image the S1 image?', ...
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
%+++++++++++++++++++v3 start++++++++++++++++++++++++++
%xx.manual or auto
switch manual
    case 1
        h=imtool(I,[]);
        imcontrast(h);
        uiwait(h);
        prompt = {'UL: 1.1/1.0/0.9:','LL: 1.1/1.0/0.9:'};
        dlg_title = 'Input';
        num_lines = 1;
        def = {'0.9','0.9'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        HCSR(1,1)=str2num(answer{1,1});
        HCSR(2,1)=str2num(answer{2,1});
    case 0
        %doing following if do auto QA
        %+++++++++++++++++++v3 finish++++++++++++++++++++++++++
        %3.use Otsu's method to threshold image
        HCSR_vec=zeros(2,3);%predefine result vector
        level=graythresh(I);
        I_bin=im2bw(I,level);
        if visual==1
            figure;
            imshow(I_bin,[]);%for visualisation purpose only
            title('Otsu''s Threshold Method Phantom Masked Image');
            hold on;
        else
            disp(['You have turned off graph visualisation '...
                'to show masked phantom image.']);
        end
        %4.find the centre of phantom
        %======================v7 start======================
%         [ind_row_low,ind_row_high]=fun_ACR_FindBndryFromBand(I_bin,'row');%extreme
%         [ind_col_low,ind_col_high]=fun_ACR_FindBndryFromBand(I_bin,'col');%pts
%         ind_centre=[round((ind_col_high-ind_col_low)/2+ind_col_low) ...
%             round((ind_row_high-ind_row_low)/2+ind_row_low)];%centre of phantom
        [cen_pxl,~,~,~,~,~]=...
            fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice,pill_r,6);%HWv8
        ind_centre=round(cen_pxl');%col to row [x y], make consistent with old code
        ind_centre=fliplr(ind_centre);%make consistent with old code
        %======================v7 start======================
        if visual==1
            plot(ind_centre(1,1),ind_centre(1,2),'r*');
            hold off;
        end
        %5.find the pixel location of UL & LR corner of 3 pairs
        hole_loc=zeros(6,2);
        for i=1:6
            hole_loc(i,:)=hole_coord(i,:)+fliplr(ind_centre);
        end
        sample_wdth=round(10.74/pxl_sz);%HW:sample width based on pxlsz=0.9766mm
        sample_wdth_09=round(9.766/pxl_sz);%shorter for 0.9mm one
        %6.plot all rows of UL holes in all 3 pairs into matrix
        hole_prof_row_1=zeros(sample_wdth,sample_wdth);
        hole_prof_row_2=zeros(sample_wdth,sample_wdth);
        hole_prof_row_3=zeros(sample_wdth_09,sample_wdth_09);
        for i=1:sample_wdth%HW:the row number is fixed to suit order in hole_loc
            hole_prof_row_1(i,:)=...
                I(hole_loc(1,2)+i-1,hole_loc(1,1):hole_loc(1,1)+sample_wdth-1);
            hole_prof_row_2(i,:)=...
                I(hole_loc(3,2)+i-1,hole_loc(3,1):hole_loc(3,1)+sample_wdth-1);
%             hole_prof_row_3(i,:)=...
%                 I(hole_loc(5,2)+i-1,hole_loc(5,1):hole_loc(5,1)+sample_wdth-1);
        end
        for i=1:sample_wdth_09
            hole_prof_row_3(i,:)=...
                I(hole_loc(5,2)+i-1,hole_loc(5,1):hole_loc(5,1)+sample_wdth_09-1);
        end
        %7.plot all cols of LR holes in all 3 pairs into matrix
        hole_prof_col_1=zeros(sample_wdth,sample_wdth);
        hole_prof_col_2=zeros(sample_wdth,sample_wdth);
        hole_prof_col_3=zeros(sample_wdth_09,sample_wdth_09);
        for i=1:sample_wdth%HW:the row number is fixed to suit order in hole_loc
            hole_prof_col_1(i,:)=I(hole_loc(2,2):hole_loc(2,2)+sample_wdth-1,...
                hole_loc(2,1)-sample_wdth+i);
            hole_prof_col_2(i,:)=I(hole_loc(4,2):hole_loc(4,2)+sample_wdth-1,...
                hole_loc(4,1)-sample_wdth+i);
%             hole_prof_col_3(i,:)=I(hole_loc(6,2):hole_loc(6,2)+sample_wdth-1,...
%                 hole_loc(6,1)-sample_wdth+i);
        end
        for i=1:sample_wdth_09
            hole_prof_col_3(i,:)=I(hole_loc(6,2):hole_loc(6,2)+sample_wdth_09-1,...
                hole_loc(6,1)-sample_wdth+i);
        end
        %====================v5 start====================
        %8.find peaks & compare to user's contrast
        for i=1:size(hole_prof_row_1,1)
            dummy=hole_prof_row_1(i,:);
%             [pks_r_1 locs_r_1]=findpeaks(dummy);
            [locs_r_1 pks_r_1]=peakfinder(dummy,0);%v6
            if size(pks_r_1,2)~=4
                continue
            elseif size(pks_r_1,2)==4
                vly_r_1=[min(dummy(locs_r_1(1,1)+1:locs_r_1(1,2)-1)) ...
                    min(dummy(locs_r_1(1,2)+1:locs_r_1(1,3)-1)) ...
                    min(dummy(locs_r_1(1,3)+1:locs_r_1(1,4)-1))];
                dummy_vly=[vly_r_1(1,1),vly_r_1(1,1),vly_r_1(1,2),...
                    vly_r_1(1,2),vly_r_1(1,3),vly_r_1(1,3)];
                dummy_pks=[pks_r_1(1,1),pks_r_1(1,2),pks_r_1(1,2),...
                    pks_r_1(1,3),pks_r_1(1,3),pks_r_1(1,4)];
                for l=1:6
                    dummy_diff(1,l)=abs(dummy_vly(1,l)-dummy_pks(1,l))/...
                        (dummy_vly(1,l)+dummy_pks(1,l));
                end
                if sum(dummy_diff<myContrast*ones(1,6))==0
                    HCSR_vec(1,1)=1;
                    if visual==1
                        figure;
                        plot(hole_prof_row_1(i,:));
                        imtool(hole_prof_row_1(i,:),[]);
                    end
                    break
                end
            end
        end
        for i=1:size(hole_prof_row_2,1)
            dummy=hole_prof_row_2(i,:);
%             [pks_r_1 locs_r_1]=findpeaks(dummy);
            [locs_r_1 pks_r_1]=peakfinder(dummy,0);%v6
            if size(pks_r_1,2)~=4
                continue
            elseif size(pks_r_1,2)==4
                vly_r_1=[min(dummy(locs_r_1(1,1)+1:locs_r_1(1,2)-1)) ...
                    min(dummy(locs_r_1(1,2)+1:locs_r_1(1,3)-1)) ...
                    min(dummy(locs_r_1(1,3)+1:locs_r_1(1,4)-1))];
                dummy_vly=[vly_r_1(1,1),vly_r_1(1,1),vly_r_1(1,2),...
                    vly_r_1(1,2),vly_r_1(1,3),vly_r_1(1,3)];
                dummy_pks=[pks_r_1(1,1),pks_r_1(1,2),pks_r_1(1,2),...
                    pks_r_1(1,3),pks_r_1(1,3),pks_r_1(1,4)];
                for l=1:6
                    dummy_diff(1,l)=abs(dummy_vly(1,l)-dummy_pks(1,l))/...
                        (dummy_vly(1,l)+dummy_pks(1,l));
                end
                if sum(dummy_diff<myContrast*ones(1,6))==0
                    HCSR_vec(1,2)=1;
                    if visual==1
                        figure;
                        plot(hole_prof_row_2(i,:));
                        imtool(hole_prof_row_2(i,:),[]);
                    end
                    break
                end
            end
        end
        for i=1:size(hole_prof_row_3,1)
            dummy=hole_prof_row_3(i,:);
%             [pks_r_1 locs_r_1]=findpeaks(dummy);
            [locs_r_1 pks_r_1]=peakfinder(dummy,0);%v6
            if size(pks_r_1,2)~=4
                continue
            elseif size(pks_r_1,2)==4
                vly_r_1=[min(dummy(locs_r_1(1,1)+1:locs_r_1(1,2)-1)) ...
                    min(dummy(locs_r_1(1,2)+1:locs_r_1(1,3)-1)) ...
                    min(dummy(locs_r_1(1,3)+1:locs_r_1(1,4)-1))];
                dummy_vly=[vly_r_1(1,1),vly_r_1(1,1),vly_r_1(1,2),...
                    vly_r_1(1,2),vly_r_1(1,3),vly_r_1(1,3)];
                dummy_pks=[pks_r_1(1,1),pks_r_1(1,2),pks_r_1(1,2),...
                    pks_r_1(1,3),pks_r_1(1,3),pks_r_1(1,4)];
                for l=1:6
                    dummy_diff(1,l)=abs(dummy_vly(1,l)-dummy_pks(1,l))/...
                        (dummy_vly(1,l)+dummy_pks(1,l));
                end
                if sum(dummy_diff<myContrast*ones(1,6))==0
                    HCSR_vec(1,3)=1;
                    if visual==1
                        figure;
                        plot(hole_prof_row_3(i,:));
                        imtool(hole_prof_row_3(i,:),[]);
                    end
                    break
                end
            end
        end
        for i=1:size(hole_prof_col_1,1)
            dummy=hole_prof_col_1(i,:);
%             [pks_r_1 locs_r_1]=findpeaks(dummy);
            [locs_r_1 pks_r_1]=peakfinder(dummy,0);%v6
            if size(pks_r_1,2)~=4
                continue
            elseif size(pks_r_1,2)==4
                vly_r_1=[min(dummy(locs_r_1(1,1)+1:locs_r_1(1,2)-1)) ...
                    min(dummy(locs_r_1(1,2)+1:locs_r_1(1,3)-1)) ...
                    min(dummy(locs_r_1(1,3)+1:locs_r_1(1,4)-1))];
                dummy_vly=[vly_r_1(1,1),vly_r_1(1,1),vly_r_1(1,2),...
                    vly_r_1(1,2),vly_r_1(1,3),vly_r_1(1,3)];
                dummy_pks=[pks_r_1(1,1),pks_r_1(1,2),pks_r_1(1,2),...
                    pks_r_1(1,3),pks_r_1(1,3),pks_r_1(1,4)];
                for l=1:6
                    dummy_diff(1,l)=abs(dummy_vly(1,l)-dummy_pks(1,l))/...
                        (dummy_vly(1,l)+dummy_pks(1,l));
                end
                if sum(dummy_diff<myContrast*ones(1,6))==0
                    HCSR_vec(2,1)=1;
                    if visual==1
                        figure;
                        plot(hole_prof_col_1(i,:));
                        imtool(hole_prof_col_1(i,:),[]);
                    end
                    break
                end
            end
        end
        for i=1:size(hole_prof_col_2,1)
            dummy=hole_prof_col_2(i,:);
%             [pks_r_1 locs_r_1]=findpeaks(dummy);
            [locs_r_1 pks_r_1]=peakfinder(dummy,0);%v6
            if size(pks_r_1,2)~=4
                continue
            elseif size(pks_r_1,2)==4
                vly_r_1=[min(dummy(locs_r_1(1,1)+1:locs_r_1(1,2)-1)) ...
                    min(dummy(locs_r_1(1,2)+1:locs_r_1(1,3)-1)) ...
                    min(dummy(locs_r_1(1,3)+1:locs_r_1(1,4)-1))];
                dummy_vly=[vly_r_1(1,1),vly_r_1(1,1),vly_r_1(1,2),...
                    vly_r_1(1,2),vly_r_1(1,3),vly_r_1(1,3)];
                dummy_pks=[pks_r_1(1,1),pks_r_1(1,2),pks_r_1(1,2),...
                    pks_r_1(1,3),pks_r_1(1,3),pks_r_1(1,4)];
                for l=1:6
                    dummy_diff(1,l)=abs(dummy_vly(1,l)-dummy_pks(1,l))/...
                        (dummy_vly(1,l)+dummy_pks(1,l));
                end
                if sum(dummy_diff<myContrast*ones(1,6))==0
                    HCSR_vec(2,2)=1;
                    if visual==1
                        figure;
                        plot(hole_prof_col_2(i,:));
                        imtool(hole_prof_col_2(i,:),[]);
                    end
                    break
                end
            end
        end
        for i=1:size(hole_prof_col_3,1)
            dummy=hole_prof_col_3(i,:);
%             [pks_r_1 locs_r_1]=findpeaks(dummy);
            [locs_r_1 pks_r_1]=peakfinder(dummy,0);%v6
            if size(pks_r_1,2)~=4
                continue
            elseif size(pks_r_1,2)==4
                vly_r_1=[min(dummy(locs_r_1(1,1)+1:locs_r_1(1,2)-1)) ...
                    min(dummy(locs_r_1(1,2)+1:locs_r_1(1,3)-1)) ...
                    min(dummy(locs_r_1(1,3)+1:locs_r_1(1,4)-1))];
                dummy_vly=[vly_r_1(1,1),vly_r_1(1,1),vly_r_1(1,2),...
                    vly_r_1(1,2),vly_r_1(1,3),vly_r_1(1,3)];
                dummy_pks=[pks_r_1(1,1),pks_r_1(1,2),pks_r_1(1,2),...
                    pks_r_1(1,3),pks_r_1(1,3),pks_r_1(1,4)];
                for l=1:6
                    dummy_diff(1,l)=abs(dummy_vly(1,l)-dummy_pks(1,l))/...
                        (dummy_vly(1,l)+dummy_pks(1,l));
                end
                if sum(dummy_diff<myContrast*ones(1,6))==0
                    HCSR_vec(2,3)=1;
                    if visual==1
                        figure;
                        plot(hole_prof_col_3(i,:));
                        imtool(hole_prof_col_3(i,:),[]);
                    end
                    break
                end
            end
        end
        dummy=sum(HCSR_vec,2);
        if dummy(1,1)==3
            HCSR(1,1)=0.9;
        elseif dummy(1,1)==2
            HCSR(1,1)=1.0;
        elseif dummy(1,1)==1
            HCSR(1,1)=1.1;
        elseif dummy(1,1)==0
            HCSR(1,1)=2;
        end
        if dummy(2,1)==3
            HCSR(2,1)=0.9;
        elseif dummy(2,1)==2
            HCSR(2,1)=1.0;
        elseif dummy(2,1)==1
            HCSR(2,1)=1.1;
        elseif dummy(2,1)==0
            HCSR(2,1)=2;
        end
        %====================v5 finish====================
%         %8.randomly select a row above the holes in all pairs for noise and mean
%         bkgrd_row_1=I(hole_loc(1,2)-randi(5,1),...%HW:1~5 pxl above hole
%             hole_loc(1,1)+1:hole_loc(1,1)+sample_wdth);
%         bkgrd_row_2=I(hole_loc(3,2)-randi(5,1),...%HW:1~5 pxl above hole
%             hole_loc(3,1)+1:hole_loc(3,1)+sample_wdth);
%         bkgrd_row_3=I(hole_loc(5,2)-randi(5,1),...%HW:1~5 pxl above hole
%             hole_loc(5,1)+1:hole_loc(5,1)+sample_wdth);
%         std_bkgrd_row_1=std(double(bkgrd_row_1));
%         std_bkgrd_row_2=std(double(bkgrd_row_2));
%         std_bkgrd_row_3=std(double(bkgrd_row_3));
%         mu_bkgrd_row_1=mean(double(bkgrd_row_1));%v2
%         mu_bkgrd_row_2=mean(double(bkgrd_row_2));%v2
%         mu_bkgrd_row_3=mean(double(bkgrd_row_3));%v2
%         %9.randomly select a col below the holes in all pairs for noise and mean
%         bkgrd_col_1=I(hole_loc(2,2)+sample_wdth:...%HW:l of vert sample=5
%             hole_loc(2,2)+sample_wdth+5,hole_loc(2,1)-randi(10,1));
%         bkgrd_col_2=I(hole_loc(4,2)+sample_wdth:...%HW:l of vert sample=5
%             hole_loc(4,2)+sample_wdth+5,hole_loc(4,1)-randi(10,1));
%         bkgrd_col_3=I(hole_loc(6,2)+sample_wdth:...%HW:l of vert sample=5
%             hole_loc(6,2)+sample_wdth+5,hole_loc(6,1)-randi(10,1));
%         std_bkgrd_col_1=std(double(bkgrd_col_1));
%         std_bkgrd_col_2=std(double(bkgrd_col_2));
%         std_bkgrd_col_3=std(double(bkgrd_col_3));
%         mu_bkgrd_col_1=mean(double(bkgrd_col_1));%v2
%         mu_bkgrd_col_2=mean(double(bkgrd_col_2));%v2
%         mu_bkgrd_col_3=mean(double(bkgrd_col_3));%v2
%         %10.pre-define output
%         HCSR=zeros(2,3);
%         %11.compare horizontal holes intensity profile to noise
%         for i=1:sample_wdth
%             [pks_r_1 locs_r_1]=findpeaks(hole_prof_row_1(i,:),...
%                 'MINPEAKHEIGHT',mu_bkgrd_row_1);
%             if size(locs_r_1,2)>3
%                 disp('Found 4 peaks at UL in 1st pair.');
%                 for j=1:4
%                     if j<4
%                         dummy(1,j)=pks_r_1(1,j)-hole_prof_row_1(i,locs_r_1(1,j)+1);
%                     elseif j==4
%                         dummy(1,j)=pks_r_1(1,j)-hole_prof_row_1(i,locs_r_1(1,j)-1);
%                     end
%                 end
%                 dummy_logic=dummy>std_bkgrd_row_1;
%                 if any(dummy_logic==0)
%                     disp('Cannot distinguish all 4 peaks at UL in 1st pair.');
%                     continue;
%                 else
%                     disp('Can distinguish all 4 peaks at UL in 1st pair.');
%                     disp(['Found on row No. ' num2str(hole_loc(1,2)+i-1)]);
%                     if visual==1
%                         figure;plot(hole_prof_row_1(i,:));title('UL 1st pair');
%                     else
%                         disp('You have turned off visualisation option');
%                     end
%                     HCSR(1,1)=1;
%                     break;
%                 end
%             else
%                 disp('Didn''t find 4 peaks at UL in 1st pair.');
%                 HCSR(1,1)=0;
%             end
%         end
%         for i=1:sample_wdth
%             [pks_r_2 locs_r_2]=findpeaks(hole_prof_row_2(i,:),...
%                 'MINPEAKHEIGHT',mu_bkgrd_row_2);
%             if size(locs_r_2,2)>3
%                 disp('Found 4 peaks at UL in 2nd pair.');
%                 for j=1:4
%                     if j<4
%                         dummy(1,j)=pks_r_2(1,j)-hole_prof_row_2(i,locs_r_2(1,j)+1);
%                     elseif j==4
%                         dummy(1,j)=pks_r_2(1,j)-hole_prof_row_2(i,locs_r_2(1,j)-1);
%                     end
%                 end
%                 dummy_logic=dummy>std_bkgrd_row_2;
%                 if any(dummy_logic==0)
%                     disp('Cannot distinguish all 4 peaks at UL in 2nd pair.');
%                     continue;
%                 else
%                     disp('Can distinguish all 4 peaks at UL in 2nd pair.');
%                     disp(['Found on row No. ' num2str(hole_loc(3,2)+i-1)]);
%                     if visual==1
%                         figure;plot(hole_prof_row_2(i,:));title('UL 2nd pair');
%                     else
%                         disp('You have turned off visualisation option');
%                     end
%                     HCSR(1,2)=1;
%                     break;
%                 end
%             else
%                 disp('Didn''t find 4 peaks at UL in 2nd pair.');
%                 HCSR(1,2)=0;
%             end
%         end
%         for i=1:sample_wdth
%             [pks_r_3 locs_r_3]=findpeaks(hole_prof_row_3(i,:),...
%                 'MINPEAKHEIGHT',mu_bkgrd_row_3);
%             if size(locs_r_3,2)>3
%                 disp('Found 4 peaks at UL in 3rd pair.');
%                 for j=1:4
%                     if j<4
%                         dummy(1,j)=pks_r_3(1,j)-hole_prof_row_3(i,locs_r_3(1,j)+1);
%                     elseif j==4
%                         dummy(1,j)=pks_r_3(1,j)-hole_prof_row_3(i,locs_r_3(1,j)-1);
%                     end
%                 end
%                 dummy_logic=dummy>std_bkgrd_row_3;
%                 if any(dummy_logic==0)
%                     disp('Cannot distinguish all 4 peaks at UL in 3rd pair.');
%                     continue;
%                 else
%                     disp('Can distinguish all 4 peaks at UL in 3rd pair.');
%                     disp(['Found on row No. ' num2str(hole_loc(5,2)+i-1)]);
%                     if visual==1
%                         figure;plot(hole_prof_row_3(i,:));title('UL 3rd pair');
%                     else
%                         disp('You have turned off visualisation option');
%                     end
%                     HCSR(1,3)=1;
%                     break;
%                 end
%             else
%                 disp('Didn''t find 4 peaks at UL in 3rd pair.');
%                 HCSR(1,3)=0;
%             end
%         end
%         %12.compare vertical holes intensity profile to noise
%         for i=1:sample_wdth
%             [pks_c_1 locs_c_1]=findpeaks(hole_prof_col_1(i,:),...
%                 'MINPEAKHEIGHT',mu_bkgrd_col_1);
%             if size(locs_c_1,2)>3
%                 disp('Found 4 peaks at UL in 1st pair.');
%                 for j=1:4
%                     if j<4
%                         dummy(1,j)=pks_c_1(1,j)-hole_prof_col_1(i,locs_c_1(1,j)+1);
%                     elseif j==4
%                         dummy(1,j)=pks_c_1(1,j)-hole_prof_col_1(i,locs_c_1(1,j)-1);
%                     end
%                 end
%                 dummy_logic=dummy>std_bkgrd_col_1;
%                 if any(dummy_logic==0)
%                     disp('Cannot distinguish all 4 peaks at LR in 1st pair.');
%                     continue;
%                 else
%                     disp('Can distinguish all 4 peaks at LR in 1st pair.');
%                     disp(['Found on col No. '...
%                         num2str(hole_loc(2,1)-sample_wdth+i)]);
%                     if visual==1
%                         figure;plot(hole_prof_col_1(i,:));title('LR 1st pair');
%                     else
%                         disp('You have turned off visualisation option');
%                     end
%                     HCSR(2,1)=1;
%                     break;
%                 end
%             else
%                 disp('Didn''t find 4 peaks at LR in 1st pair.');
%                 HCSR(2,1)=0;
%             end
%         end
%         for i=1:sample_wdth
%             [pks_c_2 locs_c_2]=findpeaks(hole_prof_col_2(i,:),...
%                 'MINPEAKHEIGHT',mu_bkgrd_col_2);
%             if size(locs_c_2,2)>3
%                 disp('Found 4 peaks at UL in 2nd pair.');
%                 for j=1:4
%                     if j<4
%                         dummy(1,j)=pks_c_2(1,j)-hole_prof_col_2(i,locs_c_2(1,j)+1);
%                     elseif j==4
%                         dummy(1,j)=pks_c_2(1,j)-hole_prof_col_2(i,locs_c_2(1,j)-1);
%                     end
%                 end
%                 dummy_logic=dummy>std_bkgrd_col_2;
%                 if any(dummy_logic==0)
%                     disp('Cannot distinguish all 4 peaks at LR in 2nd pair.');
%                     continue;
%                 else
%                     disp('Can distinguish all 4 peaks at LR in 2nd pair.');
%                     disp(['Found on col No. '...
%                         num2str(hole_loc(4,1)-sample_wdth+i)]);
%                     if visual==1
%                         figure;plot(hole_prof_col_2(i,:));title('LR 2nd pair');
%                     else
%                         disp('You have turned off visualisation option');
%                     end
%                     HCSR(2,2)=1;
%                     break;
%                 end
%             else
%                 disp('Didn''t find 4 peaks at LR in 2nd pair.');
%                 HCSR(2,2)=0;
%             end
%         end
%         for i=1:sample_wdth
%             [pks_c_3 locs_c_3]=findpeaks(hole_prof_col_3(i,:),...
%                 'MINPEAKHEIGHT',mu_bkgrd_col_3);
%             if size(locs_c_3,2)>3
%                 disp('Found 4 peaks at UL in 3rd pair.');
%                 for j=1:4
%                     if j<4
%                         dummy(1,j)=pks_c_3(1,j)-hole_prof_col_3(i,locs_c_3(1,j)+1);
%                     elseif j==4
%                         dummy(1,j)=pks_c_3(1,j)-hole_prof_col_3(i,locs_c_3(1,j)-1);
%                     end
%                 end
%                 dummy_logic=dummy>std_bkgrd_col_3;
%                 if any(dummy_logic==0)
%                     disp('Cannot distinguish all 4 peaks at LR in 3rd pair.');
%                     continue;
%                 else
%                     disp('Can distinguish all 4 peaks at LR in 3rd pair.');
%                     disp(['Found on col No. '...
%                         num2str(hole_loc(6,1)-sample_wdth+i)]);
%                     if visual==1
%                         figure;plot(hole_prof_col_3(i,:));title('LR 3rd pair');
%                     else
%                         disp('You have turned off visualisation option');
%                     end
%                     HCSR(2,3)=1;
%                     break;
%                 end
%             else
%                 disp('Didn''t find 4 peaks at LR in 3rd pair.');
%                 HCSR(2,3)=0;
%             end
%         end
%can add manual contrast adjust here to allow user interaction
end
%13.pass/fail handle
if HCSR(1,1)<=1%v4
    pf_hdl(1,1)=1;
else
    pf_hdl(1,1)=0;
end
if HCSR(2,1)<=1%v4
    pf_hdl(1,2)=1;
else
    pf_hdl(1,2)=0;
end
end